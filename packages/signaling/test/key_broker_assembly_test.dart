import 'package:mocktail/mocktail.dart';
import 'package:signaling/key_broker_assembly.dart';
import 'package:signaling/src/data/http_key_broker_gateway.dart';
import 'package:signaling/src/data/local_key_broker_gateway.dart';
import 'package:test/test.dart';

import 'mocks/mock_http_client.dart';

void main() {
  test('creates a local broker without an HTTP client', () async {
    var clientCreated = false;
    final assembly = KeyBrokerAssembly.create(
      const LocalKeyBrokerConfig(),
      httpClientFactory: () {
        clientCreated = true;

        return MockHttpClient();
      },
    );

    expect(assembly.gateway, isA<LocalKeyBrokerGateway>());
    expect(clientCreated, isFalse);
    await assembly.dispose();
  });

  test('owns and closes the HTTP client exactly once', () async {
    final client = MockHttpClient();
    var closeCount = 0;
    when(() => client.close()).thenAnswer((_) {
      closeCount += 1;
    });
    final assembly = KeyBrokerAssembly.create(
      HttpKeyBrokerConfig(
        endpoint: Uri.parse('https://broker.example.com'),
      ),
      httpClientFactory: () => client,
    );

    expect(assembly.gateway, isA<HttpKeyBrokerGateway>());
    await assembly.dispose();
    await assembly.dispose();
    expect(closeCount, 1);
  });

  test('rejects invalid remote endpoints before creating a client', () {
    var clientCreated = false;

    expect(
      () => KeyBrokerAssembly.create(
        HttpKeyBrokerConfig(
          endpoint: Uri.parse('https://broker.example.com/api'),
        ),
        httpClientFactory: () {
          clientCreated = true;

          return MockHttpClient();
        },
      ),
      throwsArgumentError,
    );
    expect(clientCreated, isFalse);
  });
}
