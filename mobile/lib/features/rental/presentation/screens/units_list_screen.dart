import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/rental_tenant.dart';
import '../../domain/entities/shop_unit.dart';
import '../providers/rental_provider.dart';

class UnitsListScreen extends ConsumerStatefulWidget {
  const UnitsListScreen({super.key});

  @override
  ConsumerState<UnitsListScreen> createState() => _UnitsListScreenState();
}

class _UnitsListScreenState extends ConsumerState<UnitsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Unit form controllers
  final _unitNameController = TextEditingController();
  final _unitAddressController = TextEditingController();
  final _unitDescController = TextEditingController();

  // Tenant form controllers
  final _tenantNameController = TextEditingController();
  final _tenantPhoneController = TextEditingController();
  final _tenantRentController = TextEditingController();
  final _tenantNotesController = TextEditingController();
  DateTime _leaseStart = DateTime.now();
  DateTime? _leaseEnd;
  String? _selectedUnitId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _unitNameController.dispose();
    _unitAddressController.dispose();
    _unitDescController.dispose();
    _tenantNameController.dispose();
    _tenantPhoneController.dispose();
    _tenantRentController.dispose();
    _tenantNotesController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Dialogs & Actions
  // -------------------------------------------------------------------------

  void _showAddUnitDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Add Shop Unit',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _unitNameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Unit Name / Number *',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _unitAddressController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _unitDescController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _unitNameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unit Name is required')),
                  );
                  return;
                }
                Navigator.pop(context);
                try {
                  await ref.read(shopUnitsListProvider.notifier).addUnit(
                        unitName: name,
                        address: _unitAddressController.text.trim().isEmpty
                            ? null
                            : _unitAddressController.text.trim(),
                        description: _unitDescController.text.trim().isEmpty
                            ? null
                            : _unitDescController.text.trim(),
                      );
                  _unitNameController.clear();
                  _unitAddressController.clear();
                  _unitDescController.clear();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shop Unit added successfully')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add shop unit: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTenantDialog() {
    final unitsState = ref.read(shopUnitsListProvider);
    final units = unitsState.value ?? [];

    if (units.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one Shop Unit first')),
      );
      return;
    }

    _selectedUnitId = units.first.id;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text(
                'Add Tenant',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      dropdownColor: AppColors.surface,
                      initialValue: _selectedUnitId,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Shop Unit *',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                      items: units.map((u) {
                        return DropdownMenuItem<String>(
                          value: u.id,
                          child: Text(u.unitName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          _selectedUnitId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tenantNameController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tenantPhoneController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tenantRentController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Monthly Rent (INR) *',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lease Start *',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _leaseStart,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2101),
                            );
                            if (date != null) {
                              setDialogState(() {
                                _leaseStart = date;
                              });
                            }
                          },
                          child: Text(
                            AppDateUtils.formatShort(_leaseStart),
                            style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lease End (Opt)',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _leaseEnd ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2101),
                            );
                            setDialogState(() {
                              _leaseEnd = date;
                            });
                          },
                          child: Text(
                            _leaseEnd != null ? AppDateUtils.formatShort(_leaseEnd!) : 'Set Date',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tenantNotesController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = _tenantNameController.text.trim();
                    final rentVal = double.tryParse(_tenantRentController.text);
                    if (name.isEmpty || rentVal == null || rentVal <= 0 || _selectedUnitId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields correctly')),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    try {
                      await ref.read(tenantsListProvider.notifier).addTenant(
                            fullName: name,
                            phone: _tenantPhoneController.text.trim().isEmpty
                                ? null
                                : _tenantPhoneController.text.trim(),
                            rentAmount: rentVal,
                            leaseStart: _leaseStart,
                            leaseEnd: _leaseEnd,
                            notes: _tenantNotesController.text.trim().isEmpty
                                ? null
                                : _tenantNotesController.text.trim(),
                            unitId: _selectedUnitId,
                          );
                      _tenantNameController.clear();
                      _tenantPhoneController.clear();
                      _tenantRentController.clear();
                      _tenantNotesController.clear();
                      _leaseStart = DateTime.now();
                      _leaseEnd = null;
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tenant added successfully')),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add tenant: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Add'),
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
    final unitsState = ref.watch(shopUnitsListProvider);
    final tenantsState = ref.watch(tenantsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Rent Management',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Shop Units'),
            Tab(text: 'Tenants'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            color: AppColors.secondary,
            backgroundColor: AppColors.surface,
            onRefresh: () => ref.read(shopUnitsListProvider.notifier).refresh(),
            child: unitsState.when(
              data: (units) => _buildUnitsList(units),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => _buildErrorState(err.toString(), () => ref.read(shopUnitsListProvider.notifier).refresh()),
            ),
          ),
          RefreshIndicator(
            color: AppColors.secondary,
            backgroundColor: AppColors.surface,
            onRefresh: () => ref.read(tenantsListProvider.notifier).refresh(),
            child: tenantsState.when(
              data: (tenants) => _buildTenantsList(tenants),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => _buildErrorState(err.toString(), () => ref.read(tenantsListProvider.notifier).refresh()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddUnitDialog();
          } else {
            _showAddTenantDialog();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUnitsList(List<ShopUnit> units) {
    if (units.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          const Center(
            child: Text(
              'No shop units registered.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: units.length,
      itemBuilder: (context, index) {
        final unit = units[index];
        return Card(
          color: AppColors.surface,
          margin: const EdgeInsets.only(bottom: 12),
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
                    Text(
                      unit.unitName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.storefront, color: AppColors.primaryLight),
                  ],
                ),
                if (unit.address != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    unit.address!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
                if (unit.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    unit.description!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        ).animate().slideY(begin: 0.1, delay: (index * 50).ms, duration: 300.ms);
      },
    );
  }

  Widget _buildTenantsList(List<RentalTenant> tenants) {
    if (tenants.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          const Center(
            child: Text(
              'No tenants registered.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: tenants.length,
      itemBuilder: (context, index) {
        final tenant = tenants[index];
        final isPending = tenant.currentMonthStatus == 'pending';
        final isPartial = tenant.currentMonthStatus == 'partially_paid';

        return Card(
          color: AppColors.surface,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white10),
          ),
          child: InkWell(
            onTap: () => context.push('/rental/tenants/${tenant.id}'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          tenant.fullName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                          (tenant.currentMonthStatus ?? 'pending').toUpperCase(),
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
                          const Text(
                            'Monthly Rent',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatINR(tenant.rentAmount),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Outstanding Ledger',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatINR(tenant.totalOutstanding ?? Decimal.zero),
                            style: TextStyle(
                              color: (tenant.totalOutstanding ?? Decimal.zero) > Decimal.zero ? AppColors.error : AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tenant.phone ?? 'No Phone Number',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const Row(
                        children: [
                          Text('Ledger', style: TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.bold)),
                          Icon(Icons.chevron_right, color: AppColors.primaryLight, size: 16),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ).animate().slideY(begin: 0.1, delay: (index * 50).ms, duration: 300.ms);
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
}
