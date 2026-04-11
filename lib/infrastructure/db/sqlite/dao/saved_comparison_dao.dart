import 'package:sqflite/sqflite.dart';
import 'package:pricecompare/infrastructure/db/sqlite/rows/saved_comparison_db_row.dart';

/// Raw SQL operations for the `saved_comparisons` table.
class SavedComparisonDao {
  const SavedComparisonDao(this._db);

  static const _table = 'saved_comparisons';

  final Database _db;

  Future<List<SavedComparisonDbRow>> getAll() async {
    final maps = await _db.query(_table, orderBy: 'created_at DESC');
    return maps.map(SavedComparisonDbRow.fromMap).toList();
  }

  Future<void> insert(SavedComparisonDbRow row) async {
    await _db.insert(
      _table,
      row.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Deletes the row with the given [id].
  ///
  /// Throws [DatabaseException] on storage failure; never suppresses it.
  Future<void> deleteById(String id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
