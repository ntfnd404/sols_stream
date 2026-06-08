/// {@template ui_kit_layout_primitive}
/// Primitive layout token — a raw scale value (spacing, radius, stroke width).
///
/// Bottom tier of the token system, but unlike color primitives ([AppPalette])
/// these are **meant for direct use in widgets**: layout metrics are not themed
/// per mode (a gap is identical in light and dark). Use e.g. `AppSpacing.l`,
/// `AppRadius.m`, `AppBorderWidth.thick` directly.
/// {@endtemplate}
///
/// 4 px base scale. See also: [AppRadius].
abstract final class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}
