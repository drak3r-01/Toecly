import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'app_router.dart';
import 'app_services.dart';
import 'theme/app_theme.dart';

class ToeclyApp extends StatefulWidget {
  const ToeclyApp({super.key, required this.services});

  final AppServices services;

  @override
  State<ToeclyApp> createState() => _ToeclyAppState();
}

class _ToeclyAppState extends State<ToeclyApp> {
  final GoRouter _router = createAppRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: widget.services,
      child: ListenableBuilder(
        listenable: widget.services.themeModeController,
        builder: (context, _) => MaterialApp.router(
          title: 'Toecly',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: widget.services.themeModeController.themeMode,
          routerConfig: _router,
        ),
      ),
    );
  }
}
