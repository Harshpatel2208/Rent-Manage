import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/borrower.dart';
import '../../domain/entities/interest_schedule.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/loan_payment.dart';
import '../../data/repositories/lending_repository_impl.dart';

part 'lending_provider.g.dart';

@riverpod
class BorrowersList extends _$BorrowersList {
  @override
  FutureOr<List<Borrower>> build() async {
    final repository = ref.watch(lendingRepositoryProvider);
    return repository.getBorrowers();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.watch(lendingRepositoryProvider);
      return repository.getBorrowers();
    });
  }

  Future<Borrower> addBorrower({
    required String fullName,
    required String phone,
    required String address,
    String? notes,
  }) async {
    final repository = ref.read(lendingRepositoryProvider);
    final result = await repository.createBorrower(
      fullName: fullName,
      phone: phone,
      address: address,
      notes: notes,
    );
    ref.invalidateSelf();
    return result;
  }
}

@riverpod
class LoansList extends _$LoansList {
  @override
  FutureOr<List<Loan>> build() async {
    final repository = ref.watch(lendingRepositoryProvider);
    return repository.getLoans();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.watch(lendingRepositoryProvider);
      return repository.getLoans();
    });
  }

  Future<Loan> addLoan({
    required String borrowerId,
    required double principal,
    required double interestRate,
    required DateTime registeredAt,
  }) async {
    final repository = ref.read(lendingRepositoryProvider);
    final result = await repository.createLoan(
      borrowerId: borrowerId,
      principal: principal,
      interestRate: interestRate,
      registeredAt: registeredAt,
    );
    ref.invalidateSelf();
    return result;
  }
}

@riverpod
class LoanDetailNotifier extends _$LoanDetailNotifier {
  @override
  FutureOr<Loan> build(String id) async {
    final repository = ref.watch(lendingRepositoryProvider);
    return repository.getLoanById(id);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.watch(lendingRepositoryProvider);
      return repository.getLoanById(id);
    });
  }
}

@riverpod
FutureOr<List<InterestSchedule>> loanSchedule(Ref ref, String loanId) {
  final repository = ref.watch(lendingRepositoryProvider);
  return repository.getLoanSchedule(loanId);
}

@riverpod
FutureOr<List<LoanPayment>> loanPayments(Ref ref, String loanId) {
  final repository = ref.watch(lendingRepositoryProvider);
  return repository.getLoanPayments(loanId);
}

@riverpod
class PaymentRecorder extends _$PaymentRecorder {
  @override
  FutureOr<void> build() {}

  Future<void> recordPayment({
    required String loanId,
    required double amount,
    required DateTime paymentDate,
    required String type,
    String? cycleMonth,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(lendingRepositoryProvider);
      await repository.recordPayment(
        loanId: loanId,
        amount: amount,
        paymentDate: paymentDate,
        type: type,
        cycleMonth: cycleMonth,
        notes: notes,
      );
      // Invalidate relevant providers to force reload
      ref.invalidate(loansListProvider);
      ref.invalidate(loanDetailNotifierProvider(loanId));
      ref.invalidate(loanScheduleProvider(loanId));
      ref.invalidate(loanPaymentsProvider(loanId));
    });
  }
}
