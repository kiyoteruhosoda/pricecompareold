import 'package:flutter/material.dart';
import 'package:pricecompare/domain/entities/saved_comparison.dart';
import 'package:pricecompare/domain/value_objects/saved_comparison_row.dart';
import 'package:pricecompare/presentation/viewmodels/saved_comparisons_viewmodel.dart';
import 'package:pricecompare/shared/l10n/app_strings.dart';
import 'package:pricecompare/shared/theme/theme.dart';

/// Displays the list of saved price comparisons and allows deletion.
class SavedComparisonsPage extends StatefulWidget {
  const SavedComparisonsPage({super.key, required this.viewModel});

  final SavedComparisonsViewModel viewModel;

  @override
  State<SavedComparisonsPage> createState() => _SavedComparisonsPageState();
}

class _SavedComparisonsPageState extends State<SavedComparisonsPage> {
  SavedComparisonsViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.savedTitle),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return switch (_viewModel.state) {
            SavedComparisonsState.loading => const Center(
                child: CircularProgressIndicator(),
              ),
            SavedComparisonsState.error => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.commonError,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: _viewModel.load,
                      child: const Text(AppStrings.commonRetry),
                    ),
                  ],
                ),
              ),
            SavedComparisonsState.loaded => _viewModel.items.isEmpty
                ? const Center(
                    child: Text(AppStrings.savedEmpty),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _viewModel.items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final comparison = _viewModel.items[index];
                      return _SavedComparisonCard(
                        comparison: comparison,
                        onDelete: () => _confirmDelete(comparison),
                      );
                    },
                  ),
          };
        },
      ),
    );
  }

  /// Shows a confirmation dialog and, **only if the ViewModel confirms
  /// successful deletion**, shows the success snackbar.
  ///
  /// If [SavedComparisonsViewModel.delete] returns `false` (storage failure),
  /// an error snackbar is shown instead so the user is never misled.
  Future<void> _confirmDelete(SavedComparison comparison) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.savedDeleteConfirmTitle),
        content: const Text(AppStrings.savedDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.savedDeleteCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(AppStrings.savedDeleteConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await _viewModel.delete(comparison.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.savedDeleteSuccess)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.savedDeleteError)),
      );
    }
  }
}

// ─── Card ────────────────────────────────────────────────────────────────────

class _SavedComparisonCard extends StatelessWidget {
  const _SavedComparisonCard({
    required this.comparison,
    required this.onDelete,
  });

  final SavedComparison comparison;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    comparison.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: AppStrings.savedDeleteConfirm,
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _formatDate(comparison.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...comparison.rows.map(
              (row) => _RowSummary(row: row),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}'
        '-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _RowSummary extends StatelessWidget {
  const _RowSummary({required this.row});

  final SavedComparisonRow row;

  @override
  Widget build(BuildContext context) {
    final unitPrice = row.unitPrice;
    final priceText = unitPrice != null
        ? '¥${unitPrice < 10 ? unitPrice.toStringAsFixed(4) : unitPrice.toStringAsFixed(2)}/unit'
        : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              row.label.isEmpty ? '—' : row.label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            priceText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
