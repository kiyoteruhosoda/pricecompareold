import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:pricecompare/infrastructure/db/sqlite/migrations/migration_v1.dart';

/// Singleton wrapper around the application's SQLite database.
class AppDatabase {
  AppDatabase._();

  static const int _version = 1;
  static const String _fileName = 'pricecompare.db';

  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase._();

  Database? _db;

  /// Opens (or creates) the database, running migrations as needed.
  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _fileName);

    return openDatabase(
      path,
      version: _version,
      onCreate: (db, version) => migrateV1(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        // Future migrations go here.
      },
    );
  }

  /// Closes the database. Used in tests and teardown.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
