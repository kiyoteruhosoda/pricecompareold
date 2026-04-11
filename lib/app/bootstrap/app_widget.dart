import 'package:flutter/material.dart';
import 'package:pricecompare/app/bootstrap/app_router.dart';
import 'package:pricecompare/app/di/service_locator.dart';
import 'package:pricecompare/presentation/pages/compare_page.dart';
import 'package:pricecompare/presentation/pages/splash_page.dart';
import 'package:pricecompare/presentation/viewmodels/theme_viewmodel.dart';
import 'package:pricecompare/shared/l10n/app_strings.dart';
import 'package:pricecompare/shared/logging/app_logger.dart';
import 'package:pricecompare/shared/theme/app_theme.dart';

/// Root widget. Listens to [ThemeViewModel] for live theme switching.
class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> with WidgetsBindingObserver {
  bool _showSplash = true;
  late final AppLogger _logger;

  @override
  void initState() {
    super.initState();
    _logger = sl<AppLogger>();
    WidgetsBinding.instance.addObserver(this);
    _logger.info('[App] AppWidget initialised');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _logger.debug('[App] Lifecycle → ${state.name}');
  }

  void _onSplashComplete() {
    _logger.info('[App] Splash complete — navigating to main');
    setState(() => _showSplash = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeViewModel = sl<ThemeViewModel>();
    return ListenableBuilder(
      listenable: themeViewModel,
      builder: (context, _) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeViewModel.themeMode,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: _showSplash
              ? SplashPage(onComplete: _onSplashComplete)
              : const ComparePage(),
        );
      },
    );
  }
}
