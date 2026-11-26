import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'app_destination.dart';

/// Cadre commun des écrans : `NavigationBar` en bas sur téléphone,
/// `NavigationRail` sur le côté sur écran large (PC, tablette).
class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Largeur à partir de laquelle on passe de la barre du bas au rail latéral.
  static const double wideLayoutMinWidth = 600;

  void _goToDestination(int index) => navigationShell.goBranch(
        index,
        // Re-toucher l'onglet actif revient à sa racine.
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= wideLayoutMinWidth;
    final selectedIndex = navigationShell.currentIndex;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: _goToDestination,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final d in AppDestination.values)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: _goToDestination,
        destinations: [
          for (final d in AppDestination.values)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
