import 'dart:async';

import 'package:solana/dto.dart' show Encoding, SignatureStatus;
import 'package:solana/solana.dart';
import 'package:solana_wallet/src/data/solana_rpc_failure_decoder.dart';
import 'package:solana_wallet/src/domain/solana_transaction_exception.dart';

typedef _StatusLookup = ({bool succeeded, SignatureStatus? status});

/// Observes one signed transaction until it is confirmed, fails, or expires.
final class SolanaTransactionConfirmer {
  static const Commitment commitment = Commitment.confirmed;

  final RpcClient _rpc;
  final Duration _pollInterval;
  final Duration _maxObservationDuration;
  final Duration _logsTimeout;
  final SolanaRpcFailureDecoder _failureDecoder;

  SolanaTransactionConfirmer(
    this._rpc, {
    this._pollInterval = const Duration(milliseconds: 500),
    this._maxObservationDuration = const Duration(minutes: 2),
    this._logsTimeout = const Duration(seconds: 2),
    this._failureDecoder = const SolanaRpcFailureDecoder(),
  }) {
    if (_pollInterval.isNegative) {
      throw ArgumentError.value(
        _pollInterval,
        'pollInterval',
        'must not be negative',
      );
    }
    if (_maxObservationDuration <= Duration.zero) {
      throw ArgumentError.value(
        _maxObservationDuration,
        'maxObservationDuration',
        'must be positive',
      );
    }
    if (_logsTimeout.isNegative) {
      throw ArgumentError.value(
        _logsTimeout,
        'logsTimeout',
        'must not be negative',
      );
    }
  }

  Future<void> confirm({
    required String signature,
    required int lastValidBlockHeight,
  }) async {
    final observation = Stopwatch()..start();

    while (observation.elapsed < _maxObservationDuration) {
      final recent = await _status(
        signature,
        observation,
        searchTransactionHistory: false,
      );
      if (recent.status != null && await _isTerminal(signature, recent.status!)) {
        return;
      }

      final blockHeight = await _blockHeight(observation);
      if (blockHeight != null && blockHeight > lastValidBlockHeight) {
        final historical = await _status(
          signature,
          observation,
          searchTransactionHistory: true,
        );
        if (historical.status != null && await _isTerminal(signature, historical.status!)) {
          return;
        }
        if (historical.succeeded && historical.status == null) {
          throw SolanaTransactionException.expired(signature: signature);
        }
      }

      await _delay(observation);
    }

    throw SolanaTransactionException.transport(signature: signature);
  }

  Future<_StatusLookup> _status(
    String signature,
    Stopwatch observation, {
    required bool searchTransactionHistory,
  }) async {
    try {
      final result = await _withinObservation(
        _rpc.getSignatureStatuses(
          [signature],
          searchTransactionHistory: searchTransactionHistory,
        ),
        observation,
      );

      return (succeeded: true, status: result.value.firstOrNull);
    } on Exception {
      return (succeeded: false, status: null);
    }
  }

  Future<int?> _blockHeight(Stopwatch observation) async {
    try {
      return await _withinObservation(
        _rpc.getBlockHeight(commitment: commitment),
        observation,
      );
    } on Exception {
      return null;
    }
  }

  Future<bool> _isTerminal(
    String signature,
    SignatureStatus status,
  ) async {
    if (status.err != null) {
      final details = _failureDecoder.fromStatus(status.err);
      throw SolanaTransactionException.failedOnChain(
        signature: signature,
        failedInstructionIndex: details.failedInstructionIndex,
        customProgramErrorCode: details.customProgramErrorCode,
        transactionError: details.transactionError,
        logs: await _logsFor(signature),
      );
    }
    if (status.confirmationStatus == Commitment.confirmed || status.confirmationStatus == Commitment.finalized) {
      return true;
    }

    return false;
  }

  Future<T> _withinObservation<T>(
    Future<T> operation,
    Stopwatch observation,
  ) {
    final remaining = _maxObservationDuration - observation.elapsed;
    if (remaining <= Duration.zero) {
      return Future<T>.error(
        SolanaTransactionException.transport(),
      );
    }

    return operation.timeout(remaining);
  }

  Future<void> _delay(Stopwatch observation) async {
    final remaining = _maxObservationDuration - observation.elapsed;
    if (remaining <= Duration.zero) return;
    final delay = remaining < _pollInterval ? remaining : _pollInterval;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
  }

  Future<List<String>> _logsFor(String signature) async {
    if (_logsTimeout == Duration.zero) return const [];
    try {
      final transaction = await _rpc
          .getTransaction(
            signature,
            commitment: commitment,
            encoding: Encoding.json,
          )
          .timeout(_logsTimeout);

      return transaction?.meta?.logMessages ?? const [];
    } on Exception {
      return const [];
    }
  }
}
