import 'dart:async';
import 'dart:convert' as dc;
import 'dart:typed_data';

import 'package:solana/dto.dart' show BinaryAccountData, Commitment, Encoding;
import 'package:solana/encoder.dart' show Instruction, Message;
import 'package:solana/solana.dart';

import 'connect_slot.dart';
import 'instruction_builder.dart';
import 'solana_crypto.dart';
import 'wallet_manager.dart';

const _pollInterval = Duration(seconds: 5);

class SignalingSession {
  final String url;
  final String slotPda;
  final String prot;
  final int slotNonce;
  final int roomNonce;

  const SignalingSession({
    required this.url,
    required this.slotPda,
    required this.prot,
    required this.slotNonce,
    required this.roomNonce,
  });
}

class FetchedOffer {
  final String sdpOffer;
  final String slotPda;
  final String roomPda;
  final String prot;
  final int slotNonce;

  const FetchedOffer({
    required this.sdpOffer,
    required this.slotPda,
    required this.roomPda,
    required this.prot,
    required this.slotNonce,
  });
}

class SolanaSignaling {
  final WalletManager _wallet;

  SolanaSignaling(this._wallet);

  String get walletAddress => _wallet.address;

  Future<void> init() async {} // wallet already inited by WalletManager

  Future<int> getBalance() => _wallet.getBalance();

  // ── Publisher ──────────────────────────────────────────────────────────────

  Future<SignalingSession> goLive(String sdpOfferJson) async {
    final funded = await _wallet.ensureFunded();
    if (!funded) {
      throw StateError('Wallet not funded. Add SOL to ${_wallet.address}');
    }

    final host = _wallet.keypair.publicKey;
    final roomNonce = _randomU64();
    final slotNonce = _randomU64();
    final prot = dc.base64.encode(SolanaCrypto.randomBytes(32));

    // create_room
    final roomIx = await buildCreateRoom(host: host, roomNonce: roomNonce);
    await _sendTx([roomIx]);

    // open_connect_slot
    final roomPda = await deriveRoomPda(host, roomNonce);
    final slotPdaKey = await deriveSlotPda(roomPda, slotNonce);
    final slotIx = await buildOpenConnectSlot(
      host: host,
      roomPda: roomPda,
      slotNonce: slotNonce,
    );
    await _sendTx([slotIx]);

    // encrypt and write offer (chunked)
    final encrypted = await SolanaCrypto.encryptSdp(sdpOfferJson, prot, slotNonce);
    final payload = encrypted.toBytes();
    final writeIxs = buildWriteOffer(
      host: host,
      slotPda: slotPdaKey,
      encryptedPayload: payload,
    );
    for (final ix in writeIxs) {
      await _sendTx([ix]);
    }

    final url = _buildUrl(
      host: host.toBase58(),
      roomNonce: roomNonce,
      slotNonce: slotNonce,
      prot: prot,
    );

    return SignalingSession(
      url: url,
      slotPda: slotPdaKey.toBase58(),
      prot: prot,
      slotNonce: slotNonce,
      roomNonce: roomNonce,
    );
  }

  Stream<String> watchForAnswer(SignalingSession session) async* {
    final slotPda = Ed25519HDPublicKey.fromBase58(session.slotPda);
    while (true) {
      await Future.delayed(_pollInterval);
      try {
        final slot = await _fetchSlot(slotPda);
        if (slot == null) continue;
        if (slot.state == ConnectSlotState.answerReady ||
            slot.state == ConnectSlotState.connected) {
          final enc = EncryptedPayload.fromBytes(slot.answerData);
          final sdp = await SolanaCrypto.decryptSdp(enc, session.prot, session.slotNonce);
          yield sdp;
          return;
        }
      } catch (_) {
        continue;
      }
    }
  }

  // ── Viewer ─────────────────────────────────────────────────────────────────

  Future<FetchedOffer> fetchOffer(String connectionUrl) async {
    final uri = Uri.parse(connectionUrl);
    final hostStr  = uri.queryParameters['host']!;
    final roomNonce = int.parse(uri.queryParameters['rn']!);
    final slotNonce = int.parse(uri.queryParameters['sn']!);
    final prot      = uri.queryParameters['prot']!;

    final host    = Ed25519HDPublicKey.fromBase58(hostStr);
    final roomPda = await deriveRoomPda(host, roomNonce);
    final slotPda = await deriveSlotPda(roomPda, slotNonce);

    final funded = await _wallet.ensureFunded();
    if (!funded) {
      throw StateError('Wallet not funded. Add SOL to ${_wallet.address}');
    }

    // claim_connect_slot
    final claimIx = await buildClaimConnectSlot(
      viewer: _wallet.keypair.publicKey,
      slotPda: slotPda,
      roomPda: roomPda,
    );
    await _sendTx([claimIx]);

    // poll until offer is written
    ConnectSlotData? slot;
    for (var i = 0; i < 24; i++) {
      await Future.delayed(_pollInterval);
      slot = await _fetchSlot(slotPda);
      if (slot != null && slot.state.index >= ConnectSlotState.offerReady.index) {
        break;
      }
    }
    if (slot == null) {
      throw TimeoutException('Offer not found on chain', _pollInterval * 24);
    }

    final enc = EncryptedPayload.fromBytes(slot.offerData);
    final sdp = await SolanaCrypto.decryptSdp(enc, prot, slotNonce);

    return FetchedOffer(
      sdpOffer: sdp,
      slotPda: slotPda.toBase58(),
      roomPda: roomPda.toBase58(),
      prot: prot,
      slotNonce: slotNonce,
    );
  }

  Future<void> submitAnswer(FetchedOffer offer, String sdpAnswerJson) async {
    final slotPda   = Ed25519HDPublicKey.fromBase58(offer.slotPda);
    final encrypted = await SolanaCrypto.encryptSdp(sdpAnswerJson, offer.prot, offer.slotNonce);
    final payload   = encrypted.toBytes();
    final ixs = buildWriteAnswer(
      viewer: _wallet.keypair.publicKey,
      slotPda: slotPda,
      encryptedPayload: payload,
    );
    for (final ix in ixs) {
      await _sendTx([ix]);
    }
  }

  // ── Both ───────────────────────────────────────────────────────────────────

  Future<void> confirmConnection(String slotPdaStr) async {
    final slotPda = Ed25519HDPublicKey.fromBase58(slotPdaStr);
    final ix = await buildConfirmConnection(
      signer: _wallet.keypair.publicKey,
      slotPda: slotPda,
    );
    await _sendTx([ix]);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<ConnectSlotData?> _fetchSlot(Ed25519HDPublicKey slotPda) async {
    final info = await _wallet.rpc.getAccountInfo(
      slotPda.toBase58(),
      encoding: Encoding.base64,
    );
    final bin = info.value?.data as BinaryAccountData?;
    final bytes = bin?.data;
    if (bytes == null) return null;
    return ConnectSlotData.parse(Uint8List.fromList(bytes));
  }

  Future<void> _sendTx(List<Instruction> instructions) async {
    await _wallet.rpc.signAndSendTransaction(
      Message(instructions: instructions),
      [_wallet.keypair],
      commitment: Commitment.confirmed,
    );
  }

  String _buildUrl({
    required String host,
    required int roomNonce,
    required int slotNonce,
    required String prot,
  }) =>
      Uri(
        scheme: 'sols',
        host: 'connect',
        queryParameters: {
          'host': host,
          'rn': roomNonce.toString(),
          'sn': slotNonce.toString(),
          'prot': prot,
          'mode': 'p2p',
        },
      ).toString();

  int _randomU64() {
    final bytes = SolanaCrypto.randomBytes(8);
    // Mask to 63 bits to keep it positive in Dart's 64-bit signed int
    return ByteData.sublistView(bytes).getUint64(0, Endian.little) & 0x7FFFFFFFFFFFFFFF;
  }
}
