import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'app_router.dart';
import '../core/widgets/brand_background.dart';
import 'providers.dart';
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
  void initState() {
    super.initState();
    ref.read(questionCountsProvider); // count the question bank at startup
  }

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
      builder: (context, child) {
        final backdrop = ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: Stack(children: [
            const Positioned.fill(child: BrandBackground()),
            Positioned.fill(child: child!),
          ]),
        );
        return widget.showSplash ? SplashOverlay(child: backdrop) : backdrop;
      },
    );
  }
}
