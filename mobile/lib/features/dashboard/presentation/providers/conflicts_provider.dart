import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/offline/local_db.dart';
import '../../../../core/offline/sync_service.dart';

part 'conflicts_provider.g.dart';

@riverpod
class ConflictsNotifier extends _$ConflictsNotifier {
  @override
  FutureOr<List<LocalConflict>> build() async {
    final db = await ref.watch(localDbProvider.future);
    return db.getConflicts();
  }

  Future<void> dismissConflict(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = await ref.read(localDbProvider.future);
      final conflicts = await db.getConflicts();
      final conflict = conflicts.firstWhere((c) => c.id == id);

      if (conflict.entityId.isNotEmpty) {
        final dio = ref.read(dioClientProvider);
        await dio.patch<dynamic>(
          '${ApiEndpoints.syncConflicts}/${conflict.entityId}',
          data: {'status': 'dismissed'},
        );
      }

      await db.dismissConflict(id);
      
      // Invalidate the sync service so it refreshes its pending/conflicts counts
      ref.invalidate(syncServiceProvider);
      
      return db.getConflicts();
    });
  }

  Future<void> resolveConflictWithRetry(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = await ref.read(localDbProvider.future);
      final conflicts = await db.getConflicts();
      final conflict = conflicts.firstWhere((c) => c.id == id);

      if (conflict.entityId.isNotEmpty) {
        final dio = ref.read(dioClientProvider);
        await dio.patch<dynamic>(
          '${ApiEndpoints.syncConflicts}/${conflict.entityId}',
          data: {'status': 'resolved'},
        );
      }

      // Re-queue the operation with a fresh idempotency key
      await db.insertToQueue(
        entityType: conflict.entityType,
        operation: 'create',
        payload: conflict.localPayload,
      );

      // Remove the conflict locally
      await db.dismissConflict(id);
      
      // Invalidate the sync service so it refreshes its pending/conflicts counts
      ref.invalidate(syncServiceProvider);
      
      // Trigger background sync to attempt processing the newly queued item
      ref.read(syncServiceProvider.notifier).triggerSync();

      return db.getConflicts();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = await ref.read(localDbProvider.future);
      return db.getConflicts();
    });
  }
}
