import 'package:pricecompare/domain/repositories/debug_settings_repository.dart';
import 'package:pricecompare/shared/logging/log_level.dart';

/// Returns persisted debug settings as plain values.
final class GetDebugSettingsUseCase {
  const GetDebugSettingsUseCase(this._repository);

  final DebugSettingsRepository _repository;

  bool executeDebugMode() => _repository.getDebugModeEnabled();
  LogLevel executeLogLevel() => _repository.getMinLogLevel();
}
