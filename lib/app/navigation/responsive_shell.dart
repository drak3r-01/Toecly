import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/widgets/replay_scope.dart';
import '../../core/widgets/toecly_logo.dart';
import '../../l10n/app_localizations.dart';
import 'app_destination.dart';

/// Common frame: `NavigationBar` at the bottom on phones,
/// `NavigationRail` on the side on wide screens (PC, tablet).
class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Width from which the bottom bar becomes a side rail.
  static const double wideLayoutMinWidth = 600;

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  StatefulNavigationShell get navigationShell => widget.navigationShell;

  /// Bumped on each tab change so the bars and gauges of the new tab replay.
  int _epoch = 0;

  @override
  void didUpdateWidget(ResponsiveShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex != widget.navigationShell.currentIndex) {
      _epoch++;
    }
  }

  void _goToDestination(int index) => navigationShell.goBranch(
    index,
    // Tapping the active tab again goes back to its root.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) =>
      ReplayScope(epoch: _epoch, child: _frame(context));

  Widget _frame(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= ResponsiveShell.wideLayoutMinWidth;
    final selectedIndex = navigationShell.currentIndex;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: _goToDestination,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: ToeclyLogo(size: 48),
              ),
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
