import 'package:flutter/foundation.dart';
import 'package:pricecompare/application/usecases/saved_comparisons/delete_saved_comparison_usecase.dart';
import 'package:pricecompare/application/usecases/saved_comparisons/get_saved_comparisons_usecase.dart';
import 'package:pricecompare/application/usecases/saved_comparisons/save_comparison_usecase.dart';
import 'package:pricecompare/domain/entities/saved_comparison.dart';
import 'package:pricecompare/shared/errors/app_error.dart';
import 'package:pricecompare/shared/logging/app_logger.dart';

/// UI state for [SavedComparisonsPage].
enum SavedComparisonsState { loading, loaded, error }

/// ViewModel for the Saved Comparisons screen.
///
/// ### Delete contract
/// [delete] returns `true` only when the record is confirmed removed from
/// storage. On any storage failure it captures the error in [deleteError],
/// notifies listeners, and returns `false` — it never swallows the exception
/// silently. The page must check the return value before showing a success
/// message.
class SavedComparisonsViewModel extends ChangeNotifier {
  SavedComparisonsViewModel(
    this._getAll,
    this._save,
    this._delete,
    this._logger,
  );

  final GetSavedComparisonsUseCase _getAll;
  final SaveComparisonUseCase _save;
  final DeleteSavedComparisonUseCase _delete;
  final AppLogger _logger;

  SavedComparisonsState _state = SavedComparisonsState.loading;
  List<SavedComparison> _items = [];
  AppError? _error;
  AppError? _deleteError;

  SavedComparisonsState get state => _state;
  List<SavedComparison> get items => List.unmodifiable(_items);
  AppError? get error => _error;

  /// Set when the most recent [delete] call failed; `null` otherwise.
  AppError? get deleteError => _deleteError;

  // ── Load ───────────────────────────────────────────────────────────────

  Future<void> load() async {
    _logger.debug('[SavedComparisonsViewModel] load start');
    _state = SavedComparisonsState.loading;
    _error = null;
    notifyListeners();

    try {
      _items = await _getAll.execute();
      _state = SavedComparisonsState.loaded;
      _logger.debug('[SavedComparisonsViewModel] load success — ${_items.length} items');
    } catch (e, st) {
      _error = UnexpectedError('Failed to load saved comparisons', cause: e, stackTrace: st);
      _state = SavedComparisonsState.error;
      _logger.error('[SavedComparisonsViewModel] load failed', error: e, stackTrace: st);
    } finally {
      notifyListeners();
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────

  Future<bool> save(SavedComparison comparison) async {
    _logger.debug('[SavedComparisonsViewModel] save: ${comparison.id}');
    try {
      await _save.execute(comparison);
      _items = [comparison, ..._items];
      notifyListeners();
      _logger.debug('[SavedComparisonsViewModel] save success');
      return true;
    } catch (e, st) {
      _logger.error('[SavedComparisonsViewModel] save failed', error: e, stackTrace: st);
      return false;
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────

  /// Attempts to permanently delete the comparison with the given [id].
  ///
  /// Returns `true` on success so the caller can show a confirmation message.
  /// Returns `false` on failure and exposes the error via [deleteError] so
  /// the caller can show an appropriate error message.
  ///
  /// The underlying storage exception is **never swallowed** — it is always
  /// captured in [deleteError] and logged.
  Future<bool> delete(String id) async {
    _logger.debug('[SavedComparisonsViewModel] delete: $id');
    _deleteError = null;

    try {
      await _delete.execute(id);
      _items.removeWhere((c) => c.id == id);
      notifyListeners();
      _logger.debug('[SavedComparisonsViewModel] delete success: $id');
      return true;
    } catch (e, st) {
      _deleteError = e is AppError
          ? e
          : UnexpectedError('Failed to delete comparison', cause: e, stackTrace: st);
      _logger.error('[SavedComparisonsViewModel] delete failed: $id', error: e, stackTrace: st);
      notifyListeners();
      return false;
    }
  }
}
