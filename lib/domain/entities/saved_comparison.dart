/// A single item within a saved price comparison.
class SavedComparisonItem {
  const SavedComparisonItem({
    required this.label,
    required this.price,
    required this.qty,
    required this.points,
    this.unitPrice,
  });

  final String label;
  final double price;
  final double qty;
  final double points;
  final double? unitPrice;
}

/// A saved price comparison with a user-defined title and timestamp.
class SavedComparison {
  const SavedComparison({
    required this.id,
    required this.title,
    required this.savedAt,
    required this.items,
  });

  final String id;
  final String title;
  final DateTime savedAt;
  final List<SavedComparisonItem> items;
}
