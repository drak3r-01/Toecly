import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/theme/brand_colors.dart';

/// Soft yellow / peach / coral glows behind the app. With [animated] they drift
/// very slowly (off in tests, where an endless animation would never settle).
class BrandBackground extends StatefulWidget {
  const BrandBackground({super.key, this.animated = false});

  final bool animated;

  @override
  State<BrandBackground> createState() => _BrandBackgroundState();
}

class _BrandBackgroundState extends State<BrandBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 28),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animated) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: CustomPaint(
        painter: _GlowPainter(strength: isDark ? 0.16 : 0.45, phase: _controller),
        size: Size.infinite,
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter({required this.strength, required this.phase}) : super(repaint: phase);

  final double strength;
  final Animation<double> phase;

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
    final t = phase.value * 2 * math.pi;
    // Each glow circles slowly around its home spot.
    Offset drift(double x, double y, double turns, double offset) => Offset(
      size.width * x + math.sin(t * turns + offset) * size.width * 0.06,
      size.height * y + math.cos(t * turns + offset) * size.height * 0.04,
    );
    glow(drift(0.1, 0, 1, 0), longest * 0.45, BrandColors.sun);
    glow(drift(1.0, 0.55, 1, 2), longest * 0.35, BrandColors.peach);
    glow(drift(0.2, 1, 2, 4), longest * 0.35, BrandColors.coral);
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.strength != strength;
}
