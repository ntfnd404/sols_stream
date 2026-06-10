import 'package:solana/encoder.dart' show Instruction;
import 'package:solana/solana.dart' show Ed25519HDPublicKey;

/// Signing capability published by the wallet bounded context.
///
/// The private key never leaves the implementation — callers can request a
/// signature but can never read key material. This is the only wallet port the
/// signaling context needs for sending transactions.
abstract interface class SolanaSigner {
  /// The signer's public key (its on-chain identity).
  Ed25519HDPublicKey get publicKey;

  /// Signs [instructions] as a single transaction, sends it, and returns the
  /// transaction signature.
  Future<String> signAndSend(List<Instruction> instructions);
}
