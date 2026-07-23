import 'package:ui_kit/src/theme/typography_theme.dart';

/// Strategy contract: assembles [TypographyTokens] from [AppTextStyles] scales
/// and [AppTypography] rendering properties.
///
/// ```dart
/// final class LargeTextTypographyVariant implements TypographyVariant {
///   const LargeTextTypographyVariant();
///   @override
///   TypographyTokens build() => TypographyTokens(
///     displayLarge: AppTextStyles.displayLarge.copyWith(fontSize: 72), …
///   );
/// }
/// ```
abstract interface class TypographyVariant {
  TypographyTokens build();
}
