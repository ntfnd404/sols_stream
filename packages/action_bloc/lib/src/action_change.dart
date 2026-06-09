import 'package:flutter/foundation.dart';

/// Snapshot passed to [ActionBlocObserver.onAction]: the action being emitted
/// now ([current]) and the one emitted just before it ([previous]).
///
/// This is the **bloc-global** previous — the last action the BLoC emitted,
/// regardless of which listeners were attached. It is for observation/logging
/// only. For per-listener filtering use the `previous` argument of
/// `ActionBlocListener.listenWhen`, which is listener-local.
///
/// [previous] is null on the very first [ActionBlocMixin.emitAction] call after
/// BLoC creation.
@immutable
final class ActionChange<A> {
  /// The action emitted immediately before [current], or null on the first
  /// emission after BLoC creation.
  final A? previous;

  /// The action being emitted now.
  final A current;

  @override
  int get hashCode => Object.hash(previous, current);

  /// Creates an action snapshot with an optional [previous] and a [current].
  const ActionChange({this.previous, required this.current});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ActionChange<A> && previous == other.previous && current == other.current;

  @override
  String toString() => 'ActionChange(previous: $previous, current: $current)';
}
