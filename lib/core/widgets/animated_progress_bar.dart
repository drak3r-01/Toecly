import 'package:material_ui/material_ui.dart';

/// Barre de progression qui s'anime vers sa valeur (0.0 à 1.0).
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({super.key, required this.value, this.height = 12});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) => ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: LinearProgressIndicator(value: animatedValue, minHeight: height),
      ),
    );
  }
}
