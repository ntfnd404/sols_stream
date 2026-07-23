import 'dart:async';

import 'package:signaling/signaling.dart';
import 'package:solana/encoder.dart' show Instruction;
import 'package:solana/solana.dart' show Ed25519HDPublicKey;
import 'package:solana_wallet/solana_wallet.dart';

/// Serializes every signaling broadcast for one wallet.
///
/// Funded and bypass views share the same FIFO queue. Funding is checked inside
/// the queued operation so every funded transaction observes the balance after
/// the preceding broadcast has completed.
final class SolanaTransactionCoordinator {
  late final SolanaSigner fundedSigner = _CoordinatedSolanaSigner(
    this,
    requiresFunding: true,
  );
  late final SolanaSigner bypassSigner = _CoordinatedSolanaSigner(
    this,
    requiresFunding: false,
  );

  final SolanaSigner _delegate;
  final SolanaFundingService _funding;
  final SignalingDiagnostics _diagnostics;
  Future<void> _tail = Future<void>.value();

  Ed25519HDPublicKey get publicKey => _delegate.publicKey;

  factory SolanaTransactionCoordinator({
    required SolanaSigner signer,
    required SolanaFundingService funding,
    SignalingDiagnostics diagnostics = noOpSignalingDiagnostics,
  }) => SolanaTransactionCoordinator._(signer, funding, diagnostics);

  SolanaTransactionCoordinator._(
    this._delegate,
    this._funding,
    this._diagnostics,
  );

  Future<String> _signAndSend(
    List<Instruction> instructions, {
    required bool requiresFunding,
  }) {
    final snapshot = List<Instruction>.unmodifiable(instructions);
    final operation = _tail.then(
      (_) => _execute(
        snapshot,
        requiresFunding: requiresFunding,
      ),
    );
    _tail = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );

    return operation;
  }

  Future<String> _execute(
    List<Instruction> instructions, {
    required bool requiresFunding,
  }) async {
    if (requiresFunding) {
      final bool funded;
      try {
        funded = await _funding.ensureFunded();
      } on Exception catch (error, stackTrace) {
        _diagnose(
          'transaction.funding.failed type=${error.runtimeType}',
        );
        Error.throwWithStackTrace(
          const SignalingFundingUnavailableException(),
          stackTrace,
        );
      }
      if (!funded) {
        _diagnose('transaction.funding.unavailable');
        throw const SignalingFundingUnavailableException();
      }
    }

    return _delegate.signAndSend(instructions);
  }

  Future<String> _signForProof(List<Instruction> instructions) =>
      _delegate.signForProof(List<Instruction>.unmodifiable(instructions));

  void _diagnose(String event) {
    try {
      _diagnostics(event);
    } on Object {
      // Diagnostics must never replace the sanitized boundary exception.
    }
  }
}

final class _CoordinatedSolanaSigner implements SolanaSigner {
  final SolanaTransactionCoordinator _coordinator;
  final bool _requiresFunding;

  @override
  Ed25519HDPublicKey get publicKey => _coordinator.publicKey;

  const _CoordinatedSolanaSigner(
    this._coordinator, {
    required this._requiresFunding,
  });

  @override
  Future<String> signAndSend(List<Instruction> instructions) => _coordinator._signAndSend(
    instructions,
    requiresFunding: _requiresFunding,
  );

  @override
  Future<String> signForProof(List<Instruction> instructions) => _coordinator._signForProof(instructions);
}
