import 'package:flutter/material.dart';
import 'package:ui_kit/src/theme/themes/theme_variant.dart';
import 'package:ui_kit/src/theme/variants/color/color_variant.dart';
import 'package:ui_kit/src/theme/variants/color/dark_color_variant.dart';

/// Dark theme — [DarkColorVariant].
final class DarkThemeVariant extends ThemeVariant {
  @override
  Brightness get brightness => Brightness.dark;

  @override
  ColorVariant get colors => const DarkColorVariant();

  const DarkThemeVariant();
}
