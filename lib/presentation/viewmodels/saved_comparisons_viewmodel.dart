import 'package:flutter/foundation.dart';
import 'package:flutterbase/application/dto/saved_comparison_dto.dart';
import 'package:flutterbase/application/usecases/comparison/delete_saved_comparison_usecase.dart';
import 'package:flutterbase/application/usecases/comparison/get_saved_comparisons_usecase.dart';
import 'package:flutterbase/shared/errors/app_error.dart';

enum SavedComparisonsState { loading, loaded, error }

class SavedComparisonsViewModel extends ChangeNotifier {
  SavedComparisonsViewModel(this._getAll, this._delete);

  final GetSavedComparisonsUseCase _getAll;
  final DeleteSavedComparisonUseCase _delete;

  SavedComparisonsState state = SavedComparisonsState.loading;
  List<SavedComparisonDto> comparisons = [];
  AppError? appError;

  Future<void> load() async {
    state = SavedComparisonsState.loading;
    notifyListeners();
    try {
      comparisons = await _getAll.execute();
      state = SavedComparisonsState.loaded;
    } catch (e) {
      appError = UnexpectedError(e.toString());
      state = SavedComparisonsState.error;
    }
    notifyListeners();
  }

  Future<void> delete(String id) async {
    try {
      await _delete.execute(id);
      comparisons.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      appError = UnexpectedError(e.toString());
      state = SavedComparisonsState.error;
      notifyListeners();
    }
  }
}
