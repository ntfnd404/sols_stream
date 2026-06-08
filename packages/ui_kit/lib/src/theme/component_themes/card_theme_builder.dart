import 'package:flutter/material.dart';
import 'package:ui_kit/src/theme/color_theme.dart';
import 'package:ui_kit/src/tokens/app_radius.dart';

/// Builds the [CardThemeData] for Flutter's [Card] from semantic tokens.
abstract final class CardThemeBuilder {
  static CardThemeData build(ColorThemeData c) => CardThemeData(
    color: c.bgCard,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.m),
      side: BorderSide(color: c.border),
    ),
    margin: EdgeInsets.zero,
  );
}
