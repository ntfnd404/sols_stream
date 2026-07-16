import 'package:mocktail/mocktail.dart';
import 'package:solana/solana.dart' show HttpException, JsonRpcException;
import 'package:solana_wallet/src/data/funding/funding_request_outcome.dart';
import 'package:solana_wallet/src/data/funding/rpc_airdrop_funding_source.dart';
import 'package:test/test.dart';

import 'mocks/mock_rpc_client.dart';

void main() {
  const address = '11111111111111111111111111111111';
  late MockRpcClient rpc;

  setUp(() => rpc = MockRpcClient());

  test('returns accepted when RPC accepts the airdrop', () async {
    when(
      () => rpc.requestAirdrop(
        any(),
        any(),
        commitment: any(named: 'commitment'),
      ),
    ).thenAnswer((_) async => 'signature');
    final source = RpcAirdropFundingSource(
      rpcClient: rpc,
      lamports: 5000,
    );

    expect(
      await source.requestFunding(address),
      FundingRequestOutcome.accepted,
    );
  });

  test('returns indeterminate for a malformed RPC response', () async {
    when(
      () => rpc.requestAirdrop(
        any(),
        any(),
        commitment: any(named: 'commitment'),
      ),
    ).thenThrow(const FormatException('malformed response'));
    final source = RpcAirdropFundingSource(
      rpcClient: rpc,
      lamports: 5000,
    );

    expect(
      await source.requestFunding(address),
      FundingRequestOutcome.indeterminate,
    );
  });

  test('allows fallback for an explicit JSON-RPC error', () async {
    when(
      () => rpc.requestAirdrop(
        any(),
        any(),
        commitment: any(named: 'commitment'),
      ),
    ).thenThrow(const JsonRpcException('airdrop disabled', -1, null));
    final source = RpcAirdropFundingSource(
      rpcClient: rpc,
      lamports: 5000,
    );

    expect(
      await source.requestFunding(address),
      FundingRequestOutcome.fallbackAllowed,
    );
  });

  test('allows dev fallback for a non-JSON HTTP response', () async {
    when(
      () => rpc.requestAirdrop(
        any(),
        any(),
        commitment: any(named: 'commitment'),
      ),
    ).thenThrow(const HttpException(429, 'rate limited'));
    final source = RpcAirdropFundingSource(
      rpcClient: rpc,
      lamports: 5000,
    );

    expect(
      await source.requestFunding(address),
      FundingRequestOutcome.fallbackAllowed,
    );
  });

  test('returns indeterminate when the RPC request times out', () async {
    when(
      () => rpc.requestAirdrop(
        any(),
        any(),
        commitment: any(named: 'commitment'),
      ),
    ).thenAnswer(
      (_) => Future<String>.delayed(
        const Duration(seconds: 1),
        () => 'late-signature',
      ),
    );
    final source = RpcAirdropFundingSource(
      rpcClient: rpc,
      lamports: 5000,
      requestTimeout: Duration.zero,
    );

    expect(
      await source.requestFunding(address),
      FundingRequestOutcome.indeterminate,
    );
  });

  test('rejects non-positive airdrop amounts', () {
    expect(
      () => RpcAirdropFundingSource(
        rpcClient: rpc,
        lamports: 0,
      ),
      throwsArgumentError,
    );
  });
}
