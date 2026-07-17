import 'package:solana_wallet/src/domain/solana_wallet_read_exception.dart';

/// Read-only Solana wallet capabilities intended for UI and diagnostics.
abstract interface class SolanaWalletReader {
  String get address;

  /// Returns the confirmed native balance in lamports.
  ///
  /// Throws [SolanaWalletReadException] when the provider read fails. The
  /// exception is sanitized and does not retain provider response details.
  Future<int> getBalanceLamports();
}
