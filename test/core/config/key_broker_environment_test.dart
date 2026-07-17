import 'package:flutter_test/flutter_test.dart';
import 'package:signaling/key_broker_assembly.dart';
import 'package:sols_stream/core/config/configuration_error.dart';
import 'package:sols_stream/core/config/key_broker_environment.dart';

void main() {
  test('local mode forbids a remote endpoint', () {
    expect(
      KeyBrokerEnvironment.fromValues(mode: 'local').config,
      isA<LocalKeyBrokerConfig>(),
    );
    expect(
      () => KeyBrokerEnvironment.fromValues(
        mode: 'local',
        url: 'https://broker.example.com',
      ),
      throwsA(isA<ConfigurationError>()),
    );
  });

  test('HTTP mode requires a clean HTTPS origin', () {
    final environment = KeyBrokerEnvironment.fromValues(
      mode: 'http',
      url: 'https://broker.example.com',
    );

    expect(
      environment.config,
      isA<HttpKeyBrokerConfig>().having(
        (config) => config.endpoint,
        'endpoint',
        Uri.parse('https://broker.example.com'),
      ),
    );
    for (final invalid in [
      'http://broker.example.com',
      'https://user:secret@broker.example.com',
      'https://broker.example.com/api',
      'https://broker.example.com?token=secret',
    ]) {
      expect(
        () => KeyBrokerEnvironment.fromValues(mode: 'http', url: invalid),
        throwsA(isA<ConfigurationError>()),
      );
    }
  });
}
