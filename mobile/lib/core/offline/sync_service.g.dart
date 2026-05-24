// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncServiceHash() => r'4d33dcae9fc6168ea11c2ad7743cb03c99f6cefa';

/// Drains the offline SQLite queue to the server whenever connectivity is
/// restored.
///
/// Usage:
/// ```dart
/// final sync = ref.watch(syncServiceProvider.notifier);
/// sync.triggerSync();
/// ```
///
/// Copied from [SyncService].
@ProviderFor(SyncService)
final syncServiceProvider = NotifierProvider<SyncService, SyncState>.internal(
  SyncService.new,
  name: r'syncServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SyncService = Notifier<SyncState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
