import 'package:pricecompare/domain/entities/saved_comparison.dart';

/// Persistent store for saved price comparisons.
abstract interface class SavedComparisonRepository {
  /// Returns all saved comparisons ordered by [SavedComparison.createdAt] descending.
  Future<List<SavedComparison>> getAll();

  /// Persists [comparison] as a new record. Throws on storage failure.
  Future<void> save(SavedComparison comparison);

  /// Permanently removes the comparison with the given [id].
  ///
  /// Throws [InfrastructureError] if the underlying storage operation fails
  /// (e.g. locked or corrupt database). Never silently swallows the error.
  Future<void> delete(String id);
}
