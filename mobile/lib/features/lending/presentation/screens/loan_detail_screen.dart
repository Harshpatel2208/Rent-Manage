import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/lending_provider.dart';

class LoanDetailScreen extends ConsumerStatefulWidget {
  const LoanDetailScreen({super.key, required this.loanId});

  final String loanId;

  @override
  ConsumerState<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends ConsumerState<LoanDetailScreen> {
  final _paymentAmountController = TextEditingController();
  final _paymentNotesController = TextEditingController();
  String _paymentType = 'interest'; // 'interest' | 'principal'
  DateTime _paymentDate = DateTime.now();
  // First-of-month that the interest payment is for (YYYY-MM-01)
  late DateTime _selectedCycleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedCycleMonth = DateTime(now.year, now.month, 1);
  }

  @override
  void dispose() {
    _paymentAmountController.dispose();
    _paymentNotesController.dispose();
    super.dispose();
  }

  void _showRecordPaymentBottomSheet(BuildContext context, decimalExpectedInterest, Decimal principal) {
    // Set default amount based on payment type
    if (_paymentType == 'interest') {
      _paymentAmountController.text = decimalExpectedInterest.toStringAsFixed(2);
    } else {
      _paymentAmountController.text = principal.toStringAsFixed(2);
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Record Payment',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Segmented control / Dropdown for payment type
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _paymentType = 'interest';
                              _paymentAmountController.text =
                                  decimalExpectedInterest.toStringAsFixed(2);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _paymentType == 'interest'
                                  ? AppColors.primary
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Interest Only',
                              style: TextStyle(
                                color: _paymentType == 'interest'
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _paymentType = 'principal';
                              _paymentAmountController.text = principal.toStringAsFixed(2);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _paymentType == 'principal'
                                  ? AppColors.primary
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Principal / Bullet',
                              style: TextStyle(
                                color: _paymentType == 'principal'
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Amount input
                  TextFormField(
                    controller: _paymentAmountController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount (INR)',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Date picker
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _paymentDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                surface: AppColors.surface,
                                onSurface: AppColors.textPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setModalState(() {
                          _paymentDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Payment Date',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          Text(
                            DateFormat('dd MMMM yyyy').format(_paymentDate),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes input
                  TextFormField(
                    controller: _paymentNotesController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final amt = double.tryParse(_paymentAmountController.text);
                        if (amt == null || amt <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid amount')),
                          );
                          return;
                        }

                        Navigator.pop(context);

                        try {
                          // Compute YYYY-MM-01 string for cycle_month
                          final cycleMonthStr = _paymentType == 'interest'
                              ? '${_selectedCycleMonth.year}-${_selectedCycleMonth.month.toString().padLeft(2, '0')}-01'
                              : null;

                          await ref.read(paymentRecorderProvider.notifier).recordPayment(
                                loanId: widget.loanId,
                                amount: amt,
                                paymentDate: _paymentDate,
                                type: _paymentType,
                                cycleMonth: cycleMonthStr,
                                notes: _paymentNotesController.text.trim().isEmpty
                                    ? null
                                    : _paymentNotesController.text.trim(),
                              );
                          _paymentNotesController.clear();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Payment recorded successfully')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to record payment: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm Payment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loanDetailState = ref.watch(loanDetailNotifierProvider(widget.loanId));
    final scheduleState = ref.watch(loanScheduleProvider(widget.loanId));
    final paymentsState = ref.watch(loanPaymentsProvider(widget.loanId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Loan Details',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.secondary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(loanDetailNotifierProvider(widget.loanId));
          ref.invalidate(loanScheduleProvider(widget.loanId));
          ref.invalidate(loanPaymentsProvider(widget.loanId));
        },
        child: loanDetailState.when(
          data: (loan) {
            final expectedInterest = loan.principal * loan.interestRate;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Borrower & Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                loan.borrowerName,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: loan.status == 'active'
                                      ? AppColors.secondary.withValues(alpha: 0.1)
                                      : Colors.white10,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  loan.status.toUpperCase(),
                                  style: TextStyle(
                                    color: loan.status == 'active'
                                        ? AppColors.secondary
                                        : AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('Principal Loan', CurrencyFormatter.formatINR(loan.principal)),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Monthly Interest Rate',
                            '${(loan.interestRate * Decimal.fromInt(100)).toStringAsFixed(1)}%',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Expected Monthly Collection',
                            CurrencyFormatter.formatINR(expectedInterest),
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Registered Date',
                            DateFormat('dd MMM yyyy').format(loan.registeredAt),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 24),

                    // Expected monthly schedule section
                    const Text(
                      'EXPECTED INTEREST CYCLE SCHEDULE',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    scheduleState.when(
                      data: (schedule) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: schedule.length,
                            separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                            itemBuilder: (context, index) {
                              final item = schedule[index];
                              final monthName = DateFormat('MMMM yyyy').format(item.cycleMonth);

                              Color statusColor = AppColors.textSecondary;
                              if (item.status == 'collected') {
                                statusColor = AppColors.secondary;
                              } else if (item.status == 'pending') {
                                statusColor = AppColors.warning;
                              } else if (item.status == 'waived') {
                                statusColor = Colors.white24;
                              }

                              return ListTile(
                                leading: Icon(
                                  item.status == 'collected'
                                      ? Icons.check_circle
                                      : item.status == 'waived'
                                          ? Icons.block
                                          : Icons.pending,
                                  color: statusColor,
                                ),
                                title: Text(
                                  monthName,
                                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  CurrencyFormatter.formatINR(item.expectedAmount),
                                  style: const TextStyle(color: AppColors.textSecondary),
                                ),
                                trailing: Text(
                                  item.status.toUpperCase(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text(
                        'Failed to load schedule: $err',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payments history section
                    const Text(
                      'PAYMENT TRANSACTION HISTORY',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    paymentsState.when(
                      data: (payments) {
                        if (payments.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'No payment transactions recorded yet.',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          );
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: payments.length,
                            separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                            itemBuilder: (context, index) {
                              final p = payments[index];
                              final pDate = DateFormat('dd MMM yyyy').format(p.paymentDate);

                              return ListTile(
                                leading: Icon(
                                  p.type == 'principal' ? Icons.monetization_on : Icons.percent,
                                  color: p.type == 'principal' ? AppColors.primary : AppColors.secondary,
                                ),
                                title: Text(
                                  p.type.toUpperCase(),
                                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  pDate + (p.notes != null ? ' - ${p.notes}' : ''),
                                  style: const TextStyle(color: AppColors.textSecondary),
                                ),
                                trailing: Text(
                                  CurrencyFormatter.formatINR(p.amount),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text(
                        'Failed to load payments: $err',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 80), // bottom spacing for fab
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (err, _) => Center(
            child: Text(
              'Failed to load loan: $err',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ),
      ),
      floatingActionButton: loanDetailState.when(
        data: (loan) {
          if (loan.status == 'closed') return null;
          final expectedInterest = loan.principal * loan.interestRate;
          return FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            onPressed: () => _showRecordPaymentBottomSheet(context, expectedInterest, loan.principal),
            label: const Text('Record Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.payment, color: Colors.white),
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
