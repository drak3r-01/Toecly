import 'package:material_ui/material_ui.dart';

import '../../app/theme/brand_colors.dart';

/// Rounded card for the key figure of a screen (score, result): a soft white
/// to cream gradient (warm dark in the dark theme) with one small colored glow.
class BrandHeroCard extends StatelessWidget {
  const BrandHeroCard({super.key, required this.child, this.padding = const EdgeInsets.all(24)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [BrandColors.cocoaRaised, BrandColors.cocoa]
              : const [Colors.white, Color(0xFFFFF3E1)],
        ),
        border: Border.all(color: BrandColors.amber.withValues(alpha: isDark ? 0.25 : 0.35)),
        boxShadow: [
          BoxShadow(
            color: BrandColors.amber.withValues(alpha: isDark ? 0.12 : 0.28),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // The colored glow, tucked in the top-right corner.
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      BrandColors.sun.withValues(alpha: isDark ? 0.18 : 0.55),
                      BrandColors.sun.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}
