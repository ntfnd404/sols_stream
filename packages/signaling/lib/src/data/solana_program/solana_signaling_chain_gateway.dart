import 'dart:typed_data';

import 'package:signaling/src/application/signaling_chain_gateway.dart';
import 'package:signaling/src/data/solana_program/connect_slot_account_parser.dart';
import 'package:signaling/src/data/solana_program/instruction_builder.dart';
import 'package:signaling/src/domain/connect_slot_data.dart';
import 'package:solana/dto.dart' show BinaryAccountData, Encoding;
import 'package:solana/solana.dart';
import 'package:solana_wallet/solana_wallet.dart';

/// Solana implementation of [SignalingChainGateway].
final class SolanaSignalingChainGateway implements SignalingChainGateway {
  final SolanaSigner _signer;

  const SolanaSignalingChainGateway(this._signer);

  @override
  String get signerAddress => _signer.address;

  @override
  Future<int> getBalance() => _signer.getBalance();

  @override
  Future<bool> ensureFunded() => _signer.ensureFunded();

  @override
  Future<SlotAddresses> openSignalingSlot({
    required int roomNonce,
    required int slotNonce,
  }) async {
    final host = _signer.publicKey;
    await _signer.signAndSend([await buildCreateRoom(host: host, roomNonce: roomNonce)]);
    final roomPda = await deriveRoomPda(host, roomNonce);
    final slotPdaKey = await deriveSlotPda(roomPda, slotNonce);
    await _signer.signAndSend([
      await buildOpenConnectSlot(host: host, roomPda: roomPda, slotNonce: slotNonce),
    ]);
    return SlotAddresses(roomPda: roomPda.toBase58(), slotPda: slotPdaKey.toBase58());
  }

  @override
  Future<SlotAddresses> resolveSlotAddresses(ConnectionParams params) async {
    final host = Ed25519HDPublicKey.fromBase58(params.hostAddress);
    final roomPda = await deriveRoomPda(host, params.roomNonce);
    final slotPda = await deriveSlotPda(roomPda, params.slotNonce);
    return SlotAddresses(roomPda: roomPda.toBase58(), slotPda: slotPda.toBase58());
  }

  @override
  Future<void> writeOffer(String slotPda, Uint8List payload) async {
    for (final ix in buildWriteOffer(
      host: _signer.publicKey,
      slotPda: Ed25519HDPublicKey.fromBase58(slotPda),
      encryptedPayload: payload,
    )) {
      await _signer.signAndSend([ix]);
    }
  }

  @override
  Future<void> claimSlot({required String slotPda, required String roomPda}) async {
    await _signer.signAndSend([
      await buildClaimConnectSlot(
        viewer: _signer.publicKey,
        slotPda: Ed25519HDPublicKey.fromBase58(slotPda),
        roomPda: Ed25519HDPublicKey.fromBase58(roomPda),
      ),
    ]);
  }

  @override
  Future<ConnectSlotData?> fetchSlot(String slotPda) async {
    final info = await _signer.rpc.getAccountInfo(slotPda, encoding: Encoding.base64);
    final bin = info.value?.data as BinaryAccountData?;
    final bytes = bin?.data;
    if (bytes == null) return null;
    return ConnectSlotAccountParser.parse(Uint8List.fromList(bytes));
  }

  @override
  Future<void> writeAnswer(String slotPda, Uint8List payload) async {
    for (final ix in buildWriteAnswer(
      viewer: _signer.publicKey,
      slotPda: Ed25519HDPublicKey.fromBase58(slotPda),
      encryptedPayload: payload,
    )) {
      await _signer.signAndSend([ix]);
    }
  }

  @override
  Future<void> confirmConnection(String slotPda) async {
    await _signer.signAndSend([
      buildConfirmConnection(
        signer: _signer.publicKey,
        slotPda: Ed25519HDPublicKey.fromBase58(slotPda),
      ),
    ]);
  }

  @override
  String buildConnectionUrl({
    required int roomNonce,
    required int slotNonce,
    required String prot,
  }) =>
      Uri(
        scheme: 'sols',
        host: 'connect',
        queryParameters: {
          'host': _signer.address,
          'rn': roomNonce.toString(),
          'sn': slotNonce.toString(),
          'prot': prot,
          'mode': 'p2p',
        },
      ).toString();

  @override
  ConnectionParams parseConnectionUrl(String url) {
    final uri = Uri.parse(url);
    for (final name in ['host', 'rn', 'sn', 'prot']) {
      final value = uri.queryParameters[name];
      if (value == null || value.isEmpty) {
        throw FormatException('Missing required connection URL parameter: $name');
      }
    }
    final host = uri.queryParameters['host'] ?? '';
    final rn = uri.queryParameters['rn'] ?? '';
    final sn = uri.queryParameters['sn'] ?? '';
    final prot = uri.queryParameters['prot'] ?? '';
    return ConnectionParams(
      hostAddress: host,
      roomNonce: int.parse(rn),
      slotNonce: int.parse(sn),
      prot: prot,
    );
  }
}
