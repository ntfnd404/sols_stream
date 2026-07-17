import 'dart:async';

import 'package:sols_stream/core/di/app_resource_disposal_exception.dart';

/// Callback that releases an application resource.
///
/// Implementations may complete synchronously or asynchronously.
typedef AppResourceDisposer<T extends Object> =
    FutureOr<void> Function(
      T resource,
    );

/// Tracks application resources that must be released during graph teardown.
///
/// Registrations form a last-in-first-out disposal stack. This mirrors
/// dependency construction: resources created later are normally consumers of
/// resources created earlier and therefore must be released first.
///
/// Disposal is idempotent. Every registered callback runs even when another
/// callback fails; all failures are preserved in
/// [AppResourceDisposalException].
final class AppResourceDisposalStack {
  final List<FutureOr<void> Function()> _disposers = [];
  Future<void>? _disposeFuture;

  /// Adds [resource] and its [disposer] to the teardown stack.
  ///
  /// The resource is returned unchanged so construction code can register and
  /// assign it in one expression. Registration after disposal has started is
  /// rejected because ownership can no longer be transferred safely.
  T register<T extends Object>(
    T resource,
    AppResourceDisposer<T> disposer,
  ) {
    if (_disposeFuture != null) {
      throw StateError('Cannot register a resource after disposal has started.');
    }
    _disposers.add(() => disposer(resource));

    return resource;
  }

  /// Releases all registered resources once, in reverse registration order.
  ///
  /// If one or more callbacks fail, cleanup continues and the returned future
  /// completes with [AppResourceDisposalException] containing every failure
  /// and its original stack trace.
  Future<void> dispose() {
    final existing = _disposeFuture;
    if (existing != null) return existing;

    final completer = Completer<void>();
    _disposeFuture = completer.future;
    _disposeResources().then(
      (_) => completer.complete(),
      onError: (Object error, StackTrace stackTrace) {
        completer.completeError(error, stackTrace);
      },
    );

    return completer.future;
  }

  @override
  String toString() => 'AppResourceDisposalStack(${_disposers.length} pending)';

  Future<void> _disposeResources() async {
    final failures = <AppResourceDisposalFailure>[];

    for (final dispose in _disposers.reversed) {
      try {
        await dispose();
      } catch (error, stackTrace) {
        failures.add((error: error, stackTrace: stackTrace));
      }
    }
    _disposers.clear();

    if (failures.isNotEmpty) {
      final exception = AppResourceDisposalException(failures);
      Error.throwWithStackTrace(exception, exception.combinedStackTrace);
    }
  }
}
