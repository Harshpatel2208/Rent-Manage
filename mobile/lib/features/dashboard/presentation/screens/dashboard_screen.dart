import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../domain/entities/dashboard_metrics.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Screen
// ─────────────────────────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final greeting = _getGreeting();
    final today = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Premium App Bar ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 52, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            authState.value?.email.split('@').first ?? AppStrings.appName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            today,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _AppBarActionButton(
                            icon: Icons.bar_chart_rounded,
                            onTap: () => context.push('/reports'),
                            tooltip: 'Reports',
                          ),
                          const SizedBox(width: 8),
                          _AppBarActionButton(
                            icon: Icons.logout_rounded,
                            onTap: () => ref.read(authNotifierProvider.notifier).logout(),
                            tooltip: 'Logout',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: RefreshIndicator(
              color: AppColors.secondary,
              backgroundColor: AppColors.surface,
              onRefresh: () => ref.read(dashboardNotifierProvider.notifier).refresh(),
              child: dashboardAsync.when(
                data: (metrics) => _DashboardBody(metrics: metrics),
                loading: () => const _DashboardShimmer(),
                error: (err, _) => _DashboardError(
                  message: err.toString(),
                  onRetry: () => ref.read(dashboardNotifierProvider.notifier).refresh(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 🌅';
    if (hour < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Body — the full scrollable content when data is loaded
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.metrics});
  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Card: Total Capital Lent ─────────────────────────────────
          _HeroCapitalCard(amount: metrics.totalActiveCapital)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.08, duration: 400.ms, curve: Curves.easeOut),

          const SizedBox(height: 16),

          // ── Income + Expenses Row ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'EXPECTED INCOME',
                  subtitle: 'This month',
                  amount: metrics.expectedMonthlyIncome,
                  icon: Icons.trending_up_rounded,
                  accentColor: AppColors.secondary,
                  gradientColors: const [Color(0xFF065F46), Color(0xFF059669)],
                ).animate().fadeIn(delay: 100.ms, duration: 350.ms).slideX(begin: -0.06),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'EXPENSES (MTD)',
                  subtitle: 'Month to date',
                  amount: metrics.totalExpensesThisMonth,
                  icon: Icons.trending_down_rounded,
                  accentColor: AppColors.error,
                  gradientColors: const [Color(0xFF7F1D1D), Color(0xFFDC2626)],
                ).animate().fadeIn(delay: 150.ms, duration: 350.ms).slideX(begin: 0.06),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Income Breakdown Card ─────────────────────────────────────────
          _BreakdownCard(metrics: metrics)
              .animate()
              .fadeIn(delay: 200.ms, duration: 350.ms),

          const SizedBox(height: 16),

          // ── Stats Row ────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatsCard(
                  label: 'Active Loans',
                  count: metrics.activeLoansCount,
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.primary,
                  route: '/loans',
                ).animate().fadeIn(delay: 250.ms, duration: 350.ms),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatsCard(
                  label: 'Active Tenants',
                  count: metrics.activeTenantsCount,
                  icon: Icons.people_alt_rounded,
                  color: Colors.blueAccent,
                  route: '/rental',
                ).animate().fadeIn(delay: 300.ms, duration: 350.ms),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Quick Actions ────────────────────────────────────────────────
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ).animate().fadeIn(delay: 350.ms),
          const SizedBox(height: 12),
          _QuickActionsRow()
              .animate()
              .fadeIn(delay: 400.ms, duration: 350.ms)
              .slideY(begin: 0.06),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Capital Card
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCapitalCard extends StatefulWidget {
  const _HeroCapitalCard({required this.amount});
  final Decimal amount;

  @override
  State<_HeroCapitalCard> createState() => _HeroCapitalCardState();
}

class _HeroCapitalCardState extends State<_HeroCapitalCard> {
  bool _compact = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _compact = !_compact),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3730A3), Color(0xFF4F46E5), Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'TOTAL CAPITAL LENT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _compact ? 'Compact' : 'Full',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _compact
                  ? CurrencyFormatter.formatCompact(widget.amount)
                  : CurrencyFormatter.formatINR(widget.amount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.white54, size: 13),
                const SizedBox(width: 5),
                Text(
                  'Tap to toggle view • Active loans only',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metric Card (Income / Expenses)
// ─────────────────────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.accentColor,
    required this.gradientColors,
  });

  final String title;
  final String subtitle;
  final Decimal amount;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Income Breakdown Card
// ─────────────────────────────────────────────────────────────────────────────

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.metrics});
  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final total = metrics.expectedMonthlyIncome;
    final totalDbl = total.toDouble();
    final interestPct = totalDbl > 0
        ? (metrics.expectedMonthlyInterest.toDouble() / totalDbl * 100)
        : 0.0;
    final rentPct = totalDbl > 0
        ? (metrics.expectedMonthlyRent.toDouble() / totalDbl * 100)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Income Breakdown',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  CurrencyFormatter.formatCompact(total),
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Stacked progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Flexible(
                  flex: interestPct.round().clamp(0, 100),
                  child: Container(height: 8, color: AppColors.secondary),
                ),
                Flexible(
                  flex: (100 - interestPct.round()).clamp(0, 100),
                  child: Container(height: 8, color: Colors.blueAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          _BreakdownRow(
            label: 'Interest Collection',
            sublabel: '${interestPct.toStringAsFixed(0)}% of income',
            value: metrics.expectedMonthlyInterest,
            dotColor: AppColors.secondary,
            icon: Icons.percent_rounded,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white10, height: 1),
          ),
          _BreakdownRow(
            label: 'Rent Collection',
            sublabel: '${rentPct.toStringAsFixed(0)}% of income',
            value: metrics.expectedMonthlyRent,
            dotColor: Colors.blueAccent,
            icon: Icons.home_rounded,
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.dotColor,
    required this.icon,
  });

  final String label;
  final String sublabel;
  final Decimal value;
  final Color dotColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: dotColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: dotColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                sublabel,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Text(
          CurrencyFormatter.formatINR(value),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Card (Active Loans / Active Tenants)
// ─────────────────────────────────────────────────────────────────────────────

class _StatsCard extends ConsumerWidget {
  const _StatsCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final String route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color.withValues(alpha: 0.5), size: 14),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions Row
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'New Loan',
            icon: Icons.add_circle_rounded,
            color: AppColors.primary,
            onPressed: () => context.push('/loans/add'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            label: 'Record Rent',
            icon: Icons.payment_rounded,
            color: AppColors.secondary,
            onPressed: () => context.go('/rental'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            label: 'Add Expense',
            icon: Icons.receipt_long_rounded,
            color: AppColors.error,
            onPressed: () => context.push('/expenses/add'),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar Action Button
// ─────────────────────────────────────────────────────────────────────────────

class _AppBarActionButton extends StatelessWidget {
  const _AppBarActionButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer Loading State
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _shimmerBox(height: 170, radius: 24),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _shimmerBox(height: 110, radius: 18)),
              const SizedBox(width: 12),
              Expanded(child: _shimmerBox(height: 110, radius: 18)),
            ],
          ),
          const SizedBox(height: 16),
          _shimmerBox(height: 140, radius: 18),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _shimmerBox(height: 80, radius: 18)),
              const SizedBox(width: 12),
              Expanded(child: _shimmerBox(height: 80, radius: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({required double height, required double radius}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 1400.ms,
          color: Colors.white.withValues(alpha: 0.07),
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error State
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Could not reach server',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Make sure the backend is running at http://10.0.2.2:5000',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
