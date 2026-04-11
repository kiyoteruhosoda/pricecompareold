import 'package:flutterbase/domain/entities/saved_comparison.dart';
import 'package:flutterbase/domain/repositories/saved_comparison_repository.dart';
import 'package:flutterbase/infrastructure/db/sqlite/dao/saved_comparison_dao.dart';
import 'package:flutterbase/infrastructure/mappers/saved_comparison_mapper.dart';

/// SQLite-backed implementation of [SavedComparisonRepository].
class SqliteSavedComparisonRepository implements SavedComparisonRepository {
  SqliteSavedComparisonRepository(this._dao);

  final SavedComparisonDao _dao;

  @override
  Future<List<SavedComparison>> getAll() async {
    final rows = await _dao.findAll();
    return rows.map(SavedComparisonMapper.toDomain).toList();
  }

  @override
  Future<void> save(SavedComparison comparison) async {
    final row = SavedComparisonMapper.toRow(comparison);
    await _dao.insert(row);
  }

  @override
  Future<void> delete(String id) async {
    await _dao.deleteById(id);
  }
}
