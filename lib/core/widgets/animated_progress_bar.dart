import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'replay_scope.dart';

/// Rounded bar that fills like a liquid, from 0 to [value] (0.0 to 1.0): the
/// leading edge ripples while it rises and settles flat. It plays again each
/// time the user arrives on a tab (see [ReplayScope]).
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({super.key, required this.value, this.height = 12, this.color});

  final double value;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = color ?? scheme.primary;
    return TweenAnimationBuilder<double>(
      key: ValueKey(ReplayScope.of(context)),
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => CustomPaint(
        size: Size(double.infinity, height),
        painter: _LiquidBarPainter(
          value: animated,
          target: value.clamp(0.0, 1.0),
          track: scheme.surfaceContainerHighest,
          fill: fill,
        ),
      ),
    );
  }
}

class _LiquidBarPainter extends CustomPainter {
  const _LiquidBarPainter({
    required this.value,
    required this.target,
    required this.track,
    required this.fill,
  });

  final double value;
  final double target;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final bar = RRect.fromRectAndRadius(Offset.zero & size, radius);
    canvas.drawRRect(bar, Paint()..color = track);
    if (value <= 0) return;

    canvas.save();
    canvas.clipRRect(bar);
    final edge = size.width * value;
    // The ripple fades out as the fill reaches its target.
    final remaining = target == 0 ? 0.0 : (1 - value / target).clamp(0.0, 1.0);
    final amplitude = size.height * 0.45 * math.sqrt(remaining);
    final path = Path()..moveTo(0, 0);
    path.lineTo(edge - amplitude, 0);
    const steps = 12;
    for (var i = 1; i <= steps; i++) {
      final y = size.height * i / steps;
      final x = edge + amplitude * math.sin(i * 1.3 + value * 25) - amplitude;
      path.lineTo(x, y);
    }
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(colors: [fill.withValues(alpha: 0.65), fill])
            .createShader(Offset.zero & size),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LiquidBarPainter old) =>
      old.value != value || old.fill != fill || old.track != track || old.target != target;
}
