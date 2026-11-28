import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import 'app_destination.dart';

/// Floating pill navigation bar. A warm bubble slides (with a small overshoot,
/// like a liquid) behind the selected tab, whose icon bounces.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key, required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const double _height = 68;
  static const double _inset = 6;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const destinations = AppDestination.values;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Container(
          height: _height,
          padding: const EdgeInsets.all(_inset),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(_height),
            border: Border.all(color: scheme.primary.withValues(alpha: isDark ? 0.2 : 0.14)),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: isDark ? 0.14 : 0.22),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final slot = constraints.maxWidth / destinations.length;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutBack,
                    left: slot * selectedIndex,
                    width: slot,
                    top: 0,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_height),
                        gradient: LinearGradient(
                          colors: [scheme.primaryContainer, scheme.primary.withValues(alpha: 0.55)],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (final (i, d) in destinations.indexed)
                        Expanded(
                          child: _NavItem(
                            icon: d.icon,
                            selectedIcon: d.selectedIcon,
                            label: d.label(l10n),
                            selected: i == selectedIndex,
                            onTap: () => onSelected(i),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(FloatingNavBar._height),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The icon pops each time its tab becomes selected.
            TweenAnimationBuilder<double>(
              key: ValueKey(selected),
              tween: Tween(begin: selected ? 0.7 : 1, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: Icon(selected ? selectedIcon : icon, size: 24, color: onSurface),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: onSurface.withValues(alpha: selected ? 1 : 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
