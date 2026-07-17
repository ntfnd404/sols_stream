/// Result of comparing the deployed IDL with its versioned artifact.
enum IdlSyncResult {
  /// Canonical JSON content is already identical.
  unchanged,

  /// Update mode wrote the deployed IDL to disk.
  written,

  /// Check-only mode detected drift and left the file unchanged.
  outOfDate,
}
