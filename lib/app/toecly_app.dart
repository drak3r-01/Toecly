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
  const ToeclyApp({super.key, this.showSplash = false, this.animateBackground = false});

  /// Plays the animated splash over the app (off in tests).
  final bool showSplash;

  /// Lets the background glows drift forever (off in tests: it would never settle).
  final bool animateBackground;

  @override
  ConsumerState<ToeclyApp> createState() => _ToeclyAppState();
}

class _ToeclyAppState extends ConsumerState<ToeclyApp> {
  final GoRouter _router = createAppRouter();

  @override
  void initState() {
    super.initState();
    ref.read(questionCountsProvider); // count the question bank at startup
    ref.read(hapticsProvider); // load the saved setting
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
        final media = MediaQuery.of(context);
        final backdrop = ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: Stack(
            children: [
              Positioned.fill(child: BrandBackground(animated: widget.animateBackground)),
              Positioned.fill(child: child!),
            ],
          ),
        );
        final app = MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(
              media.textScaler.scale(1) * ref.watch(textSizeProvider).factor,
            ),
          ),
          child: backdrop,
        );
        return widget.showSplash ? SplashOverlay(child: app) : app;
      },
    );
  }
}
