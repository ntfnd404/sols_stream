import 'package:flutter/material.dart';
import 'package:ui_kit/src/theme/themes/theme_variant.dart';
import 'package:ui_kit/src/theme/variants/color/color_variant.dart';
import 'package:ui_kit/src/theme/variants/color/light_color_variant.dart';

/// Light theme — [LightColorVariant].
final class LightThemeVariant extends ThemeVariant {
  @override
  Brightness get brightness => Brightness.light;

  @override
  ColorVariant get colors => const LightColorVariant();

  const LightThemeVariant();
}
