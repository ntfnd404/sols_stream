import 'dart:async';

import 'package:solana/solana.dart' show Commitment, HttpException, JsonRpcException, RpcClient;
import 'package:solana_wallet/src/data/funding/funding_request_outcome.dart';
import 'package:solana_wallet/src/data/funding/funding_source.dart';

const Duration defaultAirdropRequestTimeout = Duration(seconds: 30);

/// Requests lamports through Solana JSON-RPC `requestAirdrop`.
final class RpcAirdropFundingSource implements FundingSource {
  final RpcClient _rpcClient;
  final int _lamports;
  final Duration _requestTimeout;

  RpcAirdropFundingSource({
    required this._rpcClient,
    required int lamports,
    this._requestTimeout = defaultAirdropRequestTimeout,
  }) : _lamports = lamports {
    if (lamports <= 0) {
      throw ArgumentError.value(lamports, 'lamports', 'must be positive');
    }
    if (_requestTimeout.isNegative) {
      throw ArgumentError.value(
        _requestTimeout,
        'requestTimeout',
        'must not be negative',
      );
    }
  }

  @override
  Future<FundingRequestOutcome> requestFunding(String address) async {
    try {
      await _rpcClient
          .requestAirdrop(
            address,
            _lamports,
            commitment: Commitment.confirmed,
          )
          .timeout(_requestTimeout);

      return FundingRequestOutcome.accepted;
    } on TimeoutException {
      return FundingRequestOutcome.indeterminate;
    } on JsonRpcException {
      return FundingRequestOutcome.fallbackAllowed;
    } on HttpException {
      // Automatic funding is restricted to local/dev environments. Preserve
      // the existing dev faucet fallback when a public RPC rejects airdrops
      // with a non-JSON HTTP response.
      return FundingRequestOutcome.fallbackAllowed;
    } on Exception {
      return FundingRequestOutcome.indeterminate;
    }
  }
}
