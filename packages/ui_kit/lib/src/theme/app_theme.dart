import 'package:flutter/material.dart';
import 'package:ui_kit/src/theme/color_theme.dart';
import 'package:ui_kit/src/theme/component_themes/card_theme_builder.dart';
import 'package:ui_kit/src/theme/component_themes/filled_button_theme_builder.dart';
import 'package:ui_kit/src/theme/component_themes/input_decoration_theme_builder.dart';
import 'package:ui_kit/src/theme/component_themes/outlined_button_theme_builder.dart';
import 'package:ui_kit/src/theme/themes/theme_variant.dart';
import 'package:ui_kit/src/theme/typography_theme.dart';

/// Assembles [ThemeData] from a [ThemeVariant].
///
/// ## MaterialApp setup
///
/// ```dart
/// MaterialApp.router(
///   theme:     AppTheme.fromVariant(const LightThemeVariant()),
///   darkTheme: AppTheme.fromVariant(const DarkThemeVariant()),
///   themeMode: ThemeMode.system,
///   builder:   AppTheme.builder,
/// )
/// ```
///
/// [builder] wraps the app in [ColorTheme] / [TypographyTheme] so tokens survive
/// [Navigator] route pushes (dialogs, sheets, overlays) via [InheritedTheme.wrap].
///
/// ## Adding a new theme
///
/// Create a [ThemeVariant] subclass. [AppTheme] never changes:
/// ```dart
/// final class SolarThemeVariant extends ThemeVariant { … }
/// AppTheme.fromVariant(const SolarThemeVariant())
/// ```
abstract final class AppTheme {
  /// [TransitionBuilder] for [MaterialApp.builder]. Static method reference —
  /// not a getter-closure — so [MaterialApp] sees a stable [Function].
  static TransitionBuilder get builder => _buildScope;

  /// Assembles [ThemeData] from [variant]. Never needs modification regardless
  /// of how many [ThemeVariant] implementations exist.
  ///
  /// Assemble **once** — hold the result in a `late final` field or a top-level
  /// constant. Do **not** call inside `build()`: [ColorThemeData] /
  /// [TypographyTokens] intentionally omit `==` (their lifecycle is tied to
  /// [ThemeData] identity), so a fresh call every frame produces unequal
  /// extensions and rebuilds the entire themed subtree.
  static ThemeData fromVariant(ThemeVariant variant) {
    final colorData = variant.colors.build();
    final typographyData = variant.typography.build();

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: colorData.brand,
          brightness: variant.brightness,
        ).copyWith(
          primary: colorData.brand,
          surface: colorData.bgCard,
          onSurface: colorData.textPrimary,
          onSurfaceVariant: colorData.textSecondary,
          surfaceContainerLowest: colorData.bgScaffold,
          surfaceContainerLow: colorData.bgCard,
          surfaceContainer: colorData.bgElevated,
          surfaceContainerHigh: colorData.bgElevated,
          surfaceContainerHighest: colorData.bgElevated,
          outline: colorData.border,
          outlineVariant: colorData.borderDim,
          error: colorData.error,
          // onPrimary / onError / secondary / tertiary: left to fromSeed
          // (contrast-aware). The primary CTA sets its own colors via
          // FilledButtonThemeBuilder.
        );

    final textTheme = TextTheme(
      displayLarge: typographyData.displayLarge,
      displayMedium: typographyData.displayMedium,
      headlineLarge: typographyData.headlineLarge,
      headlineMedium: typographyData.headlineMedium,
      headlineSmall: typographyData.headlineSmall,
      titleLarge: typographyData.titleLarge,
      titleMedium: typographyData.titleMedium,
      titleSmall: typographyData.titleSmall,
      bodyLarge: typographyData.bodyLarge,
      bodyMedium: typographyData.bodyMedium,
      bodySmall: typographyData.bodySmall,
      labelLarge: typographyData.labelLarge,
      labelMedium: typographyData.labelMedium,
      labelSmall: typographyData.labelSmall,
    );

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorData.bgScaffold,
      useMaterial3: true,
      extensions: [colorData, typographyData],
      cardTheme: CardThemeBuilder.build(colorData),
      filledButtonTheme: FilledButtonThemeBuilder.build(colorData),
      outlinedButtonTheme: OutlinedButtonThemeBuilder.build(colorData),
      inputDecorationTheme: InputDecorationThemeBuilder.build(colorData),
    );
  }

  static Widget _buildScope(BuildContext context, Widget? child) {
    if (child == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colorExt = theme.extension<ColorThemeData>();
    final typographyExt = theme.extension<TypographyTokens>();
    assert(
      colorExt != null && typographyExt != null,
      'AppTheme.builder requires AppTheme.fromVariant(...) in '
      'MaterialApp.theme / .darkTheme.',
    );
    // Fail-fast: misconfiguration surfaces at the first ColorTheme.of() call
    // with its own clear message — no arbitrary fallback that hides the error.
    if (colorExt == null || typographyExt == null) return child;

    return ColorTheme(
      data: colorExt,
      child: TypographyTheme(
        data: typographyExt,
        child: child,
      ),
    );
  }
}
