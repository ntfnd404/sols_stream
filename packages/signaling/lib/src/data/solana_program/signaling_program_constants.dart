/// Addresses, instruction discriminators, and protocol parameters of the
/// sols.stream on-chain signaling program.
abstract final class SignalingProgramConstants {
  /// sols.stream program address.
  static const String programId = '8rYyL3AY3cb4XrFWfUokXKwQb8uU48XvuLAHNxTgdmXw';

  /// Solana System Program address.
  static const String systemProgramId = '11111111111111111111111111111111';

  /// Anchor 8-byte discriminators, from sols.stream program-client.js.
  static const List<int> discCreateRoom = [130, 166, 32, 2, 247, 120, 178, 53];
  static const List<int> discOpenSlot = [200, 199, 43, 201, 133, 53, 221, 183];
  static const List<int> discClaimSlot = [110, 60, 180, 109, 39, 35, 5, 140];
  static const List<int> discWriteOffer = [50, 36, 220, 142, 101, 119, 205, 194];
  static const List<int> discWriteAnswer = [229, 79, 107, 103, 29, 50, 93, 119];
  static const List<int> discConfirmConnection = [219, 162, 27, 145, 211, 2, 134, 122];

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
