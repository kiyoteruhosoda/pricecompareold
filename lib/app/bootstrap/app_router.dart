import 'package:flutter/material.dart';
import 'package:pricecompare/app/di/service_locator.dart';
import 'package:pricecompare/presentation/pages/saved_comparisons_page.dart';
import 'package:pricecompare/presentation/pages/system/about_page.dart';
import 'package:pricecompare/presentation/pages/system/debug_page.dart';
import 'package:pricecompare/presentation/pages/system/licenses_page.dart';
import 'package:pricecompare/presentation/pages/system/logs_page.dart';
import 'package:pricecompare/shared/l10n/app_strings.dart';
import 'package:pricecompare/shared/logging/app_logger.dart';

/// Named route definitions.
class AppRouter {
  AppRouter._();

  static const String about = '/about';
  static const String licenses = '/licenses';
  static const String debug = '/debug';
  static const String logs = '/logs';
  static const String saved = '/saved';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    sl<AppLogger>().debug('[Router] → ${settings.name}');
    return switch (settings.name) {
      about => MaterialPageRoute<void>(
          builder: (_) => const AboutPage(),
          settings: settings,
        ),
      licenses => MaterialPageRoute<void>(
          builder: (_) => const LicensesPage(),
          settings: settings,
        ),
      debug => MaterialPageRoute<void>(
          builder: (_) => const DebugPage(),
          settings: settings,
        ),
      logs => MaterialPageRoute<void>(
          builder: (_) => const LogsPage(),
          settings: settings,
        ),
      saved => MaterialPageRoute<void>(
          builder: (_) => const SavedComparisonsPage(),
          settings: settings,
        ),
      _ => MaterialPageRoute<void>(
          builder: (_) => const _NotFoundPage(),
          settings: settings,
        ),
    };
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.commonPageNotFound)),
      body: const Center(child: Text(AppStrings.commonNotFound)),
    );
  }
}
