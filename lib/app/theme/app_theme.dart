import 'package:material_ui/material_ui.dart';

/// Thèmes Material 3 clair et sombre, générés depuis une couleur jaune/orange.
class AppTheme {
  const AppTheme._();

  static const Color seedColor = Color(0xFFFFA000);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
    final base = ThemeData(useMaterial3: true, colorScheme: colorScheme);

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        // Texte de lecture plus aéré pour les questions et passages.
        bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.5),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
