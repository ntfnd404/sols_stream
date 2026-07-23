import 'package:solana/solana.dart' show Commitment, RpcClient;
import 'package:solana_wallet/src/data/funding/funding_request_outcome.dart';
import 'package:solana_wallet/src/data/funding/funding_source.dart';
import 'package:solana_wallet/src/data/funding/solana_funding_gateway.dart';

const Duration defaultFundingConfirmationTimeout = Duration(seconds: 30);
const Duration defaultFundingPollInterval = Duration(seconds: 1);

/// Ensures a confirmed balance by trying injected [FundingSource] strategies.
///
/// Sources are attempted in order. An empty source list is the explicit
/// balance-only production policy: the gateway checks existing funds but never
/// requests an airdrop or contacts a faucet.
final class ConfirmedBalanceFundingGateway implements SolanaFundingGateway {
  final RpcClient _rpcClient;
  final List<FundingSource> _sources;
  final int _minLamports;
  final Duration _fundingTimeout;
  final Duration _pollInterval;

  ConfirmedBalanceFundingGateway({
    required this._rpcClient,
    required List<FundingSource> sources,
    required int minLamports,
    this._fundingTimeout = defaultFundingConfirmationTimeout,
    this._pollInterval = defaultFundingPollInterval,
  }) : _sources = List.unmodifiable(sources),
       _minLamports = minLamports {
    if (minLamports <= 0) {
      throw ArgumentError.value(
        minLamports,
        'minLamports',
        'must be positive',
      );
    }
    if (_fundingTimeout.isNegative) {
      throw ArgumentError.value(
        _fundingTimeout,
        'fundingTimeout',
        'must not be negative',
      );
    }
    if (_pollInterval <= Duration.zero) {
      throw ArgumentError.value(
        _pollInterval,
        'pollInterval',
        'must be positive',
      );
    }
  }

  @override
  Future<bool> ensureFunded(String address) async {
    if (await _hasRequiredBalance(address)) return true;

    for (final source in _sources) {
      final outcome = await source.requestFunding(address);
      if (outcome == FundingRequestOutcome.fallbackAllowed) continue;

      return _pollUntilFunded(address);
    }

    return false;
  }

  Future<bool> _pollUntilFunded(String address) async {
    final deadline = DateTime.now().add(_fundingTimeout);
    while (true) {
      if (await _hasRequiredBalance(address)) return true;
      final remaining = deadline.difference(DateTime.now());
      if (remaining <= Duration.zero) return false;
      await Future<void>.delayed(
        remaining < _pollInterval ? remaining : _pollInterval,
      );
    }
  }

  Future<bool> _hasRequiredBalance(String address) async {
    final balance = await _rpcClient.getBalance(
      address,
      commitment: Commitment.confirmed,
    );

    return balance.value >= _minLamports;
  }
}
