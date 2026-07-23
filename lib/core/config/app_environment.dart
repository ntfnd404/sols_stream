import 'package:meta/meta.dart';
import 'package:signaling/key_broker_assembly.dart';
import 'package:solana_wallet/solana_wallet_assembly.dart';
import 'package:sols_stream/core/config/app_environment_kind.dart';
import 'package:sols_stream/core/config/configuration_error.dart';
import 'package:sols_stream/core/config/key_broker_environment.dart';
import 'package:sols_stream/core/config/peer_invite_environment.dart';
import 'package:sols_stream/core/config/rpc_environment.dart';
import 'package:sols_stream/core/config/wallet_environment.dart';

@immutable
final class AppEnvironment {
  final AppEnvironmentKind kind;
  final RpcEnvironment rpc;
  final WalletEnvironment wallet;
  final PeerInviteEnvironment peerInvite;
  final KeyBrokerEnvironment keyBroker;

  AppEnvironment({
    required this.kind,
    required this.rpc,
    required this.wallet,
    required this.peerInvite,
    required this.keyBroker,
  }) {
    _validate();
  }

  void _validate() {
    final isLocalBroker = keyBroker.config is LocalKeyBrokerConfig;
    switch (kind) {
      case AppEnvironmentKind.local:
        if (!isLocalBroker || !_isLoopback(rpc.url) || !_isLoopback(peerInvite.url)) {
          throw const ConfigurationError(
            'Local environment requires a local key broker and loopback RPC '
            'and Web client endpoints.',
          );
        }
      case AppEnvironmentKind.dev:
        if (isLocalBroker) {
          throw const ConfigurationError(
            'Dev environment requires a remote HTTPS key broker.',
          );
        }
      case AppEnvironmentKind.prod:
        if (isLocalBroker ||
            rpc.url.scheme != 'https' ||
            peerInvite.url.scheme != 'https' ||
            wallet.funding is! BalanceOnlyFundingConfig) {
          throw const ConfigurationError(
            'Production requires HTTPS endpoints, remote key broker, '
            'and balance-only funding.',
          );
        }
    }
  }

  static bool _isLoopback(Uri uri) => uri.host == 'localhost' || uri.host == '127.0.0.1' || uri.host == '::1';
}
