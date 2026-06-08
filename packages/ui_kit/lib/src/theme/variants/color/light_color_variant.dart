import 'package:ui_kit/src/theme/color_theme.dart';
import 'package:ui_kit/src/theme/variants/color/color_variant.dart';
import 'package:ui_kit/src/tokens/app_palette.dart';

/// Light mode: [AppPalette] primitives → [ColorThemeData] slots.
/// Every slot maps a primitive directly (Figma primitive → semantic).
final class LightColorVariant implements ColorVariant {
  const LightColorVariant();

  @override
  ColorThemeData build() => const ColorThemeData(
    brand: AppPalette.jade500,
    brandLight: AppPalette.jade400,
    brandDim: AppPalette.jade600,
    onBrand: AppPalette.neutral50,
    error: AppPalette.red500,
    warning: AppPalette.orange500,
    live: AppPalette.red600,
    bgScaffold: AppPalette.neutral100,
    bgCard: AppPalette.neutral50,
    bgElevated: AppPalette.neutral150,
    bgInput: AppPalette.neutral200,
    border: AppPalette.neutral300,
    borderDim: AppPalette.neutral200,
    textPrimary: AppPalette.nearBlack,
    textSecondary: AppPalette.neutral600,
    textTertiary: AppPalette.neutral550, // WCAG-AA: neutral500 fails on white (3.26)
    textDisabled: AppPalette.neutral400,
    videoBackground: AppPalette.neutral950,
  );
}
