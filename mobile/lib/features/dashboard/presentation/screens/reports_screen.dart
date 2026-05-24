import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/export/pdf_export.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/reports_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Share Export Methods
  // ---------------------------------------------------------------------------

  Future<void> _exportPdf(DateTime date, Map<String, dynamic> data) async {
    setState(() => _isExporting = true);
    try {
      final dio = ref.read(dioClientProvider);
      
      // Try backend download first, fallback to local generation
      try {
        final response = await dio.get<List<int>>(
          ApiEndpoints.reportsPdf,
          queryParameters: {
            'year': date.year,
            'month': date.month,
          },
          options: Options(responseType: ResponseType.bytes),
        );
        
        if (response.data != null) {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/Monthly_Report_${date.year}_${date.month}.pdf');
          await file.writeAsBytes(response.data!);
          
          await Share.shareXFiles(
            [XFile(file.path)],
            subject: 'Monthly Report - ${DateFormat('MMMM yyyy').format(date)}',
          );
          return;
        }
      } catch (e) {
        debugPrint('Backend PDF export failed: $e, falling back to local generation');
      }

      // Local fallback
      final summary = data['summary'] as Map<String, dynamic>? ?? {};
      final rawLoans = data['loan_payments'] as List<dynamic>? ?? [];
      final rawRent = data['rent_payments'] as List<dynamic>? ?? [];
      final rawExpenses = data['expenses'] as List<dynamic>? ?? [];
      final user = ref.read(authNotifierProvider).value;

      final reportData = ReportData(
        month: date.month,
        year: date.year,
        tenantName: user?.email.split('@').first.toUpperCase() ?? 'MY TENANT',
        totalInterestCollected: Decimal.parse(summary['total_interest_collected']?.toString() ?? '0'),
        totalRentCollected: Decimal.parse(summary['total_rent_collected']?.toString() ?? '0'),
        totalExpenses: Decimal.parse(summary['total_expenses']?.toString() ?? '0'),
        loanRows: rawLoans.map((l) {
          return LoanReportRow(
            borrowerName: l['borrower_name']?.toString() ?? 'Borrower',
            principal: Decimal.parse(l['principal']?.toString() ?? '0'),
            interestRate: Decimal.parse('1.0'),
            interestCollected: l['type'] == 'interest' ? Decimal.parse(l['amount']?.toString() ?? '0') : Decimal.zero,
            status: l['type']?.toString().toUpperCase() ?? 'INTEREST',
          );
        }).toList(),
        rentRows: rawRent.map((r) {
          return RentReportRow(
            tenantName: r['tenant_name']?.toString() ?? 'Tenant',
            unitName: r['unit_name']?.toString() ?? 'Unit',
            amountDue: Decimal.parse(r['amount_due']?.toString() ?? '0'),
            amountPaid: Decimal.parse(r['amount_paid']?.toString() ?? '0'),
            status: r['status']?.toString() ?? 'pending',
          );
        }).toList(),
        expenseRows: rawExpenses.map((e) {
          return ExpenseReportRow(
            category: e['category']?.toString() ?? 'other',
            description: e['description']?.toString() ?? '',
            amount: Decimal.parse(e['amount']?.toString() ?? '0'),
            date: DateTime.parse(e['expense_date']?.toString() ?? DateTime.now().toIso8601String()),
          );
        }).toList(),
      );

      final pdfBytes = await generateMonthlyReport(reportData);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/Monthly_Report_${date.year}_${date.month}_Local.pdf');
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Monthly Report - ${DateFormat('MMMM yyyy').format(date)}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export PDF: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportCsv(DateTime date) async {
    setState(() => _isExporting = true);
    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get<List<int>>(
        ApiEndpoints.reportsCsv,
        queryParameters: {
          'year': date.year,
          'month': date.month,
        },
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/Monthly_Report_${date.year}_${date.month}.csv');
        await file.writeAsBytes(response.data!);

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Monthly CSV Report - ${DateFormat('MMMM yyyy').format(date)}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export CSV: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build Methods
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedReportDateProvider);
    final reportState = ref.watch(monthlyReportDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Financial Reports',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () => ref.read(monthlyReportDataProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(context, selectedDate),
          TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Loans'),
              Tab(text: 'Rent'),
              Tab(text: 'Expenses'),
            ],
          ),
          Expanded(
            child: reportState.when(
              data: (data) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(selectedDate, data),
                    _buildLoansTab(data),
                    _buildRentTab(data),
                    _buildExpensesTab(data),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primary)),
              ),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load report data: $err',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(monthlyReportDataProvider.notifier).refresh(),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, DateTime selectedDate) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - 2 + index);
    final months = List.generate(12, (index) => index + 1);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Month Selector
          Expanded(
            child: DropdownButtonHideUnderline(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: DropdownButton<int>(
                  value: selectedDate.month,
                  dropdownColor: AppColors.surface,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                  items: months.map((m) {
                    final label = DateFormat('MMMM').format(DateTime(2024, m));
                    return DropdownMenuItem<int>(
                      value: m,
                      child: Text(
                        label,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(selectedReportDateProvider.notifier).setDate(
                            DateTime(selectedDate.year, val),
                          );
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Year Selector
          Expanded(
            child: DropdownButtonHideUnderline(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: DropdownButton<int>(
                  value: selectedDate.year,
                  dropdownColor: AppColors.surface,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                  items: years.map((y) {
                    return DropdownMenuItem<int>(
                      value: y,
                      child: Text(
                        '$y',
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(selectedReportDateProvider.notifier).setDate(
                            DateTime(val, selectedDate.month),
                          );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab Views
  // ---------------------------------------------------------------------------

  Widget _buildOverviewTab(DateTime date, Map<String, dynamic> data) {
    final summary = data['summary'] as Map<String, dynamic>? ?? {};
    final totalInterest = Decimal.parse(summary['total_interest_collected']?.toString() ?? '0');
    final totalPrincipal = Decimal.parse(summary['total_principal_collected']?.toString() ?? '0');
    final totalRent = Decimal.parse(summary['total_rent_collected']?.toString() ?? '0');
    final totalExpenses = Decimal.parse(summary['total_expenses']?.toString() ?? '0');
    final netIncome = Decimal.parse(summary['net_income']?.toString() ?? '0');

    final isProfit = netIncome >= Decimal.zero;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profit / Loss Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isProfit ? AppColors.secondary.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  isProfit ? 'NET PROFIT' : 'NET LOSS',
                  style: TextStyle(
                    color: isProfit ? AppColors.secondary : AppColors.error,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  CurrencyFormatter.formatINR(netIncome),
                  style: TextStyle(
                    color: isProfit ? AppColors.secondary : AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'For the period of ${DateFormat('MMMM yyyy').format(date)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Details breakdown
          const Text(
            'Aggregated Details',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSummaryItem('Interest Collected', totalInterest, AppColors.secondary, Icons.percent),
          const SizedBox(height: 8),
          _buildSummaryItem('Principal Collected', totalPrincipal, AppColors.primary, Icons.monetization_on),
          const SizedBox(height: 8),
          _buildSummaryItem('Rent Collected', totalRent, Colors.blueAccent, Icons.home),
          const SizedBox(height: 8),
          _buildSummaryItem('Total Expenses', totalExpenses, AppColors.danger, Icons.trending_down, isNegative: true),
          const SizedBox(height: 30),

          // Export Section
          const Text(
            'Export Options',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_isExporting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primary)),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text('Export PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () => _exportPdf(date, data),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.table_view, color: Colors.white),
                    label: const Text('Export CSV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () => _exportCsv(date),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, Decimal amount, Color color, IconData icon, {bool isNegative = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
          Text(
            '${isNegative ? "- " : ""}${CurrencyFormatter.formatINR(amount)}',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLoansTab(Map<String, dynamic> data) {
    final loanPayments = data['loan_payments'] as List<dynamic>? ?? [];
    if (loanPayments.isEmpty) {
      return const Center(child: Text('No loan payments recorded.', style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: loanPayments.length,
      itemBuilder: (context, index) {
        final item = loanPayments[index];
        final amount = Decimal.parse(item['amount']?.toString() ?? '0');
        final date = DateTime.parse(item['payment_date']?.toString() ?? DateTime.now().toIso8601String());
        final isInterest = item['type'] == 'interest';

        return Card(
          color: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(
              isInterest ? Icons.percent : Icons.monetization_on,
              color: isInterest ? AppColors.secondary : AppColors.primary,
            ),
            title: Text(item['borrower_name']?.toString() ?? 'Borrower', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${DateFormat('dd MMM yyyy').format(date)} • ${isInterest ? "Interest" : "Principal"}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            trailing: Text(
              '+ ${CurrencyFormatter.formatINR(amount)}',
              style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRentTab(Map<String, dynamic> data) {
    final rentPayments = data['rent_payments'] as List<dynamic>? ?? [];
    if (rentPayments.isEmpty) {
      return const Center(child: Text('No rent records for this month.', style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rentPayments.length,
      itemBuilder: (context, index) {
        final item = rentPayments[index];
        final paid = Decimal.parse(item['amount_paid']?.toString() ?? '0');
        final due = Decimal.parse(item['amount_due']?.toString() ?? '0');
        final status = item['status']?.toString().toUpperCase() ?? 'PENDING';

        final isPaid = status == 'PAID';
        final isPartiallyPaid = status == 'PARTIALLY_PAID';

        return Card(
          color: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(
              Icons.home,
              color: isPaid ? AppColors.secondary : (isPartiallyPaid ? AppColors.warning : AppColors.error),
            ),
            title: Text(item['tenant_name']?.toString() ?? 'Tenant', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Unit: ${item['unit_name'] ?? "Unknown"} • Due: ${CurrencyFormatter.formatINR(due)}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.formatINR(paid),
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: isPaid ? AppColors.secondary : (isPartiallyPaid ? AppColors.warning : AppColors.error),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpensesTab(Map<String, dynamic> data) {
    final expenses = data['expenses'] as List<dynamic>? ?? [];
    if (expenses.isEmpty) {
      return const Center(child: Text('No expenses recorded.', style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final item = expenses[index];
        final amount = Decimal.parse(item['amount']?.toString() ?? '0');
        final date = DateTime.parse(item['expense_date']?.toString() ?? DateTime.now().toIso8601String());
        final category = item['category']?.toString().toUpperCase() ?? 'OTHER';

        return Card(
          color: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.receipt_long, color: AppColors.danger),
            title: Text(item['description']?.toString() ?? 'Expense', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${DateFormat('dd MMM yyyy').format(date)} • $category',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            trailing: Text(
              '- ${CurrencyFormatter.formatINR(amount)}',
              style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        );
      },
    );
  }
}
