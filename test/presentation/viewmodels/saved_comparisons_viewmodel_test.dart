import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pricecompare/application/usecases/saved_comparisons/delete_saved_comparison_usecase.dart';
import 'package:pricecompare/application/usecases/saved_comparisons/get_saved_comparisons_usecase.dart';
import 'package:pricecompare/application/usecases/saved_comparisons/save_comparison_usecase.dart';
import 'package:pricecompare/domain/entities/saved_comparison.dart';
import 'package:pricecompare/domain/repositories/saved_comparison_repository.dart';
import 'package:pricecompare/domain/value_objects/saved_comparison_row.dart';
import 'package:pricecompare/presentation/viewmodels/saved_comparisons_viewmodel.dart';
import 'package:pricecompare/shared/errors/app_error.dart';
import 'package:pricecompare/shared/logging/app_logger.dart';
import 'package:pricecompare/shared/logging/log_entry.dart';
import 'package:pricecompare/shared/logging/log_level.dart';

// ─── Fakes ───────────────────────────────────────────────────────────────────

class _FakeRepo implements SavedComparisonRepository {
  _FakeRepo({List<SavedComparison>? initial, bool throwOnDelete = false})
      : _items = List.of(initial ?? []),
        _throwOnDelete = throwOnDelete;

  final List<SavedComparison> _items;
  final bool _throwOnDelete;

  @override
  Future<List<SavedComparison>> getAll() async => List.unmodifiable(_items);

  @override
  Future<void> save(SavedComparison comparison) async =>
      _items.insert(0, comparison);

  @override
  Future<void> delete(String id) async {
    if (_throwOnDelete) {
      throw InfrastructureError('DB locked', cause: Exception('locked'));
    }
    _items.removeWhere((c) => c.id == id);
  }
}

class _NoOpLogger implements AppLogger {
  @override
  void verbose(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void clearBuffer() {}
  @override
  void setMinLevel(LogLevel level) {}
  @override
  List<LogEntry> get entries => [];
  @override
  List<LogEntry> entriesForLevel(LogLevel? level) => [];
  @override
  Future<String?> exportLogs() async => null;
  @override
  LogLevel get minLevel => LogLevel.verbose;
  @override
  Future<List<File>> logFiles() async => [];
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

SavedComparison _makeComparison({String id = 'id-1', String name = 'Test'}) {
  return SavedComparison(
    id: id,
    name: name,
    rows: [
      const SavedComparisonRow(label: 'A', price: 100, qty: 2, points: 0),
    ],
    createdAt: DateTime(2024),
  );
}

SavedComparisonsViewModel _makeViewModel({
  List<SavedComparison>? initial,
  bool throwOnDelete = false,
}) {
  final repo = _FakeRepo(
    initial: initial,
    throwOnDelete: throwOnDelete,
  );
  return SavedComparisonsViewModel(
    GetSavedComparisonsUseCase(repo),
    SaveComparisonUseCase(repo),
    DeleteSavedComparisonUseCase(repo),
    _NoOpLogger(),
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('SavedComparisonsViewModel — load', () {
    test('transitions from loading to loaded', () async {
      final vm = _makeViewModel(initial: [_makeComparison()]);
      expect(vm.state, equals(SavedComparisonsState.loading));
      await vm.load();
      expect(vm.state, equals(SavedComparisonsState.loaded));
    });

    test('exposes items after successful load', () async {
      final vm = _makeViewModel(initial: [_makeComparison()]);
      await vm.load();
      expect(vm.items, hasLength(1));
      expect(vm.items.first.id, equals('id-1'));
    });

    test('notifies listeners on load', () async {
      final vm = _makeViewModel();
      var count = 0;
      vm.addListener(() => count++);
      await vm.load();
      expect(count, greaterThan(0));
    });
  });

  group('SavedComparisonsViewModel — delete (success)', () {
    test('returns true when deletion succeeds', () async {
      final vm = _makeViewModel(initial: [_makeComparison()]);
      await vm.load();
      final result = await vm.delete('id-1');
      expect(result, isTrue);
    });

    test('removes item from list on success', () async {
      final vm = _makeViewModel(initial: [_makeComparison()]);
      await vm.load();
      await vm.delete('id-1');
      expect(vm.items, isEmpty);
    });

    test('deleteError is null after successful delete', () async {
      final vm = _makeViewModel(initial: [_makeComparison()]);
      await vm.load();
      await vm.delete('id-1');
      expect(vm.deleteError, isNull);
    });

    test('notifies listeners on successful delete', () async {
      final vm = _makeViewModel(initial: [_makeComparison()]);
      await vm.load();
      var notified = false;
      vm.addListener(() => notified = true);
      await vm.delete('id-1');
      expect(notified, isTrue);
    });
  });

  group('SavedComparisonsViewModel — delete (failure)', () {
    test('returns false when storage throws', () async {
      final vm = _makeViewModel(
        initial: [_makeComparison()],
        throwOnDelete: true,
      );
      await vm.load();
      final result = await vm.delete('id-1');
      expect(result, isFalse);
    });

    test('sets deleteError when storage throws', () async {
      final vm = _makeViewModel(
        initial: [_makeComparison()],
        throwOnDelete: true,
      );
      await vm.load();
      await vm.delete('id-1');
      expect(vm.deleteError, isNotNull);
    });

    test('does NOT remove item from list when storage throws', () async {
      final vm = _makeViewModel(
        initial: [_makeComparison()],
        throwOnDelete: true,
      );
      await vm.load();
      await vm.delete('id-1');
      // Item must still be present — deletion did not actually succeed.
      expect(vm.items, hasLength(1));
    });

    test('notifies listeners even on failure', () async {
      final vm = _makeViewModel(
        initial: [_makeComparison()],
        throwOnDelete: true,
      );
      await vm.load();
      var notified = false;
      vm.addListener(() => notified = true);
      await vm.delete('id-1');
      expect(notified, isTrue);
    });

    test('deleteError is cleared on subsequent successful delete', () async {
      final successRepo = _FakeRepo(initial: [_makeComparison(id: 'a'), _makeComparison(id: 'b')]);
      final errorThenOkRepo = _ToggleErrorRepo(successRepo, throwOn: 0);

      final vm = SavedComparisonsViewModel(
        GetSavedComparisonsUseCase(errorThenOkRepo),
        SaveComparisonUseCase(errorThenOkRepo),
        DeleteSavedComparisonUseCase(errorThenOkRepo),
        _NoOpLogger(),
      );

      await vm.load();

      // First delete should fail.
      final firstResult = await vm.delete('a');
      expect(firstResult, isFalse);
      expect(vm.deleteError, isNotNull);

      // Second delete should succeed and clear deleteError.
      final secondResult = await vm.delete('b');
      expect(secondResult, isTrue);
      expect(vm.deleteError, isNull);
    });
  });
}

/// Repository that throws on the first [delete] call, then succeeds.
class _ToggleErrorRepo implements SavedComparisonRepository {
  _ToggleErrorRepo(this._delegate, {required int throwOn})
      : _throwOn = throwOn;

  final _FakeRepo _delegate;
  final int _throwOn;
  int _callCount = 0;

  @override
  Future<List<SavedComparison>> getAll() => _delegate.getAll();

  @override
  Future<void> save(SavedComparison comparison) => _delegate.save(comparison);

  @override
  Future<void> delete(String id) async {
    if (_callCount == _throwOn) {
      _callCount++;
      throw InfrastructureError('DB locked');
    }
    _callCount++;
    return _delegate.delete(id);
  }
}
