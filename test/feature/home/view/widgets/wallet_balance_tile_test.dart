import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sols_stream/core/di/app_scope.dart';
import 'package:sols_stream/feature/home/view/widgets/wallet_balance_tile.dart';

import '../../../../helpers/fake_app_dependencies.dart';

void main() {
  testWidgets('reads wallet data from AppScope and renders balance', (tester) async {
    const wallet = FakeSolanaWallet();

    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(
          dependencies: fakeAppDependencies(wallet: wallet),
          child: const Scaffold(
            body: WalletBalanceTile(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1.0000 SOL'), findsOneWidget);
    expect(find.textContaining('Wallet ·'), findsOneWidget);
  });
}
