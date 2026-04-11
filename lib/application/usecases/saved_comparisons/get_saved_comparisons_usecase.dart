import 'package:pricecompare/domain/entities/saved_comparison.dart';
import 'package:pricecompare/domain/repositories/saved_comparison_repository.dart';

/// Returns all saved comparisons ordered by creation time descending.
final class GetSavedComparisonsUseCase {
  const GetSavedComparisonsUseCase(this._repository);

  final SavedComparisonRepository _repository;

  Future<List<SavedComparison>> execute() => _repository.getAll();
}
