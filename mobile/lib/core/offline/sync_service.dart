import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/api_endpoints.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import 'local_db.dart';

part 'sync_service.freezed.dart';
part 'sync_service.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// Represents the current state of the background sync service.
@freezed
class SyncState with _$SyncState {
  const factory SyncState({
    @Default(false) bool isSyncing,
    @Default(0) int pendingCount,
    @Default(0) int conflictsCount,
    String? lastError,
  }) = _SyncState;
}

// ---------------------------------------------------------------------------
// SyncService notifier
// ---------------------------------------------------------------------------

/// Drains the offline SQLite queue to the server whenever connectivity is
/// restored.
///
/// Usage:
/// ```dart
/// final sync = ref.watch(syncServiceProvider.notifier);
/// sync.triggerSync();
/// ```
@Riverpod(keepAlive: true)
class SyncService extends _$SyncService {
  StreamSubscription<bool>? _connectivitySub;

  @override
  SyncState build() {
    _init();
    ref.onDispose(() {
      _connectivitySub?.cancel();
    });
    return const SyncState();
  }

  // -------------------------------------------------------------------------
  // Initialisation
  // -------------------------------------------------------------------------

  Future<void> _init() async {
    final networkInfo = ref.read(networkInfoProvider);
    _connectivitySub = networkInfo.onConnectivityChanged.listen((connected) {
      if (connected) {
        triggerSync();
      }
    });
    // Attempt initial sync if already connected.
    final connected = await networkInfo.isConnected;
    if (connected) await triggerSync();
    await _refreshCounts();
  }

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Manually trigger a sync cycle.
  Future<void> triggerSync() async {
    if (state.isSyncing) return;

    final dbAsync = await ref.read(localDbProvider.future);
    final pending = await dbAsync.getPendingItems();

    if (pending.isEmpty) {
      await _refreshCounts();
      return;
    }

    state = state.copyWith(isSyncing: true, lastError: null);

    final dio = ref.read(dioClientProvider);

    try {
      final entries = pending
          .map(
            (item) => {
              'id': item.id,
              'entity_type': item.entityType,
              'operation': item.operation,
              'payload': item.payload,
              'idempotency_key': item.idempotencyKey,
            },
          )
          .toList();

      final response = await dio.post<dynamic>(
        ApiEndpoints.syncBatch,
        data: {'operations': entries},
      );

      final responseData = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final results = responseData['results'] as List<dynamic>;

      for (final result in results) {
        final r = result as Map<String, dynamic>;
        final idempotencyKey = r['idempotency_key'] as String;
        final status = r['status'] as String;

        final itemIndex = pending.indexWhere((p) => p.idempotencyKey == idempotencyKey);
        if (itemIndex == -1) continue;
        final item = pending[itemIndex];

        if (status == 'success' || status == 'already_processed') {
          await dbAsync.markSynced(item.id);
        } else if (status == 'conflict') {
          await dbAsync.markSynced(item.id); // Remove from pending sync queue
          await dbAsync.insertConflict(
            entityType: item.entityType,
            entityId: r['conflict_id'] as String? ?? '',
            localPayload: item.payload,
            conflictReason: r['reason'] as String? ?? 'Unknown conflict',
          );
        } else {
          await dbAsync.markFailed(item.id);
        }
      }
    } on DioException catch (e) {
      debugPrint('[SyncService] DioException: $e');
      for (final item in pending) {
        await dbAsync.markFailed(item.id);
      }
      state = state.copyWith(
        isSyncing: false,
        lastError: e.message,
      );
      await _refreshCounts();
      return;
    } catch (e) {
      debugPrint('[SyncService] Error: $e');
      state = state.copyWith(
        isSyncing: false,
        lastError: e.toString(),
      );
      await _refreshCounts();
      return;
    }

    state = state.copyWith(isSyncing: false);
    await _refreshCounts();
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  Future<void> _refreshCounts() async {
    final db = await ref.read(localDbProvider.future);
    final pending = await db.pendingCount();
    final conflicts = (await db.getConflicts()).length;
    state = state.copyWith(
      pendingCount: pending,
      conflictsCount: conflicts,
    );
  }
}
