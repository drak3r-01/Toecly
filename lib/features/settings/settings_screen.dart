import 'package:material_ui/material_ui.dart';

import '../../app/app_services.dart';

/// Réglages : pour l'instant, le choix du thème (clair / sombre / système).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).themeModeController;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Réglages', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thème'),
                const SizedBox(height: 12),
                ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) => SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.system, label: Text('Auto'), icon: Icon(Icons.brightness_auto)),
                      ButtonSegment(value: ThemeMode.light, label: Text('Clair'), icon: Icon(Icons.light_mode)),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Sombre'), icon: Icon(Icons.dark_mode)),
                    ],
                    selected: {controller.themeMode},
                    onSelectionChanged: (selection) => controller.setThemeMode(selection.first),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
