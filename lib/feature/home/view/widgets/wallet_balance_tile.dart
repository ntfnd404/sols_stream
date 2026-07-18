import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:solana_wallet/solana_wallet.dart';
import 'package:sols_stream/core/di/app_scope.dart';
import 'package:sols_stream/core/security/safe_error_formatter.dart';
import 'package:sols_stream/feature/home/view/widgets/wallet_tile.dart';

class WalletBalanceTile extends StatefulWidget {
  const WalletBalanceTile({super.key});

  @override
  State<WalletBalanceTile> createState() => _WalletBalanceTileState();
}

class _WalletBalanceTileState extends State<WalletBalanceTile> {
  final _balance = ValueNotifier<int>(0);

  SolanaWalletReader? _walletReader;
  bool _initialized = false;

  Future<void> _refreshBalance() async {
    final reader = _walletReader;
    if (reader == null) return;

    try {
      final balance = await reader.getBalanceLamports();
      if (!mounted) return;

      _balance.value = balance;
    } on SolanaWalletReadException catch (error, stackTrace) {
      log(
        safeErrorFormatter.format(
          error,
          context: SafeDiagnosticContext.walletBalance,
          stackTrace: stackTrace,
        ),
        name: 'WalletBalanceTile',
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    _walletReader = AppScope.of(context).walletReader;
    _refreshBalance();
  }

  @override
  void dispose() {
    _balance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: _balance,
    builder: (context, balance, _) => WalletTile(
      walletAddress: _walletReader?.address,
      walletBalance: balance,
      onRefresh: _refreshBalance,
    ),
  );
}
