import 'dart:async';
import 'dart:convert' as dc;
import 'dart:typed_data';

import 'package:signaling/src/application/connection_url_codec.dart';
import 'package:signaling/src/application/fetched_offer.dart';
import 'package:signaling/src/application/signal_payload_codec.dart';
import 'package:signaling/src/application/signaling_chain_gateway.dart';
import 'package:signaling/src/application/signaling_protocol_constants.dart';
import 'package:signaling/src/application/signaling_reclaim_gateway.dart';
import 'package:signaling/src/application/signaling_session.dart';
import 'package:signaling/src/domain/connect_slot_data.dart';
import 'package:signaling/src/domain/connect_slot_state.dart';
import 'package:signaling/src/domain/room_creation_params.dart';
import 'package:solana_wallet/solana_wallet.dart';

/// Application service for Solana on-chain WebRTC P2P signaling.
///
/// Depends on [SignalingChainGateway] for on-chain ops and on the wallet's
/// [WalletAccount] port for the funding precondition — knows nothing about
/// Solana RPC, Borsh, AES-GCM, or keypair storage.
class SolanaSignaling {
  final SignalingChainGateway _chain;
  final SignalPayloadCodec _codec;
  final WalletAccount _account;
  final SignalingReclaimGateway _reclaim;
  final _urlCodec = const ConnectionUrlCodec();

  /// Poll cadence and attempt caps for on-chain slot-state polling. Default to
  /// [SignalingProtocolConstants]; overridable so tests can poll without waiting.
  final Duration _pollInterval;
  final int _maxOfferPollAttempts;
  final int _maxAnswerPollAttempts;

  const SolanaSignaling({
    required this._chain,
    required this._codec,
    required this._account,
    this._reclaim = const UnsupportedSignalingReclaimGateway(),
    this._pollInterval = SignalingProtocolConstants.pollInterval,
    this._maxOfferPollAttempts = SignalingProtocolConstants.maxOfferPollAttempts,
    this._maxAnswerPollAttempts =
        SignalingProtocolConstants.maxAnswerPollAttempts,
  });

  // ── Publisher ──────────────────────────────────────────────────────────────

  Future<SignalingSession> goLive(
    String sdpOfferJson, {
    RoomCreationParams room = const RoomCreationParams.p2pFree(),
  }) async {
    final funded = await _account.ensureFunded();
    if (!funded) {
      throw StateError('Wallet not funded. Add SOL to ${_account.address}');
    }

    final roomNonce = _randomU64();
    final slotNonce = _randomU64();
    final prot = dc.base64.encode(_codec.randomBytes(SignalingProtocolConstants.protKeyByteLength));

    final addresses = await _chain.openSignalingSlot(
      roomNonce: roomNonce,
      slotNonce: slotNonce,
      room: room,
    );

    // Deposits have landed on-chain. Any failure past this point must reclaim
    // them — the saga's compensation step (no-op until the IDL-backed reclaim
    // gateway is wired; see [SignalingReclaimGateway]).
    try {
      final payload = await _codec.encode(sdpOfferJson, prot, slotNonce, 'offer');
      await _chain.writeOffer(addresses.slotPda, payload);
    } on Object {
      await _compensateOpenedSlot(addresses);
      rethrow;
    }

    return SignalingSession(
      url: _urlCodec.build(
        hostAddress: _account.address,
        roomNonce: roomNonce,
        slotNonce: slotNonce,
        prot: prot,
      ),
      roomPda: addresses.roomPda,
      slotPda: addresses.slotPda,
      prot: prot,
      slotNonce: slotNonce,
      roomNonce: roomNonce,
    );
  }

  Stream<String> watchForAnswer(SignalingSession session) async* {
    for (var i = 0; i < _maxAnswerPollAttempts; i++) {
      await Future.delayed(_pollInterval);

      ConnectSlotData? slot;
      try {
        slot = await _chain.fetchSlot(session.slotPda);
      } on Exception {
        continue;
      }
      if (slot == null) continue;

      if (slot.state == ConnectSlotState.expired) {
        throw StateError('Connection slot expired before a viewer connected.');
      }
      if (slot.state == ConnectSlotState.answerReady || slot.state == ConnectSlotState.connected) {
        yield await _codec.decode(slot.answerData, session.prot, session.slotNonce, 'answer');

        return;
      }
    }
    throw TimeoutException(
      'No viewer connected before the slot expired',
      _pollInterval * _maxAnswerPollAttempts,
    );
  }

  // ── Viewer ─────────────────────────────────────────────────────────────────

  Future<FetchedOffer> fetchOffer(String connectionUrl) async {
    final params = _urlCodec.parse(connectionUrl);
    final addresses = await _chain.resolveSlotAddresses(params);

    final funded = await _account.ensureFunded();
    if (!funded) {
      throw StateError('Wallet not funded. Add SOL to ${_account.address}');
    }

    final slot = await _chain.fetchSlot(addresses.slotPda);
    if (slot == null) {
      throw StateError('Host has not started the broadcast yet. Try again in a moment.');
    }
    if (!_isUnclaimed(slot) && !_isClaimedByMe(slot)) {
      throw StateError('This connection link has already been claimed by another viewer.');
    }
    if (_isUnclaimed(slot)) {
      await _chain.claimSlot(
        slotPda: addresses.slotPda,
        roomPda: addresses.roomPda,
      );
    }

    for (var i = 0; i < _maxOfferPollAttempts; i++) {
      await Future.delayed(_pollInterval);
      final polled = await _chain.fetchSlot(addresses.slotPda);
      if (polled == null) continue;
      if (polled.state == ConnectSlotState.expired) {
        throw StateError('Connection slot expired before an offer was published.');
      }
      if (_offerAvailable(polled.state)) {
        final sdp = await _codec.decode(polled.offerData, params.prot, params.slotNonce, 'offer');

        return FetchedOffer(
          sdpOffer: sdp,
          slotPda: addresses.slotPda,
          roomPda: addresses.roomPda,
          prot: params.prot,
          slotNonce: params.slotNonce,
        );
      }
    }
    throw TimeoutException(
      'Offer not found on chain',
      _pollInterval * _maxOfferPollAttempts,
    );
  }

  Future<void> submitAnswer(FetchedOffer offer, String sdpAnswerJson) async {
    final payload = await _codec.encode(sdpAnswerJson, offer.prot, offer.slotNonce, 'answer');
    await _chain.writeAnswer(offer.slotPda, payload);
  }

  // ── Both ───────────────────────────────────────────────────────────────────

  Future<void> confirmConnection(String slotPda) => _chain.confirmConnection(slotPda);

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Best-effort compensation for a `goLive` that opened a slot but then failed.
  /// Reclaims the slot and room deposits; never throws, so it cannot mask the
  /// original failure being rethrown by the caller.
  Future<void> _compensateOpenedSlot(SlotAddresses addresses) async {
    try {
      await _reclaim.closeSlot(addresses.slotPda);
      await _reclaim.closeRoom(addresses.roomPda);
    } on Object {
      // Reclaim is best-effort; the deposit is left for the IDL-backed gateway
      // (or on-chain expiry refund) rather than surfacing a secondary error.
    }
  }

  int _randomU64() {
    final bytes = _codec.randomBytes(SignalingProtocolConstants.nonceByteLength);

    return bytes.buffer.asByteData().getUint64(0, Endian.little) & SignalingProtocolConstants.int64SignBitMask;
  }

  bool _offerAvailable(ConnectSlotState state) =>
      state == ConnectSlotState.offerReady ||
      state == ConnectSlotState.answerReady ||
      state == ConnectSlotState.connected;

  bool _isUnclaimed(ConnectSlotData slot) => slot.viewer.every((b) => b == 0);

  bool _isClaimedByMe(ConnectSlotData slot) {
    final me = _account.publicKey.bytes;
    if (slot.viewer.length != me.length) return false;
    for (var i = 0; i < me.length; i++) {
      if (slot.viewer[i] != me[i]) return false;
    }

    return true;
  }
}
