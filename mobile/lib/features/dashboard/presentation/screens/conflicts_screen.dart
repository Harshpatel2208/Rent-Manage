import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/offline/local_db.dart';
import '../../../../core/offline/sync_service.dart';
import '../providers/conflicts_provider.dart';

class ConflictsScreen extends ConsumerWidget {
  const ConflictsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conflictsState = ref.watch(conflictsNotifierProvider);
    final syncState = ref.watch(syncServiceProvider);

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
          AppStrings.syncTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            tooltip: 'Refresh',
            onPressed: () {
              ref.read(conflictsNotifierProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner displaying syncing status
          if (syncState.isSyncing)
            Container(
              width: double.infinity,
              color: AppColors.primary.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    AppStrings.syncingMessage,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else if (syncState.lastError != null)
            Container(
              width: double.infinity,
              color: AppColors.error.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      syncState.lastError!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.read(syncServiceProvider.notifier).triggerSync(),
                    child: const Text(
                      AppStrings.retry,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: conflictsState.when(
              data: (conflicts) {
                if (conflicts.isEmpty) {
                  return _buildEmptyState(context, ref);
                }
                return _buildConflictsList(context, ref, conflicts);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        err.toString(),
                        style: const TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(conflictsNotifierProvider.notifier).refresh(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text(AppStrings.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: syncState.pendingCount > 0 || conflictsState.value?.isNotEmpty == true
          ? Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${syncState.pendingCount} pending updates',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${conflictsState.value?.length ?? 0} conflicts unresolved',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: syncState.isSyncing
                          ? null
                          : () async {
                              await ref.read(syncServiceProvider.notifier).triggerSync();
                              ref.invalidate(conflictsNotifierProvider);
                            },
                      icon: const Icon(Icons.sync_outlined, size: 18),
                      label: const Text('Sync Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_done_outlined,
                color: AppColors.secondary,
                size: 64,
              ),
            ).animate().scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            const Text(
              'All Caught Up!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.noConflicts,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => ref.read(syncServiceProvider.notifier).triggerSync(),
              icon: const Icon(Icons.sync),
              label: const Text('Check for updates'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictsList(
    BuildContext context,
    WidgetRef ref,
    List<LocalConflict> conflicts,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: conflicts.length,
      itemBuilder: (context, index) {
        final conflict = conflicts[index];
        return _ConflictCard(conflict: conflict)
            .animate(delay: (index * 50).ms)
            .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuad, duration: 300.ms)
            .fadeIn(duration: 300.ms);
      },
    );
  }
}

class _ConflictCard extends ConsumerStatefulWidget {
  final LocalConflict conflict;

  const _ConflictCard({required this.conflict});

  @override
  ConsumerState<_ConflictCard> createState() => _ConflictCardState();
}

class _ConflictCardState extends ConsumerState<_ConflictCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final conflict = widget.conflict;
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(conflict.createdAt);
    final entityType = conflict.entityType.toUpperCase();
    
    // Choose entity color
    Color badgeColor;
    switch (entityType) {
      case 'LOAN':
      case 'LENDING':
        badgeColor = AppColors.primary;
        break;
      case 'RENTAL':
      case 'TENANT':
      case 'UNIT':
        badgeColor = AppColors.secondary;
        break;
      case 'EXPENSE':
      case 'EXPENSES':
        badgeColor = AppColors.warning;
        break;
      default:
        badgeColor = AppColors.textHint;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section (Header)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                entityType,
                                style: TextStyle(
                                  color: badgeColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          conflict.conflictReason,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${conflict.entityId}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Expanded Section (JSON Payload Details)
            if (_expanded)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LOCAL ATTEMPTED DATA',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        _prettyPrintPayload(conflict.localPayload),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Bottom Divider
            const Divider(height: 1, color: AppColors.border),

            // Actions Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _expanded = !_expanded;
                      });
                    },
                    icon: Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    label: Text(
                      _expanded ? 'Hide Data' : 'View Data',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showDismissConfirmation(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Keep Server'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _showKeepLocalConfirmation(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Keep Local'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _prettyPrintPayload(Map<String, dynamic> payload) {
    final buffer = StringBuffer();
    payload.forEach((key, value) {
      buffer.writeln('  $key: $value');
    });
    return buffer.toString().trimRight();
  }

  void _showDismissConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Keep Server State?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'This conflict will be marked as dismissed on the server. Your offline local transaction will be discarded, and the server-side ledger state will be kept.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                AppStrings.cancel,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Keep Server'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref
                    .read(conflictsNotifierProvider.notifier)
                    .dismissConflict(widget.conflict.id);
              },
            ),
          ],
        );
      },
    );
  }

  void _showKeepLocalConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Keep Local State?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'This conflict will be resolved on the server by allowing a retry. Your local offline transaction will be re-queued with a new idempotency key and synced again.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                AppStrings.cancel,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
              ),
              child: const Text('Keep Local'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref
                    .read(conflictsNotifierProvider.notifier)
                    .resolveConflictWithRetry(widget.conflict.id);
              },
            ),
          ],
        );
      },
    );
  }
}
