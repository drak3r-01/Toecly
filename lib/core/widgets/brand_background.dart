import 'package:material_ui/material_ui.dart';

import '../../app/theme/brand_colors.dart';

/// Soft green / teal / orange glows behind the app, painted once (no ticker).
class BrandBackground extends StatelessWidget {
  const BrandBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: CustomPaint(
        painter: _GlowPainter(strength: isDark ? 0.28 : 0.16),
        size: Size.infinite,
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter({required this.strength});

  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    void glow(Offset center, double radius, Color color) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: strength),
              color.withValues(alpha: 0),
            ],
          ).createShader(rect),
      );
    }

    final longest = size.longestSide;
    glow(Offset(size.width * 0.1, 0), longest * 0.45, BrandColors.green);
    glow(Offset(size.width * 1.0, size.height * 0.55), longest * 0.35, BrandColors.teal);
    glow(Offset(size.width * 0.2, size.height), longest * 0.35, BrandColors.orange);
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.strength != strength;
}
