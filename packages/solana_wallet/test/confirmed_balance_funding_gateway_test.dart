import 'package:mocktail/mocktail.dart';
import 'package:solana/dto.dart' show BalanceResult;
import 'package:solana_wallet/src/data/funding/confirmed_balance_funding_gateway.dart';
import 'package:solana_wallet/src/data/funding/funding_request_outcome.dart';
import 'package:test/test.dart';

import 'mocks/mock_balance_result.dart';
import 'mocks/mock_funding_source.dart';
import 'mocks/mock_rpc_client.dart';

void main() {
  const address = '11111111111111111111111111111111';
  const minLamports = 1000;
  late MockRpcClient rpc;

  setUp(() => rpc = MockRpcClient());

  BalanceResult balance(int value) {
    final result = MockBalanceResult();
    when(() => result.value).thenReturn(value);

    return result;
  }

  void stubBalances(List<int> values) {
    var index = 0;
    when(
      () => rpc.getBalance(any(), commitment: any(named: 'commitment')),
    ).thenAnswer((_) async {
      final value = values[index < values.length ? index : values.length - 1];
      index += 1;

      return balance(value);
    });
  }

  test('balance-only succeeds when existing funds meet the threshold', () async {
    stubBalances([minLamports]);
    final gateway = ConfirmedBalanceFundingGateway(
      rpcClient: rpc,
      sources: const [],
      minLamports: minLamports,
    );

    expect(
      await gateway.ensureFunded(address),
      isTrue,
    );
  });

  test('balance-only fails without invoking a funding source', () async {
    stubBalances([0]);
    final gateway = ConfirmedBalanceFundingGateway(
      rpcClient: rpc,
      sources: const [],
      minLamports: minLamports,
    );

    expect(
      await gateway.ensureFunded(address),
      isFalse,
    );
  });

  test('tries sources in order and confirms the accepted source', () async {
    final unavailable = MockFundingSource();
    final faucet = MockFundingSource();
    stubBalances([0, minLamports]);
    when(
      () => unavailable.requestFunding(address),
    ).thenAnswer((_) async => FundingRequestOutcome.fallbackAllowed);
    when(
      () => faucet.requestFunding(address),
    ).thenAnswer((_) async => FundingRequestOutcome.accepted);
    final gateway = ConfirmedBalanceFundingGateway(
      rpcClient: rpc,
      sources: [unavailable, faucet],
      minLamports: minLamports,
      fundingTimeout: Duration.zero,
    );

    expect(
      await gateway.ensureFunded(address),
      isTrue,
    );
    verifyInOrder([
      () => unavailable.requestFunding(address),
      () => faucet.requestFunding(address),
    ]);
  });

  test('does not risk fallback after an accepted source times out', () async {
    final airdrop = MockFundingSource();
    final faucet = MockFundingSource();
    stubBalances([0, 0]);
    when(
      () => airdrop.requestFunding(address),
    ).thenAnswer((_) async => FundingRequestOutcome.accepted);
    final gateway = ConfirmedBalanceFundingGateway(
      rpcClient: rpc,
      sources: [airdrop, faucet],
      minLamports: minLamports,
      fundingTimeout: Duration.zero,
    );

    expect(
      await gateway.ensureFunded(address),
      isFalse,
    );
    verify(() => airdrop.requestFunding(address)).called(1);
    verifyNever(() => faucet.requestFunding(address));
  });

  test('reconciles an indeterminate request before trying fallback', () async {
    final airdrop = MockFundingSource();
    final faucet = MockFundingSource();
    stubBalances([0, minLamports]);
    when(
      () => airdrop.requestFunding(address),
    ).thenAnswer((_) async => FundingRequestOutcome.indeterminate);
    final gateway = ConfirmedBalanceFundingGateway(
      rpcClient: rpc,
      sources: [airdrop, faucet],
      minLamports: minLamports,
      fundingTimeout: Duration.zero,
    );

    expect(
      await gateway.ensureFunded(address),
      isTrue,
    );
    verify(() => airdrop.requestFunding(address)).called(1);
    verifyNever(() => faucet.requestFunding(address));
  });

  test('does not fallback when indeterminate reconciliation times out', () async {
    final airdrop = MockFundingSource();
    final faucet = MockFundingSource();
    stubBalances([0, 0]);
    when(
      () => airdrop.requestFunding(address),
    ).thenAnswer((_) async => FundingRequestOutcome.indeterminate);
    final gateway = ConfirmedBalanceFundingGateway(
      rpcClient: rpc,
      sources: [airdrop, faucet],
      minLamports: minLamports,
      fundingTimeout: Duration.zero,
    );

    expect(await gateway.ensureFunded(address), isFalse);
    verifyNever(() => faucet.requestFunding(address));
  });

  test('validates public constructor arguments in release mode', () {
    expect(
      () => ConfirmedBalanceFundingGateway(
        rpcClient: rpc,
        sources: const [],
        minLamports: 0,
      ),
      throwsArgumentError,
    );
    expect(
      () => ConfirmedBalanceFundingGateway(
        rpcClient: rpc,
        sources: const [],
        minLamports: minLamports,
        fundingTimeout: const Duration(seconds: -1),
      ),
      throwsArgumentError,
    );
    expect(
      () => ConfirmedBalanceFundingGateway(
        rpcClient: rpc,
        sources: const [],
        minLamports: minLamports,
        pollInterval: Duration.zero,
      ),
      throwsArgumentError,
    );
  });

  test('caps polling delay at the remaining confirmation timeout', () async {
    final source = MockFundingSource();
    stubBalances([0, 0, minLamports]);
    when(
      () => source.requestFunding(address),
    ).thenAnswer((_) async => FundingRequestOutcome.accepted);
    final stopwatch = Stopwatch()..start();
    final gateway = ConfirmedBalanceFundingGateway(
      rpcClient: rpc,
      sources: [source],
      minLamports: minLamports,
      fundingTimeout: const Duration(milliseconds: 10),
      pollInterval: const Duration(seconds: 2),
    );

    expect(await gateway.ensureFunded(address), isTrue);
    stopwatch.stop();
    expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 500)));
  });
}
