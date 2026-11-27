import 'package:material_ui/material_ui.dart';

import '../../app/theme/brand_colors.dart';

/// Rounded gradient card for the key figure of a screen (score, result).
/// Its content should be white.
class BrandHeroCard extends StatelessWidget {
  const BrandHeroCard({super.key, required this.child, this.padding = const EdgeInsets.all(24)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [BrandColors.forest, BrandColors.teal, BrandColors.ink],
        ),
        boxShadow: [
          BoxShadow(
            color: BrandColors.forest.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
