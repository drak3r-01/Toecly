import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import 'app_destination.dart';

/// Common frame: `NavigationBar` at the bottom on phones,
/// `NavigationRail` on the side on wide screens (PC, tablet).
class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Width from which the bottom bar becomes a side rail.
  static const double wideLayoutMinWidth = 600;

  void _goToDestination(int index) => navigationShell.goBranch(
        index,
        // Tapping the active tab again goes back to its root.
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                    label: Text(d.label(l10n)),
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
              label: d.label(l10n),
            ),
        ],
      ),
    );
  }
}
