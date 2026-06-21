/// Addresses, instruction discriminators, and protocol parameters of the
/// sols.stream on-chain signaling program.
///
/// ## Source of truth & provenance
///
/// There is no Anchor IDL in the repo. These Anchor 8-byte discriminators are
/// transcribed from the production web client `program-client.js`. The contract
/// is still in development, so this file is the single place to re-sync when a
/// new client ships — refresh the captured copy, `git diff`, re-validate, edit.
///
/// - Source: `https://p2p.sols.stream/ipfs/bafybeiabqt3ptjgc6c7u62rzf72mwlsmk6g7sd3ah7ykedlkkiqcxtkf5q/program-client.js`
///   (the immutable IPFS CID *is* the version; a contract update yields a new CID).
/// - Captured: 2026-06-21, committed at `packages/signaling/reference/program-client.js`.
/// - sha256: `1191815b8df70204f8641061bcae2aaa6605ea0b7e1e073021125d10cc1a6b9e`.
///
/// Each discriminator below also matches the Anchor default sighash
/// (`sha256("global:"+ix_name)[:8]` / `sha256("account:"+StructName)[:8]`), an
/// independent cross-check of the transcribed bytes.
abstract final class SignalingProgramConstants {
  /// sols.stream program address.
  static const String programId = '8rYyL3AY3cb4XrFWfUokXKwQb8uU48XvuLAHNxTgdmXw';

  /// Solana System Program address.
  static const String systemProgramId = '11111111111111111111111111111111';

  // ── Instruction discriminators (happy-path P2P signaling) ──────────────────
  static const List<int> discCreateRoom = [130, 166, 32, 2, 247, 120, 178, 53];
  static const List<int> discOpenSlot = [200, 199, 43, 201, 133, 53, 221, 183];
  static const List<int> discClaimSlot = [110, 60, 180, 109, 39, 35, 5, 140];
  static const List<int> discWriteOffer = [50, 36, 220, 142, 101, 119, 205, 194];
  static const List<int> discWriteAnswer = [229, 79, 107, 103, 29, 50, 93, 119];
  static const List<int> discConfirmConnection = [219, 162, 27, 145, 211, 2, 134, 122];

  // ── Instruction discriminators (liveness + reclaim; wired in later phases) ──
  /// `heartbeat` — keeps the host User PDA alive past its TTL.
  static const List<int> discHeartbeat = [202, 104, 56, 6, 240, 170, 63, 134];

  /// `close_connect_slot` — reclaims a slot deposit.
  static const List<int> discCloseConnectSlot = [11, 246, 107, 98, 155, 124, 27, 192];

  /// `end_room` — ends a live room.
  static const List<int> discEndRoom = [102, 106, 181, 155, 61, 17, 40, 78];

  /// `close_room` — reclaims the room deposit after it ends.
  static const List<int> discCloseRoom = [152, 197, 88, 192, 98, 197, 51, 211];

  /// `cleanup_stale_room` — third-party cleanup of an expired room.
  static const List<int> discCleanupStaleRoom = [197, 165, 55, 4, 228, 181, 208, 64];

  /// `cleanup_expired_slot` — cleanup of an expired connect slot.
  static const List<int> discCleanupExpiredSlot = [47, 245, 123, 125, 160, 82, 36, 111];

  // ── Account discriminators (read by later listing/config/reclaim phases) ────
  static const List<int> discRoomAccount = [156, 199, 67, 27, 222, 23, 185, 94];
  static const List<int> discUserAccount = [159, 117, 95, 227, 239, 151, 58, 236];
  static const List<int> discProgramConfigAccount = [196, 210, 90, 231, 144, 149, 140, 63];

  /// Lamports deposited when creating a room and opening a connect slot.
  static const int depositLamports = 1000000; // 0.001 SOL

  /// Connect slot expiry, in seconds, set when opening the slot.
  static const int expiresInSec = 120; // 2 min slot expiry

  /// Max payload bytes per write instruction (chunked offer/answer writes).
  static const int chunkSize = 800;

  /// Anchor account discriminator length, in bytes.
  static const int discriminatorLength = 8;

  /// Length of an Ed25519 public key, in bytes.
  static const int pubkeyLength = 32;
}
