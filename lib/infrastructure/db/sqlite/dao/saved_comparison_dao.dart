import 'package:pricecompare/infrastructure/db/sqlite/app_database.dart';
import 'package:pricecompare/infrastructure/db/sqlite/rows/saved_comparison_row.dart';
import 'package:sqflite/sqflite.dart';

/// SQL operations for the saved_comparisons table.
class SavedComparisonDao {
  static const String _table = 'saved_comparisons';

  Future<Database> get _db => AppDatabase.instance;

  Future<List<SavedComparisonRow>> findAll() async {
    final db = await _db;
    final maps = await db.query(_table, orderBy: 'saved_at DESC');
    return maps.map(SavedComparisonRow.fromMap).toList();
  }

  Future<void> insert(SavedComparisonRow row) async {
    final db = await _db;
    await db.insert(
      _table,
      row.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteById(String id) async {
    final db = await _db;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
