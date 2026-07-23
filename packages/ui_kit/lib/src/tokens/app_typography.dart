import 'package:flutter/material.dart';

/// Primitive typography rendering properties — font family and OpenType
/// features. Consumed only by [DefaultTypographyVariant] when assembling
/// [TypographyTokens]; widgets read text styles via
/// [TypographyTheme.of] or [Theme.of].
///
/// ## Font family
///
/// [primaryFontFamily] is `null` — system default (SF Pro / Roboto / Segoe UI).
/// When a custom font is embedded, set the PostScript name here and update
/// [DefaultTypographyVariant].
///
/// ## Variable fonts
///
/// System fonts are static — use `fontWeight`. Variable fonts use a continuous
/// weight axis — replace `fontWeight` with
/// `fontVariations: [FontVariation.weight(600)]` in [DefaultTypographyVariant].
abstract final class AppTypography {
  /// `null` = system default (SF Pro / Roboto / Segoe UI).
  static const String? primaryFontFamily = null;

  /// Default OpenType features for all text styles.
  ///
  /// `tnum` — tabular numbers: digits align vertically in amounts/balances.
  /// `liga` — standard ligatures.
  ///
  static const List<FontFeature> defaultFeatures = [
    FontFeature.enable('tnum'),
    FontFeature.enable('liga'),
  ];
}
