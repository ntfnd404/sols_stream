import 'package:flutter/foundation.dart';
import 'package:signaling/signaling.dart';
import 'package:solana_wallet/solana_wallet.dart';
import 'package:sols_stream/core/event_bus/app_event_bus.dart';

/// Immutable container for application-level module assemblies.
@immutable
final class AppDependencies {
  final AppEventBus eventBus;
  final SolanaSignaling signaling;
  final SolanaSigner walletSigner;
  final WalletAccount walletAccount;

  const AppDependencies({
    required this.eventBus,
    required this.signaling,
    required this.walletSigner,
    required this.walletAccount,
  });
}
