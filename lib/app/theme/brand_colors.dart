import 'package:material_ui/material_ui.dart';

/// Toecly palette: warm sunshine tones (yellow, amber, orange, coral) on
/// cream, plus one small teal accent. The blue of the logo stays in the logo.
class BrandColors {
  const BrandColors._();

  static const Color sun = Color(0xFFFFC53D);
  static const Color amber = Color(0xFFFFA62B);
  static const Color orange = Color(0xFFF2780C);
  static const Color coral = Color(0xFFFF6B5E);
  static const Color teal = Color(0xFF2BB5A0);

  static const Color cream = Color(0xFFFFF8EE);
  static const Color peach = Color(0xFFFFE3C4);

  /// Warm browns, for text and the dark theme.
  static const Color cocoa = Color(0xFF241810);
  static const Color cocoaRaised = Color(0xFF33241A);

  /// One accent per TOEIC part, reused on the dashboard.
  static const List<Color> partAccents = [amber, coral, teal];
}
