import 'package:solana_wallet/src/data/wallet_key_store.dart';
import 'package:solana_wallet/src/domain/wallet_storage_exception.dart';
import 'package:test/test.dart';

import 'fakes/fake_secure_storage.dart';

const _key = 'wallet_v1';

void main() {
  group('WalletKeyStore.loadOrCreate', () {
    test('creates and persists a keypair when none is stored, stable on reload', () async {
      final storage = FakeSecureStorage();

      final keypair = await WalletKeyStore(storage, _key).loadOrCreate();

      expect(storage.store[_key], isNotNull, reason: 'new key must be persisted');

      // A second load returns the SAME identity, never a fresh one.
      final reloaded = await WalletKeyStore(storage, _key).loadOrCreate();
      expect(reloaded.publicKey.toBase58(), keypair.publicKey.toBase58());
    });

    test('throws (does not regenerate) when stored material is corrupt', () async {
      final storage = FakeSecureStorage(initial: {_key: 'not-valid-base64-%%%'});

      await expectLater(
        WalletKeyStore(storage, _key).loadOrCreate(),
        throwsA(isA<WalletStorageException>()),
      );
    });

    test('throws WalletStorageException on read failure', () async {
      final storage = FakeSecureStorage(throwOnGet: true);

      await expectLater(
        WalletKeyStore(storage, _key).loadOrCreate(),
        throwsA(isA<WalletStorageException>()),
      );
    });

    test('throws WalletStorageException on write failure', () async {
      final storage = FakeSecureStorage(throwOnSet: true);

      await expectLater(
        WalletKeyStore(storage, _key).loadOrCreate(),
        throwsA(isA<WalletStorageException>()),
      );
    });
  });
}
