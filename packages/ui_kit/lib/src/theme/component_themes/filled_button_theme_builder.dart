import 'package:flutter/material.dart';
import 'package:ui_kit/src/theme/color_theme.dart';
import 'package:ui_kit/src/tokens/app_radius.dart';

/// Builds the [FilledButtonThemeData] (primary CTA) from semantic tokens.
///
/// Uses [ColorThemeData.brandDim] fill + [ColorThemeData.onBrand] label —
/// white-on-jade600 passes WCAG AA (5.40:1); white-on-jade500 would be 3.08:1.
abstract final class FilledButtonThemeBuilder {
  static FilledButtonThemeData build(ColorThemeData c) => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: c.brandDim,
      foregroundColor: c.onBrand,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
    ),
  );
}
