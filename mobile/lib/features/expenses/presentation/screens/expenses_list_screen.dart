import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/expense.dart';
import '../providers/expenses_provider.dart';

class ExpensesListScreen extends ConsumerStatefulWidget {
  const ExpensesListScreen({super.key, this.showAddSheet = false});

  final bool showAddSheet;

  @override
  ConsumerState<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends ConsumerState<ExpensesListScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.showAddSheet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddExpenseSheet();
      });
    }
  }

  String? _selectedCategory;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  // Controllers for Add Expense Form
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  String _addCategory = 'food';
  DateTime _addDate = DateTime.now();

  final List<String> _categories = [
    'food',
    'maintenance',
    'travel',
    'business',
    'other',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Dialogs & Actions
  // -------------------------------------------------------------------------

  void _showAddExpenseSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: Colors.white10, width: 1),
                ),
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
                          'Log Expense',
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
                    const SizedBox(height: 20),
                    // Amount Field
                    TextField(
                      controller: _amountController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        prefixText: '₹ ',
                        prefixStyle: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 24,
                        ),
                        labelText: 'Amount *',
                        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white10),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      dropdownColor: AppColors.surface,
                      initialValue: _addCategory,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white10),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      items: _categories.map((c) {
                        return DropdownMenuItem<String>(
                          value: c,
                          child: Text(c.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() {
                            _addCategory = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Date Selector
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _addDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2101),
                        );
                        if (date != null) {
                          setSheetState(() {
                            _addDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Expense Date *',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                            ),
                            Text(
                              AppDateUtils.formatShort(_addDate),
                              style: const TextStyle(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description
                    TextField(
                      controller: _descController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description / Notes',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white10),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          final parsedAmount = CurrencyFormatter.tryParseAmount(_amountController.text);
                          if (parsedAmount == null || parsedAmount <= Decimal.zero) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid amount')),
                            );
                            return;
                          }
                          Navigator.pop(context);
                          try {
                            await ref.read(expensesListProvider.notifier).addExpense(
                                  amount: parsedAmount.toDouble(),
                                  category: _addCategory,
                                  expenseDate: _addDate,
                                  description: _descController.text.trim().isEmpty
                                      ? null
                                      : _descController.text.trim(),
                                );
                            _amountController.clear();
                            _descController.clear();
                            _addCategory = 'food';
                            _addDate = DateTime.now();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Expense logged successfully')),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to log expense: $e')),
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
                          'Save Expense',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
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

  void _showFilterDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setFilterState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text(
                'Filter Expenses',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Category', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      dropdownColor: AppColors.surface,
                      initialValue: _selectedCategory,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('ALL CATEGORIES'),
                        ),
                        ..._categories.map((c) {
                          return DropdownMenuItem<String?>(
                            value: c,
                            child: Text(c.toUpperCase()),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setFilterState(() {
                          _selectedCategory = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Date Range', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dateFrom ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2101),
                              );
                              if (date != null) {
                                setFilterState(() {
                                  _dateFrom = date;
                                });
                              }
                            },
                            child: Text(
                              _dateFrom != null ? AppDateUtils.formatShort(_dateFrom!) : 'From Date',
                              style: const TextStyle(color: AppColors.primaryLight),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dateTo ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2101),
                              );
                              if (date != null) {
                                setFilterState(() {
                                  _dateTo = date;
                                });
                              }
                            },
                            child: Text(
                              _dateTo != null ? AppDateUtils.formatShort(_dateTo!) : 'To Date',
                              style: const TextStyle(color: AppColors.primaryLight),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_dateFrom != null || _dateTo != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setFilterState(() {
                              _dateFrom = null;
                              _dateTo = null;
                            });
                          },
                          child: const Text('Clear Dates', style: TextStyle(color: AppColors.error, fontSize: 12)),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                      _dateFrom = null;
                      _dateTo = null;
                    });
                    ref.read(expensesListProvider.notifier).updateFilters(
                          category: null,
                          dateFrom: null,
                          dateTo: null,
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Reset All', style: TextStyle(color: AppColors.error)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(expensesListProvider.notifier).updateFilters(
                          category: _selectedCategory,
                          dateFrom: _dateFrom,
                          dateTo: _dateTo,
                        );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Builders
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final expensesState = ref.watch(expensesListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Daily Expenses',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: (_selectedCategory != null || _dateFrom != null || _dateTo != null)
                  ? AppColors.secondary
                  : AppColors.textSecondary,
            ),
            tooltip: 'Filter list',
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.secondary,
        backgroundColor: AppColors.surface,
        onRefresh: () => ref.read(expensesListProvider.notifier).refresh(),
        child: expensesState.when(
          data: (expenses) => _buildExpensesList(expenses),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (err, _) => _buildErrorState(err.toString(), () => ref.read(expensesListProvider.notifier).refresh()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddExpenseSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildExpensesList(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          const Center(
            child: Text(
              'No expenses found.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ),
        ],
      );
    }

    // Group expenses by date
    final Map<String, List<Expense>> grouped = {};
    for (final exp in expenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(exp.expenseDate);
      grouped.putIfAbsent(dateKey, () => []).add(exp);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final dayExpenses = grouped[dateKey]!;
        final dateParsed = DateTime.parse(dateKey);
        final dateString = DateFormat('EEEE, dd MMM yyyy').format(dateParsed);

        // Sum amount for this day
        final dayTotal = dayExpenses.fold<Decimal>(
          Decimal.zero,
          (sum, e) => sum + e.amount,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateString,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatINR(dayTotal),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            ...dayExpenses.map((exp) {
              return Card(
                color: AppColors.surface,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(exp.category).withValues(alpha: 0.15),
                    child: Icon(
                      _getCategoryIcon(exp.category),
                      color: _getCategoryColor(exp.category),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        exp.category.toUpperCase(),
                        style: TextStyle(
                          color: _getCategoryColor(exp.category),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatINR(exp.amount),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      exp.description ?? 'No description',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        ).animate().fadeIn(delay: (index * 100).ms, duration: 300.ms);
      },
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'maintenance':
        return Colors.blue;
      case 'travel':
        return Colors.teal;
      case 'business':
        return Colors.purple;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'maintenance':
        return Icons.build;
      case 'travel':
        return Icons.directions_car;
      case 'business':
        return Icons.business_center;
      default:
        return Icons.payments;
    }
  }
}
