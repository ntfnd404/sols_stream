import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana/solana.dart' show Commitment, Ed25519HDPublicKey, RpcClient;
import 'package:solana_wallet/src/domain/funding_gateway.dart';

/// [FundingGateway] backed by an RPC airdrop with an HTTP faucet fallback. This
/// is the free-lamports strategy — it only works on a cluster that offers
/// airdrops (devnet); mainnet uses a different gateway.
///
/// The injected [RpcClient] is a raw RPC client: [RpcClient.requestAirdrop]
/// returns as soon as the node accepts the request and does **not** wait for
/// the transaction to confirm. Funding is therefore confirmed here by polling
/// the account balance until it crosses [_minLamports] or [_fundingTimeout]
/// elapses. Robust slot-aware backoff is out of scope (tracked in SS-0004).
///
/// The faucet is assumed to accept a JSON body of the shape
/// `{"address": "<base58 pubkey>"}` and to signal success with a 2xx status.
final class AirdropFaucetFundingGateway implements FundingGateway {
  final RpcClient _rpcClient;
  final http.Client _httpClient;
  final Uri _faucetUri;
  final int _minLamports;
  final int _airdropLamports;
  final Duration _requestTimeout;
  final Duration _fundingTimeout;
  final Duration _pollInterval;

  const AirdropFaucetFundingGateway({
    required this._rpcClient,
    required this._httpClient,
    required this._faucetUri,
    required int minLamports,
    required int airdropLamports,
    this._requestTimeout = const Duration(seconds: 30),
    this._fundingTimeout = const Duration(seconds: 30),
    this._pollInterval = const Duration(seconds: 1),
  }) : assert(minLamports > 0, 'minLamports must be positive'),
       assert(airdropLamports > 0, 'airdropLamports must be positive'),
       assert(
         airdropLamports >= minLamports,
         'airdropLamports must cover minLamports, otherwise the airdrop can never satisfy the threshold',
       ),
       _minLamports = minLamports,
       _airdropLamports = airdropLamports;

  @override
  Future<bool> ensureFunded(Ed25519HDPublicKey account) async {
    final address = account.toBase58();
    if (await _balance(address) >= _minLamports) return true;

    if (await _airdropAndConfirm(address)) return true;

    return _faucetAndConfirm(address);
  }

  /// Requests an airdrop and waits for the balance to reflect it. Returns false
  /// (so the caller falls back to the faucet) if the airdrop request is
  /// unavailable — rate-limited or non-devnet — or does not land in time.
  Future<bool> _airdropAndConfirm(String address) async {
    try {
      await _rpcClient
          .requestAirdrop(address, _airdropLamports, commitment: Commitment.confirmed)
          .timeout(_requestTimeout);
    } on Exception {
      return false;
    }

    return _pollUntilFunded(address);
  }

  /// Posts to the faucet and waits for the balance to reflect it. Returns false
  /// on a transport error, a non-2xx response, or if funds do not land in time.
  Future<bool> _faucetAndConfirm(String address) async {
    try {
      final response = await _httpClient
          .post(
            _faucetUri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'address': address}),
          )
          .timeout(_requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) return false;
    } on Exception {
      return false;
    }

    return _pollUntilFunded(address);
  }

  /// Polls the balance until it crosses [_minLamports] or [_fundingTimeout]
  /// elapses. Always checks at least once, so a zero timeout yields a single
  /// immediate read.
  Future<bool> _pollUntilFunded(String address) async {
    final deadline = DateTime.now().add(_fundingTimeout);
    while (true) {
      if (await _balance(address) >= _minLamports) return true;
      if (!DateTime.now().isBefore(deadline)) return false;
      await Future<void>.delayed(_pollInterval);
    }
  }

  Future<int> _balance(String address) async {
    final balance = await _rpcClient.getBalance(address, commitment: Commitment.confirmed);

    return balance.value;
  }
}
