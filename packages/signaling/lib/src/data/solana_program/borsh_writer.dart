import 'package:solana/encoder.dart';

/// Encodes [s] as a Borsh `String`: u32 length prefix + UTF-8 bytes.
ByteArray bString(String s) => ByteArray.merge([
  ByteArray.u32(s.codeUnits.length),
  ByteArray(s.codeUnits),
]);

/// Encodes [bytes] as a Borsh `Vec<u8>`: u32 length prefix + raw bytes.
ByteArray bVec(Iterable<int> bytes) {
  final list = bytes.toList();

  return ByteArray.merge([
    ByteArray.u32(list.length),
    ByteArray(list),
  ]);
}
