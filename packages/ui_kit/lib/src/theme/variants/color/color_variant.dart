import 'package:ui_kit/src/theme/color_theme.dart';

/// Strategy contract: maps [AppPalette] primitives to [ColorThemeData] slots.
///
/// ```dart
/// final class SolarColorVariant implements ColorVariant {
///   const SolarColorVariant();
///   @override
///   ColorThemeData build() => const ColorThemeData(bgScaffold: Color(0xFF1A0A00), …);
/// }
/// ```
abstract interface class ColorVariant {
  ColorThemeData build();
}
