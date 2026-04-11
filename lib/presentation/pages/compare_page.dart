import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/application/dto/saved_comparison_dto.dart';
import 'package:flutterbase/application/usecases/comparison/save_comparison_usecase.dart';
import 'package:flutterbase/shared/l10n/app_strings.dart';

// Named constants for magic values
const double _disabledAlpha = 0.2;
const double _precisionThreshold = 10.0;

/// Data model for a single price comparison row.
class PriceRow {
  PriceRow({required this.id})
      : label = TextEditingController(),
        price = TextEditingController(),
        qty = TextEditingController(),
        points = TextEditingController();

  final String id;
  final TextEditingController label;
  final TextEditingController price;
  final TextEditingController qty;
  final TextEditingController points;

  /// Effective unit price = (price - points) / qty
  double? get unitPrice {
    final p = double.tryParse(price.text);
    final q = double.tryParse(qty.text);
    final pt = double.tryParse(points.text) ?? 0;
    if (p == null || q == null || q <= 0) return null;
    return (p - pt) / q;
  }

  void dispose() {
    label.dispose();
    price.dispose();
    qty.dispose();
    points.dispose();
  }
}

/// Main price comparison screen.
class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  final List<PriceRow> _rows = [];
  int _nextIndex = 1;

  @override
  void initState() {
    super.initState();
    // Start with 1 row by default
    _rows.add(PriceRow(id: _newId()));
  }

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${_nextIndex++}';

  void _addRow() {
    setState(() {
      _rows.add(PriceRow(id: _newId()));
    });
  }

  void _removeRow(String id) {
    if (_rows.length <= 1) return;
    final row = _rows.firstWhere((r) => r.id == id);
    setState(() {
      _rows.remove(row);
    });
    row.dispose();
  }

  void _rebuild() => setState(() {});

  /// Returns the id of the cheapest valid row, or null if fewer than 2 valid.
  String? _cheapestId() {
    final valid = _rows.where((r) => r.unitPrice != null).toList();
    if (valid.length < 2) return null;
    return valid.reduce((a, b) => a.unitPrice! <= b.unitPrice! ? a : b).id;
  }

  Future<void> _showSaveDialog() async {
    final titleController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.compareSaveDialogTitle),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: AppStrings.compareSaveTitleHint,
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.of(context).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.compareSaveCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.compareSaveButton),
          ),
        ],
      ),
    );

    titleController.dispose();
    if (confirmed != true) return;

    final title = titleController.text.trim().isEmpty
        ? 'Comparison ${DateTime.now().toLocal()}'
        : titleController.text.trim();

    final dto = SavedComparisonDto(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      savedAt: DateTime.now(),
      items: _rows
          .map(
            (r) => SavedComparisonItemDto(
              label: r.label.text,
              price: double.tryParse(r.price.text) ?? 0,
              qty: double.tryParse(r.qty.text) ?? 0,
              points: double.tryParse(r.points.text) ?? 0,
              unitPrice: r.unitPrice,
            ),
          )
          .toList(),
    );

    try {
      await sl<SaveComparisonUseCase>().execute(dto);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.compareSaveSuccess)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.commonError)),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cheapestId = _cheapestId();
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.compareTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: _showSaveDialog,
            tooltip: AppStrings.compareSaveTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.list_alt_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/saved'),
            tooltip: AppStrings.compareSavedListTooltip,
          ),
          PopupMenuButton<String>(
            onSelected: (route) => Navigator.of(context).pushNamed(route),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: '/about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text(AppStrings.drawerAbout),
                  ],
                ),
              ),
              PopupMenuItem(
                value: '/licenses',
                child: Row(
                  children: [
                    Icon(Icons.description_outlined),
                    SizedBox(width: 8),
                    Text(AppStrings.drawerLicenses),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              itemCount: _rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final row = _rows[index];
                final isCheapest =
                    cheapestId != null && row.id == cheapestId;
                return _PriceCard(
                  row: row,
                  index: index,
                  isCheapest: isCheapest,
                  canDelete: _rows.length > 1,
                  onDelete: () => _removeRow(row.id),
                  onChanged: _rebuild,
                );
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextButton.icon(
              onPressed: _addRow,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text(AppStrings.compareAddRow),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PriceCard ──────────────────────────────────────────────────────────────

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.row,
    required this.index,
    required this.isCheapest,
    required this.canDelete,
    required this.onDelete,
    required this.onChanged,
  });

  final PriceRow row;
  final int index;
  final bool isCheapest;
  final bool canDelete;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final unitPrice = row.unitPrice;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCheapest ? Colors.green : colorScheme.outlineVariant,
          width: isCheapest ? 2.5 : 1,
        ),
        color: colorScheme.surface,
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: label / unit price badge / delete button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.label,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText:
                        '${AppStrings.compareItemLabel} ${index + 1}',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 8),
              _UnitPriceBadge(
                unitPrice: unitPrice,
                isCheapest: isCheapest,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: canDelete
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface
                          .withValues(alpha: _disabledAlpha),
                ),
                onPressed: canDelete ? onDelete : null,
                tooltip: AppStrings.compareDeleteTooltip,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: price / qty / points
          Row(
            children: [
              Expanded(
                child: _NumField(
                  controller: row.price,
                  label: AppStrings.comparePriceLabel,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumField(
                  controller: row.qty,
                  label: AppStrings.compareQtyLabel,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumField(
                  controller: row.points,
                  label: AppStrings.comparePointsLabel,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Unit price badge ────────────────────────────────────────────────────────

class _UnitPriceBadge extends StatelessWidget {
  const _UnitPriceBadge({required this.unitPrice, required this.isCheapest});

  final double? unitPrice;
  final bool isCheapest;

  @override
  Widget build(BuildContext context) {
    if (unitPrice == null) {
      return const SizedBox.shrink();
    }

    final label = unitPrice! < _precisionThreshold
        ? '¥${unitPrice!.toStringAsFixed(4)}/unit'
        : '¥${unitPrice!.toStringAsFixed(2)}/unit';

    if (isCheapest) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.white, size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      label,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 12,
      ),
    );
  }
}

// ─── Numeric text field ──────────────────────────────────────────────────────

class _NumField extends StatelessWidget {
  const _NumField({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
      ),
      onChanged: (_) => onChanged(),
    );
  }
}
