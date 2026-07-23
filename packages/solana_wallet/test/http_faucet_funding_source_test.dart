import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:solana_wallet/src/data/funding/funding_request_outcome.dart';
import 'package:solana_wallet/src/data/funding/http_faucet_funding_source.dart';
import 'package:test/test.dart';

import 'mocks/mock_http_client.dart';

void main() {
  const address = '11111111111111111111111111111111';
  final faucet = Uri.parse('https://faucet.test/fund');
  late MockHttpClient client;

  setUpAll(
    () => registerFallbackValue(http.Request('POST', faucet)),
  );
  setUp(() => client = MockHttpClient());

  test('posts the documented wallet contract and accepts 2xx', () async {
    when(
      () => client.send(any()),
    ).thenAnswer((_) async => http.StreamedResponse(const Stream.empty(), 204));
    final source = HttpFaucetFundingSource(
      httpClient: client,
      faucetUri: faucet,
    );

    expect(
      await source.requestFunding(address),
      FundingRequestOutcome.accepted,
    );
    final request =
        verify(
              () => client.send(captureAny()),
            ).captured.single
            as http.Request;
    expect(request.url, faucet);
    expect(request.method, 'POST');
    expect(request.followRedirects, isFalse);
    expect(request.headers['Content-Type'], 'application/json');
    expect(jsonDecode(request.body), {'wallet': address});
  });

  test('allows fallback for ordinary 4xx responses', () async {
    for (final status in [400, 429]) {
      when(
        () => client.send(any()),
      ).thenAnswer(
        (_) async => http.StreamedResponse(const Stream.empty(), status),
      );
      final source = HttpFaucetFundingSource(
        httpClient: client,
        faucetUri: faucet,
      );

      expect(
        await source.requestFunding(address),
        FundingRequestOutcome.fallbackAllowed,
        reason: 'status=$status',
      );
    }
  });

  test('treats 408, redirects, and 5xx as indeterminate', () async {
    for (final status in [302, 408, 500]) {
      when(
        () => client.send(any()),
      ).thenAnswer(
        (_) async => http.StreamedResponse(const Stream.empty(), status),
      );
      final source = HttpFaucetFundingSource(
        httpClient: client,
        faucetUri: faucet,
      );

      expect(
        await source.requestFunding(address),
        FundingRequestOutcome.indeterminate,
        reason: 'status=$status',
      );
    }
  });

  test('treats transport failure as indeterminate', () async {
    when(
      () => client.send(any()),
    ).thenThrow(Exception('offline'));
    final source = HttpFaucetFundingSource(
      httpClient: client,
      faucetUri: faucet,
    );

    expect(
      await source.requestFunding(address),
      FundingRequestOutcome.indeterminate,
    );
  });

  test('returns indeterminate when the faucet request times out', () async {
    when(
      () => client.send(any()),
    ).thenAnswer(
      (_) => Future<http.StreamedResponse>.delayed(
        const Duration(seconds: 1),
        () => http.StreamedResponse(const Stream.empty(), 200),
      ),
    );
    final source = HttpFaucetFundingSource(
      httpClient: client,
      faucetUri: faucet,
      requestTimeout: Duration.zero,
    );

    expect(
      await source.requestFunding(address),
      FundingRequestOutcome.indeterminate,
    );
  });

  test('times out while consuming a stalled response body', () async {
    final body = StreamController<List<int>>();
    addTearDown(body.close);
    when(
      () => client.send(any()),
    ).thenAnswer(
      (_) async => http.StreamedResponse(body.stream, 200),
    );
    final source = HttpFaucetFundingSource(
      httpClient: client,
      faucetUri: faucet,
      requestTimeout: Duration.zero,
    );

    expect(
      await source.requestFunding(address),
      FundingRequestOutcome.indeterminate,
    );
  });

  test('rejects relative faucet URIs', () {
    expect(
      () => HttpFaucetFundingSource(
        httpClient: client,
        faucetUri: Uri.parse('/fund'),
      ),
      throwsArgumentError,
    );
  });

  test('rejects URIs without authority or with credentials or fragment', () {
    for (final uri in [
      Uri.parse('https:/fund'),
      Uri.parse('https://user@example.com/fund'),
      Uri.parse('https://faucet.example.com/fund#fragment'),
    ]) {
      expect(
        () => HttpFaucetFundingSource(
          httpClient: client,
          faucetUri: uri,
        ),
        throwsArgumentError,
        reason: '$uri',
      );
    }
  });
}
