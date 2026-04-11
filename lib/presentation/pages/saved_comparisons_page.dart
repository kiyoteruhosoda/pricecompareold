import 'package:flutter/material.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/application/dto/saved_comparison_dto.dart';
import 'package:flutterbase/presentation/viewmodels/saved_comparisons_viewmodel.dart';
import 'package:flutterbase/shared/l10n/app_strings.dart';
import 'package:flutterbase/shared/theme/theme.dart';

const double _precisionThreshold = 10.0;

/// Displays the list of saved price comparisons.
class SavedComparisonsPage extends StatefulWidget {
  const SavedComparisonsPage({super.key});

  @override
  State<SavedComparisonsPage> createState() => _SavedComparisonsPageState();
}

class _SavedComparisonsPageState extends State<SavedComparisonsPage> {
  late final SavedComparisonsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<SavedComparisonsViewModel>();
    _viewModel.addListener(_onChanged);
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.savedTitle),
        centerTitle: true,
      ),
      body: switch (_viewModel.state) {
        SavedComparisonsState.loading => const Center(
            child: CircularProgressIndicator(),
          ),
        SavedComparisonsState.error => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_viewModel.appError?.message ?? AppStrings.commonError),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: _viewModel.load,
                  child: const Text(AppStrings.commonRetry),
                ),
              ],
            ),
          ),
        SavedComparisonsState.loaded => _viewModel.comparisons.isEmpty
            ? const Center(
                child: Text(AppStrings.savedEmpty),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _viewModel.comparisons.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final comparison = _viewModel.comparisons[index];
                  return _SavedComparisonCard(
                    comparison: comparison,
                    onDelete: () => _confirmDelete(comparison),
                  );
                },
              ),
      },
    );
  }

  Future<void> _confirmDelete(SavedComparisonDto comparison) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.savedDeleteConfirmTitle),
        content: Text(
          '"${comparison.title}" — ${AppStrings.savedDeleteConfirmBody}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.savedDeleteCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppStrings.savedDeleteConfirm,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _viewModel.delete(comparison.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.savedDeleteSuccess)),
        );
      }
    }
  }
}

// ─── Card ────────────────────────────────────────────────────────────────────

class _SavedComparisonCard extends StatelessWidget {
  const _SavedComparisonCard({
    required this.comparison,
    required this.onDelete,
  });

  final SavedComparisonDto comparison;
  final VoidCallback onDelete;

  String _formatDate(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  String _formatUnitPrice(double? up) {
    if (up == null) return '—';
    return up < _precisionThreshold
        ? '¥${up.toStringAsFixed(4)}/unit'
        : '¥${up.toStringAsFixed(2)}/unit';
  }

  SavedComparisonItemDto? _cheapestItem() {
    final valid =
        comparison.items.where((i) => i.unitPrice != null).toList();
    if (valid.length < 2) return null;
    return valid.reduce(
      (a, b) => a.unitPrice! <= b.unitPrice! ? a : b,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cheapest = _cheapestItem();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surface,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Expanded(
                child: Text(
                  comparison.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: onDelete,
                tooltip: AppStrings.savedDeleteTooltip,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
          Text(
            _formatDate(comparison.savedAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Items
          ...comparison.items.map((item) {
            final isCheapest = cheapest != null && item == cheapest;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.label.isEmpty
                          ? '${AppStrings.compareItemLabel} ?'
                          : item.label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  if (isCheapest)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 10),
                          SizedBox(width: 2),
                          Text(
                            AppStrings.savedCheapestLabel,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    _formatUnitPrice(item.unitPrice),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isCheapest
                              ? Colors.green
                              : colorScheme.onSurfaceVariant,
                          fontWeight: isCheapest
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
