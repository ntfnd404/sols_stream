import 'package:flutter/material.dart';
import 'package:ui_kit/src/theme/color_theme.dart';
import 'package:ui_kit/src/tokens/app_radius.dart';

/// Builds the [OutlinedButtonThemeData] from semantic tokens.
abstract final class OutlinedButtonThemeBuilder {
  static OutlinedButtonThemeData build(ColorThemeData c) => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: c.textPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      side: BorderSide(color: c.border),
    ),
  );
}
