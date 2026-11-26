import 'package:material_ui/material_ui.dart';

/// Les 5 écrans principaux, dans l'ordre d'affichage de la navigation.
enum AppDestination {
  dashboard('/', 'Accueil', Icons.dashboard_outlined, Icons.dashboard),
  practice('/entrainement', 'Entraînement', Icons.fitness_center_outlined, Icons.fitness_center),
  mockExam('/examen-blanc', 'Examen blanc', Icons.timer_outlined, Icons.timer),
  review('/revision', 'Révision', Icons.replay_outlined, Icons.replay),
  settings('/reglages', 'Réglages', Icons.settings_outlined, Icons.settings);

  const AppDestination(this.path, this.label, this.icon, this.selectedIcon);

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
