import 'dart:convert';

import 'package:secure_storage/secure_storage.dart';
import 'package:solana/solana.dart' show Ed25519HDKeyPair;
import 'package:solana_wallet/src/domain/wallet_storage_exception.dart';

/// Loads the persisted wallet keypair, or creates and persists a new one.
///
/// Distinguishes "no key yet" (→ create) from "key present but unreadable"
/// (→ throw [WalletStorageException]): a corrupt/unreadable keystore must NOT
/// silently replace the user's identity.
final class WalletKeyStore {
  final SecureStorage _storage;
  final String _key;

  const WalletKeyStore(this._storage, this._key);

  /// Returns the stored keypair, creating and persisting a new one only when
  /// no key has ever been stored under the configured key.
  Future<Ed25519HDKeyPair> loadOrCreate() async {
    final String? stored;
    try {
      stored = await _storage.get(_key);
    } on SecureStorageException catch (_, stack) {
      Error.throwWithStackTrace(
        const WalletStorageException('failed to read key material'),
        stack,
      );
    }

    if (stored == null) return _createAndPersist();

    try {
      return await Ed25519HDKeyPair.fromPrivateKeyBytes(
        privateKey: base64.decode(stored),
      );
    } on Object catch (_, stack) {
      // Present but undecodable — do NOT regenerate (would abandon the account).
      Error.throwWithStackTrace(
        const WalletStorageException('stored key material is corrupt'),
        stack,
      );
    }
  }

  Future<Ed25519HDKeyPair> _createAndPersist() async {
    final keypair = await Ed25519HDKeyPair.random();
    final extracted = await keypair.extract();
    try {
      await _storage.set(_key, base64.encode(extracted.bytes));
    } on SecureStorageException catch (_, stack) {
      Error.throwWithStackTrace(
        const WalletStorageException('failed to persist key material'),
        stack,
      );
    }

    return keypair;
  }
}
