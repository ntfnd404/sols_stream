import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:signaling/src/data/crypto/signal_crypto_constants.dart';

/// Browser-interoperable password payload crypto (scheme #2).
///
/// Used for the on-chain `offer_data` / `answer_data` of a ConnectSlot when
/// joining through the Web-compatible signaling flow. The passphrase is
/// obtained from the key broker (`/unprotect-key`), NOT carried in the URL.
///
/// Wire format is a JSON envelope `{ct, iv, salt, v:3, z:1}` (all base64):
///   - key  = PBKDF2(password-utf8, salt = **utf8 of the base64 salt STRING**,
///            150_000 iters, SHA-256) -> AES-GCM-256. The salt being the UTF-8
///            bytes of the base64 string (not the raw salt bytes) mirrors
///            `deriveAesKeyFromSecret`, which does `TextEncoder.encode(salt)`.
///   - AES-GCM has NO additional data; the 128-bit tag is appended to the
///     ciphertext (Web Crypto convention), so we split it back off here.
///   - `z:1` means the plaintext is DEFLATE-compressed (zlib / RFC1950 wrapper,
///     matching `CompressionStream('deflate')`) before encryption.
///
final class PassphrasePayloadCrypto {
  static const int _version = 3;
  static const int _saltLength = 16;
  static const int _nonceLength = 12;

  const PassphrasePayloadCrypto._();

  /// Decrypts a web-interop `{ct,iv,salt,...}` envelope with [passphrase].
  /// Returns the UTF-8 plaintext (an offer/answer JSON document).
  static Future<String> decrypt(String envelopeJson, String passphrase) async {
    final Object? decoded = jsonDecode(envelopeJson);
    if (decoded is! Map<Object?, Object?>) {
      throw const FormatException('Encrypted payload must be a JSON object.');
    }
    final saltB64 = decoded['salt'];
    final ivB64 = decoded['iv'];
    final ctB64 = decoded['ct'];
    final version = decoded['v'];
    final compressionFlag = decoded['z'];
    if (saltB64 is! String || ivB64 is! String || ctB64 is! String || version != _version || compressionFlag != 1) {
      throw const FormatException('Encrypted payload fields are invalid.');
    }

    final List<int> salt;
    final List<int> iv;
    final List<int> ctAndTag;
    try {
      salt = base64.decode(saltB64);
      iv = base64.decode(ivB64);
      ctAndTag = base64.decode(ctB64);
    } on FormatException {
      throw const FormatException('Encrypted payload fields are invalid.');
    }
    if (salt.length != _saltLength ||
        iv.length != _nonceLength ||
        ctAndTag.length <= SignalCryptoConstants.gcmTagLength) {
      throw const FormatException('Encrypted payload fields are invalid.');
    }

    final key = await _deriveKey(passphrase, saltB64);
    final algo = AesGcm.with256bits();
    final ct = ctAndTag.sublist(0, ctAndTag.length - SignalCryptoConstants.gcmTagLength);
    final tag = ctAndTag.sublist(ctAndTag.length - SignalCryptoConstants.gcmTagLength);
    final plain = await algo.decrypt(
      SecretBox(ct, nonce: iv, mac: Mac(tag)),
      secretKey: key,
    );

    final bytes = Uint8List.fromList(
      const ZLibDecoder().decodeBytes(plain),
    );

    return utf8.decode(bytes);
  }

  /// Encrypts [plaintext] (an answer JSON document) under [passphrase] into a
  /// web-interop `{ct,iv,salt,v:3,z:1}` envelope. The salt and IV are random.
  static Future<String> encrypt(String plaintext, String passphrase) async {
    final salt = _randomBytes(_saltLength);
    final saltB64 = base64.encode(salt);
    final key = await _deriveKey(passphrase, saltB64);
    final algo = AesGcm.with256bits();
    final nonce = algo.newNonce();
    final compressed = Uint8List.fromList(
      const ZLibEncoder().encodeBytes(utf8.encode(plaintext)),
    );
    final box = await algo.encrypt(compressed, secretKey: key, nonce: nonce);
    final ctAndTag = Uint8List.fromList([...box.cipherText, ...box.mac.bytes]);

    return jsonEncode({
      'ct': base64.encode(ctAndTag),
      'iv': base64.encode(nonce),
      'salt': saltB64,
      'v': _version,
      'z': 1,
    });
  }

  // key = PBKDF2(passphrase, salt = utf8(base64-salt-string), 150_000, SHA-256).
  static Future<SecretKey> _deriveKey(String passphrase, String saltB64) {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: SignalCryptoConstants.pbkdf2Iterations,
      bits: SignalCryptoConstants.derivedKeyBits,
    );

    return pbkdf2.deriveKeyFromPassword(
      password: passphrase,
      nonce: utf8.encode(saltB64),
    );
  }

  static Uint8List _randomBytes(int length) {
    final rng = Random.secure();
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = rng.nextInt(256);
    }

    return bytes;
  }
}
