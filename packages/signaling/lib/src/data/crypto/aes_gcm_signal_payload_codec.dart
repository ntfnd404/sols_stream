import 'dart:typed_data';

import 'package:cryptography/helpers.dart' as crypto_helpers;
import 'package:signaling/src/application/signal_payload_codec.dart';
import 'package:signaling/src/data/crypto/encrypted_payload.dart';
import 'package:signaling/src/data/crypto/signal_payload_crypto.dart';

/// AES-GCM + PBKDF2 implementation of [SignalPayloadCodec].
final class AesGcmSignalPayloadCodec implements SignalPayloadCodec {
  const AesGcmSignalPayloadCodec();

  @override
  Future<Uint8List> encode(String sdpJson, String prot, int slotNonce) async {
    final payload = await SignalPayloadCrypto.encryptSdp(sdpJson, prot, slotNonce);

    return payload.bytes;
  }

  @override
  Future<String> decode(Uint8List bytes, String prot, int slotNonce) {
    final enc = EncryptedPayload.fromBytes(bytes);

    return SignalPayloadCrypto.decryptSdp(enc, prot, slotNonce);
  }

  @override
  Uint8List randomBytes(int n) => crypto_helpers.randomBytes(n);
}
