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
    _require(length);
    final bytes = _data.sublist(_offset, _offset + length);
    _offset += length;

    return bytes;
  }

  /// Reads a Borsh `Vec<u8>`: u32 length prefix followed by that many bytes.
  Uint8List readVec() {
    _require(_lengthPrefixBytes);
    final length = ByteData.sublistView(_data, _offset, _offset + _lengthPrefixBytes).getUint32(0, Endian.little);
    _offset += _lengthPrefixBytes;

    return readFixed(length);
  }

  /// Reads a Borsh `u64` field and advances the cursor.
  ///
  /// Lamport amounts (deposits) fit comfortably below 2^53, so the returned
  /// `int` is exact on every platform; only theoretical values above 2^63 would
  /// wrap, which deposits never reach.
  int readU64() {
    _require(_u64Bytes);
    final value = ByteData.sublistView(_data, _offset, _offset + _u64Bytes).getUint64(0, Endian.little);
    _offset += _u64Bytes;

    return value;
  }

  /// Reads a Borsh `i64` field and advances the cursor.
  int readI64() {
    _require(_u64Bytes);
    final value = ByteData.sublistView(_data, _offset, _offset + _u64Bytes).getInt64(0, Endian.little);
    _offset += _u64Bytes;

    return value;
  }

  /// Reads a single byte and advances the cursor.
  int readU8() {
    _require(1);

    return _data[_offset++];
  }

  /// Guards a read of [bytes] against a truncated/malformed buffer. Throws a
  /// typed [FormatException] (an `Exception`, not a `RangeError`) so the
  /// application's `on Exception` poll guards treat a bad on-chain account as a
  /// transient read rather than crashing the session.
  void _require(int bytes) {
    if (_offset + bytes > _data.length) {
      throw FormatException(
        'Borsh read out of bounds: need $bytes byte(s) at offset $_offset of ${_data.length}',
      );
    }
  }
}
