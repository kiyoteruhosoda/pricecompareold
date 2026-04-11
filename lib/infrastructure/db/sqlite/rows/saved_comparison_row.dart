/// DB row model for the saved_comparisons table.
class SavedComparisonRow {
  const SavedComparisonRow({
    required this.id,
    required this.title,
    required this.savedAt,
    required this.itemsJson,
  });

  factory SavedComparisonRow.fromMap(Map<String, Object?> map) {
    return SavedComparisonRow(
      id: map['id'] as String,
      title: map['title'] as String,
      savedAt: map['saved_at'] as int,
      itemsJson: map['items_json'] as String,
    );
  }

  final String id;
  final String title;
  final int savedAt; // Unix timestamp in milliseconds
  final String itemsJson;

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'saved_at': savedAt,
        'items_json': itemsJson,
      };
}
