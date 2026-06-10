import 'package:http/http.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:signaling/signaling.dart';
import 'package:solana/solana.dart' show RpcClient;
import 'package:solana_wallet/solana_wallet.dart';
import 'package:sols_stream/core/config/app_environment.dart';
import 'package:sols_stream/core/di/app_dependencies.dart';
import 'package:sols_stream/core/event_bus/app_event_bus.dart';

/// Composition root — wires all concrete infrastructure implementations.
final class AppDependenciesBuilder {
  // Wallet policy lives in the composition root (RpcEnvironment carries only
  // endpoints). The wallet package stays free of app-specific constants.
  static const String _walletStorageKey = 'sols_stream_wallet_v1';
  static const int _minLamports = 2000000; // 0.002 SOL — room + slot + writes
  static const int _airdropLamports = 40000000; // 0.04 SOL

  final AppEnvironment _environment;
  final void Function(AppDependencies dependencies) _builder;
  final void Function(Object error, StackTrace stack) _onError;

  AppDependenciesBuilder._({
    required this._environment,
    required this._builder,
    required this._onError,
  });

  static void create({
    required AppEnvironment environment,
    required void Function(AppDependencies dependencies) builder,
    required void Function(Object error, StackTrace stack) onError,
  }) {
    final instance = AppDependenciesBuilder._(
      environment: environment,
      builder: builder,
      onError: onError,
    );
    instance._build();
  }

  Future<void> _build() async {
    try {
      const secureStorage = SecureStorageImpl();
      final rpcEnvironment = _environment.rpc;
      final rpc = RpcClient(rpcEnvironment.url);
      final airdropRpc = RpcClient(rpcEnvironment.airdropUrl);
      final httpClient = Client();

      final fundingGateway = AirdropFaucetFundingGateway(
        rpcClient: airdropRpc,
        httpClient: httpClient,
        faucetUri: rpcEnvironment.faucetUri,
        minLamports: _minLamports,
        airdropLamports: _airdropLamports,
      );

      final wallet = await SolanaWalletAssembly.create(
        storage: secureStorage,
        rpc: rpc,
        fundingGateway: fundingGateway,
        storageKey: _walletStorageKey,
      );

      // `reader` is the same RPC instance the wallet uses; signaling owns its
      // reads through this port rather than borrowing the signer's transport.
      final signalingAssembly = SignalingAssembly(
        signer: wallet.signer,
        account: wallet.account,
        reader: rpc,
      );

      _builder(
        AppDependencies(
          eventBus: AppEventBus(),
          signaling: signalingAssembly.signaling,
          walletSigner: wallet.signer,
          walletAccount: wallet.account,
        ),
      );
    } catch (e, s) {
      _onError(e, s);
    }
  }
}
