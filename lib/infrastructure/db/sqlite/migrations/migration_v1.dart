import 'package:sqflite/sqflite.dart';

/// Applies schema version 1.
///
/// Creates the `saved_comparisons` table that stores each comparison as a
/// row with a JSON-encoded list of price rows.
Future<void> migrateV1(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS saved_comparisons (
      id         TEXT    NOT NULL PRIMARY KEY,
      name       TEXT    NOT NULL,
      rows_json  TEXT    NOT NULL,
      created_at INTEGER NOT NULL
    )
  ''');
}
