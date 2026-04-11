import 'package:pricecompare/domain/repositories/saved_comparison_repository.dart';

/// Permanently removes a saved comparison by its [id].
///
/// Any storage-level exception from the repository propagates to the caller
/// unchanged — this use case never swallows errors.
final class DeleteSavedComparisonUseCase {
  const DeleteSavedComparisonUseCase(this._repository);

  final SavedComparisonRepository _repository;

  Future<void> execute(String id) => _repository.delete(id);
}
