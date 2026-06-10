import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'package:signaling/src/data/crypto/encrypted_payload.dart';
import 'package:signaling/src/data/crypto/signal_crypto_constants.dart';

final class SignalPayloadCrypto {
  const SignalPayloadCrypto._();

  static Future<EncryptedPayload> encryptSdp(
    String sdpJson,
    String prot,
    int slotNonce,
  ) async {
    final key = await _deriveKey(prot, slotNonce);
    final algo = AesGcm.with256bits();
    final nonce = algo.newNonce();
    final box = await algo.encrypt(
      utf8.encode(sdpJson),
      secretKey: key,
      nonce: nonce,
      aad: utf8.encode(slotNonce.toString()),
    );
    final ctAndTag = Uint8List.fromList([...box.cipherText, ...box.mac.bytes]);
    final payload = EncryptedPayload(
      ct: base64.encode(ctAndTag),
      iv: base64.encode(nonce),
    );

    return payload;
  }

  static Future<String> decryptSdp(
    EncryptedPayload enc,
    String prot,
    int slotNonce,
  ) async {
    final key = await _deriveKey(prot, slotNonce);
    final algo = AesGcm.with256bits();
    final ctAndTag = base64.decode(enc.ct);
    final iv = base64.decode(enc.iv);
    final ct = ctAndTag.sublist(0, ctAndTag.length - SignalCryptoConstants.gcmTagLength);
    final tag = ctAndTag.sublist(ctAndTag.length - SignalCryptoConstants.gcmTagLength);
    final box = SecretBox(ct, nonce: iv, mac: Mac(tag));
    final plain = await algo.decrypt(
      box,
      secretKey: key,
      aad: utf8.encode(slotNonce.toString()),
    );

    return utf8.decode(plain);
  }

  static Uint8List randomBytes(int n) {
    // Uses cryptography's secure random via AesGcm nonce generator.
    // AES-GCM nonce = 12 bytes; for 32 bytes generate 3 nonces and trim.
    final algo = AesGcm.with256bits();
    final buf = <int>[];
    while (buf.length < n) {
      buf.addAll(algo.newNonce());
    }

    return Uint8List.fromList(buf.sublist(0, n));
  }

  // Matches JS: PBKDF2(prot, "{slotNonce}|signal", 150_000, SHA-256) -> AES-GCM-256.
  static Future<SecretKey> _deriveKey(String prot, int slotNonce) {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: SignalCryptoConstants.pbkdf2Iterations,
      bits: SignalCryptoConstants.derivedKeyBits,
    );

    return pbkdf2.deriveKeyFromPassword(
      password: prot,
      nonce: utf8.encode('$slotNonce${SignalCryptoConstants.saltSuffix}'),
    );
  }
}
