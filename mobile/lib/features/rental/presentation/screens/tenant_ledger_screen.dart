import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/rent_payment.dart';
import '../../domain/entities/rental_tenant.dart';
import '../providers/rental_provider.dart';

class TenantLedgerScreen extends ConsumerStatefulWidget {
  const TenantLedgerScreen({super.key, required this.tenantId});

  final String tenantId;

  @override
  ConsumerState<TenantLedgerScreen> createState() => _TenantLedgerScreenState();
}

class _TenantLedgerScreenState extends ConsumerState<TenantLedgerScreen> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedCycleMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showRecordPaymentSheet(RentalTenant tenant, List<RentPayment> payments) {
    // Find first pending/partially paid cycle to suggest, or default to current month
    DateTime initialMonth = _selectedCycleMonth;
    final incompletePayments = payments.where((p) => p.status != 'paid').toList();
    if (incompletePayments.isNotEmpty) {
      // Sort oldest first
      incompletePayments.sort((a, b) => a.cycleMonth.compareTo(b.cycleMonth));
      initialMonth = DateTime(incompletePayments.first.cycleMonth.year, incompletePayments.first.cycleMonth.month, 1);
      final remaining = incompletePayments.first.remainingBalance;
      _amountController.text = remaining.toString();
    } else {
      _amountController.text = tenant.rentAmount.toString();
    }

    _selectedCycleMonth = initialMonth;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Record Rent Payment',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Cycle month selector
                    InkWell(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedCycleMonth,
                          firstDate: DateTime(now.year - 2),
                          lastDate: DateTime(now.year + 2),
                          initialDatePickerMode: DatePickerMode.year,
                          selectableDayPredicate: (day) => day.day == 1,
                        );
                        if (picked != null) {
                          setSheetState(() {
                            _selectedCycleMonth = DateTime(picked.year, picked.month, 1);
                            // If there is an existing payment record for this month, suggest the remaining balance
                            final existing = payments.firstWhere(
                              (p) => p.cycleMonth.year == picked.year && p.cycleMonth.month == picked.month,
                              orElse: () => RentPayment(
                                id: '',
                                rentalTenantId: tenant.id,
                                cycleMonth: _selectedCycleMonth,
                                amountDue: tenant.rentAmount,
                                amountPaid: Decimal.zero,
                                remainingBalance: tenant.rentAmount,
                                status: 'pending',
                                idempotencyKey: '',
                                createdAt: DateTime.now(),
                              ),
                            );
                            _amountController.text = existing.remainingBalance.toString();
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Cycle Month',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MMMM yyyy').format(_selectedCycleMonth),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.calendar_today, color: AppColors.primaryLight),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Amount Paid (INR) *',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.notes, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Consumer(
                      builder: (context, ref, child) {
                        final recordState = ref.watch(rentPaymentRecorderProvider);
                        final isLoading = recordState is AsyncLoading;

                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final amountVal = double.tryParse(_amountController.text);
                                    if (amountVal == null || amountVal <= 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please enter a valid amount')),
                                      );
                                      return;
                                    }
                                    await ref.read(rentPaymentRecorderProvider.notifier).recordRentPayment(
                                          rentalTenantId: tenant.id,
                                          cycleMonth: _selectedCycleMonth,
                                          amountPaid: amountVal,
                                          notes: _notesController.text.trim().isEmpty
                                              ? null
                                              : _notesController.text.trim(),
                                        );
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      _notesController.clear();
                                      _amountController.clear();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Payment recorded successfully')),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Confirm Payment',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ledgerState = ref.watch(tenantLedgerNotifierProvider(widget.tenantId));

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
          'Tenant Ledger',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () => ref.read(tenantLedgerNotifierProvider(widget.tenantId).notifier).refresh(),
          ),
        ],
      ),
      body: ledgerState.when(
        data: (data) {
          final tenant = data['tenant'] as RentalTenant;
          final payments = data['payments'] as List<RentPayment>;
          final totalOutstanding = data['total_outstanding'] as Decimal;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: _buildTenantCard(tenant, totalOutstanding),
                    ),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Payment History',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: payments.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Text(
                                  'No payments recorded yet.',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final payment = payments[index];
                                return _buildPaymentItem(payment);
                              },
                              childCount: payments.length,
                            ),
                          ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _showRecordPaymentSheet(tenant, payments),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.add_card, color: Colors.white),
                    label: const Text(
                      'Record Payment',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load ledger: $err',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(tenantLedgerNotifierProvider(widget.tenantId).notifier).refresh(),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTenantCard(RentalTenant tenant, Decimal totalOutstanding) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenant.fullName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tenant.unitName ?? 'No Unit Assigned',
                        style: const TextStyle(color: AppColors.primaryLight, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: tenant.isActive ? AppColors.statusActiveBg : AppColors.statusClosedBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tenant.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      color: tenant.isActive ? AppColors.statusActiveFg : AppColors.statusClosedFg,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly Rent',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatINR(tenant.rentAmount),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Outstanding Balance',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatINR(totalOutstanding),
                      style: TextStyle(
                        color: totalOutstanding > Decimal.zero ? AppColors.error : AppColors.secondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tenant.phone != null) ...[
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    tenant.phone!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Lease: ${AppDateUtils.formatShort(tenant.leaseStart)} — ${tenant.leaseEnd != null ? AppDateUtils.formatShort(tenant.leaseEnd!) : 'Ongoing'}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
            if (tenant.notes != null && tenant.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tenant.notes!,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fade().slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _buildPaymentItem(RentPayment payment) {
    final isPending = payment.status == 'pending';
    final isPartial = payment.status == 'partially_paid';

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(payment.cycleMonth),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPending
                        ? AppColors.statusPendingBg
                        : isPartial
                            ? AppColors.statusPartialBg
                            : AppColors.statusPaidBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    payment.status.toUpperCase(),
                    style: TextStyle(
                      color: isPending
                          ? AppColors.statusPendingFg
                          : isPartial
                              ? AppColors.statusPartialFg
                              : AppColors.statusPaidFg,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Due', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatINR(payment.amountDue),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Paid', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatINR(payment.amountPaid),
                      style: const TextStyle(color: AppColors.secondaryLight, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Balance', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatINR(payment.remainingBalance),
                      style: TextStyle(
                        color: payment.remainingBalance > Decimal.zero ? AppColors.error : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (payment.notes != null && payment.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(color: Colors.white10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  payment.notes!,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
