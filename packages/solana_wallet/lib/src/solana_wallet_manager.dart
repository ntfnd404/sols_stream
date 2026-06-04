// ignore_for_file: prefer_initializing_formals

// TODO(SS-00XX): Migrate to secure_mnemonic for Secure Enclave-backed key storage
// once the package is production-ready. Currently uses flutter_secure_storage
// which stores AES-encrypted bytes in Keychain/Android Keystore.

import 'dart:convert' as dc;
import 'dart:developer' as dev;

import 'package:http/http.dart' as http;
import 'package:secure_storage/secure_storage.dart';
import 'package:solana/encoder.dart' show Instruction, Message;
import 'package:solana/solana.dart';

import 'package:solana_wallet/src/solana_signer.dart';

const _kStorageKey = 'sols_stream_wallet_v1';
const _kAirdropLamports = 40000000; // 0.04 SOL
const _kMinLamports = 2000000; // 0.002 SOL for room + slot + writes

/// Solana wallet identity with local key persistence and devnet funding support.
///
/// This class owns wallet concerns only: keypair lifecycle, balance lookup, and
/// funding. Protocol packages should depend on its public behavior instead of
/// managing secure storage or faucet calls themselves.
final class SolanaWalletManager implements SolanaSigner {
  final SecureStorage _storage;
  final RpcClient _rpc;
  final RpcClient _airdropRpc;
  final Uri _faucetUri;
  late final Ed25519HDKeyPair _keypair;

  Ed25519HDKeyPair get keypair => _keypair;

  @override
  String get address => _keypair.publicKey.toBase58();

  @override
  Ed25519HDPublicKey get publicKey => _keypair.publicKey;

  @override
  RpcClient get rpc => _rpc;

  SolanaWalletManager(
    this._storage, {
    required RpcClient rpc,
    required RpcClient airdropRpc,
    required Uri faucetUri,
  }) : _rpc = rpc,
       _airdropRpc = airdropRpc,
       _faucetUri = faucetUri;

  Future<void> init() async {
    final stored = await _storage.get(_kStorageKey);
    if (stored != null) {
      final bytes = dc.base64.decode(stored);
      _keypair = await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: bytes);
    } else {
      _keypair = await Ed25519HDKeyPair.random();
      final data = await _keypair.extract();
      await _storage.set(_kStorageKey, dc.base64.encode(data.bytes));
    }
  }

  @override
  Future<int> getBalance() async {
    final result = await _rpc.getBalance(address);

    return result.value;
  }

  @override
  Future<void> signAndSend(List<Instruction> instructions) async {
    await _rpc.signAndSendTransaction(
      Message(instructions: instructions),
      [_keypair],
      commitment: Commitment.confirmed,
    );
  }

  /// Returns true if the wallet has enough SOL, auto-airdrops on devnet.
  @override
  Future<bool> ensureFunded() async {
    if (await getBalance() >= _kMinLamports) return true;

    return _requestAirdrop();
  }

  Future<bool> _requestAirdrop() async {
    try {
      final sig = await _airdropRpc.requestAirdrop(address, _kAirdropLamports);
      await _pollConfirmation(_airdropRpc, sig);
      if (await getBalance() >= _kMinLamports) return true;
    } on Exception catch (e) {
      dev.log('Devnet airdrop failed: $e', name: 'SolanaWalletManager');
    }

    try {
      await http.post(
        _faucetUri,
        headers: {'Content-Type': 'application/json'},
        body: dc.jsonEncode({'address': address}),
      );
      // TODO(ntfnd): replace fixed delay with confirmation polling.
      await Future.delayed(const Duration(seconds: 5));

      return getBalance().then((balance) => balance >= _kMinLamports);
    } on Exception catch (e) {
      dev.log('Faucet fallback failed: $e', name: 'SolanaWalletManager');
      return false;
    }
  }

  Future<void> _pollConfirmation(RpcClient rpc, String sig) async {
    for (int i = 0; i < 30; i++) {
      // TODO(ntfnd): replace fixed delay with block/slot-aware backoff.
      await Future.delayed(const Duration(seconds: 1));
      final result = await rpc.getSignatureStatuses(
        [sig],
        searchTransactionHistory: false,
      );
      if (result.value.first != null) return;
    }
  }
}
