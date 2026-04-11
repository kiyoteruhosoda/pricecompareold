import 'package:pricecompare/domain/entities/saved_comparison.dart';
import 'package:pricecompare/domain/repositories/saved_comparison_repository.dart';

/// Persists a new saved comparison.
final class SaveComparisonUseCase {
  const SaveComparisonUseCase(this._repository);

  final SavedComparisonRepository _repository;

  Future<void> execute(SavedComparison comparison) =>
      _repository.save(comparison);
}
