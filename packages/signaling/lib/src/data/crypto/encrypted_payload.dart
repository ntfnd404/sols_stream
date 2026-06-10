import 'dart:convert';
import 'dart:typed_data';

class EncryptedPayload {
  /// base64(ciphertext + 16-byte GCM tag)
  final String ct;

  /// base64(12-byte nonce)
  final String iv;

  Uint8List get bytes {
    final json = jsonEncode(toJson());
    final result = utf8.encode(json);

    return Uint8List.fromList(result);
  }

  const EncryptedPayload({
    required this.ct,
    required this.iv,
  });

  factory EncryptedPayload.fromJson(Map<String, Object?> json) => EncryptedPayload(
    ct: json['ct'] as String,
    iv: json['iv'] as String,
  );

  factory EncryptedPayload.fromBytes(Uint8List bytes) => EncryptedPayload.fromJson(
    jsonDecode(utf8.decode(bytes)) as Map<String, Object?>,
  );

  Map<String, String> toJson() => {
    'ct': ct,
    'iv': iv,
  };
}
