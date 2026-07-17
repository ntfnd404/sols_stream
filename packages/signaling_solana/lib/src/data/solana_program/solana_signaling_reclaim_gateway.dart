import 'dart:async';

import 'package:signaling/signaling.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_instruction_factory.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_program_error_adapter.dart';
import 'package:signaling_solana/src/generated/sols_stream_solana.dart';
import 'package:solana/encoder.dart' show Instruction;
import 'package:solana/solana.dart' show Ed25519HDPublicKey, JsonRpcException, TransactionError;
import 'package:solana_wallet/solana_signer.dart';

/// Best-effort diagnostic sink for reclaim. Receives non-fatal, human-readable
/// notes (e.g. a decoded Anchor error name) for logging/telemetry. Defaults to a
/// no-op so reclaim stays silent unless the host app opts in.
typedef ReclaimDiagnostics = void Function(String message);

void _noopDiagnostics(String _) {}

/// Real [SignalingReclaimGateway] over the sols.stream signaling program.
///
/// Sends each `close_connect_slot` / `end_room` / `close_room` as its own
/// single-instruction transaction (the default 200k CU budget comfortably fits
/// one close; batching could exceed it — ComputeBudget is a later phase), which
/// also makes every step fail independently.
///
/// The `host` is the [SolanaSigner]; the mandated 1%-skim `service_wallet` is
/// resolved on-chain from `ProgramConfig` and cached for the session — never a
/// literal, never a caller-supplied value. A missing/unreadable config disables
/// reclaim for the session (no close is attempted; the program would reject it
/// without a service wallet anyway), recorded as a diagnostic, never surfaced.
///
/// Every public method is best-effort: an already-closed account is idempotent
/// success, `DepositMismatch` and transient RPC errors are retried a bounded
/// number of times, and no exception ever escapes (the residual deposit is left
/// for the program's passive `cleanup_*` fallback).
final class SolanaSignalingReclaimGateway implements SignalingReclaimGateway {
  /// Default bounded-retry attempt cap for explicitly classified transient
  /// failures and `DepositMismatch` (6023).
  static const int defaultMaxAttempts = 3;

  /// Default backoff between retry attempts.
  static const Duration defaultRetryBackoff = Duration(milliseconds: 250);

  final SolanaSigner _signer;
  final SignalingChainGateway _chain;
  final SolsStreamInstructionFactory _instructions;
  final SolsStreamProgramErrorAdapter _errors;
  final ReclaimDiagnostics _diagnostics;
  final int _maxAttempts;
  final Duration _retryBackoff;

  // Session cache for the on-chain service wallet. `_serviceWalletResolved`
  // gates the cache so a resolved-to-null outcome (config absent/unreadable) is
  // not re-fetched on every close in the same teardown.
  Ed25519HDPublicKey? _serviceWallet;
  bool _serviceWalletResolved = false;

  SolanaSignalingReclaimGateway(
    this._signer,
    this._chain, {
    SolsStreamInstructionFactory? instructionFactory,
    SolsStreamProgramErrorAdapter errorAdapter = const SolsStreamProgramErrorAdapter(),
    this._diagnostics = _noopDiagnostics,
    this._maxAttempts = defaultMaxAttempts,
    this._retryBackoff = defaultRetryBackoff,
  }) : _instructions = instructionFactory ?? SolsStreamInstructionFactory(),
       _errors = errorAdapter;

  @override
  Future<ReclaimOutcome> closeConnectSlot({
    required String slotPda,
    String? viewer,
  }) async {
    try {
      final serviceWallet = await _resolveServiceWallet();
      if (serviceWallet == null) return ReclaimOutcome.disabled;

      final slot = await _chain.fetchSlot(slotPda);
      if (slot == null) {
        _diagnostics('close_connect_slot.already_closed');

        return ReclaimOutcome.alreadyClosed;
      }

      final host = _signer.publicKey;
      final ix = await _instructions.closeConnectSlot(
        host: host,
        slotPda: Ed25519HDPublicKey.fromBase58(slotPda),
        viewer: _viewerFor(viewer, slot, host),
        configPda: await _instructions.deriveConfigPda(),
        serviceWallet: serviceWallet,
      );

      return _send(ix, 'close_connect_slot');
    } on Object catch (error) {
      _diagnostics(
        'close_connect_slot.failed type=${error.runtimeType}',
      );

      return ReclaimOutcome.failed;
    }
  }

  @override
  Future<ReclaimOutcome> endRoom({required String roomPda}) async {
    try {
      if (await _resolveServiceWallet() == null) {
        return ReclaimOutcome.disabled;
      }
      final ix = await _instructions.endRoom(
        host: _signer.publicKey,
        roomPda: Ed25519HDPublicKey.fromBase58(roomPda),
      );

      return _send(
        ix,
        'end_room',
        roomAlreadyEndedIsSuccess: true,
      );
    } on Object catch (error) {
      _diagnostics('end_room.failed type=${error.runtimeType}');

      return ReclaimOutcome.failed;
    }
  }

  @override
  Future<ReclaimOutcome> closeRoom({required String roomPda}) async {
    try {
      if (await _resolveServiceWallet() == null) {
        return ReclaimOutcome.disabled;
      }
      final ix = await _instructions.closeRoom(
        host: _signer.publicKey,
        roomPda: Ed25519HDPublicKey.fromBase58(roomPda),
      );

      return _send(ix, 'close_room');
    } on Object catch (error) {
      _diagnostics('close_room.failed type=${error.runtimeType}');

      return ReclaimOutcome.failed;
    }
  }

  /// Resolves and caches the on-chain service wallet. Returns `null` (and caches
  /// that outcome) when the config is absent/unreadable — reclaim is then
  /// disabled for the session. Never throws.
  Future<Ed25519HDPublicKey?> _resolveServiceWallet() async {
    if (_serviceWalletResolved) return _serviceWallet;
    _serviceWalletResolved = true;
    try {
      final config = await _chain.fetchConfig();
      if (config == null) {
        _diagnostics('reclaim disabled: ProgramConfig unavailable; deposits left for cleanup_*');
      } else {
        _serviceWallet = Ed25519HDPublicKey(config.serviceWallet);
      }
    } on Object catch (error) {
      _diagnostics(
        'reclaim.disabled config_read_failed type=${error.runtimeType}',
      );
    }

    return _serviceWallet;
  }

  /// Refund recipient for the slot's viewer leg. Prefers the caller's [viewer]
  /// hint; otherwise reads the slot's on-chain viewer. An unclaimed slot
  /// (all-zero == System Program) refunds to the [host] placeholder.
  Ed25519HDPublicKey _viewerFor(
    String? viewer,
    ConnectSlotData slot,
    Ed25519HDPublicKey host,
  ) {
    if (viewer != null) {
      final key = Ed25519HDPublicKey.fromBase58(viewer);

      return key.bytes.every((b) => b == 0) ? host : key;
    }
    final bytes = slot.viewer;

    return bytes.every((b) => b == 0) ? host : Ed25519HDPublicKey(bytes);
  }

  /// Sends [ix] as its own transaction with bounded retry. Never throws:
  /// already-closed accounts and [idempotentCodes] are treated as success;
  /// `DepositMismatch` (6023) and explicitly classified transient errors are
  /// retried;
  /// any other failure is recorded and swallowed (left for `cleanup_*`).
  Future<ReclaimOutcome> _send(
    Instruction ix,
    String label, {
    bool roomAlreadyEndedIsSuccess = false,
  }) async {
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        await _signer.signAndSend([ix]);

        return ReclaimOutcome.succeeded;
      } on Object catch (error) {
        final programError = _errors.decode(error);
        if (roomAlreadyEndedIsSuccess && programError is SolsStreamRoomAlreadyEndedException) {
          _diagnostics('$label: RoomAlreadyEnded; idempotent success');

          return ReclaimOutcome.alreadyClosed;
        }
        if (_isAccountGone(error)) {
          _diagnostics('$label: account already closed; idempotent success');

          return ReclaimOutcome.alreadyClosed;
        }
        final retryable = programError is SolsStreamDepositMismatchException || _isTransient(error, programError);
        if (!retryable || attempt == _maxAttempts) {
          final reason = programError?.idlName ?? error.runtimeType.toString();
          _diagnostics(
            '$label.failed attempts=$attempt reason=$reason',
          );

          return ReclaimOutcome.failed;
        }
        final reason = programError is SolsStreamDepositMismatchException ? 'DepositMismatch' : 'transient';
        _diagnostics('$label: attempt $attempt failed ($reason); retrying');
        await Future<void>.delayed(_retryBackoff);
      }
    }

    return ReclaimOutcome.failed;
  }

  /// True when [error] indicates the target account no longer exists — closing
  /// an already-closed account is idempotent success, not a failure.
  bool _isAccountGone(Object error) {
    if (error case SolanaTransactionException(
      transactionError: TransactionError.accountNotFound,
    )) {
      return true;
    }
    if (error is! JsonRpcException) return false;
    if (error.transactionError == TransactionError.accountNotFound) return true;
    final message = error.message.toLowerCase();

    return message.contains('account does not exist') ||
        message.contains('accountnotinitialized') ||
        message.contains('could not find account');
  }

  /// True only for failures whose delivery/expiry state makes a retry safe.
  bool _isTransient(
    Object error,
    SolsStreamProgramException? programError,
  ) {
    if (programError != null || _isAccountGone(error)) return false;

    return switch (error) {
      SolanaTransactionException(
        :final kind,
        :final signature,
        :final transactionError,
      ) =>
        kind == SolanaTransactionFailureKind.expired ||
            (kind == SolanaTransactionFailureKind.transport && signature == null) ||
            (kind == SolanaTransactionFailureKind.submissionRejected &&
                (transactionError == TransactionError.accountInUse ||
                    transactionError == TransactionError.clusterMaintenance)),
      TimeoutException() => true,
      _ => false,
    };
  }
}
