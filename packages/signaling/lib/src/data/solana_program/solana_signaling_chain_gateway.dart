import 'dart:typed_data';

import 'package:signaling/src/application/signaling_chain_gateway.dart';
import 'package:signaling/src/data/solana_program/connect_slot_account_parser.dart';
import 'package:signaling/src/data/solana_program/connect_slot_mapper.dart';
import 'package:signaling/src/data/solana_program/instruction_builder.dart';
import 'package:signaling/src/domain/connect_slot_data.dart';
import 'package:signaling/src/domain/room_creation_params.dart';
import 'package:solana/dto.dart' show BinaryAccountData, Encoding;
import 'package:solana/solana.dart';
import 'package:solana_wallet/solana_wallet.dart';

/// Solana implementation of [SignalingChainGateway].
///
/// Signs via the wallet's [SolanaSigner] port; reads chain accounts via its own
/// injected [RpcClient] — it does not borrow the wallet's transport.
final class SolanaSignalingChainGateway implements SignalingChainGateway {
  final SolanaSigner _signer;
  final RpcClient _reader;

  const SolanaSignalingChainGateway(this._signer, this._reader);

  @override
  Future<SlotAddresses> openSignalingSlot({
    required int roomNonce,
    required int slotNonce,
    RoomCreationParams room = const RoomCreationParams.p2pFree(),
  }) async {
    final host = _signer.publicKey;
    final roomPda = await deriveRoomPda(host, roomNonce);
    final slotPdaKey = await deriveSlotPda(roomPda, slotNonce);

    // create_room + open_slot in ONE atomic transaction: PDAs derive purely, so
    // instruction order guarantees create_room executes first, and either both
    // deposits land or neither does — no room-without-slot leak on failure.
    await _signer.signAndSend([
      await buildCreateRoom(host: host, roomNonce: roomNonce, params: room),
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
    final info = await _reader.getAccountInfo(slotPda, encoding: Encoding.base64);
    final bin = info.value?.data as BinaryAccountData?;
    final bytes = bin?.data;
    if (bytes == null) return null;

    final account = ConnectSlotAccountParser.parse(Uint8List.fromList(bytes));

    return ConnectSlotMapper.toDomain(account);
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
}
