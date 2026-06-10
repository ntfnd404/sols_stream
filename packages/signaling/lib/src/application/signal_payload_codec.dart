import 'dart:typed_data';

/// Encodes and decodes SDP payloads for the signaling protocol.
///
/// Implementations live in data/crypto/. The application layer
/// depends on this abstraction, not on AES-GCM/PBKDF2 internals.
abstract interface class SignalPayloadCodec {
  /// Encrypts [sdpJson] and returns the serialised payload bytes.
  Future<Uint8List> encode(String sdpJson, String prot, int slotNonce);

  /// Decrypts [bytes] produced by [encode].
  Future<String> decode(Uint8List bytes, String prot, int slotNonce);

  /// Returns [n] cryptographically random bytes.
  Uint8List randomBytes(int n);
}
