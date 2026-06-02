import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:signaling/signaling.dart';

/// Global DI container. Access via [AppScope.of(context)].
class AppScope extends InheritedWidget {
  final SolanaSignaling signaling;
  final AppDependencies deps;

  const AppScope({
    super.key,
    required this.signaling,
    required this.deps,
    required super.child,
  });

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope old) => false;
}

/// Holds app-level dependencies. Built once at startup.
class AppDependencies {
  final WalletManager walletManager;
  final SolanaSignaling signaling;

  const AppDependencies({
    required this.walletManager,
    required this.signaling,
  });

  static Future<AppDependencies> build() async {
    const storage = FlutterSecureStorage();
    final keyStorage = _SecureKeyStorage(storage);
    final walletManager = WalletManager(keyStorage);
    await walletManager.init();
    final signaling = SolanaSignaling(walletManager);
    await signaling.init();
    return AppDependencies(walletManager: walletManager, signaling: signaling);
  }
}

class _SecureKeyStorage implements KeyStorage {
  final FlutterSecureStorage _storage;
  const _SecureKeyStorage(this._storage);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}
