import 'dart:convert';

import 'package:flutterbase/domain/entities/saved_comparison.dart';
import 'package:flutterbase/infrastructure/db/sqlite/rows/saved_comparison_row.dart';

/// Converts between [SavedComparison] domain objects and [SavedComparisonRow]
/// DB row models.
class SavedComparisonMapper {
  SavedComparisonMapper._();

  static SavedComparison toDomain(SavedComparisonRow row) {
    final rawList = jsonDecode(row.itemsJson) as List<dynamic>;
    final items = rawList
        .cast<Map<String, dynamic>>()
        .map(_itemFromJson)
        .toList();
    return SavedComparison(
      id: row.id,
      title: row.title,
      savedAt: DateTime.fromMillisecondsSinceEpoch(row.savedAt),
      items: items,
    );
  }

  static SavedComparisonRow toRow(SavedComparison comparison) {
    final itemsJson =
        jsonEncode(comparison.items.map(_itemToJson).toList());
    return SavedComparisonRow(
      id: comparison.id,
      title: comparison.title,
      savedAt: comparison.savedAt.millisecondsSinceEpoch,
      itemsJson: itemsJson,
    );
  }

  static SavedComparisonItem _itemFromJson(Map<String, dynamic> json) {
    return SavedComparisonItem(
      label: json['label'] as String,
      price: (json['price'] as num).toDouble(),
      qty: (json['qty'] as num).toDouble(),
      points: (json['points'] as num).toDouble(),
      unitPrice: json['unit_price'] != null
          ? (json['unit_price'] as num).toDouble()
          : null,
    );
  }

  static Map<String, dynamic> _itemToJson(SavedComparisonItem item) => {
        'label': item.label,
        'price': item.price,
        'qty': item.qty,
        'points': item.points,
        'unit_price': item.unitPrice,
      };
}
