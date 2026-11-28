import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/theme/brand_colors.dart';

/// One-shot burst of pastel confetti from the center of its box. It plays once
/// when built, then stops (no pending animation left).
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, this.particles = 22, this.spread = 90});

  final int particles;

  /// How far the confetti flies, in logical pixels.
  final double spread;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  static const _colors = [
    BrandColors.sun,
    BrandColors.amber,
    BrandColors.coral,
    BrandColors.teal,
    BrandColors.peach,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        painter: _ConfettiPainter(_controller, widget.particles, widget.spread),
        size: Size.infinite,
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.animation, this.count, this.spread) : super(repaint: animation);

  final Animation<double> animation;
  final int count;
  final double spread;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeOutCubic.transform(animation.value);
    final fade = (1 - animation.value).clamp(0.0, 1.0);
    final center = size.center(Offset.zero);
    for (var i = 0; i < count; i++) {
      // Deterministic spread: golden-angle directions, varied distance and size.
      final angle = i * 2.399963;
      final distance = spread * (0.45 + 0.55 * ((i * 37) % 10) / 10) * t;
      final gravity = 30 * animation.value * animation.value;
      final position =
          center + Offset(math.cos(angle), math.sin(angle)) * distance + Offset(0, gravity);
      final paint = Paint()
        ..color = _ConfettiBurstState._colors[i % _ConfettiBurstState._colors.length].withValues(
          alpha: fade,
        );
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(angle + animation.value * 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 7 + (i % 3) * 2, height: 4),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}
