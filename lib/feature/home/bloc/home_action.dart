part of 'home_bloc.dart';

sealed class HomeAction {
  const HomeAction();
}

/// Requests cleanup of the active transport before the mode changes.
final class TransportModeChangingAction extends HomeAction {
  final TransportMode newMode;

  const TransportModeChangingAction(this.newMode);
}
