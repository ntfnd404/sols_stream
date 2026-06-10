import 'dart:typed_data';

import 'package:signaling/src/domain/connect_slot_data.dart';

/// Gateway to the Solana on-chain signaling program.
///
/// Implementations live in data/solana_program/. The application layer
/// depends on this abstraction, not on Solana RPC, Borsh, or discriminators.
///
/// Scope: on-chain signaling operations only. Wallet concerns (balance,
/// funding, address) belong to the wallet context's `WalletAccount` port, not
/// here.
abstract interface class SignalingChainGateway {
  /// Creates room + slot on-chain and returns their PDA addresses.
  Future<SlotAddresses> openSignalingSlot({
    required int roomNonce,
    required int slotNonce,
  });

  /// Derives slot addresses from a remote host's connection parameters.
  Future<SlotAddresses> resolveSlotAddresses(ConnectionParams params);

  Future<void> writeOffer(
    String slotPda,
    Uint8List payload,
  );

  Future<void> claimSlot({
    required String slotPda,
    required String roomPda,
  });

  Future<ConnectSlotData?> fetchSlot(String slotPda);

  Future<void> writeAnswer(
    String slotPda,
    Uint8List payload,
  );

  Future<void> confirmConnection(String slotPda);

  /// Builds the shareable `sols://` connection URL.
  String buildConnectionUrl({
    required int roomNonce,
    required int slotNonce,
    required String prot,
  });

  /// Parses a `sols://` URL. Throws [FormatException] if a required param is missing.
  ConnectionParams parseConnectionUrl(String url);
}

/// Slot addresses after opening or resolving a signaling slot.
class SlotAddresses {
  final String roomPda;
  final String slotPda;

  const SlotAddresses({
    required this.roomPda,
    required this.slotPda,
  });
}

/// Parameters decoded from a connection URL.
class ConnectionParams {
  final String hostAddress;
  final int roomNonce;
  final int slotNonce;
  final String prot;

  const ConnectionParams({
    required this.hostAddress,
    required this.roomNonce,
    required this.slotNonce,
    required this.prot,
  });
}
