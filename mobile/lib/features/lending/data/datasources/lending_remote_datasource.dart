import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/borrower.dart';
import '../../domain/entities/interest_schedule.dart';
import '../../domain/entities/loan.dart';

part 'lending_remote_datasource.g.dart';

abstract class LendingRemoteDataSource {
  Future<List<Borrower>> getBorrowers();
  Future<Borrower> createBorrower({
    required String fullName,
    required String phone,
    required String address,
    String? notes,
  });

  Future<List<Loan>> getLoans();
  Future<Loan> createLoan({
    required String borrowerId,
    required double principal,
    required double interestRate,
    required DateTime registeredAt,
  });

  Future<Map<String, dynamic>> getLoanDetail(String id);
  Future<List<InterestSchedule>> getLoanSchedule(String loanId);
  Future<void> recordPayment({
    required String loanId,
    required double amount,
    required DateTime paymentDate,
    required String type,
    required String idempotencyKey,
    String? cycleMonth, // YYYY-MM-01, required when type='interest'
    String? notes,
  });
}

class LendingRemoteDataSourceImpl implements LendingRemoteDataSource {
  const LendingRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Borrower>> getBorrowers() async {
    final response = await _dio.get(ApiEndpoints.loanBorrowers);
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.map((json) => Borrower.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Borrower> createBorrower({
    required String fullName,
    required String phone,
    required String address,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.loanBorrowers,
      data: {
        'full_name': fullName,
        'phone': phone,
        'address': address,
        'notes': notes,
      },
    );
    final body = response.data as Map<String, dynamic>;
    return Borrower.fromJson(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<Loan>> getLoans() async {
    final response = await _dio.get(ApiEndpoints.loans);
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.map((json) => Loan.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Loan> createLoan({
    required String borrowerId,
    required double principal,
    required double interestRate,
    required DateTime registeredAt,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.loanCreate,
      data: {
        'borrower_id': borrowerId,
        'principal': principal,
        'interest_rate': interestRate,
        'registered_at': registeredAt.toIso8601String(),
      },
    );
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    return Loan.fromJson(data['loan'] as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getLoanDetail(String id) async {
    final response = await _dio.get(ApiEndpoints.loanDetail(id));
    final body = response.data as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  @override
  Future<List<InterestSchedule>> getLoanSchedule(String loanId) async {
    final response = await _dio.get(ApiEndpoints.loanSchedule(loanId));
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    final scheduleList = data['schedule'] as List<dynamic>;
    return scheduleList.map((json) => InterestSchedule.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> recordPayment({
    required String loanId,
    required double amount,
    required DateTime paymentDate,
    required String type,
    required String idempotencyKey,
    String? cycleMonth,
    String? notes,
  }) async {
    await _dio.post(
      ApiEndpoints.loanPayments(loanId),
      data: {
        'amount': amount,
        'payment_date': paymentDate.toIso8601String().substring(0, 10), // yyyy-MM-dd
        'type': type,
        'idempotency_key': idempotencyKey,
        if (cycleMonth != null) 'cycle_month': cycleMonth,
        if (notes != null) 'notes': notes,
      },
    );
  }
}

@Riverpod(keepAlive: true)
LendingRemoteDataSource lendingRemoteDataSource(Ref ref) =>
    LendingRemoteDataSourceImpl(ref.watch(dioClientProvider));
