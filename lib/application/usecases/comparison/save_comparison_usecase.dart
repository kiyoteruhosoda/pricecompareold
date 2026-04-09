import 'package:flutterbase/application/dto/saved_comparison_dto.dart';
import 'package:flutterbase/domain/entities/saved_comparison.dart';
import 'package:flutterbase/domain/repositories/saved_comparison_repository.dart';

class SaveComparisonUseCase {
  SaveComparisonUseCase(this._repository);

  final SavedComparisonRepository _repository;

  Future<void> execute(SavedComparisonDto dto) async {
    final entity = SavedComparison(
      id: dto.id,
      title: dto.title,
      savedAt: dto.savedAt,
      items: dto.items
          .map(
            (i) => SavedComparisonItem(
              label: i.label,
              price: i.price,
              qty: i.qty,
              points: i.points,
              unitPrice: i.unitPrice,
            ),
          )
          .toList(),
    );
    await _repository.save(entity);
  }
}
