import 'dart:async';

import 'package:signaling/src/application/signaling_chain_gateway.dart';
import 'package:signaling/src/application/signaling_reclaim_gateway.dart';
import 'package:signaling/src/data/solana_program/instruction_builder.dart';
import 'package:signaling/src/data/solana_program/solana_error_codes.dart';
import 'package:signaling/src/domain/connect_slot_data.dart';
import 'package:solana/encoder.dart' show Instruction;
import 'package:solana/solana.dart' show Ed25519HDPublicKey, JsonRpcException, TransactionError;
import 'package:solana_wallet/solana_wallet.dart' show SolanaSigner;

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
  /// Default bounded-retry attempt cap for [TransactionError]-free transient
  /// failures and `DepositMismatch` (6023).
  static const int defaultMaxAttempts = 3;

  /// Default backoff between retry attempts.
  static const Duration defaultRetryBackoff = Duration(milliseconds: 250);

  final SolanaSigner _signer;
  final SignalingChainGateway _chain;
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
    this._diagnostics = _noopDiagnostics,
    this._maxAttempts = defaultMaxAttempts,
    this._retryBackoff = defaultRetryBackoff,
  });

  @override
  Future<void> closeConnectSlot({required String slotPda, String? viewer}) async {
    final serviceWallet = await _resolveServiceWallet();
    if (serviceWallet == null) return; // reclaim disabled for this session

    // Idempotency: an already-closed/absent slot has no account to read. A read
    // failure must not strand teardown — skip and leave it for `cleanup_*`.
    final ConnectSlotData? slot;
    try {
      slot = await _chain.fetchSlot(slotPda);
    } on Object catch (error) {
      _diagnostics('close_connect_slot $slotPda: slot read failed ($error); skipped');

      return;
    }
    if (slot == null) {
      _diagnostics('close_connect_slot $slotPda: already closed; idempotent success');

      return;
    }

    final host = _signer.publicKey;
    final ix = buildCloseConnectSlot(
      host: host,
      slotPda: Ed25519HDPublicKey.fromBase58(slotPda),
      viewer: _viewerFor(viewer, slot, host),
      configPda: await deriveConfigPda(),
      serviceWallet: serviceWallet,
    );
    await _send(ix, 'close_connect_slot $slotPda');
  }

  @override
  Future<void> endRoom({required String roomPda}) async {
    // Gated on config availability: with no service wallet the slots cannot be
    // closed, so the room cannot reach a closeable state anyway — reclaim is
    // disabled for the session (leak == baseline).
    if (await _resolveServiceWallet() == null) return;
    final ix = await buildEndRoom(
      host: _signer.publicKey,
      roomPda: Ed25519HDPublicKey.fromBase58(roomPda),
    );
    // RoomAlreadyEnded ⇒ the room is already not-live: idempotent success.
    await _send(ix, 'end_room $roomPda', idempotentCodes: const {SolanaErrorCodes.roomAlreadyEnded});
  }

  @override
  Future<void> closeRoom({required String roomPda}) async {
    if (await _resolveServiceWallet() == null) return; // reclaim disabled (see endRoom)
    final ix = await buildCloseRoom(
      host: _signer.publicKey,
      roomPda: Ed25519HDPublicKey.fromBase58(roomPda),
    );
    await _send(ix, 'close_room $roomPda');
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
      _diagnostics('reclaim disabled: ProgramConfig read failed ($error)');
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
  /// `DepositMismatch` (6023) and transient (code-less) errors are retried;
  /// any other failure is recorded and swallowed (left for `cleanup_*`).
  Future<void> _send(
    Instruction ix,
    String label, {
    Set<int> idempotentCodes = const {},
  }) async {
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        await _signer.signAndSend([ix]);

        return;
      } on Object catch (error) {
        final code = solanaCustomErrorCode(error);
        if (code != null && idempotentCodes.contains(code)) {
          _diagnostics('$label: ${solanaErrorName(code)}; idempotent success');

          return;
        }
        if (_isAccountGone(error)) {
          _diagnostics('$label: account already closed; idempotent success');

          return;
        }
        final retryable = code == SolanaErrorCodes.depositMismatch || _isTransient(error, code);
        if (!retryable || attempt == _maxAttempts) {
          final named = code == null ? '$error' : (solanaErrorName(code) ?? 'custom $code');
          _diagnostics('$label: giving up after $attempt attempt(s): $named');

          return;
        }
        final reason = code == SolanaErrorCodes.depositMismatch
            ? solanaErrorName(SolanaErrorCodes.depositMismatch) ?? 'DepositMismatch'
            : 'transient';
        _diagnostics('$label: attempt $attempt failed ($reason); retrying');
        await Future<void>.delayed(_retryBackoff);
      }
    }
  }

  /// True when [error] indicates the target account no longer exists — closing
  /// an already-closed account is idempotent success, not a failure.
  bool _isAccountGone(Object error) {
    if (error is! JsonRpcException) return false;
    if (error.transactionError == TransactionError.accountNotFound) return true;
    final message = error.message.toLowerCase();

    return message.contains('account does not exist') ||
        message.contains('accountnotinitialized') ||
        message.contains('could not find account');
  }

  /// True for retryable transient failures: a code-less RPC/network error that
  /// is not an already-gone account (which is success, handled separately).
  bool _isTransient(Object error, int? code) => code == null && !_isAccountGone(error);
}
