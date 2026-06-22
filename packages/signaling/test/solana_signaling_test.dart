import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:signaling/signaling.dart';
import 'package:solana/solana.dart' show Ed25519HDPublicKey;
import 'package:test/test.dart';

import 'fakes/fake_account.dart';
import 'fakes/fake_codec.dart';
import 'fakes/fake_gateway.dart';

ConnectSlotData _slot({
  required ConnectSlotState state,
  Uint8List? viewer,
  List<int> offer = const [],
  List<int> answer = const [],
}) => ConnectSlotData(
  room: Uint8List(32),
  host: Uint8List(32),
  viewer: viewer ?? Uint8List(32), // all-zero = unclaimed
  offerData: Uint8List.fromList(offer),
  answerData: Uint8List.fromList(answer),
  state: state,
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
SolanaSignaling _signaling(
  FakeGateway gateway,
  Ed25519HDPublicKey publicKey,
) => SolanaSignaling(
  chain: gateway,
  codec: FakeCodec(),
  account: FakeAccount(publicKey: publicKey),
  pollInterval: Duration.zero,
  maxOfferPollAttempts: 3,
  maxAnswerPollAttempts: 3,
);

const _session = SignalingSession(
  url: 'sols://connect',
  roomPda: 'ROOM',
  slotPda: 'SLOT',
  prot: 'PROT',
  slotNonce: 2,
  roomNonce: 1,
);

// Valid sols:// URL that ConnectionUrlCodec can parse; values match _session.
const _connectionUrl =
    'sols://connect?host=HOST&rn=1&sn=2&prot=PROT&mode=p2p';

void main() {
  final publicKey = Ed25519HDPublicKey(List<int>.filled(32, 9));

  group('SolanaSignaling.fetchOffer', () {
    test('throws when the host has not started (slot is null)', () {
      expect(
        () => _signaling(FakeGateway([null]), publicKey).fetchOffer(_connectionUrl),
        throwsA(isA<StateError>()),
      );
    });

    test('throws when the slot is already claimed by another viewer', () {
      final other = Uint8List.fromList(List.filled(32, 5));

      expect(
        () => _signaling(
          FakeGateway([
            _slot(
              state: ConnectSlotState.claimed,
              viewer: other,
            ),
          ]),
          publicKey,
        ).fetchOffer(_connectionUrl),
        throwsA(isA<StateError>()),
      );
    });

    test('claims an unclaimed slot, then returns the offer', () async {
      final gateway = FakeGateway([
        _slot(state: ConnectSlotState.open), // precondition: unclaimed
        _slot(state: ConnectSlotState.offerReady, offer: utf8.encode('OFFER')),
      ]);

      final offer = await _signaling(gateway, publicKey).fetchOffer(_connectionUrl);

      expect(offer.sdpOffer, 'OFFER');
      expect(gateway.claimCalls, 1);
    });

    test('does not re-claim a slot already claimed by me', () async {
      final mine = Uint8List.fromList(publicKey.bytes);
      final gateway = FakeGateway([
        _slot(state: ConnectSlotState.claimed, viewer: mine),
        _slot(state: ConnectSlotState.offerReady, offer: utf8.encode('OFFER')),
      ]);

      final offer = await _signaling(gateway, publicKey).fetchOffer(_connectionUrl);

      expect(gateway.claimCalls, 0);
      expect(offer.sdpOffer, 'OFFER');
    });

    test('throws when the slot expires before an offer appears', () {
      final gateway = FakeGateway([
        _slot(state: ConnectSlotState.open),
        _slot(state: ConnectSlotState.expired),
      ]);

      expect(
        () => _signaling(gateway, publicKey).fetchOffer(_connectionUrl),
        throwsA(isA<StateError>()),
      );
    });

    test('times out when no offer appears within the attempt cap', () {
      final gateway = FakeGateway([
        _slot(state: ConnectSlotState.open),
        _slot(state: ConnectSlotState.claimed), // never reaches offerReady
      ]);

      expect(
        () => _signaling(gateway, publicKey).fetchOffer(_connectionUrl),
        throwsA(isA<TimeoutException>()),
      );
    });
  });

  group('SolanaSignaling.watchForAnswer', () {
    test('yields the decrypted answer once answerReady', () async {
      final gateway = FakeGateway([
        _slot(state: ConnectSlotState.answerReady, answer: utf8.encode('ANSWER')),
      ]);

      expect(await _signaling(gateway, publicKey).watchForAnswer(_session).first, 'ANSWER');
    });

    test('errors when the slot expires before an answer', () {
      final gateway = FakeGateway([_slot(state: ConnectSlotState.expired)]);

      expect(
        _signaling(gateway, publicKey).watchForAnswer(_session).first,
        throwsA(isA<StateError>()),
      );
    });

    test('times out when no answer appears within the attempt cap', () {
      final gateway = FakeGateway([_slot(state: ConnectSlotState.claimed)]);

      expect(
        _signaling(gateway, publicKey).watchForAnswer(_session).first,
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
