/// DTO for a single item within a saved comparison.
class SavedComparisonItemDto {
  const SavedComparisonItemDto({
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

/// DTO representing a saved comparison result.
class SavedComparisonDto {
  const SavedComparisonDto({
    required this.id,
    required this.title,
    required this.savedAt,
    required this.items,
  });

  final String id;
  final String title;
  final DateTime savedAt;
  final List<SavedComparisonItemDto> items;
}
