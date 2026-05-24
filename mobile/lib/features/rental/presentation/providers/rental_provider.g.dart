// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rental_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shopUnitsListHash() => r'7483f3849d5c779d1df92020c93841825b831206';

/// See also [ShopUnitsList].
@ProviderFor(ShopUnitsList)
final shopUnitsListProvider =
    AutoDisposeAsyncNotifierProvider<ShopUnitsList, List<ShopUnit>>.internal(
  ShopUnitsList.new,
  name: r'shopUnitsListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shopUnitsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShopUnitsList = AutoDisposeAsyncNotifier<List<ShopUnit>>;
String _$tenantsListHash() => r'f29fb3bfb22fe4e47351e9a3a9f8d634f2f3175b';

/// See also [TenantsList].
@ProviderFor(TenantsList)
final tenantsListProvider =
    AutoDisposeAsyncNotifierProvider<TenantsList, List<RentalTenant>>.internal(
  TenantsList.new,
  name: r'tenantsListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tenantsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TenantsList = AutoDisposeAsyncNotifier<List<RentalTenant>>;
String _$tenantLedgerNotifierHash() =>
    r'10e2495514bfa34e976f792cfb4cfcb268385781';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$TenantLedgerNotifier
    extends BuildlessAutoDisposeAsyncNotifier<Map<String, dynamic>> {
  late final String id;

  FutureOr<Map<String, dynamic>> build(
    String id,
  );
}

/// See also [TenantLedgerNotifier].
@ProviderFor(TenantLedgerNotifier)
const tenantLedgerNotifierProvider = TenantLedgerNotifierFamily();

/// See also [TenantLedgerNotifier].
class TenantLedgerNotifierFamily
    extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [TenantLedgerNotifier].
  const TenantLedgerNotifierFamily();

  /// See also [TenantLedgerNotifier].
  TenantLedgerNotifierProvider call(
    String id,
  ) {
    return TenantLedgerNotifierProvider(
      id,
    );
  }

  @override
  TenantLedgerNotifierProvider getProviderOverride(
    covariant TenantLedgerNotifierProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tenantLedgerNotifierProvider';
}

/// See also [TenantLedgerNotifier].
class TenantLedgerNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    TenantLedgerNotifier, Map<String, dynamic>> {
  /// See also [TenantLedgerNotifier].
  TenantLedgerNotifierProvider(
    String id,
  ) : this._internal(
          () => TenantLedgerNotifier()..id = id,
          from: tenantLedgerNotifierProvider,
          name: r'tenantLedgerNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tenantLedgerNotifierHash,
          dependencies: TenantLedgerNotifierFamily._dependencies,
          allTransitiveDependencies:
              TenantLedgerNotifierFamily._allTransitiveDependencies,
          id: id,
        );

  TenantLedgerNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  FutureOr<Map<String, dynamic>> runNotifierBuild(
    covariant TenantLedgerNotifier notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(TenantLedgerNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TenantLedgerNotifierProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<TenantLedgerNotifier,
      Map<String, dynamic>> createElement() {
    return _TenantLedgerNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TenantLedgerNotifierProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TenantLedgerNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<Map<String, dynamic>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _TenantLedgerNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TenantLedgerNotifier,
        Map<String, dynamic>> with TenantLedgerNotifierRef {
  _TenantLedgerNotifierProviderElement(super.provider);

  @override
  String get id => (origin as TenantLedgerNotifierProvider).id;
}

String _$rentPaymentRecorderHash() =>
    r'13c00f33147a371aea274845469d335682af3843';

/// See also [RentPaymentRecorder].
@ProviderFor(RentPaymentRecorder)
final rentPaymentRecorderProvider =
    AutoDisposeAsyncNotifierProvider<RentPaymentRecorder, void>.internal(
  RentPaymentRecorder.new,
  name: r'rentPaymentRecorderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rentPaymentRecorderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RentPaymentRecorder = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
