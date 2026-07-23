import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';

import '../../../tool/idl/anchor_idl_fetcher.dart';

const int _payloadLengthOffset = 40;
const int _payloadOffset = 44;

void main() {
  test('decodes a valid compressed Anchor IDL account', () {
    final decoded = AnchorIdlFetcher.decodeAccountData(
      _accountData({
        'instructions': [
          {'name': 'create_room'},
        ],
      }),
    );

    expect(decoded['instructions'], hasLength(1));
  });

  test('rejects a truncated Anchor IDL account header', () {
    expect(
      () => AnchorIdlFetcher.decodeAccountData(
        Uint8List(_payloadOffset - 1),
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('account is truncated'),
        ),
      ),
    );
  });

  test('rejects a declared payload longer than the account data', () {
    final accountData = Uint8List(_payloadOffset);
    ByteData.sublistView(
      accountData,
      _payloadLengthOffset,
      _payloadOffset,
    ).setUint32(0, 1, Endian.little);

    expect(
      () => AnchorIdlFetcher.decodeAccountData(accountData),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('payload is truncated'),
        ),
      ),
    );
  });

  test('rejects malformed compressed payload', () {
    final accountData = Uint8List(_payloadOffset + 1);
    ByteData.sublistView(
      accountData,
      _payloadLengthOffset,
      _payloadOffset,
    ).setUint32(0, 1, Endian.little);
    accountData[_payloadOffset] = 0xFF;

    expect(
      () => AnchorIdlFetcher.decodeAccountData(accountData),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('payload is invalid'),
        ),
      ),
    );
  });
}

Uint8List _accountData(Map<String, Object?> idl) {
  final payload = zlib.encode(utf8.encode(jsonEncode(idl)));
  final accountData = Uint8List(_payloadOffset + payload.length);
  ByteData.sublistView(
    accountData,
    _payloadLengthOffset,
    _payloadOffset,
  ).setUint32(0, payload.length, Endian.little);
  accountData.setRange(_payloadOffset, accountData.length, payload);

  return accountData;
}
