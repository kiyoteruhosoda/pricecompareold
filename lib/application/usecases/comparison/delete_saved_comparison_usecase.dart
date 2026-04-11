import 'package:pricecompare/domain/repositories/saved_comparison_repository.dart';

class DeleteSavedComparisonUseCase {
  DeleteSavedComparisonUseCase(this._repository);

  final SavedComparisonRepository _repository;

  Future<void> execute(String id) => _repository.delete(id);
}
