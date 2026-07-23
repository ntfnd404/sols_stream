const _base58Alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

String base58Encode(List<int> bytes) {
  if (bytes.isEmpty) return '';

  var zeros = 0;
  while (zeros < bytes.length && bytes[zeros] == 0) {
    zeros++;
  }

  final digits = <int>[0];
  for (final byte in bytes.skip(zeros)) {
    var carry = byte;
    for (var i = 0; i < digits.length; i++) {
      carry += digits[i] << 8;
      digits[i] = carry % 58;
      carry ~/= 58;
    }
    while (carry > 0) {
      digits.add(carry % 58);
      carry ~/= 58;
    }
  }

  final buffer = StringBuffer();
  for (var i = 0; i < zeros; i++) {
    buffer.write(_base58Alphabet[0]);
  }
  if (zeros < bytes.length) {
    for (var i = digits.length - 1; i >= 0; i--) {
      buffer.write(_base58Alphabet[digits[i]]);
    }
  }

  return buffer.toString();
}
