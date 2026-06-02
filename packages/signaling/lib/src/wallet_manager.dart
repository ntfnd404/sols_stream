// TODO(SS-00XX): Migrate to secure_mnemonic for Secure Enclave-backed key storage
// once the package is production-ready. Currently uses flutter_secure_storage
// which stores AES-encrypted bytes in Keychain/Android Keystore.

import 'dart:convert' as dc;

import 'package:http/http.dart' as http;
import 'package:solana/solana.dart';

abstract interface class KeyStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

const _kStorageKey     = 'sols_stream_wallet_v1';
const _kProgramRpc     = 'https://winonah-va4s3h-fast-devnet.helius-rpc.com';
const _kPublicDevnet   = 'https://api.devnet.solana.com';
const _kFaucetUrl      = 'https://turn.sols.stream/faucet';
const _kAirdropLamports = 40000000;  // 0.04 SOL
const _kMinLamports     = 2000000;   // 0.002 SOL for room + slot + writes

class WalletManager {
  final KeyStorage _storage;
  Ed25519HDKeyPair? _keypair;
  late final RpcClient _rpc;

  WalletManager(this._storage) {
    _rpc = RpcClient(_kProgramRpc);
  }

  Ed25519HDKeyPair get keypair => _keypair!;
  String get address => _keypair!.publicKey.toBase58();
  RpcClient get rpc => _rpc;

  Future<void> init() async {
    final stored = await _storage.read(_kStorageKey);
    if (stored != null) {
      final bytes = dc.base64.decode(stored);
      _keypair = await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: bytes);
    } else {
      _keypair = await Ed25519HDKeyPair.random();
      final data = await _keypair!.extract();
      await _storage.write(_kStorageKey, dc.base64.encode(data.bytes));
    }
  }

  Future<int> getBalance() async {
    final result = await _rpc.getBalance(address);
    return result.value;
  }

  /// Returns true if the wallet has enough SOL, auto-airdrops on devnet.
  Future<bool> ensureFunded() async {
    if (await getBalance() >= _kMinLamports) return true;
    return _requestAirdrop();
  }

  Future<bool> _requestAirdrop() async {
    // Primary: Solana public devnet faucet
    try {
      final pubRpc = RpcClient(_kPublicDevnet);
      final sig = await pubRpc.requestAirdrop(address, _kAirdropLamports);
      await _pollConfirmation(pubRpc, sig);
      if (await getBalance() >= _kMinLamports) return true;
    } catch (_) {}

    // Fallback: sols.stream faucet
    try {
      await http.post(
        Uri.parse(_kFaucetUrl),
        headers: {'Content-Type': 'application/json'},
        body: dc.jsonEncode({'address': address}),
      );
      await Future.delayed(const Duration(seconds: 5));
      return await getBalance() >= _kMinLamports;
    } catch (_) {
      return false;
    }
  }

  Future<void> _pollConfirmation(RpcClient rpc, String sig) async {
    for (var i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 1));
      final result = await rpc.getSignatureStatuses(
        [sig],
        searchTransactionHistory: false,
      );
      if (result.value.first != null) return;
    }
  }
}
