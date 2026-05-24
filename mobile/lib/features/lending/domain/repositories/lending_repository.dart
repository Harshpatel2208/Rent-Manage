import '../entities/borrower.dart';
import '../entities/loan.dart';
import '../entities/loan_payment.dart';
import '../entities/interest_schedule.dart';

abstract class LendingRepository {
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

  Future<Loan> getLoanById(String id);
  Future<List<InterestSchedule>> getLoanSchedule(String loanId);
  Future<List<LoanPayment>> getLoanPayments(String loanId);

  Future<void> recordPayment({
    required String loanId,
    required double amount,
    required DateTime paymentDate,
    required String type, // 'interest' | 'principal'
    String? cycleMonth, // YYYY-MM-01, required when type='interest'
    String? notes,
  });
}
