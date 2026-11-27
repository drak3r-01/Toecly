import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/theme/brand_colors.dart';
import 'replay_scope.dart';

/// Three-quarter ring that fills to [value] (0.0 to 1.0) with a brand
/// gradient. Put the label in [child].
class ScoreGauge extends StatelessWidget {
  const ScoreGauge({
    super.key,
    required this.value,
    this.size = 140,
    this.stroke = 14,
    this.colors = const [BrandColors.sun, BrandColors.orange, BrandColors.coral],
    this.child,
  });

  final double value;
  final double size;
  final double stroke;
  final List<Color> colors;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(ReplayScope.of(context)),
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _GaugePainter(
            animated,
            stroke: stroke,
            colors: colors,
            track: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.09),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter(
    this.value, {
    required this.stroke,
    required this.colors,
    required this.track,
  });

  final double value;
  final double stroke;
  final List<Color> colors;
  final Color track;

  static const double _start = 3 * math.pi / 4;
  static const double _sweep = 3 * math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arc, _start, _sweep, false, paint..color = track);
    if (value <= 0) return;
    canvas.drawArc(
      arc,
      _start,
      _sweep * value,
      false,
      paint
        ..color = Colors
            .black // a shader is multiplied by the paint's alpha
        ..shader = SweepGradient(
          // The ring spans 3/4 of the circle: spread the colors over that part.
          colors: [...colors, colors.last, colors.first, colors.first],
          stops: [
            for (var i = 0; i < colors.length; i++) 0.75 * i / (colors.length - 1),
            0.875, // the cap of the ring's start wraps around to here
            0.875,
            1,
          ],
          transform: const GradientRotation(_start),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.value != value || old.colors != colors || old.track != track;
}
