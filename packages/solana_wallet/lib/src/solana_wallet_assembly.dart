import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:secure_storage/secure_storage_contracts.dart';
import 'package:solana/solana.dart' show RpcClient;
import 'package:solana_wallet/src/data/funding/confirmed_balance_funding_gateway.dart';
import 'package:solana_wallet/src/data/funding/funding_source.dart';
import 'package:solana_wallet/src/data/funding/http_faucet_funding_source.dart';
import 'package:solana_wallet/src/data/funding/rpc_airdrop_funding_source.dart';
import 'package:solana_wallet/src/data/solana_wallet.dart';
import 'package:solana_wallet/src/data/wallet_key_store.dart';
import 'package:solana_wallet/src/domain/solana_funding_service.dart';
import 'package:solana_wallet/src/domain/solana_signer.dart';
import 'package:solana_wallet/src/domain/solana_wallet_reader.dart';
import 'package:solana_wallet/src/domain/wallet_storage_exception.dart';
import 'package:solana_wallet/src/funding_config/wallet_funding_config.dart';

typedef WalletHttpClientFactory = http.Client Function();

/// Composition of the wallet bounded context. Resolves the keypair via the key
/// store and exposes only the published ports — never the concrete adapter,
/// the keypair, or the [RpcClient].
final class SolanaWalletAssembly {
  static const int _maxExactWebInteger = 0x1fffffffffffff;

  /// Signing port (sign only).
  final SolanaSigner signer;

  /// Read-only address and native SOL balance capabilities.
  final SolanaWalletReader reader;

  /// Workspace-internal funding precondition capability.
  final SolanaFundingService fundingService;

  final http.Client? _ownedHttpClient;
  Future<void>? _disposeFuture;

  SolanaWalletAssembly._({
    required this.signer,
    required this.reader,
    required this.fundingService,
    required this._ownedHttpClient,
  });

  /// Loads or creates the wallet keypair, then wires the wallet adapter.
  ///
  /// Throws [WalletStorageException] if stored key material is unreadable.
  static Future<SolanaWalletAssembly> create({
    required SecureStorage storage,
    required RpcClient rpc,
    required WalletFundingConfig funding,
    required String storageKey,
    WalletHttpClientFactory httpClientFactory = http.Client.new,
  }) async {
    _validateFunding(funding);
    final keypair = await WalletKeyStore(storage, storageKey).loadOrCreate();

    http.Client? ownedHttpClient;
    try {
      final sources = <FundingSource>[];
      switch (funding) {
        case BalanceOnlyFundingConfig():
          break;
        case RpcAirdropFundingConfig(
          :final airdropRpcUri,
          :final airdropLamports,
        ):
          sources.add(
            RpcAirdropFundingSource(
              rpcClient: RpcClient(airdropRpcUri.toString()),
              lamports: airdropLamports,
            ),
          );
        case RpcAirdropWithFaucetFundingConfig(
          :final airdropRpcUri,
          :final airdropLamports,
          :final faucetUri,
        ):
          sources.add(
            RpcAirdropFundingSource(
              rpcClient: RpcClient(airdropRpcUri.toString()),
              lamports: airdropLamports,
            ),
          );
          ownedHttpClient = httpClientFactory();
          sources.add(
            HttpFaucetFundingSource(
              httpClient: ownedHttpClient,
              faucetUri: faucetUri,
            ),
          );
      }

      final gateway = ConfirmedBalanceFundingGateway(
        rpcClient: rpc,
        sources: sources,
        minLamports: funding.minimumBalanceLamports,
      );
      final wallet = SolanaWallet(keypair, rpc, gateway);

      return SolanaWalletAssembly._(
        signer: wallet,
        reader: wallet,
        fundingService: wallet,
        ownedHttpClient: ownedHttpClient,
      );
    } catch (_) {
      ownedHttpClient?.close();
      rethrow;
    }
  }

  /// Releases resources created by this assembly.
  Future<void> dispose() => _disposeFuture ??= Future<void>.sync(
    () => _ownedHttpClient?.close(),
  );

  static void _validateFunding(WalletFundingConfig funding) {
    _validateLamports(
      funding.minimumBalanceLamports,
      'minimumBalanceLamports',
    );

    switch (funding) {
      case BalanceOnlyFundingConfig():
        break;
      case RpcAirdropFundingConfig(
        :final airdropRpcUri,
        :final airdropLamports,
      ):
        _validateAirdrop(
          airdropRpcUri,
          airdropLamports,
          funding.minimumBalanceLamports,
        );
      case RpcAirdropWithFaucetFundingConfig(
        :final airdropRpcUri,
        :final airdropLamports,
        :final faucetUri,
      ):
        _validateAirdrop(
          airdropRpcUri,
          airdropLamports,
          funding.minimumBalanceLamports,
        );
        _validateHttpUri(faucetUri, 'faucetUri');
    }
  }

  static void _validateAirdrop(
    Uri uri,
    int lamports,
    int minimumBalanceLamports,
  ) {
    _validateHttpUri(uri, 'airdropRpcUri');
    _validateLamports(lamports, 'airdropLamports');
    if (lamports < minimumBalanceLamports) {
      throw ArgumentError.value(
        lamports,
        'airdropLamports',
        'must cover minimumBalanceLamports for a newly created wallet',
      );
    }
  }

  static void _validateHttpUri(Uri uri, String name) {
    if (!uri.isAbsolute ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment) {
      throw ArgumentError.value(
        uri,
        name,
        'must be an absolute HTTP or HTTPS URI without user info or fragment',
      );
    }
  }

  static void _validateLamports(int value, String name) {
    if (value <= 0 || value > _maxExactWebInteger) {
      throw ArgumentError.value(
        value,
        name,
        'must be positive and exactly representable on Flutter Web',
      );
    }
  }
}
