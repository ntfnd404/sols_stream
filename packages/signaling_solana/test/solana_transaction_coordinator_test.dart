import 'dart:async';

import 'package:signaling/signaling.dart';
import 'package:signaling_solana/src/data/solana_transaction_coordinator.dart';
import 'package:solana/encoder.dart' show ByteArray, Instruction;
import 'package:solana/solana.dart';
import 'package:solana_wallet/solana_wallet.dart';
import 'package:test/test.dart';

import 'fakes/recording_signer.dart';

final class _RecordingFundingService implements SolanaFundingService {
  final bool result;
  final Object? failure;
  final List<String> events;
  int calls = 0;

  _RecordingFundingService({
    this.result = true,
    this.failure,
    List<String>? events,
  }) : events = events ?? [];

  @override
  Future<bool> ensureFunded() async {
    calls += 1;
    events.add('funding$calls');
    if (failure case final error?) throw error;

    return result;
  }
}

final class _BlockingSigner implements SolanaSigner {
  @override
  final Ed25519HDPublicKey publicKey;
  final List<String> events;
  final Completer<void> firstSendStarted = Completer<void>();
  final Completer<void> releaseFirstSend = Completer<void>();
  int sends = 0;

  _BlockingSigner(this.publicKey, this.events);

  @override
  Future<String> signAndSend(List<Instruction> instructions) async {
    sends += 1;
    events.add('send$sends');
    if (sends == 1) {
      firstSendStarted.complete();
      await releaseFirstSend.future;
    }

    return 'signature$sends';
  }

  @override
  Future<String> signForProof(List<Instruction> instructions) async => 'proof';
}

void main() {
  final publicKey = Ed25519HDPublicKey(List<int>.filled(32, 1));

  test('serializes the full funding check and broadcast operation', () async {
    final events = <String>[];
    final delegate = _BlockingSigner(publicKey, events);
    final funding = _RecordingFundingService(events: events);
    final coordinator = SolanaTransactionCoordinator(
      signer: delegate,
      funding: funding,
    );

    final first = coordinator.fundedSigner.signAndSend(const []);
    await delegate.firstSendStarted.future;
    final second = coordinator.fundedSigner.signAndSend(const []);
    await Future<void>.delayed(Duration.zero);

    expect(funding.calls, 1);
    delegate.releaseFirstSend.complete();
    await Future.wait([first, second]);

    expect(funding.calls, 2);
    expect(events, ['funding1', 'send1', 'funding2', 'send2']);
  });

  test('snapshots the instruction list before the operation is queued', () async {
    final delegate = RecordingSigner(publicKey);
    final coordinator = SolanaTransactionCoordinator(
      signer: delegate,
      funding: _RecordingFundingService(),
    );
    final instruction = Instruction(
      programId: publicKey,
      accounts: const [],
      data: const ByteArray.empty(),
    );
    final mutable = <Instruction>[instruction];

    final pending = coordinator.fundedSigner.signAndSend(mutable);
    mutable.clear();
    await pending;

    expect(delegate.sent.single, [instruction]);
  });

  test('funded and bypass views share one queue', () async {
    final events = <String>[];
    final delegate = _BlockingSigner(publicKey, events);
    final funding = _RecordingFundingService(events: events);
    final coordinator = SolanaTransactionCoordinator(
      signer: delegate,
      funding: funding,
    );

    final funded = coordinator.fundedSigner.signAndSend(const []);
    await delegate.firstSendStarted.future;
    final bypass = coordinator.bypassSigner.signAndSend(const []);
    await Future<void>.delayed(Duration.zero);

    expect(delegate.sends, 1);
    delegate.releaseFirstSend.complete();
    await Future.wait([funded, bypass]);

    expect(funding.calls, 1);
    expect(events, ['funding1', 'send1', 'send2']);
  });

  test('queue continues after a transaction failure', () async {
    final failure = StateError('failed');
    final delegate = RecordingSigner(publicKey, failures: [failure]);
    final funding = _RecordingFundingService();
    final coordinator = SolanaTransactionCoordinator(
      signer: delegate,
      funding: funding,
    );

    await expectLater(
      coordinator.fundedSigner.signAndSend(const []),
      throwsA(same(failure)),
    );
    expect(
      await coordinator.fundedSigner.signAndSend(const []),
      'sig1',
    );

    expect(funding.calls, 2);
    expect(delegate.sent, hasLength(2));
  });

  test('sanitizes funding exceptions at the signaling boundary', () async {
    const sourceFailure = JsonRpcException('secret response', -1, null);
    final diagnostics = <String>[];
    final coordinator = SolanaTransactionCoordinator(
      signer: RecordingSigner(publicKey),
      funding: _RecordingFundingService(failure: sourceFailure),
      diagnostics: diagnostics.add,
    );

    await expectLater(
      coordinator.fundedSigner.signAndSend(const []),
      throwsA(
        isA<SignalingFundingUnavailableException>().having(
          (error) => error.toString(),
          'sanitized message',
          isNot(contains('secret')),
        ),
      ),
    );
    expect(
      diagnostics,
      ['transaction.funding.failed type=JsonRpcException'],
    );
  });

  test('diagnostics failure does not replace the funding exception', () async {
    final coordinator = SolanaTransactionCoordinator(
      signer: RecordingSigner(publicKey),
      funding: _RecordingFundingService(
        failure: const JsonRpcException('secret response', -1, null),
      ),
      diagnostics: (_) => throw StateError('diagnostics unavailable'),
    );

    await expectLater(
      coordinator.fundedSigner.signAndSend(const []),
      throwsA(isA<SignalingFundingUnavailableException>()),
    );
  });

  test('unfunded result prevents broadcast', () async {
    final delegate = RecordingSigner(publicKey);
    final coordinator = SolanaTransactionCoordinator(
      signer: delegate,
      funding: _RecordingFundingService(result: false),
    );

    await expectLater(
      coordinator.fundedSigner.signAndSend(const []),
      throwsA(isA<SignalingFundingUnavailableException>()),
    );
    expect(delegate.sent, isEmpty);
  });

  test('proof signing bypasses funding and the broadcast queue', () async {
    final events = <String>[];
    final delegate = _BlockingSigner(publicKey, events);
    final funding = _RecordingFundingService(events: events);
    final coordinator = SolanaTransactionCoordinator(
      signer: delegate,
      funding: funding,
    );

    final pendingSend = coordinator.fundedSigner.signAndSend(const []);
    await delegate.firstSendStarted.future;

    expect(
      await coordinator.fundedSigner.signForProof(const []),
      'proof',
    );
    expect(funding.calls, 1);

    delegate.releaseFirstSend.complete();
    await pendingSend;
  });
}
