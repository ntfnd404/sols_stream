import 'package:flutter/material.dart';
import 'package:ui_kit/src/theme/typography_theme.dart';
import 'package:ui_kit/src/theme/variants/typography/typography_variant.dart';
import 'package:ui_kit/src/tokens/app_text_styles.dart';
import 'package:ui_kit/src/tokens/app_typography.dart';

/// Default typography — system font, Material 3 scale.
///
/// Adds to each [AppTextStyles] primitive:
/// - `leadingDistribution: even` — matches Figma's symmetric line-height,
///   fixes Flutter's default of putting all leading at the top.
/// - `fontFeatures: AppTypography.defaultFeatures` — tabular numbers, ligatures.
///
/// System font is used by default. To apply a custom font add
/// `fontFamily: AppTypography.primaryFontFamily` to each `copyWith` call
/// after setting [AppTypography.primaryFontFamily].
///
/// Variable font: replace `fontWeight` with `fontVariations: [FontVariation.weight(n)]`.
final class DefaultTypographyVariant implements TypographyVariant {
  const DefaultTypographyVariant();

  @override
  TypographyTokens build() => TypographyTokens(
    displayLarge: AppTextStyles.displayLarge.copyWith(
      fontFeatures: AppTypography.defaultFeatures,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    displayMedium: AppTextStyles.displayMedium.copyWith(
      fontFeatures: AppTypography.defaultFeatures,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headlineLarge: AppTextStyles.headlineLarge.copyWith(
      fontFeatures: AppTypography.defaultFeatures,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headlineMedium: AppTextStyles.headlineMedium.copyWith(
      fontFeatures: AppTypography.defaultFeatures,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headlineSmall: AppTextStyles.headlineSmall.copyWith(
      fontFeatures: AppTypography.defaultFeatures,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    titleLarge: AppTextStyles.titleLarge.copyWith(
      fontFeatures: AppTypography.defaultFeatures,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    titleMedium: AppTextStyles.titleMedium.copyWith(
      fontFeatures: AppTypography.defaultFeatures,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    titleSmall: AppTextStyles.titleSmall.copyWith(
      fontFeatures: AppTypography.defaultFeatures,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bodyLarge: AppTextStyles.bodyLarge.copyWith(
      fontFeatures: AppTypography.defaultFeatures,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bodyMedium: AppTextStyles.bodyMedium.copyWith(
      fontFeatures: AppTypography.defaultFeatures,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bodySmall: AppTextStyles.bodySmall.copyWith(
      fontFeatures: AppTypography.defaultFeatures,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    labelLarge: AppTextStyles.labelLarge.copyWith(
      fontFeatures: AppTypography.defaultFeatures,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    labelMedium: AppTextStyles.labelMedium.copyWith(
      fontFeatures: AppTypography.defaultFeatures,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    labelSmall: AppTextStyles.labelSmall.copyWith(
      fontFeatures: AppTypography.defaultFeatures,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );
}
