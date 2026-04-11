import 'dart:convert';

import 'package:pricecompare/domain/entities/saved_comparison.dart';
import 'package:pricecompare/domain/value_objects/saved_comparison_row.dart';
import 'package:pricecompare/infrastructure/db/sqlite/rows/saved_comparison_db_row.dart';

/// Converts between [SavedComparison] domain objects and [SavedComparisonDbRow]
/// database row models.
final class SavedComparisonMapper {
  const SavedComparisonMapper();

  SavedComparison toDomain(SavedComparisonDbRow row) {
    final rawList = jsonDecode(row.rowsJson) as List<dynamic>;
    final rows = rawList
        .cast<Map<String, dynamic>>()
        .map(
          (m) => SavedComparisonRow(
            label: (m['label'] as String?) ?? '',
            price: (m['price'] as num).toDouble(),
            qty: (m['qty'] as num).toDouble(),
            points: (m['points'] as num? ?? 0).toDouble(),
          ),
        )
        .toList();

    return SavedComparison(
      id: row.id,
      name: row.name,
      rows: rows,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAtMs),
    );
  }

  SavedComparisonDbRow toRow(SavedComparison comparison) {
    final rowsJson = jsonEncode(
      comparison.rows
          .map(
            (r) => {
              'label': r.label,
              'price': r.price,
              'qty': r.qty,
              'points': r.points,
            },
          )
          .toList(),
    );

    return SavedComparisonDbRow(
      id: comparison.id,
      name: comparison.name,
      rowsJson: rowsJson,
      createdAtMs: comparison.createdAt.millisecondsSinceEpoch,
    );
  }
}
