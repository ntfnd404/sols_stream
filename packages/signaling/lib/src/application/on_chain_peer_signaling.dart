import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:signaling/src/application/base58_codec.dart';
import 'package:signaling/src/application/key_broker_gateway.dart';
import 'package:signaling/src/application/peer_host_session.dart';
import 'package:signaling/src/application/peer_invite_claimed_exception.dart';
import 'package:signaling/src/application/peer_invite_codec.dart';
import 'package:signaling/src/application/peer_offer.dart';
import 'package:signaling/src/application/peer_self_connection_exception.dart';
import 'package:signaling/src/application/peer_signaling.dart';
import 'package:signaling/src/application/protected_slot_gateway.dart';
import 'package:signaling/src/application/reclaim_outcome.dart';
import 'package:signaling/src/application/signaling_chain_gateway.dart';
import 'package:signaling/src/application/signaling_diagnostics.dart';
import 'package:signaling/src/application/signaling_nonce.dart';
import 'package:signaling/src/application/signaling_participant_identity.dart';
import 'package:signaling/src/application/signaling_reclaim_gateway.dart';
import 'package:signaling/src/application/signaling_state_integrity_exception.dart';
import 'package:signaling/src/application/slot_polling_scheduler.dart';
import 'package:signaling/src/application/transient_signaling_read_exception.dart';
import 'package:signaling/src/data/crypto/passphrase_payload_crypto.dart';
import 'package:signaling/src/domain/connect_slot_data.dart';
import 'package:signaling/src/domain/connect_slot_state.dart';

/// Canonical on-chain implementation of [PeerSignaling].
///
/// Web, mobile, and desktop clients use the same protected-slot protocol and
/// differ only in their media adapters.
final class OnChainPeerSignaling implements PeerSignaling {
  final PeerInviteBase peerInviteBase;
  final SignalingDiagnostics diagnostics;
  static const _inviteLifetime = Duration(hours: 24);
  final ProtectedSlotGateway _slots;
  final SignalingChainGateway _chain;
  final KeyBrokerGateway _broker;
  final SignalingParticipantIdentity _identity;
  late final SignalingReclaimGateway _reclaim;
  final SlotPollingScheduler _polling;
  final _urlCodec = const PeerInviteCodec();

  OnChainPeerSignaling({
    required this._slots,
    required this._chain,
    required this._broker,
    required this._identity,
    required this.peerInviteBase,
    SignalingReclaimGateway reclaim = const UnsupportedSignalingReclaimGateway(),
    this._polling = const DefaultSlotPollingScheduler(),
    this.diagnostics = noOpSignalingDiagnostics,
  }) {
    _reclaim = reclaim;
  }

  /// Discovers, claims, and decrypts the offer referenced by [invite].
  ///
  /// Mirrors the web client's `_tryConnectViaSlot`: discover an Open slot in the
  /// host's room, claim it, wait for the host to write the offer, then release
  /// the passphrase from the broker (via a signed proof) and decrypt the offer.
  @override
  Future<PeerOffer> fetchOffer(Uri invite) async {
    diagnostics('viewer.fetch_offer.started');
    final params = _parseViewerConnection(invite);

    diagnostics('viewer.slot_discovery.started');
    final discovery = await _slots.discoverOpenSlot(params.hostAddress);
    final DiscoveredSlot discovered;
    switch (discovery) {
      case DiscoveredSlot():
        discovered = discovery;
      case ProtectedSlotUnavailable(
        reason: ProtectedSlotUnavailableReason.claimedByAnotherViewer,
      ):
        diagnostics('viewer.slot_discovery.claimed_by_another_viewer');
        throw const PeerInviteClaimedException();
      case ProtectedSlotUnavailable():
        diagnostics('viewer.slot_discovery.not_found');
        throw StateError(
          'Host is not live, or has no open connection slot yet. '
          'Try again in a moment.',
        );
    }
    diagnostics('viewer.slot_discovery.found');
    _requireSlotConsistency(
      discovered.slot,
      expectedHost: params.hostAddress,
      expectedRoom: discovered.roomPda,
      requireCurrentViewer: true,
    );

    if (_isUnclaimed(discovered.slot)) {
      await _trace(
        'viewer.slot_claim',
        () => _chain.claimSlot(
          slotPda: discovered.slotPda,
          roomPda: discovered.roomPda,
        ),
      );
    } else if (!_isClaimedByMe(discovered.slot)) {
      diagnostics('viewer.slot_claim.owned_by_another_viewer');
      throw StateError('This connection slot was already claimed by another viewer.');
    } else {
      diagnostics('viewer.slot_claim.already_owned');
    }

    diagnostics('viewer.offer_wait.started');
    final slot = await _awaitOffer(
      discovered.slotPda,
      expectedHost: params.hostAddress,
      expectedRoom: discovered.roomPda,
      requireCurrentViewer: true,
    );
    diagnostics('viewer.offer_wait.ready');
    final hostAddress = base58Encode(slot.host);

    final signedProof = await _trace(
      'viewer.proof_signing',
      () => _slots.buildSignedProof(discovered.slotPda),
    );
    final passphrase = await _trace(
      'viewer.offer_key_release',
      () => _broker.unprotect(
        protectedKey: utf8.decode(slot.hostProtectedKey),
        hostAddress: hostAddress,
        offerId: discovered.slotPda,
        signedProof: signedProof,
        slotPda: discovered.slotPda,
      ),
    );

    final offerJson = await _trace(
      'viewer.offer_decryption',
      () => PassphrasePayloadCrypto.decrypt(
        utf8.decode(slot.offerData),
        passphrase,
      ),
    );
    final sdp = _extractSdp(offerJson);
    diagnostics('viewer.fetch_offer.completed');

    return PeerOffer(
      sdpOffer: jsonEncode({'type': 'offer', 'sdp': sdp}),
      slotPda: discovered.slotPda,
      hostAddress: hostAddress,
    );
  }

  /// Encrypts and writes the viewer's answer for [offer]. [sdpAnswerJson] is a
  /// `{"type":"answer","sdp":...}` document from the WebRTC layer.
  ///
  /// The viewer generates its own passphrase, protects it with the broker (so
  /// the host can release it), writes it as the slot's `viewer_protected_key`,
  /// and encrypts the answer under it (scheme #2).
  @override
  Future<void> submitAnswer(PeerOffer offer, String sdpAnswerJson) async {
    diagnostics('viewer.submit_answer.started');
    final sdp = _extractSdp(sdpAnswerJson);
    final viewerPassphrase = _generatePassphrase();

    final protectedKey = await _trace(
      'viewer.answer_key_protection',
      () => _broker.protect(
        passphrase: viewerPassphrase,
        hostAddress: _identity.address,
        offerId: offer.slotPda,
      ),
    );

    final compactAnswer = jsonEncode({
      'type': 'answer',
      'sdp': sdp,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
    final envelope = await PassphrasePayloadCrypto.encrypt(compactAnswer, viewerPassphrase);

    await _trace(
      'viewer.answer_write',
      () => _slots.writeAnswerWithProtectedKey(
        slotPda: offer.slotPda,
        protectedKey: protectedKey,
        payload: Uint8List.fromList(utf8.encode(envelope)),
      ),
    );
    diagnostics('viewer.submit_answer.completed');
  }

  @override
  Future<void> confirm(PeerOffer offer) => _chain.confirmConnection(offer.slotPda);

  // ── Host (web dialect) ─────────────────────────────────────────────────────

  /// Opens a signaling slot, encrypts [sdpOfferJson] with scheme #2, protects
  /// the passphrase via the key broker, and writes both on-chain.
  ///
  /// Returns a [PeerHostSession] whose [PeerHostSession.connectionUrl] can be
  /// shared with any viewer (native or web) and whose
  /// [PeerHostSession.awaitAnswerSdp] polls until the viewer's encrypted answer
  /// is available, then decrypts and returns it.
  @override
  Future<PeerHostSession> publishOffer(String sdpOfferJson) async {
    diagnostics('host.go_live.started');
    final slotNonce = generateSecureSignalingNonce();

    // readStreamCount() + stale-role cleanup happen inside openSignalingSlot
    // (mirrors JS startAdvertising: re-fetch after cleanup, then streamCount).
    // A generous on-chain expiry: the host should be able to share the link
    // and wait for a viewer without the slot itself expiring underneath the
    // (now unbounded) answer-poll in _awaitClaimWriteOfferThenAnswer.
    final addresses = await _trace(
      'host.slot_open',
      () => _chain.openSignalingSlot(
        slotNonce: slotNonce,
        expiresInSeconds: _inviteLifetime.inSeconds,
      ),
    );
    Future<void>? reclaimFuture;
    Future<void> reclaimHost(String phase) => reclaimFuture ??= _reclaimHost(
      phase: phase,
      slotPda: addresses.slotPda,
      roomPda: addresses.roomPda,
    );

    try {
      // Initial heartbeat failure is non-fatal because the newly opened room
      // can still complete promptly.
      try {
        await _chain.sendHeartbeat();
        diagnostics('host.initial_heartbeat.completed');
      } on Exception catch (error) {
        diagnostics(
          'host.initial_heartbeat.failed type=${error.runtimeType}',
        );
      }

      // Precompute the encrypted offer before polling. The write itself is
      // deferred until the slot is Claimed.
      final passphrase = _generatePassphrase();
      final protectedKey = await _trace(
        'host.offer_key_protection',
        () => _broker.protect(
          passphrase: passphrase,
          hostAddress: _identity.address,
          offerId: addresses.slotPda,
          ttl: _inviteLifetime,
        ),
      );
      final envelope = await PassphrasePayloadCrypto.encrypt(
        sdpOfferJson,
        passphrase,
      );
      final encryptedPayload = Uint8List.fromList(utf8.encode(envelope));

      final connectionUrl = _urlCodec
          .buildViewerInvite(
            base: peerInviteBase,
            hostAddress: _identity.address,
            isPublic: true,
          )
          .toString();
      diagnostics('host.invite.created');

      final cancelled = _CancellationFlag();

      return PeerHostSession(
        connectionUrl: connectionUrl,
        slotPda: addresses.slotPda,
        awaitAnswerSdp: () => _awaitClaimWriteOfferThenAnswer(
          slotPda: addresses.slotPda,
          protectedKey: protectedKey,
          encryptedPayload: encryptedPayload,
          cancelled: cancelled,
          expectedHost: _identity.address,
          expectedRoom: addresses.roomPda,
          requireCurrentViewer: false,
        ),
        confirm: () => _chain.confirmConnection(addresses.slotPda),
        cancelWaiting: cancelled.cancel,
        teardown: () => reclaimHost('host.teardown'),
      );
    } on Object {
      await reclaimHost('host.compensation');
      rethrow;
    }
  }

  Future<void> _reclaimHost({
    required String phase,
    required String slotPda,
    required String roomPda,
  }) async {
    diagnostics('$phase.started');
    await _runReclaimStep(
      phase,
      'close_slot',
      () => _reclaim.closeConnectSlot(slotPda: slotPda),
    );
    await _runReclaimStep(
      phase,
      'end_room',
      () => _reclaim.endRoom(roomPda: roomPda),
    );
    await _runReclaimStep(
      phase,
      'close_room',
      () => _reclaim.closeRoom(roomPda: roomPda),
    );
  }

  Future<void> _runReclaimStep(
    String phase,
    String step,
    Future<ReclaimOutcome> Function() operation,
  ) async {
    try {
      final outcome = await operation();
      diagnostics('$phase.$step.${outcome.name}');
    } on Object catch (error) {
      diagnostics(
        '$phase.$step.failed type=${error.runtimeType}',
      );
    }
  }

  /// Polls the slot in three phases:
  /// 1. Wait for a viewer to claim (slot.viewer != zeros).
  /// 2. Write the precomputed offer once claimed (program requires Claimed).
  /// 3. Wait for the viewer's encrypted answer, then unprotect + decrypt it.
  Future<String> _awaitClaimWriteOfferThenAnswer({
    required String slotPda,
    required String protectedKey,
    required Uint8List encryptedPayload,
    required _CancellationFlag cancelled,
    required String expectedHost,
    required String expectedRoom,
    required bool requireCurrentViewer,
  }) async {
    diagnostics('host.answer_wait.started');
    var offerWritten = false;

    for (var i = 0; i < _polling.maxAnswerAttempts; i++) {
      await _polling.tick();
      if (cancelled.isCancelled) {
        diagnostics('host.answer_wait.cancelled');
        throw StateError('Waiting for the viewer was cancelled.');
      }

      ConnectSlotData? slot;
      try {
        slot = await _chain.fetchSlot(slotPda);
      } on TransientSignalingReadException {
        continue;
      }
      if (slot == null) continue;
      _requireSlotConsistency(
        slot,
        expectedHost: expectedHost,
        expectedRoom: expectedRoom,
        requireCurrentViewer: requireCurrentViewer,
      );
      if (slot.state == ConnectSlotState.expired) {
        throw StateError('Connection slot expired before a viewer connected.');
      }

      if (!offerWritten && !_isUnclaimed(slot)) {
        await _trace(
          'host.offer_write',
          () => _slots.writeOfferWithProtectedKey(
            slotPda: slotPda,
            protectedKey: protectedKey,
            payload: encryptedPayload,
          ),
        );
        offerWritten = true;
      }

      if (offerWritten && _answerReady(slot)) {
        final answerSlot = slot;
        final viewerAddress = base58Encode(answerSlot.viewer);
        diagnostics('host.answer_wait.ready');
        final proof = await _trace(
          'host.proof_signing',
          () => _slots.buildSignedProof(slotPda),
        );
        final viewerPassphrase = await _trace(
          'host.answer_key_release',
          () => _broker.unprotect(
            protectedKey: utf8.decode(answerSlot.viewerProtectedKey),
            hostAddress: viewerAddress,
            offerId: slotPda,
            signedProof: proof,
            slotPda: slotPda,
          ),
        );

        return _trace(
          'host.answer_decryption',
          () => PassphrasePayloadCrypto.decrypt(
            utf8.decode(answerSlot.answerData),
            viewerPassphrase,
          ),
        );
      }
    }
    diagnostics('host.answer_wait.timed_out');
    throw TimeoutException('Viewer did not answer before the slot expired');
  }

  Future<T> _trace<T>(
    String operation,
    Future<T> Function() action,
  ) async {
    diagnostics('$operation.started');
    try {
      final result = await action();
      diagnostics('$operation.completed');

      return result;
    } on Object catch (error) {
      diagnostics('$operation.failed type=${error.runtimeType}');
      rethrow;
    }
  }

  PeerInvite _parseViewerConnection(Uri invite) {
    final params = _urlCodec.parse(invite);
    if (params.hostAddress == _identity.address) {
      diagnostics('viewer.self_connection.rejected');
      throw const PeerSelfConnectionException();
    }

    return params;
  }

  bool _answerReady(ConnectSlotData slot) {
    final hasAnswer = slot.answerData.isNotEmpty && slot.viewerProtectedKey.isNotEmpty;
    final advanced = slot.state == ConnectSlotState.answerReady || slot.state == ConnectSlotState.connected;

    return hasAnswer && advanced;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Polls the slot until the host has written the offer (state OfferReady or
  /// later, with non-empty offer/protected-key payloads).
  Future<ConnectSlotData> _awaitOffer(
    String slotPda, {
    required String expectedHost,
    required String expectedRoom,
    required bool requireCurrentViewer,
  }) async {
    for (var i = 0; i < _polling.maxOfferAttempts; i++) {
      await _polling.tick();

      ConnectSlotData? slot;
      try {
        slot = await _chain.fetchSlot(slotPda);
      } on TransientSignalingReadException {
        continue;
      }
      if (slot == null) continue;
      _requireSlotConsistency(
        slot,
        expectedHost: expectedHost,
        expectedRoom: expectedRoom,
        requireCurrentViewer: requireCurrentViewer,
      );
      if (slot.state == ConnectSlotState.expired) {
        throw StateError('Connection slot expired before the host wrote the offer.');
      }
      if (_offerReady(slot)) return slot;
    }
    throw TimeoutException('Host did not write the offer before the slot expired');
  }

  bool _offerReady(ConnectSlotData slot) {
    final hasOffer = slot.offerData.isNotEmpty && slot.hostProtectedKey.isNotEmpty;
    final advanced =
        slot.state == ConnectSlotState.offerReady ||
        slot.state == ConnectSlotState.answerReady ||
        slot.state == ConnectSlotState.connected;

    return hasOffer && advanced;
  }

  String _extractSdp(String json) {
    final Object? parsed = jsonDecode(json);
    if (parsed is! Map<Object?, Object?>) {
      throw const FormatException('Decrypted payload must be a JSON object.');
    }
    final sdp = parsed['sdp'];
    if (sdp is! String || sdp.isEmpty) {
      throw const FormatException('Decrypted payload has no SDP');
    }

    return sdp;
  }

  bool _isUnclaimed(ConnectSlotData slot) => slot.viewer.every((b) => b == 0);

  bool _isClaimedByMe(ConnectSlotData slot) {
    final me = _identity.publicKeyBytes;
    if (slot.viewer.length != me.length) return false;
    for (var i = 0; i < me.length; i++) {
      if (slot.viewer[i] != me[i]) return false;
    }

    return true;
  }

  void _requireSlotConsistency(
    ConnectSlotData slot, {
    required String expectedHost,
    required String expectedRoom,
    required bool requireCurrentViewer,
  }) {
    if (base58Encode(slot.host) != expectedHost || base58Encode(slot.room) != expectedRoom) {
      throw const SignalingStateIntegrityException();
    }
    if (requireCurrentViewer && !_isUnclaimed(slot) && !_isClaimedByMe(slot)) {
      throw const SignalingStateIntegrityException();
    }
  }

  /// A 12-segment, 48-hex-char passphrase (~192 bits). The viewer's own secret —
  /// only round-trips through our own broker/crypto, so the exact format need
  /// not match the web client; the entropy mirrors its `generatePassphrase`.
  String _generatePassphrase() {
    final rng = Random.secure();
    const hexDigits = '0123456789abcdef';
    final buffer = StringBuffer();
    for (var segment = 0; segment < 12; segment++) {
      if (segment > 0) buffer.write('-');
      for (var c = 0; c < 4; c++) {
        buffer.write(hexDigits[rng.nextInt(16)]);
      }
    }

    return buffer.toString();
  }
}

/// A one-way cancellation signal checked by the answer-poll loop, set via
/// [PeerHostSession.cancelWaiting] so a disconnected host stops polling
/// the chain instead of leaving an unbounded background loop running.
final class _CancellationFlag {
  bool isCancelled = false;
  void cancel() => isCancelled = true;
}
