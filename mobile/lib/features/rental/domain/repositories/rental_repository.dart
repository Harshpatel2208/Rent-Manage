import '../entities/shop_unit.dart';
import '../entities/rental_tenant.dart';

abstract class RentalRepository {
  Future<List<ShopUnit>> getUnits();
  Future<ShopUnit> createUnit({
    required String unitName,
    String? address,
    String? description,
  });

  Future<List<RentalTenant>> getTenants({bool? isActive, String? unitId});
  Future<RentalTenant> createTenant({
    required String fullName,
    String? phone,
    required double rentAmount,
    required DateTime leaseStart,
    DateTime? leaseEnd,
    String? notes,
    String? unitId,
  });

  Future<Map<String, dynamic>> getTenantLedger(String id);

  Future<void> recordRentPayment({
    required String rentalTenantId,
    required DateTime cycleMonth,
    required double amountPaid,
    String? notes,
  });
}
