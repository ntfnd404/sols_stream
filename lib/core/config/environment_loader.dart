import 'package:sols_stream/core/config/app_environment.dart';
import 'package:sols_stream/core/config/app_environment_kind.dart';
import 'package:sols_stream/core/config/configuration_error.dart';
import 'package:sols_stream/core/config/key_broker_environment.dart';
import 'package:sols_stream/core/config/peer_invite_environment.dart';
import 'package:sols_stream/core/config/rpc_environment.dart';
import 'package:sols_stream/core/config/wallet_environment.dart';

/// Loads [AppEnvironment] from compile-time dart-define values.
///
/// Run Flutter with `--dart-define-from-file=config/<env>.env`.
///
/// When web release needs runtime injection (e.g. window.parameters), split
/// this into environment_loader_native.dart + environment_loader_web.dart
/// and add:
///   export 'environment_loader_native.dart'
///       if (dart.library.js_interop) 'environment_loader_web.dart';
const String _environmentRaw = String.fromEnvironment('APP_ENVIRONMENT');

AppEnvironment loadEnvironment() => AppEnvironment(
  kind: switch (_environmentRaw.trim()) {
    'local' => AppEnvironmentKind.local,
    'dev' => AppEnvironmentKind.dev,
    'prod' => AppEnvironmentKind.prod,
    _ => throw const ConfigurationError(
      'Invalid or missing APP_ENVIRONMENT. Expected local, dev, or prod.',
    ),
  },
  rpc: RpcEnvironment.fromDartDefines(),
  wallet: WalletEnvironment.fromDartDefines(),
  peerInvite: PeerInviteEnvironment.fromDartDefines(),
  keyBroker: KeyBrokerEnvironment.fromDartDefines(),
);
