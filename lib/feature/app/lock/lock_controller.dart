import 'package:flutter/foundation.dart';

/// Demo session-lock state. When locked, the `LockGuard` redirects protected
/// routes to the unlock screen; unlocking restores the intended location.
class LockController extends ChangeNotifier {
  bool _locked = false;

  bool get isLocked => _locked;

  void lock() {
    if (!_locked) {
      _locked = true;
      notifyListeners();
    }
  }

  void unlock() {
    if (_locked) {
      _locked = false;
      notifyListeners();
    }
  }
}
