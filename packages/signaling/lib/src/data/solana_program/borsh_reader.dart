import 'dart:typed_data';

/// Cursor-based reader for Borsh-encoded byte buffers.
final class BorshReader {
  /// Length, in bytes, of the `u32` length-prefix preceding a Borsh
  /// `String`/`Vec<u8>`.
  static const int _lengthPrefixBytes = 4;

  /// Length, in bytes, of a Borsh `u64`/`i64` field.
  static const int _u64Bytes = 8;

  final Uint8List _data;
  int _offset;

  /// Current read position, in bytes.
  int get offset => _offset;

  BorshReader(
    this._data, [
    this._offset = 0,
  ]);

  /// Reads [length] raw bytes and advances the cursor.
  Uint8List readFixed(int length) {
    final bytes = _data.sublist(_offset, _offset + length);
    _offset += length;

    return bytes;
  }

  /// Reads a Borsh `Vec<u8>`: u32 length prefix followed by that many bytes.
  Uint8List readVec() {
    final length = ByteData.sublistView(_data, _offset, _offset + _lengthPrefixBytes).getUint32(0, Endian.little);
    _offset += _lengthPrefixBytes;

    return readFixed(length);
  }

  /// Skips a Borsh `u64` field without decoding it.
  void skipU64() => _offset += _u64Bytes;

  /// Reads a Borsh `i64` field and advances the cursor.
  int readI64() {
    final value = ByteData.sublistView(_data, _offset, _offset + _u64Bytes).getInt64(0, Endian.little);
    _offset += _u64Bytes;

    return value;
  }

  /// Reads a single byte and advances the cursor.
  int readU8() => _data[_offset++];
}
