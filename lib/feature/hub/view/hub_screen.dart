import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:solana_wallet/solana_wallet.dart';
import 'package:sols_stream/core/di/app_scope.dart';
import 'package:sols_stream/core/security/safe_error_formatter.dart';

class HubScreen extends StatefulWidget {
  const HubScreen({
    super.key,
    required this.onStream,
    required this.onP2PCall,
    required this.onJoinRoom,
    required this.onAccount,
  });

  final VoidCallback? onStream;
  final VoidCallback onP2PCall;
  final VoidCallback onJoinRoom;
  final VoidCallback onAccount;

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  SolanaWalletReader? _walletReader;
  int _balanceLamports = 0;
  bool _loadingBalance = false;

  Future<void> _fetchBalance() async {
    final reader = _walletReader;
    if (reader == null || _loadingBalance) return;
    setState(() => _loadingBalance = true);
    try {
      final balance = await reader.getBalanceLamports();
      if (!mounted) return;
      setState(() => _balanceLamports = balance);
    } on SolanaWalletReadException catch (error, stackTrace) {
      log(
        formatSafeError(
          error,
          context: 'Balance fetch',
          stackTrace: stackTrace,
        ),
        name: 'HubScreen',
      );
    } finally {
      if (mounted) setState(() => _loadingBalance = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_walletReader == null) {
      _walletReader = AppScope.of(context).walletReader;
      _fetchBalance();
    }
  }

  String get _solBalance => (_balanceLamports / 1e9).toStringAsFixed(4);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('sols.stream'),
        backgroundColor: Colors.transparent,
        actions: [
          _BalanceChip(
            solBalance: _solBalance,
            loading: _loadingBalance,
            onRefresh: _fetchBalance,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Account',
            onPressed: widget.onAccount,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'What would you like to do?',
                          style: textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        _ActionCard(
                          icon: Icons.videocam_outlined,
                          title: 'Stream',
                          description: 'Go live and broadcast to viewers',
                          color: colorScheme.primaryContainer,
                          onTap: widget.onStream,
                          unavailableLabel: 'Coming soon',
                        ),
                        const SizedBox(height: 16),
                        _ActionCard(
                          icon: Icons.call_outlined,
                          title: 'P2P Call',
                          description: 'Start a private peer-to-peer video call',
                          color: colorScheme.secondaryContainer,
                          onTap: widget.onP2PCall,
                        ),
                        const SizedBox(height: 16),
                        _ActionCard(
                          icon: Icons.tv_outlined,
                          title: 'Join Room',
                          description: 'Connect to an ongoing stream',
                          color: colorScheme.tertiaryContainer,
                          onTap: widget.onJoinRoom,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({
    required this.solBalance,
    required this.loading,
    required this.onRefresh,
  });

  final String solBalance;
  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onRefresh,
    child: Chip(
      avatar: loading
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.account_balance_wallet_outlined, size: 16),
      label: Text('$solBalance SOL'),
      visualDensity: VisualDensity.compact,
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
    this.unavailableLabel,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback? onTap;
  final String? unavailableLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (unavailableLabel case final label?) ...[
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                onTap == null ? Icons.lock_clock_outlined : Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
