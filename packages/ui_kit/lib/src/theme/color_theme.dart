import 'package:flutter/material.dart';

/// {@template ui_kit_theme_scope}
/// Delivers theme data to the widget subtree via [InheritedTheme].
///
/// Placed in [MaterialApp.builder] via [AppTheme.builder] to bridge:
/// - **[ThemeExtension]** — participates in [AnimatedTheme] lerp.
/// - **[InheritedTheme]** — survives [Navigator] route pushes via [wrap].
///
/// Lookup order in [of]:
/// 1. Nearest ancestor [ColorTheme] — local subtree override.
/// 2. [ThemeData.extension<ColorThemeData>()] — global theme.
/// {@endtemplate}
///
/// Local override:
/// ```dart
/// ColorTheme(
///   data: ColorTheme.of(context).copyWith(bgCard: specialColor),
///   child: SpecialPanel(),
/// )
/// ```
class ColorTheme extends InheritedTheme {
  const ColorTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Returns [ColorThemeData] if available, `null` otherwise.
  static ColorThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ColorTheme>()?.data ?? Theme.of(context).extension<ColorThemeData>();

  static ColorThemeData of(BuildContext context) {
    final data = maybeOf(context);
    assert(
      data != null,
      'ColorTheme not found in the widget tree.\n'
      'Ensure MaterialApp is configured with:\n'
      '  theme:     AppTheme.fromVariant(const LightThemeVariant())\n'
      '  darkTheme: AppTheme.fromVariant(const DarkThemeVariant())\n'
      '  builder:   AppTheme.builder\n',
    );

    return data!;
  }

  final ColorThemeData data;

  /// Reference equality is intentional — [ColorThemeData] lifecycle is tied
  /// to [ThemeData]. Flutter's own theme data classes (e.g. [SliderThemeData])
  /// follow the same approach and do not override `==`.
  @override
  bool updateShouldNotify(ColorTheme old) => data != old.data;

  @override
  Widget wrap(BuildContext context, Widget child) => ColorTheme(data: data, child: child);
}

// =============================================================================

/// Semantic color token schema (Level 2).
///
/// Defines **what** color slots exist — not what values they hold.
/// Each variant maps [AppPalette] primitives to these slots:
///
/// ```
/// Primitive  →  AppPalette.neutral850       (raw hex, static const)
/// Semantic   →  ColorThemeData.bgCard        (this class — schema only)
/// Component  →  theme/component_themes/      (CardThemeBuilder, … builders)
/// ```
///
/// ```dart
/// final colors = ColorTheme.of(context);
/// Container(color: colors.bgCard)
/// ```
@immutable
class ColorThemeData extends ThemeExtension<ColorThemeData> {
  // --- Brand -----------------------------------------------------------------

  final Color brand;
  final Color brandLight;
  final Color brandDim;

  /// Text/icon color on a brand-colored fill (e.g. filled button label).
  final Color onBrand;

  // --- Status ----------------------------------------------------------------

  final Color error;
  final Color warning;

  /// Product-semantic: livestream "on air" indicator. A themeable color slot,
  /// not behavior — the sole product concept ui_kit encodes, kept here so status
  /// colors live together. See also [videoBackground].
  final Color live;

  // --- Backgrounds -----------------------------------------------------------

  final Color bgScaffold;
  final Color bgCard;
  final Color bgElevated;
  final Color bgInput;

  // --- Borders ---------------------------------------------------------------

  final Color border;
  final Color borderDim;

  // --- Text ------------------------------------------------------------------

  final Color textPrimary;

  /// ~70 % opacity equivalent.
  final Color textSecondary;

  /// ~54 %.
  final Color textTertiary;

  /// ~38 %.
  final Color textDisabled;

  // --- Misc ------------------------------------------------------------------

  /// Product-semantic: letterbox fill behind the video player. A themeable color
  /// slot, not behavior. See also [live].
  final Color videoBackground;

  // ---------------------------------------------------------------------------

  const ColorThemeData({
    required this.brand,
    required this.brandLight,
    required this.brandDim,
    required this.onBrand,
    required this.error,
    required this.warning,
    required this.live,
    required this.bgScaffold,
    required this.bgCard,
    required this.bgElevated,
    required this.bgInput,
    required this.border,
    required this.borderDim,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.videoBackground,
  });

  @override
  ColorThemeData copyWith({
    Color? brand,
    Color? brandLight,
    Color? brandDim,
    Color? onBrand,
    Color? error,
    Color? warning,
    Color? live,
    Color? bgScaffold,
    Color? bgCard,
    Color? bgElevated,
    Color? bgInput,
    Color? border,
    Color? borderDim,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? videoBackground,
  }) => ColorThemeData(
    brand: brand ?? this.brand,
    brandLight: brandLight ?? this.brandLight,
    brandDim: brandDim ?? this.brandDim,
    onBrand: onBrand ?? this.onBrand,
    error: error ?? this.error,
    warning: warning ?? this.warning,
    live: live ?? this.live,
    bgScaffold: bgScaffold ?? this.bgScaffold,
    bgCard: bgCard ?? this.bgCard,
    bgElevated: bgElevated ?? this.bgElevated,
    bgInput: bgInput ?? this.bgInput,
    border: border ?? this.border,
    borderDim: borderDim ?? this.borderDim,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary: textTertiary ?? this.textTertiary,
    textDisabled: textDisabled ?? this.textDisabled,
    videoBackground: videoBackground ?? this.videoBackground,
  );

  /// Called by [AnimatedTheme] on every frame during a theme transition.
  /// This is the reason [ColorThemeData] extends [ThemeExtension].
  @override
  ColorThemeData lerp(covariant ColorThemeData? other, double t) {
    if (other == null) return this;

    return ColorThemeData(
      brand: Color.lerp(brand, other.brand, t)!,
      brandLight: Color.lerp(brandLight, other.brandLight, t)!,
      brandDim: Color.lerp(brandDim, other.brandDim, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      live: Color.lerp(live, other.live, t)!,
      bgScaffold: Color.lerp(bgScaffold, other.bgScaffold, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgElevated: Color.lerp(bgElevated, other.bgElevated, t)!,
      bgInput: Color.lerp(bgInput, other.bgInput, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderDim: Color.lerp(borderDim, other.borderDim, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      videoBackground: Color.lerp(videoBackground, other.videoBackground, t)!,
    );
  }
}
