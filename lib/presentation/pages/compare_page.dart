import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  /// 実質単価 = (金額 - ポイント) ÷ 数量
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

/// 単価比較メイン画面
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
    // 初期 3 件
    _rows.add(PriceRow(id: _newId()));
    _rows.add(PriceRow(id: _newId()));
    _rows.add(PriceRow(id: _newId()));
  }

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}_${_nextIndex++}';

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

  /// 有効行（単価が算出できる行）の中で最安の id を返す。
  /// 有効行が 2 件未満の場合は null を返す。
  String? _cheapestId() {
    final valid = _rows.where((r) => r.unitPrice != null).toList();
    if (valid.length < 2) return null;
    return valid.reduce((a, b) => a.unitPrice! <= b.unitPrice! ? a : b).id;
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
        title: const Text('単価 比較'),
        centerTitle: true,
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
                final isCheapest = cheapestId != null && row.id == cheapestId;
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextButton.icon(
              onPressed: _addRow,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('行を追加'),
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
          // ── 行 1: 店名 / 単価 / 削除ボタン ──────────────────────────────
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.label,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: '店舗・商品 ${index + 1}',
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
              // 単価バッジ
              _UnitPriceBadge(
                unitPrice: unitPrice,
                isCheapest: isCheapest,
              ),
              const SizedBox(width: 4),
              // 削除ボタン
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: canDelete
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface.withValues(alpha: _disabledAlpha),
                ),
                onPressed: canDelete ? onDelete : null,
                tooltip: '削除',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ── 行 2: 金額 / 数量 / ポイント ───────────────────────────────
          Row(
            children: [
              Expanded(
                child: _NumField(
                  controller: row.price,
                  label: '金額（円）',
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumField(
                  controller: row.qty,
                  label: '数量',
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumField(
                  controller: row.points,
                  label: 'ポイント',
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

// ─── 単価バッジ ──────────────────────────────────────────────────────────────

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

// ─── 数値入力フィールド ───────────────────────────────────────────────────────

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
