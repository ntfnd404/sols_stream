import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';
import 'package:secure_storage/secure_storage.dart';

/// [SecureStorage] adapter backed by [FlutterSecureStorage].
///
/// Wraps platform-level exceptions in [SecureStorageException] to prevent
/// secret-leak surfaces — `PlatformException.message` may echo the storage key
/// or the secret value in plain text.
///
/// This is a placeholder custody mechanism for the current local-key signer.
/// The chosen account/identity model (see the Identity ticket) may replace it
/// entirely via a different `SolanaSigner` implementation.
final class SecureStorageImpl implements SecureStorage {
  final FlutterSecureStorage _storage;

  const SecureStorageImpl() : _storage = const FlutterSecureStorage();

  @visibleForTesting
  const SecureStorageImpl.withStorage(this._storage);

  @override
  Future<String?> get(String key) => _guard(() => _storage.read(key: key));

  @override
  Future<void> set(String key, String value) => _guard(() => _storage.write(key: key, value: value));

  @override
  Future<void> remove(String key) => _guard(() => _storage.delete(key: key));

  /// Runs [op], converting any platform failure into a [SecureStorageException]
  /// without inspecting the caught error — its message may carry the storage
  /// key or secret value in plain text.
  Future<T> _guard<T>(Future<T> Function() op) async {
    try {
      return await op();
    } on Exception catch (_, stack) {
      // SECURITY: do NOT inspect the caught exception.
      Error.throwWithStackTrace(const SecureStorageException(), stack);
    }
  }
}
