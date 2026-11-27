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
    final scheme = ColorScheme.fromSeed(seedColor: BrandColors.amber, brightness: brightness)
        .copyWith(
          primary: isDark ? const Color(0xFFFFB454) : const Color(0xFFF28A0F),
          onPrimary: BrandColors.cocoa,
          secondary: isDark ? const Color(0xFFFF8A75) : const Color(0xFFE5483A),
          tertiary: isDark ? const Color(0xFF4FD6C0) : const Color(0xFF16907F),
          surface: isDark ? BrandColors.cocoa : BrandColors.cream,
          onSurface: isDark ? const Color(0xFFFFF1E0) : BrandColors.cocoa,
          surfaceContainerLow: isDark ? BrandColors.cocoaRaised : Colors.white,
          surfaceContainer: isDark ? BrandColors.cocoaRaised : Colors.white,
          surfaceContainerHighest: isDark ? const Color(0xFF4A3426) : const Color(0xFFFCEBD3),
          primaryContainer: isDark ? const Color(0xFF5A3A1E) : BrandColors.peach,
          onPrimaryContainer: isDark ? const Color(0xFFFFE3C4) : const Color(0xFF4A2A06),
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
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
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
