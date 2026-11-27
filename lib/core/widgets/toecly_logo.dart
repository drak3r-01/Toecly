import 'dart:math' as math;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// The Toecly logo. Without [reveal] it is the plain SVG; with it, the three
/// layers (book, cap, tassel) enter one after the other as it runs 0 to 1.
class ToeclyLogo extends StatelessWidget {
  const ToeclyLogo({super.key, this.size = 96, this.reveal});

  final double size;
  final Animation<double>? reveal;

  @override
  Widget build(BuildContext context) {
    final animation = reveal;
    if (animation == null) {
      return SvgPicture.asset('assets/brand/logo.svg', width: size, height: size);
    }
    return SizedBox.square(
      dimension: size,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          double phase(double from, double to, [Curve curve = Curves.easeOutCubic]) =>
              curve.transform(Interval(from, to).transform(animation.value));
          final book = phase(0, 0.5);
          final cap = phase(0.25, 0.75, Curves.easeOutBack);
          final tassel = phase(0.6, 1, Curves.elasticOut);
          Widget layer(String name) =>
              SvgPicture.asset('assets/brand/logo_$name.svg', width: size, height: size);
          return Stack(
            children: [
              Opacity(
                opacity: book.clamp(0, 1),
                child: Transform.translate(
                  offset: Offset(0, (1 - book) * size * 0.18),
                  child: layer('book'),
                ),
              ),
              Opacity(
                opacity: phase(0.25, 0.5).clamp(0, 1),
                child: Transform.translate(
                  offset: Offset(0, -(1 - cap) * size * 0.3),
                  child: layer('cap'),
                ),
              ),
              // The tassel swings from the corner of the board.
              Opacity(
                opacity: phase(0.6, 0.75).clamp(0, 1),
                child: Transform.rotate(
                  angle: (1 - tassel) * math.pi / 5,
                  alignment: const Alignment(-0.75, -0.43),
                  child: layer('tassel'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
