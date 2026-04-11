/// SQLite row model for the `saved_comparisons` table.
///
/// [rowsJson] is a JSON-encoded list of row objects:
/// `[{"label":"...","price":0.0,"qty":0.0,"points":0.0}, ...]`
final class SavedComparisonDbRow {
  const SavedComparisonDbRow({
    required this.id,
    required this.name,
    required this.rowsJson,
    required this.createdAtMs,
  });

  factory SavedComparisonDbRow.fromMap(Map<String, Object?> map) {
    return SavedComparisonDbRow(
      id: map['id'] as String,
      name: map['name'] as String,
      rowsJson: map['rows_json'] as String,
      createdAtMs: map['created_at'] as int,
    );
  }

  final String id;
  final String name;
  final String rowsJson;
  final int createdAtMs;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'rows_json': rowsJson,
        'created_at': createdAtMs,
      };
}
