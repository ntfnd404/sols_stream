import 'dart:typed_data';

/// Encodes and decodes SDP payloads for the signaling protocol.
///
/// Implementations live in data/crypto/. The application layer
/// depends on this abstraction, not on AES-GCM/PBKDF2 internals.
abstract interface class SignalPayloadCodec {
  /// Encrypts [sdpJson] and returns the serialised payload bytes.
  ///
  /// [messageType] is bound into the AAD so an offer ciphertext cannot be
  /// replayed as an answer. Use `'offer'` or `'answer'`.
  Future<Uint8List> encode(String sdpJson, String prot, int slotNonce, String messageType);

  /// Decrypts [bytes] produced by [encode]. [messageType] must match the value
  /// used when encoding, otherwise decryption fails (AAD mismatch).
  Future<String> decode(Uint8List bytes, String prot, int slotNonce, String messageType);

  /// Returns [n] cryptographically random bytes.
  Uint8List randomBytes(int n);
}
