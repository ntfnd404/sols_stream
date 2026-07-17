import 'dart:convert';

final class HlsAuthConfig {
  final String username;
  final String password;
  final String bearerToken;

  const HlsAuthConfig({
    this.username = '',
    this.password = '',
    this.bearerToken = '',
  });

  Map<String, String> toHeaders() {
    final headers = <String, String>{};
    final user = username.trim();
    final pass = password.trim();
    final token = bearerToken.trim();
    if (user.isNotEmpty || pass.isNotEmpty) {
      final credentials = base64Encode(utf8.encode('$user:$pass'));
      headers['Authorization'] = 'Basic $credentials';
    } else if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  @override
  String toString() {
    final hasBasic = username.trim().isNotEmpty || password.trim().isNotEmpty;
    final hasBearer = bearerToken.trim().isNotEmpty;

    return 'HlsAuthConfig(basic: $hasBasic, bearer: $hasBearer, credentials: [redacted])';
  }
}
