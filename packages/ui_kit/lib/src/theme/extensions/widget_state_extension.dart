import 'package:flutter/material.dart';

/// Convenience extension on [Set<WidgetState>] for readable state checks.
///
/// Used in [WidgetStateProperty.resolveWith] callbacks (e.g. inside the
/// `theme/component_themes/` builders) to replace verbose
/// `states.contains(WidgetState.xxx)` calls:
///
/// ```dart
/// WidgetStateProperty.resolveWith((states) {
///   if (states.isDisabled) return colors.textDisabled;
///   if (states.isPressed)  return colors.bgElevated;
///   if (states.isHovered)  return colors.bgCard;
///   return colors.bgInput;
/// });
/// ```
extension WidgetStateExtension on Set<WidgetState> {
  bool get isDisabled => contains(WidgetState.disabled);

  bool get isSelected => contains(WidgetState.selected);

  bool get isPressed => contains(WidgetState.pressed);

  bool get isHovered => contains(WidgetState.hovered);

  bool get isFocused => contains(WidgetState.focused);

  bool get isDragged => contains(WidgetState.dragged);

  bool get isError => contains(WidgetState.error);
}
