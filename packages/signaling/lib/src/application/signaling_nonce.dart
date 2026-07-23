import 'dart:math';

import 'package:signaling/src/application/signaling_protocol_constants.dart';

/// Generates a random nonce that is exact on Dart native and Dart web.
int generateSecureSignalingNonce() {
  final random = Random.secure();
  final bytes = List<int>.generate(
    SignalingProtocolConstants.nonceByteLength,
    (_) => random.nextInt(256),
    growable: false,
  );

  return signalingNonceFromBytes(bytes);
}

int signalingNonceFromBytes(List<int> bytes) {
  if (bytes.length != SignalingProtocolConstants.nonceByteLength) {
    throw ArgumentError.value(
      bytes.length,
      'bytes.length',
      'must equal ${SignalingProtocolConstants.nonceByteLength}',
    );
  }

  // Seven bytes carry 56 bits. Keep five bits from the first byte and all
  // remaining bytes to stay within JavaScript's exact 53-bit integer range.
  var value = bytes.first & 0x1f;
  for (final byte in bytes.skip(1)) {
    value = value * 256 + byte;
  }

  return value;
}
