import 'package:solana/encoder.dart' show Instruction;
import 'package:solana/solana.dart' show Ed25519HDPublicKey;
import 'package:solana_wallet/src/domain/solana_transaction_exception.dart';

/// Signing capability published by the wallet bounded context.
///
/// The private key never leaves the implementation — callers can request a
/// signature but can never read key material. This is the only wallet port the
/// signaling context needs for sending transactions.
abstract interface class SolanaSigner {
  /// The signer's public key (its on-chain identity).
  Ed25519HDPublicKey get publicKey;

  /// Signs [instructions] as a single transaction, sends it, waits until it
  /// reaches confirmed commitment, and returns the transaction signature.
  /// Send and confirmation failures are reported as
  /// [SolanaTransactionException].
  Future<String> signAndSend(List<Instruction> instructions);

  /// Signs [instructions] as a single transaction and returns the serialized,
  /// base64-encoded signed transaction **without broadcasting it**.
  ///
  /// Used to prove signer identity to an off-chain verifier (the key broker):
  /// the verifier deserializes the transaction and checks the signer, but the
  /// transaction is never sent to the cluster. Mirrors the web client's
  /// `signAllTransactions(...).serialize({verifySignatures:false})` proof.
  Future<String> signForProof(List<Instruction> instructions);
}
