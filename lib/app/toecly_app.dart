import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'app_router.dart';
import 'settings/settings_providers.dart';
import 'splash/splash_overlay.dart';
import 'theme/app_theme.dart';

class ToeclyApp extends ConsumerStatefulWidget {
  const ToeclyApp({super.key, this.showSplash = false});

  /// Plays the animated splash over the app (off in tests).
  final bool showSplash;

  @override
  ConsumerState<ToeclyApp> createState() => _ToeclyAppState();
}

class _ToeclyAppState extends ConsumerState<ToeclyApp> {
  final GoRouter _router = createAppRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      locale: ref.watch(localeProvider),
      localizationsDelegates: [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
      builder: (context, child) => widget.showSplash ? SplashOverlay(child: child!) : child!,
    );
  }
}
