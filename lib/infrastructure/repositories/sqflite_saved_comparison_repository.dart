import 'package:pricecompare/domain/entities/saved_comparison.dart';
import 'package:pricecompare/domain/repositories/saved_comparison_repository.dart';
import 'package:pricecompare/infrastructure/db/sqlite/dao/saved_comparison_dao.dart';
import 'package:pricecompare/infrastructure/mappers/saved_comparison_mapper.dart';
import 'package:pricecompare/shared/errors/app_error.dart';

/// SQLite-backed implementation of [SavedComparisonRepository].
final class SqfliteSavedComparisonRepository
    implements SavedComparisonRepository {
  SqfliteSavedComparisonRepository(this._dao, this._mapper);

  final SavedComparisonDao _dao;
  final SavedComparisonMapper _mapper;

  @override
  Future<List<SavedComparison>> getAll() async {
    try {
      final rows = await _dao.getAll();
      return rows.map(_mapper.toDomain).toList();
    } catch (e) {
      throw InfrastructureError(
        'Failed to load saved comparisons',
        cause: e,
      );
    }
  }

  @override
  Future<void> save(SavedComparison comparison) async {
    try {
      await _dao.insert(_mapper.toRow(comparison));
    } catch (e) {
      throw InfrastructureError(
        'Failed to save comparison',
        cause: e,
      );
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dao.deleteById(id);
    } catch (e) {
      // Rethrow as a typed InfrastructureError so callers receive a
      // structured error rather than a raw DatabaseException.
      throw InfrastructureError(
        'Failed to delete comparison',
        cause: e,
      );
    }
  }
}
