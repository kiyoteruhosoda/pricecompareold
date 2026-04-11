import 'package:pricecompare/application/dto/saved_comparison_dto.dart';
import 'package:pricecompare/domain/entities/saved_comparison.dart';
import 'package:pricecompare/domain/repositories/saved_comparison_repository.dart';

class GetSavedComparisonsUseCase {
  GetSavedComparisonsUseCase(this._repository);

  final SavedComparisonRepository _repository;

  Future<List<SavedComparisonDto>> execute() async {
    final entities = await _repository.getAll();
    return entities.map(_toDto).toList();
  }

  static SavedComparisonDto _toDto(SavedComparison e) => SavedComparisonDto(
        id: e.id,
        title: e.title,
        savedAt: e.savedAt,
        items: e.items
            .map(
              (i) => SavedComparisonItemDto(
                label: i.label,
                price: i.price,
                qty: i.qty,
                points: i.points,
                unitPrice: i.unitPrice,
              ),
            )
            .toList(),
      );
}
