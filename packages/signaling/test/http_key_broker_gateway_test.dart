import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:signaling/signaling.dart';
import 'package:signaling/src/data/http_key_broker_gateway.dart';
import 'package:test/test.dart';

import 'stubs/stub_streaming_http_client.dart';

void main() {
  test('reports broker status without exposing response content', () async {
    const secret = 'broker-secret-response';
    final gateway = HttpKeyBrokerGateway(
      endpoint: Uri.parse('https://broker.example.com'),
      client: MockClient(
        (_) async => http.Response(secret, 403),
      ),
      requestTimeout: const Duration(seconds: 1),
    );

    await expectLater(
      gateway.unprotect(
        protectedKey: 'protected',
        hostAddress: 'host',
        offerId: 'offer',
      ),
      throwsA(
        isA<KeyBrokerException>()
            .having((error) => error.statusCode, 'statusCode', 403)
            .having((error) => error.toString(), 'message', isNot(contains(secret))),
      ),
    );
  });

  test('maps malformed success bodies to a sanitized typed failure', () async {
    final gateway = HttpKeyBrokerGateway(
      endpoint: Uri.parse('https://broker.example.com'),
      client: MockClient(
        (_) async => http.Response('not-json-secret', 200),
      ),
      requestTimeout: const Duration(seconds: 1),
    );

    await expectLater(
      gateway.protect(
        passphrase: 'passphrase',
        hostAddress: 'host',
        offerId: 'offer',
      ),
      throwsA(
        isA<KeyBrokerException>()
            .having((error) => error.statusCode, 'statusCode', 200)
            .having(
              (error) => error.reason,
              'reason',
              'returned an invalid response',
            ),
      ),
    );
  });

  test('does not follow redirects for secret-bearing requests', () async {
    var requestCount = 0;
    final gateway = HttpKeyBrokerGateway(
      endpoint: Uri.parse('https://broker.example.com'),
      client: MockClient((request) async {
        requestCount += 1;
        expect(request.followRedirects, isFalse);

        return http.Response(
          '',
          307,
          headers: {'location': 'https://attacker.example.com'},
        );
      }),
      requestTimeout: const Duration(seconds: 1),
    );

    await expectLater(
      gateway.protect(
        passphrase: 'secret',
        hostAddress: 'host',
        offerId: 'offer',
      ),
      throwsA(
        isA<KeyBrokerException>().having(
          (error) => error.statusCode,
          'statusCode',
          307,
        ),
      ),
    );
    expect(requestCount, 1);
  });

  test('uses only JSON headers and maps timeout to a sanitized failure', () async {
    final gateway = HttpKeyBrokerGateway(
      endpoint: Uri.parse('https://broker.example.com'),
      client: MockClient((request) async {
        expect(request.headers, hasLength(1));
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.url.path, '/protect-key');
        await Completer<void>().future;

        return http.Response('', 200);
      }),
      requestTimeout: const Duration(milliseconds: 1),
    );

    await expectLater(
      gateway.protect(
        passphrase: 'secret',
        hostAddress: 'host',
        offerId: 'offer',
      ),
      throwsA(
        isA<KeyBrokerException>().having(
          (error) => error.reason,
          'reason',
          'request timed out',
        ),
      ),
    );
  });

  test('times out while reading a stalled response body', () async {
    final gateway = HttpKeyBrokerGateway(
      endpoint: Uri.parse('https://broker.example.com'),
      client: StubStreamingHttpClient(
        (_) async => http.StreamedResponse(
          Stream<List<int>>.fromFuture(Completer<List<int>>().future),
          200,
        ),
      ),
      requestTimeout: const Duration(milliseconds: 1),
    );

    await expectLater(
      gateway.protect(
        passphrase: 'secret',
        hostAddress: 'host',
        offerId: 'offer',
      ),
      throwsA(
        isA<KeyBrokerException>().having(
          (error) => error.reason,
          'reason',
          'request timed out',
        ),
      ),
    );
  });

  test('rejects an oversized response body without exposing it', () async {
    final gateway = HttpKeyBrokerGateway(
      endpoint: Uri.parse('https://broker.example.com'),
      client: StubStreamingHttpClient(
        (_) async => http.StreamedResponse(
          Stream.value(List<int>.filled(64 * 1024 + 1, 65)),
          200,
        ),
      ),
      requestTimeout: const Duration(seconds: 1),
    );

    await expectLater(
      gateway.protect(
        passphrase: 'secret',
        hostAddress: 'host',
        offerId: 'offer',
      ),
      throwsA(
        isA<KeyBrokerException>().having(
          (error) => error.reason,
          'reason',
          'returned an invalid response',
        ),
      ),
    );
  });

  test('maps HTTP client failures to a sanitized typed failure', () async {
    const secretEndpoint = 'https://secret-broker.example.com';
    final gateway = HttpKeyBrokerGateway(
      endpoint: Uri.parse(secretEndpoint),
      client: StubStreamingHttpClient(
        (_) async => throw http.ClientException(
          'connection failed for $secretEndpoint',
        ),
      ),
      requestTimeout: const Duration(seconds: 1),
    );

    await expectLater(
      gateway.protect(
        passphrase: 'secret',
        hostAddress: 'host',
        offerId: 'offer',
      ),
      throwsA(
        isA<KeyBrokerException>()
            .having((error) => error.reason, 'reason', 'request failed')
            .having(
              (error) => error.toString(),
              'message',
              isNot(contains(secretEndpoint)),
            ),
      ),
    );
  });
}
