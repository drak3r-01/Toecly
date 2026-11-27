import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/theme/brand_colors.dart';

/// Three-quarter ring that fills to [value] (0.0 to 1.0) with a brand
/// gradient. Put the label in [child].
class ScoreGauge extends StatelessWidget {
  const ScoreGauge({super.key, required this.value, this.size = 140, this.child});

  final double value;
  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _GaugePainter(animated),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter(this.value);

  final double value;

  static const double _start = 3 * math.pi / 4;
  static const double _sweep = 3 * math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arc, _start, _sweep, false, paint..color = Colors.white.withValues(alpha: 0.18));
    if (value <= 0) return;
    canvas.drawArc(
      arc,
      _start,
      _sweep * value,
      false,
      paint
        ..shader = const SweepGradient(
          startAngle: _start,
          endAngle: _start + _sweep,
          colors: [BrandColors.orange, Colors.white, BrandColors.lime],
          transform: GradientRotation(0),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value;
}
