import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:solana/dto.dart' show BalanceResult;
import 'package:solana/solana.dart' show Commitment, Ed25519HDPublicKey;
import 'package:solana_wallet/solana_wallet.dart';
import 'package:test/test.dart';

import 'fakes/mock_http_client.dart';
import 'fakes/mock_rpc_client.dart';

void main() {
  // System Program id (32 zero bytes) — a valid base58 pubkey for the test.
  final account = Ed25519HDPublicKey.fromBase58('11111111111111111111111111111111');
  final faucet = Uri.parse('http://faucet.test/airdrop');
  const minLamports = 1000;
  const airdropLamports = 5000;

  late MockRpcClient rpcClient;
  late MockHttpClient httpClient;

  setUpAll(() {
    registerFallbackValue(Commitment.confirmed);
    registerFallbackValue(faucet);
  });

  setUp(() {
    rpcClient = MockRpcClient();
    httpClient = MockHttpClient();
  });

  AirdropFaucetFundingGateway gateway() => AirdropFaucetFundingGateway(
    rpcClient: rpcClient,
    httpClient: httpClient,
    faucetUri: faucet,
    minLamports: minLamports,
    airdropLamports: airdropLamports,
    // Zero timeout => the balance poll performs a single immediate read, so the
    // stubbed balance sequences below map one-to-one onto the reads made.
    fundingTimeout: Duration.zero,
  );

  BalanceResult balanceOf(int lamports) {
    final result = MockBalanceResult();
    when(() => result.value).thenReturn(lamports);

    return result;
  }

  void stubBalances(List<int> sequence) {
    var call = 0;
    when(() => rpcClient.getBalance(any(), commitment: any(named: 'commitment'))).thenAnswer((_) async {
      final value = sequence[call < sequence.length ? call : sequence.length - 1];
      call++;

      return balanceOf(value);
    });
  }

  test('returns true without airdrop when already funded', () async {
    stubBalances([minLamports]);

    final ok = await gateway().ensureFunded(account);

    expect(ok, isTrue);
    verifyNever(() => rpcClient.requestAirdrop(any(), any(), commitment: any(named: 'commitment')));
    verifyNever(
      () => httpClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    );
  });

  test('airdrops when below threshold and succeeds', () async {
    stubBalances([0, minLamports]);
    when(
      () => rpcClient.requestAirdrop(any(), any(), commitment: any(named: 'commitment')),
    ).thenAnswer((_) async => 'sig');

    final ok = await gateway().ensureFunded(account);

    expect(ok, isTrue);
    verify(() => rpcClient.requestAirdrop(any(), airdropLamports, commitment: any(named: 'commitment'))).called(1);
    verifyNever(
      () => httpClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    );
  });

  test('falls back to faucet when airdrop does not fund', () async {
    stubBalances([0, 0, minLamports]);
    when(
      () => rpcClient.requestAirdrop(any(), any(), commitment: any(named: 'commitment')),
    ).thenAnswer((_) async => 'sig');
    when(
      () => httpClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => http.Response('', 200));

    final ok = await gateway().ensureFunded(account);

    expect(ok, isTrue);
    final captured = verify(
      () => httpClient.post(
        any(),
        headers: any(named: 'headers'),
        body: captureAny(named: 'body'),
      ),
    ).captured.single;
    // Pin the faucet contract: it expects {"wallet": "<base58>"} and 400s on any
    // other field name (e.g. "address"). Regression guard for that exact shape.
    expect(jsonDecode(captured as String), {'wallet': account.toBase58()});
  });

  test('returns false when neither airdrop nor faucet funds', () async {
    stubBalances([0]);
    when(
      () => rpcClient.requestAirdrop(any(), any(), commitment: any(named: 'commitment')),
    ).thenAnswer((_) async => 'sig');
    when(
      () => httpClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => http.Response('', 200));

    final ok = await gateway().ensureFunded(account);

    expect(ok, isFalse);
  });

  test('returns false without re-reading balance when faucet responds non-2xx', () async {
    stubBalances([0]);
    when(
      () => rpcClient.requestAirdrop(any(), any(), commitment: any(named: 'commitment')),
    ).thenAnswer((_) async => 'sig');
    when(
      () => httpClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => http.Response('rate limited', 429));

    final ok = await gateway().ensureFunded(account);

    expect(ok, isFalse);
    // One read before airdrop, one to confirm the airdrop; the faucet's non-2xx
    // short-circuits before any further balance read.
    verify(() => rpcClient.getBalance(any(), commitment: any(named: 'commitment'))).called(2);
  });

  test('asserts when airdropLamports cannot cover minLamports', () {
    expect(
      () => AirdropFaucetFundingGateway(
        rpcClient: rpcClient,
        httpClient: httpClient,
        faucetUri: faucet,
        minLamports: 1000,
        airdropLamports: 500,
      ),
      throwsA(isA<AssertionError>()),
    );
  });
}
