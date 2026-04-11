import 'package:pricecompare/domain/value_objects/saved_comparison_row.dart';

/// A named snapshot of a price comparison session, persisted to local storage.
final class SavedComparison {
  const SavedComparison({
    required this.id,
    required this.name,
    required this.rows,
    required this.createdAt,
  });

  /// Unique identifier (UUID string).
  final String id;

  /// User-visible name for this saved comparison.
  final String name;

  /// The individual price rows captured at save time.
  final List<SavedComparisonRow> rows;

  /// When the comparison was first saved.
  final DateTime createdAt;
}
