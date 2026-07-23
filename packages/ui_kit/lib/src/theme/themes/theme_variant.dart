import 'package:flutter/material.dart';
import 'package:ui_kit/src/theme/variants/color/color_variant.dart';
import 'package:ui_kit/src/theme/variants/typography/default_typography_variant.dart';
import 'package:ui_kit/src/theme/variants/typography/typography_variant.dart';

/// {@template ui_kit_theme_variant}
/// Contract for a complete theme variant.
///
/// `abstract class` so future sub-variant getters can have default
/// implementations — existing subclasses compile unchanged (OCP).
///
/// ```dart
/// final class SolarThemeVariant extends ThemeVariant {
///   const SolarThemeVariant();
///   @override Brightness   get brightness => Brightness.dark;
///   @override ColorVariant get colors     => const SolarColorVariant();
/// }
/// ```
/// {@endtemplate}
abstract class ThemeVariant {
  Brightness get brightness;

  /// Maps [AppPalette] primitives to [ColorThemeData] slots.
  /// Brand color and seed for [ColorScheme.fromSeed] come from [ColorThemeData.brand].
  ColorVariant get colors;

  /// Defaults to [DefaultTypographyVariant]. Override for custom font or scale.
  TypographyVariant get typography => const DefaultTypographyVariant();

  const ThemeVariant();

  // Reserved — add with defaults to keep existing subclasses intact:
  // SpacingVariant   get spacing    => const DefaultSpacingVariant();
  // ComponentVariant get components => const DefaultComponentVariant();
}
