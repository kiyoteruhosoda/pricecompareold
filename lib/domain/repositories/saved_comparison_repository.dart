import 'package:pricecompare/domain/entities/saved_comparison.dart';

abstract interface class SavedComparisonRepository {
  Future<List<SavedComparison>> getAll();
  Future<void> save(SavedComparison comparison);
  Future<void> delete(String id);
}
