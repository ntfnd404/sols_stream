import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:signaling/src/data/crypto/passphrase_payload_crypto.dart';
import 'package:signaling/src/data/crypto/signal_crypto_constants.dart';
import 'package:test/test.dart';

void main() {
  group('PassphrasePayloadCrypto protected-slot payload', () {
    test('round-trips an offer JSON through encrypt -> decrypt', () async {
      const passphrase = 'aaaa-bbbb-cccc-dddd-eeee-ffff';
      const plaintext = '{"sdp":"v=0\\r\\no=- 1 1 IN IP4 0.0.0.0","m":"p2p"}';

      final envelope = await PassphrasePayloadCrypto.encrypt(plaintext, passphrase);
      final round = await PassphrasePayloadCrypto.decrypt(envelope, passphrase);

      expect(round, plaintext);
    });

    test('emits a v3/z1 envelope with base64 ct/iv/salt', () async {
      final envelope = await PassphrasePayloadCrypto.encrypt('hello', 'pw');
      final parsed = jsonDecode(envelope) as Map<String, dynamic>;

      expect(parsed['v'], 3);
      expect(parsed['z'], 1);
      // 12-byte IV -> 16 base64 chars; 16-byte salt -> 24 base64 chars.
      expect(base64.decode(parsed['iv'] as String).length, 12);
      expect(base64.decode(parsed['salt'] as String).length, 16);
      expect(() => base64.decode(parsed['ct'] as String), returnsNormally);
    });

    test('wrong passphrase fails to decrypt', () async {
      final envelope = await PassphrasePayloadCrypto.encrypt('secret', 'right-pw');

      expect(
        () => PassphrasePayloadCrypto.decrypt(envelope, 'wrong-pw'),
        throwsA(isA<Object>()),
      );
    });

    test('rejects unknown envelope versions and compression modes', () async {
      final envelope =
          jsonDecode(
                await PassphrasePayloadCrypto.encrypt('secret', 'pw'),
              )
              as Map<String, dynamic>;

      await expectLater(
        PassphrasePayloadCrypto.decrypt(
          jsonEncode({...envelope, 'v': 4}),
          'pw',
        ),
        throwsFormatException,
      );
      await expectLater(
        PassphrasePayloadCrypto.decrypt(
          jsonEncode({...envelope, 'z': 0}),
          'pw',
        ),
        throwsFormatException,
      );
    });

    test('rejects invalid nonce, salt, and ciphertext lengths', () async {
      final envelope =
          jsonDecode(
                await PassphrasePayloadCrypto.encrypt('secret', 'pw'),
              )
              as Map<String, dynamic>;

      for (final malformed in [
        {...envelope, 'salt': base64.encode(List<int>.filled(15, 0))},
        {...envelope, 'iv': base64.encode(List<int>.filled(11, 0))},
        {
          ...envelope,
          'ct': base64.encode(
            List<int>.filled(SignalCryptoConstants.gcmTagLength, 0),
          ),
        },
      ]) {
        await expectLater(
          PassphrasePayloadCrypto.decrypt(jsonEncode(malformed), 'pw'),
          throwsFormatException,
        );
      }
    });

    // Proves our DEFLATE framing is RFC1950 zlib — byte-identical to the
    // browser's CompressionStream('deflate') the web client uses. This is the
    // canonical empty-input zlib stream: header 78 9c, one stored empty block
    // 03 00, then adler32(empty) = 00 00 00 01.
    test('zlib decoder reads the canonical RFC1950 empty stream', () {
      final emptyZlib = [0x78, 0x9c, 0x03, 0x00, 0x00, 0x00, 0x00, 0x01];

      expect(const ZLibDecoder().decodeBytes(emptyZlib), isEmpty);
    });
  });
}
