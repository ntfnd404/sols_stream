import 'package:flutter_test/flutter_test.dart';
import 'package:streaming/streaming.dart';

void main() {
  test('HLS auth toString redacts credentials', () {
    const auth = HlsAuthConfig(
      username: 'user',
      password: 'password',
      bearerToken: 'token',
    );

    final value = auth.toString();

    expect(value, contains('[redacted]'));
    expect(value, isNot(contains('password')));
    expect(value, isNot(contains('token')));
  });
}
