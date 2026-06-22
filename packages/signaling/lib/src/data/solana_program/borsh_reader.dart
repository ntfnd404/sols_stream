import 'dart:typed_data';

/// Cursor-based reader for Borsh-encoded byte buffers.
final class BorshReader {
  /// Length, in bytes, of the `u32` length-prefix preceding a Borsh
  /// `String`/`Vec<u8>`.
  static const int _lengthPrefixBytes = 4;

  /// Length, in bytes, of a Borsh `u64`/`i64` field.
  static const int _u64Bytes = 8;

  /// `2^63` — the sign bit of a 64-bit two's-complement integer.
  static final BigInt _signBit = BigInt.one << 63;

  /// `2^64` — used to map an unsigned 64-bit value into its signed range.
  static final BigInt _twoPow64 = BigInt.one << 64;

  final Uint8List _data;
  int _offset;

  /// Current read position, in bytes.
  int get offset => _offset;

  /// Bytes left between the cursor and the end of the buffer. Used to detect
  /// optional appended fields (e.g. an account written before a layout upgrade
  /// lacks the trailing fields) before attempting to read them.
  int get remaining => _data.length - _offset;

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

  /// Reads a little-endian Borsh `u64` field as a [BigInt] and advances the
  /// cursor.
  ///
  /// Assembled byte-by-byte rather than via `ByteData.getUint64`, which throws
  /// `UnsupportedError` on the web (JS has no native 64-bit integer). [BigInt]
  /// is exact across the full `u64` range on every platform.
  BigInt readU64() {
    _require(_u64Bytes);
    var value = BigInt.zero;
    for (var i = _u64Bytes - 1; i >= 0; i--) {
      value = (value << 8) | BigInt.from(_data[_offset + i]);
    }
    _offset += _u64Bytes;

    return value;
  }

  /// Reads a little-endian Borsh `i64` field as a [BigInt] and advances the
  /// cursor. Reinterprets the unsigned bytes as two's-complement: values with
  /// the sign bit set map into the negative range.
  BigInt readI64() {
    final unsigned = readU64();

    return unsigned >= _signBit ? unsigned - _twoPow64 : unsigned;
  }

  /// Reads a single byte and advances the cursor.
  int readU8() {
    _require(1);

    return _data[_offset++];
  }

  /// Reads a Borsh `bool` (one byte; any non-zero value is `true`) and advances
  /// the cursor.
  bool readBool() => readU8() != 0;

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
