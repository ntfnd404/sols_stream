/// Encrypted key-value storage contract.
///
/// All operations are asynchronous. Keys are plain strings; implementations
/// handle encryption transparently.
abstract interface class SecureStorage {
  /// Returns the string value for [key], or `null` if not present.
  Future<String?> get(String key);

  /// Stores a string [value] under [key].
  Future<void> set(String key, String value);

  /// Removes the entry for [key]. No-op if absent.
  Future<void> remove(String key);
}
