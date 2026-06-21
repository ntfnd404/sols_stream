import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:rolter/rolter.dart';
import 'package:sols_stream/feature/app/lock/lock_controller.dart';
import 'package:sols_stream/feature/app/routing/routes/app_route.dart';

/// Redirects protected routes (here [AccountRoute]) to [LockRoute] while the
/// session is locked, remembering the intended location. When [LockController]
/// changes, the guard's `Listenable` fires, the pipeline reruns, and the intended
/// location is restored.
class LockGuard with ChangeNotifier implements RouteGuard<AppRoute> {
  final LockController _lock;

  List<AppRoute>? _intended;

  LockGuard(this._lock) {
    _lock.addListener(notifyListeners);
  }

  @override
  FutureOr<GuardResult<AppRoute>> call(
    List<List<AppRoute>> history,
    List<AppRoute> requested,
    Map<String, Object?> context,
  ) {
    final wantsProtected = requested.any((route) => route is AccountRoute);
    final onLockScreen = requested.any((route) => route is LockRoute);

    if (_lock.isLocked) {
      if (wantsProtected && !onLockScreen) {
        _intended = requested;

        return const GuardResult<AppRoute>.proceed(<AppRoute>[HubRoute(), LockRoute()]);
      }

      return GuardResult<AppRoute>.proceed(requested);
    }

    final intended = _intended;
    if (intended != null && onLockScreen) {
      _intended = null;

      return GuardResult<AppRoute>.proceed(intended);
    }

    return GuardResult<AppRoute>.proceed(requested);
  }

  @override
  void dispose() {
    _lock.removeListener(notifyListeners);
    super.dispose();
  }
}
