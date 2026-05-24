// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lending_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loanScheduleHash() => r'bc172f4af1dda19442787dc8db93df0cb80bb426';

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

/// See also [loanSchedule].
@ProviderFor(loanSchedule)
const loanScheduleProvider = LoanScheduleFamily();

/// See also [loanSchedule].
class LoanScheduleFamily extends Family<AsyncValue<List<InterestSchedule>>> {
  /// See also [loanSchedule].
  const LoanScheduleFamily();

  /// See also [loanSchedule].
  LoanScheduleProvider call(
    String loanId,
  ) {
    return LoanScheduleProvider(
      loanId,
    );
  }

  @override
  LoanScheduleProvider getProviderOverride(
    covariant LoanScheduleProvider provider,
  ) {
    return call(
      provider.loanId,
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
  String? get name => r'loanScheduleProvider';
}

/// See also [loanSchedule].
class LoanScheduleProvider
    extends AutoDisposeFutureProvider<List<InterestSchedule>> {
  /// See also [loanSchedule].
  LoanScheduleProvider(
    String loanId,
  ) : this._internal(
          (ref) => loanSchedule(
            ref as LoanScheduleRef,
            loanId,
          ),
          from: loanScheduleProvider,
          name: r'loanScheduleProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$loanScheduleHash,
          dependencies: LoanScheduleFamily._dependencies,
          allTransitiveDependencies:
              LoanScheduleFamily._allTransitiveDependencies,
          loanId: loanId,
        );

  LoanScheduleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.loanId,
  }) : super.internal();

  final String loanId;

  @override
  Override overrideWith(
    FutureOr<List<InterestSchedule>> Function(LoanScheduleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LoanScheduleProvider._internal(
        (ref) => create(ref as LoanScheduleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        loanId: loanId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<InterestSchedule>> createElement() {
    return _LoanScheduleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LoanScheduleProvider && other.loanId == loanId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, loanId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LoanScheduleRef on AutoDisposeFutureProviderRef<List<InterestSchedule>> {
  /// The parameter `loanId` of this provider.
  String get loanId;
}

class _LoanScheduleProviderElement
    extends AutoDisposeFutureProviderElement<List<InterestSchedule>>
    with LoanScheduleRef {
  _LoanScheduleProviderElement(super.provider);

  @override
  String get loanId => (origin as LoanScheduleProvider).loanId;
}

String _$loanPaymentsHash() => r'69e211833a8cf616c7c586afe2980332c2cea239';

/// See also [loanPayments].
@ProviderFor(loanPayments)
const loanPaymentsProvider = LoanPaymentsFamily();

/// See also [loanPayments].
class LoanPaymentsFamily extends Family<AsyncValue<List<LoanPayment>>> {
  /// See also [loanPayments].
  const LoanPaymentsFamily();

  /// See also [loanPayments].
  LoanPaymentsProvider call(
    String loanId,
  ) {
    return LoanPaymentsProvider(
      loanId,
    );
  }

  @override
  LoanPaymentsProvider getProviderOverride(
    covariant LoanPaymentsProvider provider,
  ) {
    return call(
      provider.loanId,
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
  String? get name => r'loanPaymentsProvider';
}

/// See also [loanPayments].
class LoanPaymentsProvider
    extends AutoDisposeFutureProvider<List<LoanPayment>> {
  /// See also [loanPayments].
  LoanPaymentsProvider(
    String loanId,
  ) : this._internal(
          (ref) => loanPayments(
            ref as LoanPaymentsRef,
            loanId,
          ),
          from: loanPaymentsProvider,
          name: r'loanPaymentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$loanPaymentsHash,
          dependencies: LoanPaymentsFamily._dependencies,
          allTransitiveDependencies:
              LoanPaymentsFamily._allTransitiveDependencies,
          loanId: loanId,
        );

  LoanPaymentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.loanId,
  }) : super.internal();

  final String loanId;

  @override
  Override overrideWith(
    FutureOr<List<LoanPayment>> Function(LoanPaymentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LoanPaymentsProvider._internal(
        (ref) => create(ref as LoanPaymentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        loanId: loanId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<LoanPayment>> createElement() {
    return _LoanPaymentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LoanPaymentsProvider && other.loanId == loanId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, loanId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LoanPaymentsRef on AutoDisposeFutureProviderRef<List<LoanPayment>> {
  /// The parameter `loanId` of this provider.
  String get loanId;
}

class _LoanPaymentsProviderElement
    extends AutoDisposeFutureProviderElement<List<LoanPayment>>
    with LoanPaymentsRef {
  _LoanPaymentsProviderElement(super.provider);

  @override
  String get loanId => (origin as LoanPaymentsProvider).loanId;
}

String _$borrowersListHash() => r'a0b411073cf6a32487829e92ff3cd888fbf7480c';

/// See also [BorrowersList].
@ProviderFor(BorrowersList)
final borrowersListProvider =
    AutoDisposeAsyncNotifierProvider<BorrowersList, List<Borrower>>.internal(
  BorrowersList.new,
  name: r'borrowersListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$borrowersListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BorrowersList = AutoDisposeAsyncNotifier<List<Borrower>>;
String _$loansListHash() => r'4dbfc451bcd2606097b7dd8ecb1283e2c4b85500';

/// See also [LoansList].
@ProviderFor(LoansList)
final loansListProvider =
    AutoDisposeAsyncNotifierProvider<LoansList, List<Loan>>.internal(
  LoansList.new,
  name: r'loansListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$loansListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LoansList = AutoDisposeAsyncNotifier<List<Loan>>;
String _$loanDetailNotifierHash() =>
    r'7821c42d1a37cf86f4033ac222aead025281753d';

abstract class _$LoanDetailNotifier
    extends BuildlessAutoDisposeAsyncNotifier<Loan> {
  late final String id;

  FutureOr<Loan> build(
    String id,
  );
}

/// See also [LoanDetailNotifier].
@ProviderFor(LoanDetailNotifier)
const loanDetailNotifierProvider = LoanDetailNotifierFamily();

/// See also [LoanDetailNotifier].
class LoanDetailNotifierFamily extends Family<AsyncValue<Loan>> {
  /// See also [LoanDetailNotifier].
  const LoanDetailNotifierFamily();

  /// See also [LoanDetailNotifier].
  LoanDetailNotifierProvider call(
    String id,
  ) {
    return LoanDetailNotifierProvider(
      id,
    );
  }

  @override
  LoanDetailNotifierProvider getProviderOverride(
    covariant LoanDetailNotifierProvider provider,
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
  String? get name => r'loanDetailNotifierProvider';
}

/// See also [LoanDetailNotifier].
class LoanDetailNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<LoanDetailNotifier, Loan> {
  /// See also [LoanDetailNotifier].
  LoanDetailNotifierProvider(
    String id,
  ) : this._internal(
          () => LoanDetailNotifier()..id = id,
          from: loanDetailNotifierProvider,
          name: r'loanDetailNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$loanDetailNotifierHash,
          dependencies: LoanDetailNotifierFamily._dependencies,
          allTransitiveDependencies:
              LoanDetailNotifierFamily._allTransitiveDependencies,
          id: id,
        );

  LoanDetailNotifierProvider._internal(
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
  FutureOr<Loan> runNotifierBuild(
    covariant LoanDetailNotifier notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(LoanDetailNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: LoanDetailNotifierProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<LoanDetailNotifier, Loan>
      createElement() {
    return _LoanDetailNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LoanDetailNotifierProvider && other.id == id;
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
mixin LoanDetailNotifierRef on AutoDisposeAsyncNotifierProviderRef<Loan> {
  /// The parameter `id` of this provider.
  String get id;
}

class _LoanDetailNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<LoanDetailNotifier, Loan>
    with LoanDetailNotifierRef {
  _LoanDetailNotifierProviderElement(super.provider);

  @override
  String get id => (origin as LoanDetailNotifierProvider).id;
}

String _$paymentRecorderHash() => r'65ab98297d620b84aee267e7d10ba5167ab58f2b';

/// See also [PaymentRecorder].
@ProviderFor(PaymentRecorder)
final paymentRecorderProvider =
    AutoDisposeAsyncNotifierProvider<PaymentRecorder, void>.internal(
  PaymentRecorder.new,
  name: r'paymentRecorderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paymentRecorderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PaymentRecorder = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
