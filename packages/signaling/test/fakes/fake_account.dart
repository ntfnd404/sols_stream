import 'package:solana/solana.dart';
import 'package:solana_wallet/solana_wallet.dart';

class FakeAccount implements WalletAccount {
  final Ed25519HDPublicKey _publicKey;

  @override
  Ed25519HDPublicKey get publicKey => _publicKey;

  @override
  String get address => 'FakeAddr';

  FakeAccount({required this._publicKey});

  @override
  Future<int> getBalance() async => 0;

  @override
  Future<bool> ensureFunded() async => true;
}
