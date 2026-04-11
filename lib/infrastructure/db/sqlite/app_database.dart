import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Opens and manages the SQLite database, applying migrations in order.
class AppDatabase {
  AppDatabase._();

  static const String _dbName = 'pricecompare.db';
  static const int _currentVersion = 1;

  static Database? _instance;

  static Future<Database> get instance async {
    _instance ??= await _open();
    return _instance!;
  }

  static Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _currentVersion,
      onCreate: (db, version) => _migrate(db, 0, version),
      onUpgrade: (db, oldVersion, newVersion) =>
          _migrate(db, oldVersion, newVersion),
    );
  }

  static Future<void> _migrate(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 1) {
      await db.execute('''
        CREATE TABLE saved_comparisons (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          saved_at INTEGER NOT NULL,
          items_json TEXT NOT NULL
        )
      ''');
    }
  }
}
