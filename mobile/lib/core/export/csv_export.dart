import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import '../../features/expenses/domain/entities/expense.dart';
import '../../features/lending/domain/entities/loan.dart';
import '../../features/rental/domain/entities/rent_payment.dart';
import '../utils/currency_formatter.dart';

/// Utility class for generating CSV exports.
class CsvExport {
  CsvExport._();

  // ---------------------------------------------------------------------------
  // Generic
  // ---------------------------------------------------------------------------

  /// Converts a list of row maps to a CSV string using [headers] as columns.
  static String generateCsv(
    List<Map<String, dynamic>> data,
    List<String> headers,
  ) {
    final rows = <List<dynamic>>[headers];
    for (final row in data) {
      rows.add(headers.map((h) => row[h] ?? '').toList());
    }
    return const ListToCsvConverter().convert(rows);
  }

  // ---------------------------------------------------------------------------
  // Domain-specific exports
  // ---------------------------------------------------------------------------

  /// Exports a list of [Loan] entities to a CSV string.
  static String exportLoans(List<Loan> loans) {
    final headers = [
      'Borrower Name',
      'Principal (₹)',
      'Interest Rate (%)',
      'Status',
      'Registered At',
      'Outstanding Balance (₹)',
    ];

    final rows = <List<dynamic>>[headers];
    for (final loan in loans) {
      rows.add([
        loan.borrowerName,
        CurrencyFormatter.formatINR(loan.principal),
        loan.interestRate.toString(),
        loan.status,
        DateFormat('dd/MM/yyyy').format(loan.registeredAt),
        loan.status == 'active' ? CurrencyFormatter.formatINR(loan.principal) : '₹0.00',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Exports a list of [Expense] entities to a CSV string.
  static String exportExpenses(List<Expense> expenses) {
    final headers = [
      'Date',
      'Category',
      'Amount (₹)',
      'Description',
    ];

    final rows = <List<dynamic>>[headers];
    for (final expense in expenses) {
      rows.add([
        DateFormat('dd/MM/yyyy').format(expense.expenseDate),
        expense.category,
        CurrencyFormatter.formatINR(expense.amount),
        expense.description,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Exports a list of [RentPayment] records to a CSV string.
  static String exportRentLedger(List<RentPayment> payments) {
    final headers = [
      'Cycle Month',
      'Amount Due (₹)',
      'Amount Paid (₹)',
      'Remaining Balance (₹)',
      'Status',
    ];

    final rows = <List<dynamic>>[headers];
    for (final payment in payments) {
      rows.add([
        DateFormat('MMM yyyy').format(payment.cycleMonth),
        CurrencyFormatter.formatINR(payment.amountDue),
        CurrencyFormatter.formatINR(payment.amountPaid),
        CurrencyFormatter.formatINR(payment.remainingBalance),
        payment.status.toUpperCase(),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}
