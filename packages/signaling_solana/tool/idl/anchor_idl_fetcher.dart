import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

/// Anchor IDL account prefix: 8-byte discriminator + 32-byte authority.
const int _anchorIdlDataLengthOffset = 40;

/// Four-byte little-endian compressed payload length follows the prefix.
const int _anchorIdlPayloadOffset = 44;

/// Seed used by Anchor to derive a program's legacy on-chain IDL account.
const String _anchorIdlSeed = 'anchor:idl';

/// Fetches and decodes the legacy Anchor IDL account for a Solana program.
final class AnchorIdlFetcher {
  final RpcClient _rpc;

  /// Creates a fetcher backed by [rpc].
  AnchorIdlFetcher(this._rpc);

  /// Loads and decodes the on-chain IDL owned by [programId].
  Future<Map<String, dynamic>> fetch({
    required String programId,
  }) async {
    final program = Ed25519HDPublicKey.fromBase58(programId);
    final base = await Ed25519HDPublicKey.findProgramAddress(
      seeds: const [],
      programId: program,
    );
    final idlAddress = await Ed25519HDPublicKey.createWithSeed(
      fromPublicKey: base,
      seed: _anchorIdlSeed,
      programId: program,
    );

    final info = await _rpc.getAccountInfo(
      idlAddress.toBase58(),
      encoding: Encoding.base64,
    );
    final account = info.value;
    if (account != null && account.owner != programId) {
      throw StateError(
        'The on-chain Anchor IDL account has an unexpected owner.',
      );
    }
    final data = account?.data;
    if (data is! BinaryAccountData) {
      throw StateError('The configured program has no on-chain Anchor IDL.');
    }

    return decodeAccountData(data.data);
  }

  /// Decodes raw bytes from a legacy Anchor IDL account.
  static Map<String, dynamic> decodeAccountData(List<int> accountData) {
    final raw = Uint8List.fromList(accountData);
    if (raw.length < _anchorIdlPayloadOffset) {
      throw const FormatException(
        'The on-chain Anchor IDL account is truncated.',
      );
    }

    final dataLength = ByteData.sublistView(
      raw,
      _anchorIdlDataLengthOffset,
      _anchorIdlPayloadOffset,
    ).getUint32(0, Endian.little);
    final payloadEnd = _anchorIdlPayloadOffset + dataLength;
    if (payloadEnd > raw.length) {
      throw const FormatException(
        'The on-chain Anchor IDL payload is truncated.',
      );
    }

    final Object? decoded;
    try {
      final compressed = raw.sublist(_anchorIdlPayloadOffset, payloadEnd);
      decoded = jsonDecode(utf8.decode(zlib.decode(compressed)));
    } on Object {
      throw const FormatException(
        'The on-chain Anchor IDL payload is invalid.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('IDL JSON root is not an object.');
    }

    return decoded;
  }
}
