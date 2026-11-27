import 'package:material_ui/material_ui.dart';

import 'brand_colors.dart';

/// Toecly light and dark themes: brand palette, bundled variable fonts
/// (Bricolage Grotesque for headings, Figtree for text) and rounded surfaces.
class AppTheme {
  const AppTheme._();

  static const String headingFont = 'BricolageGrotesque';
  static const String bodyFont = 'Figtree';

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(seedColor: BrandColors.green, brightness: brightness)
        .copyWith(
          primary: isDark ? const Color(0xFF3DDC8B) : BrandColors.forest,
          onPrimary: isDark ? BrandColors.ink : Colors.white,
          secondary: isDark ? const Color(0xFFFF9A4D) : const Color(0xFFD95F0A),
          tertiary: isDark ? const Color(0xFF2FD3B5) : const Color(0xFF04806B),
          surface: isDark ? BrandColors.ink : const Color(0xFFF6F8F2),
          onSurface: isDark ? const Color(0xFFEAF5EE) : BrandColors.ink,
          surfaceContainerLow: isDark ? BrandColors.inkRaised : Colors.white,
          surfaceContainer: isDark ? BrandColors.inkRaised : Colors.white,
          surfaceContainerHighest: isDark ? const Color(0xFF1B4536) : const Color(0xFFE4EEDF),
          primaryContainer: isDark ? const Color(0xFF14543C) : const Color(0xFFCDF1DC),
          onPrimaryContainer: isDark ? const Color(0xFFCDF1DC) : const Color(0xFF053B22),
        );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: bodyFont);

    TextStyle? heading(TextStyle? style, {double spacing = -0.5}) => style?.copyWith(
      fontFamily: headingFont,
      fontWeight: FontWeight.w700,
      letterSpacing: spacing,
    );
    final text = base.textTheme;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));

    return base.copyWith(
      // Transparent: the brand glow is painted once behind the whole navigator.
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      textTheme: text.copyWith(
        displayLarge: heading(text.displayLarge),
        displayMedium: heading(text.displayMedium),
        displaySmall: heading(text.displaySmall),
        headlineLarge: heading(text.headlineLarge),
        headlineMedium: heading(text.headlineMedium),
        headlineSmall: heading(text.headlineSmall, spacing: -0.25),
        titleLarge: heading(text.titleLarge, spacing: 0),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        // Airier reading text for questions and documents.
        bodyLarge: text.bodyLarge?.copyWith(height: 1.55),
        bodyMedium: text.bodyMedium?.copyWith(height: 1.55),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: shape.copyWith(
          side: BorderSide(color: scheme.primary.withValues(alpha: isDark ? 0.18 : 0.10)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: const StadiumBorder(),
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontFamily: bodyFont, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: const StadiumBorder(),
        selectedLabelTextStyle: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface),
        unselectedLabelTextStyle: TextStyle(fontWeight: FontWeight.w600, color: scheme.onSurface),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}
