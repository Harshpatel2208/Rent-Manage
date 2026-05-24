import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

part 'local_db.g.dart';

// ---------------------------------------------------------------------------
// SQLite schema version
// ---------------------------------------------------------------------------
const int _kDbVersion = 1;
const String _kDbName = 'money_manager.db';

// ---------------------------------------------------------------------------
// Table & column names
// ---------------------------------------------------------------------------
const String _tSyncQueue = 'sync_queue';
const String _tConflicts = 'local_conflicts';

// ---------------------------------------------------------------------------
// DTO types
// ---------------------------------------------------------------------------

/// Represents a row in the [_tSyncQueue] table.
class SyncQueueItem {
  const SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.operation,
    required this.payload,
    required this.idempotencyKey,
    required this.status,
    required this.retryCount,
    required this.createdAt,
  });

  factory SyncQueueItem.fromMap(Map<String, Object?> map) => SyncQueueItem(
        id: map['id'] as String,
        entityType: map['entity_type'] as String,
        operation: map['operation'] as String,
        payload: jsonDecode(map['payload'] as String) as Map<String, dynamic>,
        idempotencyKey: map['idempotency_key'] as String,
        status: map['status'] as String,
        retryCount: map['retry_count'] as int,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      );

  final String id;
  final String entityType;
  final String operation;
  final Map<String, dynamic> payload;
  final String idempotencyKey;
  final String status;
  final int retryCount;
  final DateTime createdAt;
}

/// Represents a row in the [_tConflicts] table.
class LocalConflict {
  const LocalConflict({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.localPayload,
    required this.conflictReason,
    required this.status,
    required this.createdAt,
  });

  factory LocalConflict.fromMap(Map<String, Object?> map) => LocalConflict(
        id: map['id'] as String,
        entityType: map['entity_type'] as String? ?? '',
        entityId: map['entity_id'] as String? ?? '',
        localPayload:
            jsonDecode(map['local_payload'] as String) as Map<String, dynamic>,
        conflictReason: map['conflict_reason'] as String? ?? '',
        status: map['status'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      );

  final String id;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> localPayload;
  final String conflictReason;
  final String status;
  final DateTime createdAt;
}

// ---------------------------------------------------------------------------
// LocalDb — singleton wrapper
// ---------------------------------------------------------------------------

/// Manages the SQLite database for offline-first operation.
///
/// All writes to the remote API are queued here first. A background
/// [SyncService] drains the queue when connectivity is restored.
class LocalDb {
  LocalDb._();

  static final LocalDb instance = LocalDb._();

  Database? _db;

  // -------------------------------------------------------------------------
  // Initialisation
  // -------------------------------------------------------------------------

  /// Opens (or creates) the database, running migrations as needed.
  Future<void> init() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, _kDbName);

    _db = await openDatabase(
      fullPath,
      version: _kDbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Database get _database {
    assert(_db != null, 'LocalDb.init() must be called before use');
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tSyncQueue (
        id                TEXT PRIMARY KEY,
        entity_type       TEXT NOT NULL,
        operation         TEXT NOT NULL,
        payload           TEXT NOT NULL,
        idempotency_key   TEXT UNIQUE NOT NULL,
        status            TEXT DEFAULT 'pending',
        retry_count       INTEGER DEFAULT 0,
        created_at        INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tConflicts (
        id                TEXT PRIMARY KEY,
        entity_type       TEXT,
        entity_id         TEXT,
        local_payload     TEXT,
        conflict_reason   TEXT,
        status            TEXT DEFAULT 'pending',
        created_at        INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here.
  }

  // -------------------------------------------------------------------------
  // Sync queue operations
  // -------------------------------------------------------------------------

  /// Inserts a new mutation into the sync queue.
  ///
  /// Uses [idempotencyKey] to prevent duplicate entries.
  Future<void> insertToQueue({
    required String entityType,
    required String operation,
    required Map<String, dynamic> payload,
    String? idempotencyKey,
  }) async {
    const uuid = Uuid();
    final id = uuid.v4();
    final key = idempotencyKey ?? uuid.v4();

    await _database.insert(
      _tSyncQueue,
      {
        'id': id,
        'entity_type': entityType,
        'operation': operation,
        'payload': jsonEncode(payload),
        'idempotency_key': key,
        'status': 'pending',
        'retry_count': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Returns all items in the queue with status = 'pending'.
  Future<List<SyncQueueItem>> getPendingItems() async {
    final rows = await _database.query(
      _tSyncQueue,
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );
    return rows.map(SyncQueueItem.fromMap).toList();
  }

  /// Marks a queue item as successfully synced.
  Future<void> markSynced(String id) async {
    await _database.update(
      _tSyncQueue,
      {'status': 'synced'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Increments the retry count and optionally marks as failed.
  Future<void> markFailed(String id) async {
    await _database.rawUpdate('''
      UPDATE $_tSyncQueue
      SET retry_count = retry_count + 1,
          status = CASE WHEN retry_count + 1 >= 5 THEN 'failed' ELSE 'pending' END
      WHERE id = ?
    ''', [id]);
  }

  /// Returns count of pending items.
  Future<int> pendingCount() async {
    final result = await _database.rawQuery(
      "SELECT COUNT(*) as cnt FROM $_tSyncQueue WHERE status = 'pending'",
    );
    return result.first['cnt'] as int;
  }

  // -------------------------------------------------------------------------
  // Conflict operations
  // -------------------------------------------------------------------------

  /// Saves a conflict received from the server (HTTP 409).
  Future<void> insertConflict({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> localPayload,
    required String conflictReason,
  }) async {
    const uuid = Uuid();
    await _database.insert(
      _tConflicts,
      {
        'id': uuid.v4(),
        'entity_type': entityType,
        'entity_id': entityId,
        'local_payload': jsonEncode(localPayload),
        'conflict_reason': conflictReason,
        'status': 'pending',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Returns all unresolved conflicts.
  Future<List<LocalConflict>> getConflicts() async {
    final rows = await _database.query(
      _tConflicts,
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at DESC',
    );
    return rows.map(LocalConflict.fromMap).toList();
  }

  /// Dismisses a conflict by marking it resolved.
  Future<void> dismissConflict(String id) async {
    await _database.update(
      _tConflicts,
      {'status': 'resolved'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Closes the database connection (for testing).
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Provides the [LocalDb] singleton after ensuring it has been initialised.
@Riverpod(keepAlive: true)
Future<LocalDb> localDb(Ref ref) async {
  await LocalDb.instance.init();
  return LocalDb.instance;
}
