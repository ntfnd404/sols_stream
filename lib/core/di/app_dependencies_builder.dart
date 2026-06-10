import 'package:http/http.dart' as http;
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

      // final keys = KeysAssembly(
      //   storage: secureStorage,
      //   network: _environment.network,
      // );

      // final wallet = WalletAssembly(
      //   storage: secureStorage,
      //   remoteDataSource: NodeWalletGatewayImpl(rpcClient: rpcClient),
      //   addressRemoteDataSource: NodeAddressGatewayImpl(rpcClient: rpcClient),
      //   bip39Service: keys.bip39Service,
      //   seedRepository: keys.seedRepository,
      //   keyDerivationService: keys.keyDerivationService,
      // );

      // final nodeTxDataSource = NodeTransactionGatewayImpl(rpcClient: rpcClient);
      // final blockGenDataSource = BlockGenerationGatewayImpl(rpcClient: rpcClient);
      // final broadcastDataSource = BroadcastGatewayImpl(rpcClient: rpcClient);
      // final hdSigner = HdTransactionSigner(signTransaction: keys.signTransaction.call);

      // final transaction = TransactionAssembly(
      //   transactionRemoteDataSource: TransactionHistoryGatewayImpl(rpcClient: rpcClient),
      //   utxoRemoteDataSource: UtxoGatewayImpl(rpcClient: rpcClient),
      //   utxoScanDataSource: UtxoScanGatewayImpl(rpcClient: rpcClient),
      //   broadcastDataSource: broadcastDataSource,
      //   nodeTransactionDataSource: nodeTxDataSource,
      //   blockGenerationDataSource: blockGenDataSource,
      //   addressRepository: wallet.addressRepository,
      //   coinSelectors: [
      //     const BranchAndBoundCoinSelector(),
      //     KnapsackCoinSelector(),
      //     const SmallestSingleCoinSelector(),
      //     const FifoCoinSelector(),
      //     const LifoCoinSelector(),
      //     const MinimizeInputsCoinSelector(),
      //     const MinimizeChangeCoinSelector(),
      //     SingleRandomDrawCoinSelector(),
      //   ],
      //   feeEstimator: const P2wpkhFeeEstimator(),
      //   hdSigner: hdSigner,
      //   bech32Hrp: _environment.network.bech32Hrp,
      // );

      final rpc = RpcClient(_environment.rpc.url);
      final airdropRpc = RpcClient(_environment.rpc.airdropUrl);

      final funder = DevnetWalletFunder(
        airdropRpc: airdropRpc,
        http: http.Client(),
        faucetUri: _environment.rpc.faucetUri,
        minLamports: _minLamports,
        airdropLamports: _airdropLamports,
      );

      final wallet = await SolanaWalletAssembly.create(
        storage: secureStorage,
        rpc: rpc,
        funder: funder,
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
