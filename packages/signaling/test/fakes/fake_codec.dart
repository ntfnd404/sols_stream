import 'dart:convert';
import 'dart:typed_data';

import 'package:signaling/signaling.dart';

/// Trivial codec: ciphertext == UTF-8 of the SDP (round-trips without crypto).
class FakeCodec implements SignalPayloadCodec {
  @override
  Future<Uint8List> encode(String sdpJson, String prot, int slotNonce, String messageType) async =>
      Uint8List.fromList(utf8.encode(sdpJson));

  @override
  Future<String> decode(Uint8List bytes, String prot, int slotNonce, String messageType) async =>
      utf8.decode(bytes);

  @override
  Uint8List randomBytes(int n) => Uint8List.fromList(List.filled(n, 1));
}
