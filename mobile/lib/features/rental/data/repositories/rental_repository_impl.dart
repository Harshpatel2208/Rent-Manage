import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/network_info.dart';
import '../../../../core/offline/local_db.dart';
import '../../domain/entities/rent_payment.dart';
import '../../domain/entities/rental_tenant.dart';
import '../../domain/entities/shop_unit.dart';
import '../../domain/repositories/rental_repository.dart';
import '../datasources/rental_remote_datasource.dart';

part 'rental_repository_impl.g.dart';

class RentalRepositoryImpl implements RentalRepository {
  RentalRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final RentalRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<List<ShopUnit>> getUnits() async {
    return remoteDataSource.getUnits();
  }

  @override
  Future<ShopUnit> createUnit({
    required String unitName,
    String? address,
    String? description,
  }) async {
    // Only support online creation for shop units as backend sync doesn't support them.
    return remoteDataSource.createUnit(
      unitName: unitName,
      address: address,
      description: description,
    );
  }

  @override
  Future<List<RentalTenant>> getTenants({bool? isActive, String? unitId}) async {
    return remoteDataSource.getTenants(isActive: isActive, unitId: unitId);
  }

  @override
  Future<RentalTenant> createTenant({
    required String fullName,
    String? phone,
    required double rentAmount,
    required DateTime leaseStart,
    DateTime? leaseEnd,
    String? notes,
    String? unitId,
  }) async {
    const uuid = Uuid();
    final tempId = uuid.v4();

    if (await networkInfo.isConnected) {
      try {
        return await remoteDataSource.createTenant(
          fullName: fullName,
          phone: phone,
          rentAmount: rentAmount,
          leaseStart: leaseStart,
          leaseEnd: leaseEnd,
          notes: notes,
          unitId: unitId,
        );
      } catch (_) {
        // Fallback to offline queue
      }
    }

    // Offline / Failed: Queue operation
    final db = LocalDb.instance;
    await db.insertToQueue(
      entityType: 'rental_tenant',
      operation: 'create',
      payload: {
        'id': tempId,
        'full_name': fullName,
        'phone': phone,
        'rent_amount': rentAmount,
        'lease_start': leaseStart.toIso8601String().substring(0, 10),
        'lease_end': leaseEnd?.toIso8601String().substring(0, 10),
        'notes': notes,
        'unit_id': unitId,
      },
    );

    return RentalTenant(
      id: tempId,
      unitId: unitId,
      fullName: fullName,
      phone: phone,
      rentAmount: Decimal.parse(rentAmount.toString()),
      leaseStart: leaseStart,
      leaseEnd: leaseEnd,
      isActive: true,
      notes: notes,
      currentMonthStatus: 'pending',
      currentMonthPaid: Decimal.zero,
      currentMonthDue: Decimal.parse(rentAmount.toString()),
      currentMonthBalance: Decimal.parse(rentAmount.toString()),
      totalOutstanding: Decimal.parse(rentAmount.toString()),
    );
  }

  @override
  Future<Map<String, dynamic>> getTenantLedger(String id) async {
    final detail = await remoteDataSource.getTenantLedger(id);
    final tenantJson = detail['tenant'] as Map<String, dynamic>;
    final paymentsJson = detail['payments'] as List<dynamic>;
    final totalOutstandingStr = detail['total_outstanding'] as String;

    return {
      'tenant': RentalTenant.fromJson(tenantJson),
      'payments': paymentsJson.map((json) => RentPayment.fromJson(json as Map<String, dynamic>)).toList(),
      'total_outstanding': Decimal.parse(totalOutstandingStr),
    };
  }

  @override
  Future<void> recordRentPayment({
    required String rentalTenantId,
    required DateTime cycleMonth,
    required double amountPaid,
    String? notes,
  }) async {
    const uuid = Uuid();
    final idempotencyKey = uuid.v4();

    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.recordRentPayment(
          rentalTenantId: rentalTenantId,
          cycleMonth: cycleMonth,
          amountPaid: amountPaid,
          idempotencyKey: idempotencyKey,
          notes: notes,
        );
        return;
      } catch (_) {
        // Fallback to offline queue
      }
    }

    // Offline / Failed: Queue operation
    final db = LocalDb.instance;
    await db.insertToQueue(
      entityType: 'rent_payment',
      operation: 'create',
      payload: {
        'rental_tenant_id': rentalTenantId,
        'cycle_month': cycleMonth.toIso8601String().substring(0, 10),
        'amount_paid': amountPaid,
        'idempotency_key': idempotencyKey,
        'notes': notes,
      },
      idempotencyKey: idempotencyKey,
    );
  }
}

@Riverpod(keepAlive: true)
RentalRepository rentalRepository(Ref ref) {
  return RentalRepositoryImpl(
    remoteDataSource: ref.watch(rentalRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
}
