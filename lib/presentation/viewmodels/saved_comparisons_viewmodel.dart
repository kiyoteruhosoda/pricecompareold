import 'package:flutter/foundation.dart';
import 'package:pricecompare/application/dto/saved_comparison_dto.dart';
import 'package:pricecompare/application/usecases/comparison/delete_saved_comparison_usecase.dart';
import 'package:pricecompare/application/usecases/comparison/get_saved_comparisons_usecase.dart';
import 'package:pricecompare/shared/errors/app_error.dart';

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

  /// Attempts to delete the comparison with [id].
  ///
  /// Returns `true` on success so the caller can show a confirmation message.
  /// Returns `false` on failure and exposes the error via [appError].
  /// The underlying storage exception is **never swallowed** silently.
  Future<bool> delete(String id) async {
    try {
      await _delete.execute(id);
      comparisons.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      appError = UnexpectedError(e.toString());
      notifyListeners();
      return false;
    }
  }
}
