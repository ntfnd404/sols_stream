import 'package:flutter/material.dart';

/// {@template ui_kit_color_primitive}
/// Primitive color token — a raw swatch with no semantic meaning.
///
/// Bottom tier of the token system. Referenced **only** by color variants when
/// mapping to [ColorThemeData] slots — never used directly in widgets. Widgets
/// read semantic color via `ColorTheme.of(context)`.
///
/// Contrast with layout primitives ([AppSpacing] / [AppRadius] /
/// [AppBorderWidth]), which *are* meant for direct widget use.
/// {@endtemplate}
///
/// Color palette named by hue + numeric step (no semantic intent).
/// Referenced only by [ColorVariant] implementations.
abstract final class AppPalette {
  // --- Jade ------------------------------------------------------------------
  static const Color jade400 = Color(0xFF00C07A);
  static const Color jade500 = Color(0xFF00A86B);
  static const Color jade600 = Color(0xFF007A4D);

  // --- Red -------------------------------------------------------------------
  static const Color red500 = Color(0xFFFF443A);
  static const Color red600 = Color(0xFFFF3B30);

  // --- Orange ----------------------------------------------------------------
  static const Color orange500 = Color(0xFFFF9500);

  // --- Neutral (50 = lightest … 950 = darkest) -------------------------------
  static const Color neutral50 = Color(0xFFFFFFFF);
  static const Color neutral100 = Color(0xFFF5F5F7);
  static const Color neutral150 = Color(0xFFEFEFF1);
  static const Color neutral200 = Color(0xFFE5E5EA);
  static const Color neutral300 = Color(0xFFD1D1D6);
  static const Color neutral400 = Color(0xFFAEAEB2);
  static const Color neutral500 = Color(0xFF8E8E93);

  /// WCAG-AA fix: light-theme tertiary text on white needs ≥4.5:1.
  /// neutral500 is 3.26:1; this is 4.93:1.
  static const Color neutral550 = Color(0xFF707074);

  static const Color neutral600 = Color(0xFF636366);
  static const Color neutral700 = Color(0xFF2A3036);

  /// Non-standard step: [ColorThemeData.borderDim] (#1E2228) between 700–800.
  static const Color neutral710 = Color(0xFF1E2228);

  /// Non-standard step: [ColorThemeData.bgInput] (#242830) between 700–800.
  static const Color neutral750 = Color(0xFF242830);

  static const Color neutral800 = Color(0xFF1A1D20);
  static const Color neutral850 = Color(0xFF171A1D);
  static const Color neutral900 = Color(0xFF101214);
  static const Color neutral950 = Color(0xFF000000);

  /// Apple-standard near-black label color for light backgrounds.
  static const Color nearBlack = Color(0xFF1C1C1E);

  // --- White alpha (dark-theme text) -----------------------------------------
  // Convention: dark theme uses white-with-opacity for secondary/tertiary text;
  // light theme uses opaque neutrals (see LightColorVariant). White-alpha on a
  // dark surface reads as graded gray and composites correctly over any bg.
  static const Color whiteAlpha70 = Color(0xB3FFFFFF);
  static const Color whiteAlpha54 = Color(0x8AFFFFFF);
  static const Color whiteAlpha38 = Color(0x61FFFFFF);
}
