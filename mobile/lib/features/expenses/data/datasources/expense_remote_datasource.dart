import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/expense.dart';

part 'expense_remote_datasource.g.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<Expense>> getExpenses({
    String? category,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? limit,
    int? offset,
  });

  Future<Expense> createExpense({
    required double amount,
    required String category,
    required DateTime expenseDate,
    required String idempotencyKey,
    String? description,
  });
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  const ExpenseRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Expense>> getExpenses({
    String? category,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (category != null) queryParams['category'] = category;
    if (dateFrom != null) {
      queryParams['date_from'] = dateFrom.toIso8601String().substring(0, 10);
    }
    if (dateTo != null) {
      queryParams['date_to'] = dateTo.toIso8601String().substring(0, 10);
    }
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    final response = await _dio.get(ApiEndpoints.expenses, queryParameters: queryParams);
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.map((json) => Expense.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Expense> createExpense({
    required double amount,
    required String category,
    required DateTime expenseDate,
    required String idempotencyKey,
    String? description,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.expenses,
      data: {
        'amount': amount,
        'category': category,
        'expense_date': expenseDate.toIso8601String().substring(0, 10),
        'description': description,
        'idempotency_key': idempotencyKey,
      },
    );
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    return Expense.fromJson(data['expense'] as Map<String, dynamic>);
  }
}

@Riverpod(keepAlive: true)
ExpenseRemoteDataSource expenseRemoteDataSource(Ref ref) =>
    ExpenseRemoteDataSourceImpl(ref.watch(dioClientProvider));
