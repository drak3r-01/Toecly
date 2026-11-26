import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// The 5 main screens, in navigation order.
enum AppDestination {
  dashboard('/', Icons.dashboard_outlined, Icons.dashboard),
  practice('/practice', Icons.fitness_center_outlined, Icons.fitness_center),
  mockExam('/mock-exam', Icons.timer_outlined, Icons.timer),
  review('/review', Icons.replay_outlined, Icons.replay),
  settings('/settings', Icons.settings_outlined, Icons.settings);

  const AppDestination(this.path, this.icon, this.selectedIcon);

  final String path;
  final IconData icon;
  final IconData selectedIcon;

  String label(AppLocalizations l10n) => switch (this) {
        dashboard => l10n.navHome,
        practice => l10n.navPractice,
        mockExam => l10n.navMockExam,
        review => l10n.navReview,
        settings => l10n.navSettings,
      };
}
