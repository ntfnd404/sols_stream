import 'package:flutter/widgets.dart';

import 'package:sols_stream/feature/app/lock/lock_controller.dart';

/// Exposes the [LockController] to the widget tree. Placed above
/// `MaterialApp.router` (like `NavigatorScope`) so screens can lock/unlock.
class LockScope extends InheritedWidget {
  const LockScope({required this.controller, required super.child, super.key});

  /// Reads the nearest [LockController].
  static LockController of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<LockScope>();
    if (scope == null) {
      throw FlutterError('LockScope not found. Place it above MaterialApp.router.');
    }

    return scope.controller;
  }

  final LockController controller;

  @override
  bool updateShouldNotify(LockScope oldWidget) => controller != oldWidget.controller;
}
