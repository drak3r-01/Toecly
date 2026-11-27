import 'package:material_ui/material_ui.dart';

/// Toecly palette, taken from the green and orange book of the logo (the blue stays in the logo only).
class BrandColors {
  const BrandColors._();

  static const Color lime = Color(0xFF7DF53A);
  static const Color green = Color(0xFF1FC96F);
  static const Color teal = Color(0xFF05A88A);
  static const Color forest = Color(0xFF0B7A46);
  static const Color orange = Color(0xFFFF7A1A);

  /// Forest night behind the splash and the dark theme.
  static const Color ink = Color(0xFF08201A);
  static const Color inkRaised = Color(0xFF0F2F26);

  static const LinearGradient wordmarkGradient = LinearGradient(colors: [lime, teal, orange]);

  /// One accent per TOEIC part, reused on the dashboard and in the quiz.
  static const List<Color> partAccents = [green, orange, teal];
}
