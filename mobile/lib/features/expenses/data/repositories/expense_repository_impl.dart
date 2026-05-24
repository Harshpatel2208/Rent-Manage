import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/network_info.dart';
import '../../../../core/offline/local_db.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_datasource.dart';

part 'expense_repository_impl.g.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final ExpenseRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<List<Expense>> getExpenses({
    String? category,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? limit,
    int? offset,
  }) async {
    return remoteDataSource.getExpenses(
      category: category,
      dateFrom: dateFrom,
      dateTo: dateTo,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<Expense> createExpense({
    required double amount,
    required String category,
    required DateTime expenseDate,
    String? description,
  }) async {
    const uuid = Uuid();
    final tempId = uuid.v4();
    final idempotencyKey = uuid.v4();

    if (await networkInfo.isConnected) {
      try {
        return await remoteDataSource.createExpense(
          amount: amount,
          category: category,
          expenseDate: expenseDate,
          idempotencyKey: idempotencyKey,
          description: description,
        );
      } catch (_) {
        // Fallback to offline queue
      }
    }

    // Offline / Failed: Queue operation
    final db = LocalDb.instance;
    await db.insertToQueue(
      entityType: 'expense',
      operation: 'create',
      payload: {
        'id': tempId,
        'amount': amount,
        'category': category,
        'expense_date': expenseDate.toIso8601String().substring(0, 10),
        'description': description,
        'idempotency_key': idempotencyKey,
      },
      idempotencyKey: idempotencyKey,
    );

    return Expense(
      id: tempId,
      amount: Decimal.parse(amount.toString()),
      category: category,
      expenseDate: expenseDate,
      description: description,
      idempotencyKey: idempotencyKey,
      createdAt: DateTime.now(),
    );
  }
}

@Riverpod(keepAlive: true)
ExpenseRepository expenseRepository(Ref ref) {
  return ExpenseRepositoryImpl(
    remoteDataSource: ref.watch(expenseRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
}
