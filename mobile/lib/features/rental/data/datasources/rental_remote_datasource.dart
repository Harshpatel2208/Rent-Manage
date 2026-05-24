import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/rental_tenant.dart';
import '../../domain/entities/shop_unit.dart';

part 'rental_remote_datasource.g.dart';

abstract class RentalRemoteDataSource {
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
    required String idempotencyKey,
    String? notes,
  });
}

class RentalRemoteDataSourceImpl implements RentalRemoteDataSource {
  const RentalRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ShopUnit>> getUnits() async {
    final response = await _dio.get(ApiEndpoints.rentalUnits);
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.map((json) => ShopUnit.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<ShopUnit> createUnit({
    required String unitName,
    String? address,
    String? description,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.rentalUnits,
      data: {
        'unit_name': unitName,
        'address': address,
        'description': description,
      },
    );
    final body = response.data as Map<String, dynamic>;
    return ShopUnit.fromJson(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<RentalTenant>> getTenants({bool? isActive, String? unitId}) async {
    final queryParams = <String, dynamic>{};
    if (isActive != null) {
      queryParams['is_active'] = isActive ? 'true' : 'false';
    }
    if (unitId != null) {
      queryParams['unit_id'] = unitId;
    }

    final response = await _dio.get(ApiEndpoints.rentalTenants, queryParameters: queryParams);
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.map((json) => RentalTenant.fromJson(json as Map<String, dynamic>)).toList();
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
    final response = await _dio.post(
      ApiEndpoints.rentalTenants,
      data: {
        'full_name': fullName,
        'phone': phone,
        'rent_amount': rentAmount,
        'lease_start': leaseStart.toIso8601String().substring(0, 10),
        'lease_end': leaseEnd?.toIso8601String().substring(0, 10),
        'notes': notes,
        'unit_id': unitId,
      },
    );
    final body = response.data as Map<String, dynamic>;
    return RentalTenant.fromJson(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getTenantLedger(String id) async {
    final response = await _dio.get(ApiEndpoints.tenantLedger(id));
    final body = response.data as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  @override
  Future<void> recordRentPayment({
    required String rentalTenantId,
    required DateTime cycleMonth,
    required double amountPaid,
    required String idempotencyKey,
    String? notes,
  }) async {
    await _dio.post(
      ApiEndpoints.rentalPayments,
      data: {
        'rental_tenant_id': rentalTenantId,
        'cycle_month': cycleMonth.toIso8601String().substring(0, 10),
        'amount_paid': amountPaid,
        'idempotency_key': idempotencyKey,
        'notes': notes,
      },
    );
  }
}

@Riverpod(keepAlive: true)
RentalRemoteDataSource rentalRemoteDataSource(Ref ref) =>
    RentalRemoteDataSourceImpl(ref.watch(dioClientProvider));
