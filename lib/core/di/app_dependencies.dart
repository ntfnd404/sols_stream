// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:signaling/signaling.dart';
import 'package:solana_wallet/solana_wallet.dart';
import 'package:sols_stream/core/di/app_resource_disposal_exception.dart';
import 'package:sols_stream/core/di/app_resource_disposal_stack.dart';
import 'package:sols_stream/core/event_bus/app_event_bus.dart';

typedef AppErrorReporter =
    FutureOr<void> Function(
      Object error,
      StackTrace stackTrace,
    );

/// Immutable container for application-level module assemblies.
@immutable
final class AppDependencies {
  final AppEventBus eventBus;
  final PeerSignaling peerSignaling;
  final SolanaWalletReader walletReader;
  final AppResourceDisposalStack _resourceDisposalStack;
  final AppErrorReporter _errorReporter;
  late final Future<void> _disposeFuture = _disposeResources();

  AppDependencies({
    required this.eventBus,
    required this.peerSignaling,
    required this.walletReader,
    required AppResourceDisposalStack resourceDisposalStack,
    required AppErrorReporter errorReporter,
  }) : _resourceDisposalStack = resourceDisposalStack,
       _errorReporter = errorReporter;

  /// Releases every disposable resource owned by this dependency graph.
  ///
  /// Each cleanup failure is sent to the application error reporter before the
  /// aggregate [AppResourceDisposalException] is rethrown to the caller.
  Future<void> dispose() => _disposeFuture;

  Future<void> _disposeResources() async {
    try {
      await _resourceDisposalStack.dispose();
    } on AppResourceDisposalException catch (error) {
      for (final failure in error.failures) {
        await _reportSafely(failure.error, failure.stackTrace);
      }
      Error.throwWithStackTrace(error, error.combinedStackTrace);
    }
  }

  Future<void> _reportSafely(
    Object error,
    StackTrace stackTrace,
  ) async {
    try {
      await _errorReporter(error, stackTrace);
    } catch (reportError, reportStackTrace) {
      Zone.current.handleUncaughtError(reportError, reportStackTrace);
    }
  }
}
