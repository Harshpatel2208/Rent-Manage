import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/shop_unit.dart';
import '../../domain/entities/rental_tenant.dart';
import '../../data/repositories/rental_repository_impl.dart';

part 'rental_provider.g.dart';

@riverpod
class ShopUnitsList extends _$ShopUnitsList {
  @override
  FutureOr<List<ShopUnit>> build() async {
    final repository = ref.watch(rentalRepositoryProvider);
    return repository.getUnits();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(rentalRepositoryProvider);
      return repository.getUnits();
    });
  }

  Future<ShopUnit> addUnit({
    required String unitName,
    String? address,
    String? description,
  }) async {
    final repository = ref.read(rentalRepositoryProvider);
    final result = await repository.createUnit(
      unitName: unitName,
      address: address,
      description: description,
    );
    ref.invalidateSelf();
    return result;
  }
}

@riverpod
class TenantsList extends _$TenantsList {
  bool? _isActive;
  String? _unitId;

  @override
  FutureOr<List<RentalTenant>> build() async {
    final repository = ref.watch(rentalRepositoryProvider);
    return repository.getTenants(isActive: _isActive, unitId: _unitId);
  }

  Future<void> filterTenants({bool? isActive, String? unitId}) async {
    _isActive = isActive;
    _unitId = unitId;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(rentalRepositoryProvider);
      return repository.getTenants(isActive: _isActive, unitId: _unitId);
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(rentalRepositoryProvider);
      return repository.getTenants(isActive: _isActive, unitId: _unitId);
    });
  }

  Future<RentalTenant> addTenant({
    required String fullName,
    String? phone,
    required double rentAmount,
    required DateTime leaseStart,
    DateTime? leaseEnd,
    String? notes,
    String? unitId,
  }) async {
    final repository = ref.read(rentalRepositoryProvider);
    final result = await repository.createTenant(
      fullName: fullName,
      phone: phone,
      rentAmount: rentAmount,
      leaseStart: leaseStart,
      leaseEnd: leaseEnd,
      notes: notes,
      unitId: unitId,
    );
    ref.invalidateSelf();
    return result;
  }
}

@riverpod
class TenantLedgerNotifier extends _$TenantLedgerNotifier {
  @override
  FutureOr<Map<String, dynamic>> build(String id) async {
    final repository = ref.watch(rentalRepositoryProvider);
    return repository.getTenantLedger(id);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(rentalRepositoryProvider);
      return repository.getTenantLedger(id);
    });
  }
}

@riverpod
class RentPaymentRecorder extends _$RentPaymentRecorder {
  @override
  FutureOr<void> build() {}

  Future<void> recordRentPayment({
    required String rentalTenantId,
    required DateTime cycleMonth,
    required double amountPaid,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(rentalRepositoryProvider);
      await repository.recordRentPayment(
        rentalTenantId: rentalTenantId,
        cycleMonth: cycleMonth,
        amountPaid: amountPaid,
        notes: notes,
      );
      ref.invalidate(tenantsListProvider);
      ref.invalidate(tenantLedgerNotifierProvider(rentalTenantId));
    });
  }
}
