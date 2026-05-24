import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/offline/local_db.dart';
import '../../domain/entities/borrower.dart';
import '../../domain/entities/interest_schedule.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/loan_payment.dart';
import '../../domain/repositories/lending_repository.dart';
import '../datasources/lending_remote_datasource.dart';

part 'lending_repository_impl.g.dart';

class LendingRepositoryImpl implements LendingRepository {
  LendingRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final LendingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<List<Borrower>> getBorrowers() async {
    // Try online, if fails or offline we return empty/cached list if we had caching,
    // but since we only cache the sync queue, we try remote directly.
    return remoteDataSource.getBorrowers();
  }

  @override
  Future<Borrower> createBorrower({
    required String fullName,
    required String phone,
    required String address,
    String? notes,
  }) async {
    const uuid = Uuid();
    final tempId = uuid.v4();

    if (await networkInfo.isConnected) {
      try {
        return await remoteDataSource.createBorrower(
          fullName: fullName,
          phone: phone,
          address: address,
          notes: notes,
        );
      } catch (_) {
        // Fallback to queue if remote fails
      }
    }

    // Offline / Failed: Queue operation
    final db = LocalDb.instance;
    await db.insertToQueue(
      entityType: 'borrower',
      operation: 'create',
      payload: {
        'id': tempId,
        'full_name': fullName,
        'phone': phone,
        'address': address,
        'notes': notes,
      },
    );

    return Borrower(
      id: tempId,
      fullName: fullName,
      phone: phone,
      address: address,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<Loan>> getLoans() async {
    return remoteDataSource.getLoans();
  }

  @override
  Future<Loan> createLoan({
    required String borrowerId,
    required double principal,
    required double interestRate,
    required DateTime registeredAt,
  }) async {
    const uuid = Uuid();
    final tempId = uuid.v4();

    if (await networkInfo.isConnected) {
      try {
        return await remoteDataSource.createLoan(
          borrowerId: borrowerId,
          principal: principal,
          interestRate: interestRate,
          registeredAt: registeredAt,
        );
      } catch (_) {
        // Fallback to queue
      }
    }

    // Offline / Failed: Queue operation
    final db = LocalDb.instance;
    await db.insertToQueue(
      entityType: 'loan',
      operation: 'create',
      payload: {
        'id': tempId,
        'borrower_id': borrowerId,
        'principal': principal,
        'interest_rate': interestRate,
        'registered_at': registeredAt.toIso8601String(),
      },
    );

    return Loan(
      id: tempId,
      borrowerId: borrowerId,
      borrowerName: 'Pending Sync',
      principal: Decimal.parse(principal.toString()),
      interestRate: Decimal.parse(interestRate.toString()),
      status: 'active',
      registeredAt: registeredAt,
      firstCycleDate: DateTime(registeredAt.year, registeredAt.month + 1, 1),
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Loan> getLoanById(String id) async {
    final detail = await remoteDataSource.getLoanDetail(id);
    return Loan.fromJson(detail['loan'] as Map<String, dynamic>);
  }

  @override
  Future<List<InterestSchedule>> getLoanSchedule(String loanId) async {
    return remoteDataSource.getLoanSchedule(loanId);
  }

  @override
  Future<List<LoanPayment>> getLoanPayments(String loanId) async {
    final detail = await remoteDataSource.getLoanDetail(loanId);
    final list = detail['payments'] as List<dynamic>;
    return list.map((json) => LoanPayment.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> recordPayment({
    required String loanId,
    required double amount,
    required DateTime paymentDate,
    required String type,
    String? cycleMonth,
    String? notes,
  }) async {
    const uuid = Uuid();
    final idempotencyKey = uuid.v4();

    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.recordPayment(
          loanId: loanId,
          amount: amount,
          paymentDate: paymentDate,
          type: type,
          idempotencyKey: idempotencyKey,
          cycleMonth: cycleMonth,
          notes: notes,
        );
        return;
      } catch (_) {
        // Fallback to queue
      }
    }

    // Offline / Failed: Queue operation
    final db = LocalDb.instance;
    await db.insertToQueue(
      entityType: 'loan_payment',
      operation: 'create',
      payload: {
        'loan_id': loanId,
        'amount': amount,
        'payment_date': paymentDate.toIso8601String().substring(0, 10),
        'type': type,
        'idempotency_key': idempotencyKey,
        if (cycleMonth != null) 'cycle_month': cycleMonth,
        if (notes != null) 'notes': notes,
      },
      idempotencyKey: idempotencyKey,
    );
  }
}

@Riverpod(keepAlive: true)
LendingRepository lendingRepository(Ref ref) {
  return LendingRepositoryImpl(
    remoteDataSource: ref.watch(lendingRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
}
