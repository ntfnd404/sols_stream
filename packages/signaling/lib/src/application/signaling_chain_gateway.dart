import 'package:signaling/src/domain/connect_slot_data.dart';
import 'package:signaling/src/domain/program_config.dart';
import 'package:signaling/src/domain/room_creation_params.dart';

/// Gateway to the Solana on-chain signaling program.
///
/// Implementations live in data/solana_program/. The application layer
/// depends on this abstraction, not on Solana RPC, Borsh, or discriminators.
///
/// Scope: on-chain signaling operations only. Provider-specific funding and
/// transaction transport are adapter concerns and do not belong here.
abstract interface class SignalingChainGateway {
  /// Creates room + slot on-chain and returns their PDA addresses. [room]
  /// configures the room (defaults to a public, free, P2P room).
  ///
  /// The room nonce is derived internally from the host's current `stream_count`
  /// (mirrors JS `startAdvertising` which re-fetches user after cleanup before
  /// using `userData.streamCount`). The used nonce is returned in
  /// [SlotAddresses.roomNonce] for callers that need it (e.g. URL building).
  Future<SlotAddresses> openSignalingSlot({
    required int slotNonce,
    RoomCreationParams room = const RoomCreationParams.p2pFree(),
    int expiresInSeconds = 120,
  });

  /// Ends the host's live room on-chain (`end_room`). Resets `host_user.role`
  /// to Idle so a new room can be created. Always call this on session teardown.
  Future<void> endRoom(String roomPda);

  /// Closes a previously ended room account, reclaiming its rent. Call after
  /// [endRoom] as part of host session cleanup.
  Future<void> closeRoom(String roomPda);

  Future<void> claimSlot({
    required String slotPda,
    required String roomPda,
  });

  /// Returns `null` only when the account is absent. Implementations may throw
  /// `TransientSignalingReadException` for a retryable transport/read failure.
  /// Integrity and decoding failures must not be converted to that marker.
  Future<ConnectSlotData?> fetchSlot(String slotPda);

  /// Reads the singleton `ProgramConfig` account. Returns `null` only when the
  /// config PDA is absent. Owner, representation, discriminator, and payload
  /// failures are integrity failures. The reclaim flow uses `serviceWallet` as
  /// the mandated 1%-skim recipient.
  Future<ProgramConfig?> fetchConfig();

  Future<void> confirmConnection(String slotPda);

  /// Sends a `heartbeat` instruction for the signer's own User PDA.
  /// Zero parameters — signer identity and PDA derivation are internal to the
  /// implementation. Called periodically by [HeartbeatDriver] while a session
  /// is live to prevent third-party `cleanup_stale_room`.
  Future<void> sendHeartbeat();

  /// Returns the host's current `stream_count` from their User PDA, or 0 if
  /// the account does not yet exist. The program validates that `create_room`
  /// nonce equals `host_user.stream_count` (room.rs:47 Unauthorized gate), so
  /// callers must fetch this before building the room nonce.
  Future<int> readStreamCount();
}

/// Slot addresses after opening or resolving a signaling slot.
class SlotAddresses {
  final String roomPda;
  final String slotPda;

  /// The room nonce used when creating the room (`host_user.stream_count` at
  /// the time of `create_room`).
  final int roomNonce;

  const SlotAddresses({
    required this.roomPda,
    required this.slotPda,
    this.roomNonce = 0,
  });
}
