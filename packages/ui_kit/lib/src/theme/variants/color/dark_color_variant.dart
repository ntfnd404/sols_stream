import 'package:ui_kit/src/theme/color_theme.dart';
import 'package:ui_kit/src/theme/variants/color/color_variant.dart';
import 'package:ui_kit/src/tokens/app_palette.dart';

/// Dark mode: [AppPalette] primitives → [ColorThemeData] slots.
/// Every slot maps a primitive directly (Figma primitive → semantic).
/// To add a slot: add the raw value to [AppPalette] first, then map here.
final class DarkColorVariant implements ColorVariant {
  const DarkColorVariant();

  @override
  ColorThemeData build() => const ColorThemeData(
    brand: AppPalette.jade500,
    brandLight: AppPalette.jade400,
    brandDim: AppPalette.jade600,
    onBrand: AppPalette.neutral50,
    error: AppPalette.red500,
    warning: AppPalette.orange500,
    live: AppPalette.red600,
    bgScaffold: AppPalette.neutral900,
    bgCard: AppPalette.neutral850,
    bgElevated: AppPalette.neutral800,
    bgInput: AppPalette.neutral750,
    border: AppPalette.neutral700,
    borderDim: AppPalette.neutral710,
    textPrimary: AppPalette.neutral50,
    textSecondary: AppPalette.whiteAlpha70,
    textTertiary: AppPalette.whiteAlpha54,
    textDisabled: AppPalette.whiteAlpha38,
    videoBackground: AppPalette.neutral950,
  );
}
