import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solana_wallet/solana_wallet.dart';

class WalletTile extends StatefulWidget {
  const WalletTile({
    super.key,
    required this.walletAccount,
    required this.walletBalance,
    required this.onRefresh,
  });

  final WalletAccount? walletAccount;
  final int walletBalance;
  final VoidCallback onRefresh;

  @override
  State<WalletTile> createState() => _WalletTileState();
}

class _WalletTileState extends State<WalletTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final account = widget.walletAccount;
    if (account == null) return const SizedBox.shrink();

    final address = account.address;
    final shortAddr = address.length > 12
        ? '${address.substring(0, 6)}…${address.substring(address.length - 4)}'
        : address;
    final solBalance = widget.walletBalance / 1e9;

    return Material(
      color: const Color(0xff1a1d20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xff2a3036)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet, size: 18),
            const SizedBox(width: 8),
            Text('Wallet · $shortAddr'),
            const Spacer(),
            Text('${solBalance.toStringAsFixed(4)} SOL'),
          ],
        ),
        initiallyExpanded: _expanded,
        onExpansionChanged: (v) {
          setState(() => _expanded = v);
          if (v) widget.onRefresh();
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SelectableText(
                  address,
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy address'),
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: address)),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh'),
                      onPressed: widget.onRefresh,
                    ),
                  ],
                ),
                const Text(
                  'Network: Solana devnet\nMin balance: 0.002 SOL',
                  style: TextStyle(fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
