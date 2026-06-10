import 'dart:async';
import 'dart:convert' as dc;
import 'dart:typed_data';

import 'package:signaling/src/application/fetched_offer.dart';
import 'package:signaling/src/application/signal_payload_codec.dart';
import 'package:signaling/src/application/signaling_chain_gateway.dart';
import 'package:signaling/src/application/signaling_protocol_constants.dart';
import 'package:signaling/src/application/signaling_session.dart';
import 'package:signaling/src/domain/connect_slot_data.dart';
import 'package:signaling/src/domain/connect_slot_state.dart';
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

  const SolanaSignaling({
    required this._chain,
    required this._codec,
    required this._account,
  });

  // ── Publisher ──────────────────────────────────────────────────────────────

  Future<SignalingSession> goLive(String sdpOfferJson) async {
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
    );

    final payload = await _codec.encode(sdpOfferJson, prot, slotNonce);
    await _chain.writeOffer(addresses.slotPda, payload);

    return SignalingSession(
      url: _chain.buildConnectionUrl(
        roomNonce: roomNonce,
        slotNonce: slotNonce,
        prot: prot,
      ),
      slotPda: addresses.slotPda,
      prot: prot,
      slotNonce: slotNonce,
      roomNonce: roomNonce,
    );
  }

  Stream<String> watchForAnswer(SignalingSession session) async* {
    for (var i = 0; i < SignalingProtocolConstants.maxAnswerPollAttempts; i++) {
      await Future.delayed(SignalingProtocolConstants.pollInterval);

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
        yield await _codec.decode(slot.answerData, session.prot, session.slotNonce);

        return;
      }
    }
    throw TimeoutException(
      'No viewer connected before the slot expired',
      SignalingProtocolConstants.pollInterval * SignalingProtocolConstants.maxAnswerPollAttempts,
    );
  }

  // ── Viewer ─────────────────────────────────────────────────────────────────

  Future<FetchedOffer> fetchOffer(String connectionUrl) async {
    final params = _chain.parseConnectionUrl(connectionUrl);
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

    for (var i = 0; i < SignalingProtocolConstants.maxOfferPollAttempts; i++) {
      await Future.delayed(SignalingProtocolConstants.pollInterval);
      final polled = await _chain.fetchSlot(addresses.slotPda);
      if (polled == null) continue;
      if (polled.state == ConnectSlotState.expired) {
        throw StateError('Connection slot expired before an offer was published.');
      }
      if (_offerAvailable(polled.state)) {
        final sdp = await _codec.decode(polled.offerData, params.prot, params.slotNonce);

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
      SignalingProtocolConstants.pollInterval * SignalingProtocolConstants.maxOfferPollAttempts,
    );
  }

  Future<void> submitAnswer(FetchedOffer offer, String sdpAnswerJson) async {
    final payload = await _codec.encode(sdpAnswerJson, offer.prot, offer.slotNonce);
    await _chain.writeAnswer(offer.slotPda, payload);
  }

  // ── Both ───────────────────────────────────────────────────────────────────

  Future<void> confirmConnection(String slotPda) => _chain.confirmConnection(slotPda);

  // ── Helpers ────────────────────────────────────────────────────────────────

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
