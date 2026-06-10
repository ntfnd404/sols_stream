import 'package:secure_storage/secure_storage.dart';

/// In-memory [SecureStorage] for tests, with optional read/write failure
/// injection to exercise error paths.
final class FakeSecureStorage implements SecureStorage {
  final Map<String, String> store;
  final bool throwOnGet;
  final bool throwOnSet;

  FakeSecureStorage({
    Map<String, String>? initial,
    this.throwOnGet = false,
    this.throwOnSet = false,
  }) : store = initial ?? {};

  @override
  Future<String?> get(String key) async {
    if (throwOnGet) throw const SecureStorageException();

    return store[key];
  }

  @override
  Future<void> set(String key, String value) async {
    if (throwOnSet) throw const SecureStorageException();
    store[key] = value;
  }

  @override
  Future<void> remove(String key) async => store.remove(key);
}
