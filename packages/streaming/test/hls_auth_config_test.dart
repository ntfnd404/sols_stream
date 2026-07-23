import 'package:flutter_test/flutter_test.dart';
import 'package:streaming/streaming.dart';

void main() {
  group('HlsAuthConfig.toHeaders', () {
    test('builds basic auth before bearer token', () {
      const auth = HlsAuthConfig(
        username: 'user',
        password: 'pass',
        bearerToken: 'token',
      );

      expect(auth.toHeaders(), {'Authorization': 'Basic dXNlcjpwYXNz'});
    });

    test('builds bearer auth when basic credentials are empty', () {
      const auth = HlsAuthConfig(bearerToken: 'token');

      expect(auth.toHeaders(), {'Authorization': 'Bearer token'});
    });

    test('omits authorization header when credentials are empty', () {
      expect(const HlsAuthConfig().toHeaders(), isEmpty);
    });
  });
}
