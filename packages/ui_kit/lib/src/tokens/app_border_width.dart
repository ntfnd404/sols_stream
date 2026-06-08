/// {@macro ui_kit_layout_primitive}
///
/// Border / stroke width scale. See also: [AppRadius].
abstract final class AppBorderWidth {
  /// Default border — cards, inputs, buttons at rest. Equals Flutter's
  /// [BorderSide.width] default, so resting borders rely on that default rather
  /// than restating it (avoids `avoid_redundant_argument_values`). Named here
  /// as the reference value and counterpart to [thick].
  static const double thin = 1;

  /// Emphasised border — focused inputs, selected states.
  static const double thick = 1.5;
}
