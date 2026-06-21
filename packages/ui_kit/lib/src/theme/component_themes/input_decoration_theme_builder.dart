import 'package:flutter/material.dart';
import 'package:ui_kit/src/theme/color_theme.dart';
import 'package:ui_kit/src/tokens/app_border_width.dart';
import 'package:ui_kit/src/tokens/app_radius.dart';
import 'package:ui_kit/src/tokens/app_spacing.dart';

/// Builds the [InputDecorationTheme] for text fields from semantic tokens.
InputDecorationTheme buildInputDecorationTheme(ColorThemeData c) => InputDecorationTheme(
  filled: true,
  fillColor: c.bgInput,
  // Resting borders use BorderSide's default width (1.0 == AppBorderWidth.thin);
  // passing it explicitly trips avoid_redundant_argument_values.
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.m),
    borderSide: BorderSide(color: c.border),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.m),
    borderSide: BorderSide(color: c.border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.m),
    borderSide: BorderSide(color: c.brand, width: AppBorderWidth.thick),
  ),
  contentPadding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.l,
    vertical: AppSpacing.m,
  ),
);
