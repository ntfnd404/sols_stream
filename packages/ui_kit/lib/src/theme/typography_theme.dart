import 'package:flutter/material.dart';

/// {@macro ui_kit_theme_scope}
///
/// Prefer [Theme.of(context).textTheme] for standard Material text roles.
/// Use [TypographyTheme.of] for custom styles not in [TextTheme].
class TypographyTheme extends InheritedTheme {
  const TypographyTheme({
    super.key,
    required this.data,
    required super.child,
  });

  static TypographyTokens of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<TypographyTheme>();
    final extension = Theme.of(context).extension<TypographyTokens>();
    assert(
      inherited != null || extension != null,
      'TypographyTheme not found in the widget tree.\n'
      'Ensure MaterialApp is configured with:\n'
      '  theme:   AppTheme.fromVariant(...)\n'
      '  builder: AppTheme.builder\n',
    );

    return inherited?.data ?? extension!;
  }

  final TypographyTokens data;

  @override
  bool updateShouldNotify(TypographyTheme old) => data != old.data;

  @override
  Widget wrap(BuildContext context, Widget child) => TypographyTheme(
    data: data,
    child: child,
  );
}

// =============================================================================

/// Semantic typography token schema for the app theme.
///
/// Defines **what** text style slots exist — not what values they hold.
/// Values are assembled by a [TypographyVariant] via [AppTheme.fromVariant].
///
/// [TypographyTokens] are colorless — apply color via [ColorTheme.of]:
/// ```dart
/// style: TypographyTheme.of(context).bodyMedium.copyWith(color: colors.textSecondary)
/// ```
///
/// Prefer [Theme.of(context).textTheme] for standard Material roles —
/// it is auto-populated from [TypographyTokens] by [AppTheme.fromVariant].
///
@immutable
class TypographyTokens extends ThemeExtension<TypographyTokens> {
  // --- Display ---------------------------------------------------------------

  final TextStyle displayLarge;

  final TextStyle displayMedium;

  // --- Headline --------------------------------------------------------------

  final TextStyle headlineLarge;

  final TextStyle headlineMedium;

  final TextStyle headlineSmall;

  // --- Title -----------------------------------------------------------------

  final TextStyle titleLarge;

  final TextStyle titleMedium;

  final TextStyle titleSmall;

  // --- Body ------------------------------------------------------------------

  final TextStyle bodyLarge;

  final TextStyle bodyMedium;

  final TextStyle bodySmall;

  // --- Label -----------------------------------------------------------------

  final TextStyle labelLarge;

  final TextStyle labelMedium;

  final TextStyle labelSmall;

  // ---------------------------------------------------------------------------

  const TypographyTokens({
    required this.displayLarge,
    required this.displayMedium,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  @override
  TypographyTokens copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
  }) => TypographyTokens(
    displayLarge: displayLarge ?? this.displayLarge,
    displayMedium: displayMedium ?? this.displayMedium,
    headlineLarge: headlineLarge ?? this.headlineLarge,
    headlineMedium: headlineMedium ?? this.headlineMedium,
    headlineSmall: headlineSmall ?? this.headlineSmall,
    titleLarge: titleLarge ?? this.titleLarge,
    titleMedium: titleMedium ?? this.titleMedium,
    titleSmall: titleSmall ?? this.titleSmall,
    bodyLarge: bodyLarge ?? this.bodyLarge,
    bodyMedium: bodyMedium ?? this.bodyMedium,
    bodySmall: bodySmall ?? this.bodySmall,
    labelLarge: labelLarge ?? this.labelLarge,
    labelMedium: labelMedium ?? this.labelMedium,
    labelSmall: labelSmall ?? this.labelSmall,
  );

  /// Called by [AnimatedTheme] during animated theme transitions.
  @override
  TypographyTokens lerp(covariant TypographyTokens? other, double t) {
    if (other == null) return this;

    return TypographyTokens(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
    );
  }
}
