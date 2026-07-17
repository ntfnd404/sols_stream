import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:signaling/signaling.dart';
import 'package:signaling/src/application/base58_codec.dart';
import 'package:signaling/src/data/crypto/passphrase_payload_crypto.dart';
import 'package:test/test.dart';

import 'fakes/failing_key_broker_gateway.dart';
import 'fakes/fake_key_broker_gateway.dart';
import 'fakes/fake_protected_slot_gateway.dart';
import 'fakes/immediate_polling_scheduler.dart';
import 'fakes/peer_chain_gateway.dart';
import 'fakes/recording_key_broker_gateway.dart';
import 'fakes/recording_reclaim_gateway.dart';

// Passphrase the fake viewer uses to encrypt its answer.
const _viewerPassphrase = 'test-viewer-passphrase';
// Simulated SDP answer the viewer encrypts and writes on-chain.
const _answerJson = '{"type":"answer","sdp":"v=0 test-sdp"}';
const _roomAddress = '11111111111111111111111111111111';
// Non-zero viewer bytes — "someone claimed the slot".
final _viewerBytes = Uint8List.fromList(List.filled(32, 7));

ConnectSlotData _openSlot() => ConnectSlotData(
  room: Uint8List(32),
  host: Uint8List(32),
  viewer: Uint8List(32), // all-zero = unclaimed
  hostProtectedKey: Uint8List(0),
  viewerProtectedKey: Uint8List(0),
  offerData: Uint8List(0),
  answerData: Uint8List(0),
  state: ConnectSlotState.open,
  createdAt: BigInt.zero,
  expiresAt: BigInt.zero,
  hostDeposit: BigInt.zero,
  viewerDeposit: BigInt.zero,
  hostRentPaid: BigInt.zero,
  viewerRentPaid: BigInt.zero,
  accessPrice: BigInt.zero,
  hostConfirmed: false,
  viewerConfirmed: false,
);

ConnectSlotData _claimedSlot() => ConnectSlotData(
  room: Uint8List(32),
  host: Uint8List(32),
  viewer: _viewerBytes,
  hostProtectedKey: Uint8List(0),
  viewerProtectedKey: Uint8List(0),
  offerData: Uint8List(0),
  answerData: Uint8List(0),
  state: ConnectSlotState.claimed,
  createdAt: BigInt.zero,
  expiresAt: BigInt.zero,
  hostDeposit: BigInt.zero,
  viewerDeposit: BigInt.zero,
  hostRentPaid: BigInt.zero,
  viewerRentPaid: BigInt.zero,
  accessPrice: BigInt.zero,
  hostConfirmed: false,
  viewerConfirmed: false,
);

ConnectSlotData _answerReadySlot(Uint8List encryptedAnswer) => ConnectSlotData(
  room: Uint8List(32),
  host: Uint8List(32),
  viewer: _viewerBytes,
  hostProtectedKey: Uint8List(0),
  viewerProtectedKey: Uint8List.fromList(utf8.encode('viewer-key')),
  offerData: Uint8List(0),
  answerData: encryptedAnswer,
  state: ConnectSlotState.answerReady,
  createdAt: BigInt.zero,
  expiresAt: BigInt.zero,
  hostDeposit: BigInt.zero,
  viewerDeposit: BigInt.zero,
  hostRentPaid: BigInt.zero,
  viewerRentPaid: BigInt.zero,
  accessPrice: BigInt.zero,
  hostConfirmed: false,
  viewerConfirmed: false,
);

OnChainPeerSignaling _buildSignaling({
  required PeerChainGateway chain,
  required FakeProtectedSlotGateway interop,
  KeyBrokerGateway? broker,
  int maxAnswerAttempts = 10,
  Uri? peerInviteBaseUrl,
  SignalingReclaimGateway? reclaim,
  SignalingDiagnostics diagnostics = noOpSignalingDiagnostics,
}) => OnChainPeerSignaling(
  slots: interop,
  chain: chain,
  broker: broker ?? const FakeKeyBrokerGateway(passphraseToUnprotect: _viewerPassphrase),
  identity: SignalingParticipantIdentity.fromPublicKey(
    publicKeyBytes: List<int>.filled(32, 0),
    addressEncoder: base58Encode,
  ),
  peerInviteBase: const PeerInviteCodec().parseBase(
    peerInviteBaseUrl ??
        Uri.parse(
          'https://p2p.sols.stream/home?intent=p2p&role=viewer',
        ),
  ),
  reclaim: reclaim ?? const UnsupportedSignalingReclaimGateway(),
  polling: ImmediatePollingScheduler(maxAnswerAttempts: maxAnswerAttempts),
  diagnostics: diagnostics,
);

void main() {
  late Uint8List encryptedAnswer;

  setUpAll(() async {
    // Compute the encrypted answer the fake viewer will have written on-chain.
    final envelope = await PassphrasePayloadCrypto.encrypt(
      _answerJson,
      _viewerPassphrase,
    );
    encryptedAnswer = Uint8List.fromList(utf8.encode(envelope));
  });

  group('OnChainPeerSignaling.publishOffer', () {
    test('protects the offer key for the full invite lifetime', () async {
      final broker = RecordingKeyBrokerGateway();
      final signaling = _buildSignaling(
        chain: PeerChainGateway([_openSlot()]),
        interop: FakeProtectedSlotGateway(),
        broker: broker,
      );

      await signaling.publishOffer('{"type":"offer","sdp":"v=0"}');

      expect(broker.lastTtl, const Duration(hours: 24));
    });

    test('returns a connection URL without writing the offer', () async {
      final interop = FakeProtectedSlotGateway();
      final chain = PeerChainGateway([_openSlot()]);
      final signaling = _buildSignaling(chain: chain, interop: interop);

      final session = await signaling.publishOffer('{"type":"offer","sdp":"v=0"}');

      expect(session.connectionUrl, contains('p2p.sols.stream'));
      expect(interop.writeOfferCalls, 0, reason: 'write_offer must be deferred until the slot is claimed');
    });

    test('does not write offer while the slot is still Open', () async {
      final interop = FakeProtectedSlotGateway();
      // Three Open polls, then times out.
      final chain = PeerChainGateway([_openSlot()]);
      final signaling = _buildSignaling(
        chain: chain,
        interop: interop,
        maxAnswerAttempts: 3,
      );

      final session = await signaling.publishOffer('{"type":"offer","sdp":"v=0"}');
      await expectLater(session.awaitAnswerSdp(), throwsA(isA<TimeoutException>()));

      expect(interop.writeOfferCalls, 0, reason: 'write_offer must not be sent while slot is Open');
    });

    test('writes offer exactly once after the slot is claimed', () async {
      final interop = FakeProtectedSlotGateway();
      final chain = PeerChainGateway([
        _openSlot(), // poll 1 — still Open, no write
        _claimedSlot(), // poll 2 — Claimed → write offer
        _claimedSlot(), // poll 3 — still waiting for answer
        _claimedSlot(), // (repeated until timeout)
      ]);
      final signaling = _buildSignaling(
        chain: chain,
        interop: interop,
        maxAnswerAttempts: 4,
      );

      final session = await signaling.publishOffer('{"type":"offer","sdp":"v=0"}');
      expect(interop.writeOfferCalls, 0); // not yet

      await expectLater(session.awaitAnswerSdp(), throwsA(isA<TimeoutException>()));
      expect(interop.writeOfferCalls, 1, reason: 'write_offer must be sent exactly once after Claimed');
    });

    test('teardown reclaims slot then room exactly once', () async {
      final interop = FakeProtectedSlotGateway();
      final chain = PeerChainGateway([_openSlot()]);
      final reclaim = RecordingReclaimGateway();
      final diagnostics = <String>[];
      final signaling = _buildSignaling(
        chain: chain,
        interop: interop,
        reclaim: reclaim,
        diagnostics: diagnostics.add,
      );

      final session = await signaling.publishOffer('{"type":"offer","sdp":"v=0"}');
      await session.teardown();
      await session.teardown();

      expect(
        reclaim.calls,
        [
          'closeConnectSlot:SLOT',
          'endRoom:$_roomAddress',
          'closeRoom:$_roomAddress',
        ],
      );
      expect(chain.endRoomCalls, 0);
      expect(chain.closeRoomCalls, 0);
      expect(
        diagnostics,
        containsAllInOrder([
          'host.teardown.close_slot.succeeded',
          'host.teardown.end_room.succeeded',
          'host.teardown.close_room.succeeded',
        ]),
      );
    });

    test('teardown isolates failures and never reports false completion', () async {
      final reclaim = RecordingReclaimGateway(
        throwOnCloseConnectSlot: StateError('slot'),
        throwOnEndRoom: StateError('end'),
        throwOnCloseRoom: StateError('room'),
      );
      final diagnostics = <String>[];
      final signaling = _buildSignaling(
        chain: PeerChainGateway([_openSlot()]),
        interop: FakeProtectedSlotGateway(),
        reclaim: reclaim,
        diagnostics: diagnostics.add,
      );

      final session = await signaling.publishOffer(
        '{"type":"offer","sdp":"v=0"}',
      );
      await session.teardown();

      expect(
        reclaim.calls,
        [
          'closeConnectSlot:SLOT',
          'endRoom:$_roomAddress',
          'closeRoom:$_roomAddress',
        ],
      );
      expect(
        diagnostics,
        containsAllInOrder([
          'host.teardown.close_slot.failed type=StateError',
          'host.teardown.end_room.failed type=StateError',
          'host.teardown.close_room.failed type=StateError',
        ]),
      );
      expect(
        diagnostics.where(
          (event) => event.startsWith('host.teardown.') && event.endsWith('.completed'),
        ),
        isEmpty,
      );
    });

    test(
      'compensates every host account when setup fails after opening the slot',
      () async {
        final originalError = StateError('broker unavailable');
        final reclaim = RecordingReclaimGateway(
          throwOnCloseConnectSlot: StateError('slot reclaim failed'),
        );
        final diagnostics = <String>[];
        final signaling = _buildSignaling(
          chain: PeerChainGateway([_openSlot()]),
          interop: FakeProtectedSlotGateway(),
          broker: FailingKeyBrokerGateway(originalError),
          reclaim: reclaim,
          diagnostics: diagnostics.add,
        );

        await expectLater(
          signaling.publishOffer('{"type":"offer","sdp":"v=0"}'),
          throwsA(same(originalError)),
        );

        expect(
          reclaim.calls,
          [
            'closeConnectSlot:SLOT',
            'endRoom:$_roomAddress',
            'closeRoom:$_roomAddress',
          ],
        );
        expect(
          diagnostics,
          containsAllInOrder([
            'host.offer_key_protection.failed type=StateError',
            'host.compensation.started',
            'host.compensation.close_slot.failed type=StateError',
            'host.compensation.end_room.succeeded',
            'host.compensation.close_room.succeeded',
          ]),
        );
      },
    );

    test('connection URL uses the injected local peer invite base URL', () async {
      final diagnostics = <String>[];
      final interop = FakeProtectedSlotGateway();
      final chain = PeerChainGateway([_openSlot()]);
      final signaling = _buildSignaling(
        chain: chain,
        interop: interop,
        peerInviteBaseUrl: Uri.parse(
          'http://localhost:8080/home?intent=p2p&role=viewer',
        ),
        diagnostics: diagnostics.add,
      );

      final session = await signaling.publishOffer(
        '{"type":"offer","sdp":"v=0"}',
      );
      final url = Uri.parse(session.connectionUrl);

      expect(url.origin, 'http://localhost:8080');
      expect(url.path, '/home');
      expect(url.queryParameters['intent'], 'p2p');
      expect(url.queryParameters['role'], 'viewer');
      expect(url.queryParameters['host'], isNotEmpty);
      expect(url.queryParameters['public'], '1');
      expect(url.queryParameters.containsKey('mode'), isFalse);
      expect(
        diagnostics,
        containsAllInOrder([
          'host.go_live.started',
          'host.slot_open.completed',
          'host.offer_key_protection.completed',
          'host.invite.created',
        ]),
      );
    });

    test('P2P invite does not duplicate the session mode', () async {
      final interop = FakeProtectedSlotGateway();
      final chain = PeerChainGateway([_openSlot()]);
      final signaling = _buildSignaling(chain: chain, interop: interop);

      final session = await signaling.publishOffer(
        '{"type":"offer","sdp":"v=0"}',
      );

      final url = Uri.parse(session.connectionUrl);
      expect(url.queryParameters['intent'], 'p2p');
      expect(url.queryParameters['role'], 'viewer');
      expect(url.queryParameters.containsKey('mode'), isFalse);
    });

    test('cancelWaiting stops polling immediately — no further fetchSlot calls', () async {
      final interop = FakeProtectedSlotGateway();
      // Never claimed — without cancellation this would poll forever.
      final chain = PeerChainGateway([_openSlot()]);
      final signaling = _buildSignaling(chain: chain, interop: interop, maxAnswerAttempts: 1000);

      final session = await signaling.publishOffer('{"type":"offer","sdp":"v=0"}');
      final answerFuture = session.awaitAnswerSdp();
      session.cancelWaiting();

      await expectLater(answerFuture, throwsA(isA<StateError>()));
      expect(chain.fetchSlotCalls, 0, reason: 'cancellation must pre-empt the loop before any chain read');
    });

    test('awaitAnswerSdp decrypts the viewer answer after offer is written', () async {
      // encryptedAnswer is computed by setUpAll above.
      final interop = FakeProtectedSlotGateway();
      final chain = PeerChainGateway([
        _openSlot(), // poll 1 — Open, no write
        _claimedSlot(), // poll 2 — Claimed → write offer
        _answerReadySlot(encryptedAnswer), // poll 3 — answer ready → decrypt
      ]);
      final signaling = _buildSignaling(chain: chain, interop: interop);

      final session = await signaling.publishOffer('{"type":"offer","sdp":"v=0"}');
      final answer = await session.awaitAnswerSdp();

      expect(interop.writeOfferCalls, 1);
      final parsed = jsonDecode(answer) as Map<String, dynamic>;
      expect(parsed['type'], 'answer');
      expect(parsed['sdp'], contains('test-sdp'));
    });

    test('retries only explicitly transient slot reads', () async {
      final interop = FakeProtectedSlotGateway();
      final chain = PeerChainGateway([
        const TransientSignalingReadException(),
        _claimedSlot(),
        _answerReadySlot(encryptedAnswer),
      ]);
      final signaling = _buildSignaling(chain: chain, interop: interop);

      final session = await signaling.publishOffer('{"type":"offer","sdp":"v=0"}');
      final answer = await session.awaitAnswerSdp();

      expect(answer, contains('test-sdp'));
      expect(chain.fetchSlotCalls, 3);
    });

    test('does not mask slot integrity failures as polling timeouts', () async {
      final chain = PeerChainGateway([
        const FormatException('malformed known slot'),
      ]);
      final signaling = _buildSignaling(
        chain: chain,
        interop: FakeProtectedSlotGateway(),
      );

      final session = await signaling.publishOffer('{"type":"offer","sdp":"v=0"}');

      await expectLater(
        session.awaitAnswerSdp(),
        throwsA(isA<FormatException>()),
      );
      expect(chain.fetchSlotCalls, 1);
    });
  });

  group('OnChainPeerSignaling.fetchOffer', () {
    test('rejects a discovered slot whose host differs from the invite', () async {
      final signaling = _buildSignaling(
        chain: PeerChainGateway([_openSlot()]),
        interop: FakeProtectedSlotGateway(
          discoveryResult: DiscoveredSlot(
            slotPda: 'slot',
            roomPda: base58Encode(_openSlot().room),
            slot: _openSlot(),
          ),
        ),
      );

      await expectLater(
        signaling.fetchOffer(
          Uri.parse(
            'https://p2p.sols.stream/home?intent=p2p&role=viewer'
            '&host=11111111111111111111111111111112&public=1',
          ),
        ),
        throwsA(isA<SignalingStateIntegrityException>()),
      );
    });

    test('rejects using the host wallet as viewer before chain access', () async {
      final diagnostics = <String>[];
      final interop = FakeProtectedSlotGateway();
      final signaling = OnChainPeerSignaling(
        slots: interop,
        chain: PeerChainGateway([_openSlot()]),
        broker: const FakeKeyBrokerGateway(
          passphraseToUnprotect: _viewerPassphrase,
        ),
        identity: SignalingParticipantIdentity.fromPublicKey(
          publicKeyBytes: List<int>.filled(32, 1),
          addressEncoder: (_) => 'same-wallet',
        ),
        peerInviteBase: const PeerInviteCodec().parseBase(
          Uri.parse(
            'http://localhost:8080/home?intent=p2p&role=viewer',
          ),
        ),
        diagnostics: diagnostics.add,
      );

      await expectLater(
        signaling.fetchOffer(
          Uri.parse(
            'http://localhost:8080/home?intent=p2p&role=viewer'
            '&host=same-wallet&public=1',
          ),
        ),
        throwsA(isA<PeerSelfConnectionException>()),
      );
      expect(
        diagnostics,
        [
          'viewer.fetch_offer.started',
          'viewer.self_connection.rejected',
        ],
      );
    });

    test('reports an invite claimed by another viewer', () async {
      final diagnostics = <String>[];
      final signaling = _buildSignaling(
        chain: PeerChainGateway([_openSlot()]),
        interop: FakeProtectedSlotGateway(
          discoveryResult: const ProtectedSlotUnavailable(
            ProtectedSlotUnavailableReason.claimedByAnotherViewer,
          ),
        ),
        diagnostics: diagnostics.add,
      );

      await expectLater(
        signaling.fetchOffer(
          Uri.parse(
            'http://localhost:8080/home?intent=p2p&role=viewer'
            '&host=host-wallet&public=1',
          ),
        ),
        throwsA(isA<PeerInviteClaimedException>()),
      );
      expect(
        diagnostics,
        contains(
          'viewer.slot_discovery.claimed_by_another_viewer',
        ),
      );
    });
  });
}
