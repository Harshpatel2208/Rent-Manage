import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/currency_formatter.dart';

// ---------------------------------------------------------------------------
// Data models for the report
// ---------------------------------------------------------------------------

/// Aggregated data required to generate a monthly PDF report.
class ReportData {
  const ReportData({
    required this.month,
    required this.year,
    required this.tenantName,
    required this.loanRows,
    required this.rentRows,
    required this.expenseRows,
    required this.totalInterestCollected,
    required this.totalRentCollected,
    required this.totalExpenses,
  });

  final int month;
  final int year;
  final String tenantName;
  final List<LoanReportRow> loanRows;
  final List<RentReportRow> rentRows;
  final List<ExpenseReportRow> expenseRows;
  final Decimal totalInterestCollected;
  final Decimal totalRentCollected;
  final Decimal totalExpenses;

  Decimal get netIncome =>
      totalInterestCollected + totalRentCollected - totalExpenses;
}

class LoanReportRow {
  const LoanReportRow({
    required this.borrowerName,
    required this.principal,
    required this.interestRate,
    required this.interestCollected,
    required this.status,
  });

  final String borrowerName;
  final Decimal principal;
  final Decimal interestRate;
  final Decimal interestCollected;
  final String status;
}

class RentReportRow {
  const RentReportRow({
    required this.tenantName,
    required this.unitName,
    required this.amountDue,
    required this.amountPaid,
    required this.status,
  });

  final String tenantName;
  final String unitName;
  final Decimal amountDue;
  final Decimal amountPaid;
  final String status;
}

class ExpenseReportRow {
  const ExpenseReportRow({
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });

  final String category;
  final String description;
  final Decimal amount;
  final DateTime date;
}

// ---------------------------------------------------------------------------
// PDF export
// ---------------------------------------------------------------------------

/// Generates a professional monthly report PDF.
///
/// Returns the raw [Uint8List] bytes which can be saved or shared.
Future<Uint8List> generateMonthlyReport(ReportData data) async {
  final pdf = pw.Document();
  final monthYear = DateFormat('MMMM yyyy')
      .format(DateTime(data.year, data.month));

  // ---- Colours (approximated for PDF) ----
  const primaryColor = PdfColor.fromInt(0xFF4F46E5);
  const textLight = PdfColors.white;
  const textMuted = PdfColor.fromInt(0xFF94A3B8);

  // -------------------------------------------------------------------------
  // Page
  // -------------------------------------------------------------------------
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (context) => _buildHeader(monthYear, data.tenantName, primaryColor, textLight),
      footer: (context) => _buildFooter(context, textMuted),
      build: (context) => [
        pw.SizedBox(height: 16),
        _sectionTitle('Loan Summary', primaryColor),
        pw.SizedBox(height: 8),
        _loanTable(data.loanRows),
        pw.SizedBox(height: 20),
        _sectionTitle('Rent Summary', primaryColor),
        pw.SizedBox(height: 8),
        _rentTable(data.rentRows),
        pw.SizedBox(height: 20),
        _sectionTitle('Expense Breakdown', primaryColor),
        pw.SizedBox(height: 8),
        _expenseTable(data.expenseRows),
        pw.SizedBox(height: 20),
        _sectionTitle('Profit & Loss', primaryColor),
        pw.SizedBox(height: 8),
        _plSection(data, primaryColor),
      ],
    ),
  );

  return pdf.save();
}

// ---------------------------------------------------------------------------
// Builders
// ---------------------------------------------------------------------------

pw.Widget _buildHeader(
  String monthYear,
  String tenantName,
  PdfColor primary,
  PdfColor textLight,
) =>
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: pw.BoxDecoration(
        color: primary,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '₹ MoneyManager',
                style: pw.TextStyle(
                  color: textLight,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Monthly Report — $monthYear',
                style: pw.TextStyle(color: textLight, fontSize: 12),
              ),
            ],
          ),
          pw.Text(
            tenantName,
            style: pw.TextStyle(color: textLight, fontSize: 12),
          ),
        ],
      ),
    );

pw.Widget _buildFooter(pw.Context context, PdfColor textMuted) =>
    pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: pw.TextStyle(color: textMuted, fontSize: 10),
      ),
    );

pw.Widget _sectionTitle(String title, PdfColor color) => pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: color,
      ),
    );

pw.Widget _loanTable(List<LoanReportRow> rows) {
  if (rows.isEmpty) {
    return pw.Text('No loan records for this period.',
        style: const pw.TextStyle(fontSize: 10));
  }
  return pw.TableHelper.fromTextArray(
    headers: ['Borrower', 'Principal', 'Rate %', 'Interest Collected', 'Status'],
    data: rows
        .map(
          (r) => [
            r.borrowerName,
            CurrencyFormatter.formatINR(r.principal),
            '${r.interestRate}%',
            CurrencyFormatter.formatINR(r.interestCollected),
            r.status,
          ],
        )
        .toList(),
    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
    cellStyle: const pw.TextStyle(fontSize: 9),
    border: pw.TableBorder.all(color: PdfColors.grey300),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
  );
}

pw.Widget _rentTable(List<RentReportRow> rows) {
  if (rows.isEmpty) {
    return pw.Text('No rent records for this period.',
        style: const pw.TextStyle(fontSize: 10));
  }
  return pw.TableHelper.fromTextArray(
    headers: ['Tenant', 'Unit', 'Due', 'Paid', 'Status'],
    data: rows
        .map(
          (r) => [
            r.tenantName,
            r.unitName,
            CurrencyFormatter.formatINR(r.amountDue),
            CurrencyFormatter.formatINR(r.amountPaid),
            r.status,
          ],
        )
        .toList(),
    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
    cellStyle: const pw.TextStyle(fontSize: 9),
    border: pw.TableBorder.all(color: PdfColors.grey300),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
  );
}

pw.Widget _expenseTable(List<ExpenseReportRow> rows) {
  if (rows.isEmpty) {
    return pw.Text('No expense records for this period.',
        style: const pw.TextStyle(fontSize: 10));
  }
  return pw.TableHelper.fromTextArray(
    headers: ['Date', 'Category', 'Description', 'Amount'],
    data: rows
        .map(
          (r) => [
            DateFormat('dd MMM').format(r.date),
            r.category,
            r.description,
            CurrencyFormatter.formatINR(r.amount),
          ],
        )
        .toList(),
    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
    cellStyle: const pw.TextStyle(fontSize: 9),
    border: pw.TableBorder.all(color: PdfColors.grey300),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
  );
}

pw.Widget _plSection(ReportData data, PdfColor primaryColor) {
  final rows = [
    ['Interest Income', CurrencyFormatter.formatINR(data.totalInterestCollected)],
    ['Rent Income', CurrencyFormatter.formatINR(data.totalRentCollected)],
    ['Total Expenses', '- ${CurrencyFormatter.formatINR(data.totalExpenses)}'],
    ['Net Income', CurrencyFormatter.formatINR(data.netIncome)],
  ];

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: rows.asMap().entries.map((entry) {
      final isLast = entry.key == rows.length - 1;
      final row = entry.value;
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: pw.BoxDecoration(
          color: isLast ? primaryColor : PdfColors.grey100,
          border: const pw.Border(
            bottom: pw.BorderSide(color: PdfColors.grey300),
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              row[0],
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: isLast ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: isLast ? PdfColors.white : PdfColors.black,
              ),
            ),
            pw.Text(
              row[1],
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: isLast ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: isLast ? PdfColors.white : PdfColors.black,
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}
