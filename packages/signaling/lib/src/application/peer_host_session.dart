/// Host-side handle for an active on-chain signaling slot.
final class PeerHostSession {
  final String connectionUrl;
  final String slotPda;

  /// Ends the host's on-chain room and closes the slot on session teardown.
  /// Always call this when the host stops the P2P session.
  final Future<String> Function() _awaitAnswerSdp;
  final Future<void> Function() _confirm;
  final void Function() _cancelWaiting;
  final Future<void> Function() _teardown;
  Future<String>? _answerFuture;
  Future<void>? _confirmationFuture;
  Future<void>? _teardownFuture;

  factory PeerHostSession({
    required String connectionUrl,
    required String slotPda,
    required Future<String> Function() awaitAnswerSdp,
    required Future<void> Function() confirm,
    required void Function() cancelWaiting,
    required Future<void> Function() teardown,
  }) => PeerHostSession._(
    connectionUrl,
    slotPda,
    awaitAnswerSdp,
    confirm,
    cancelWaiting,
    teardown,
  );

  PeerHostSession._(
    this.connectionUrl,
    this.slotPda,
    this._awaitAnswerSdp,
    this._confirm,
    this._cancelWaiting,
    this._teardown,
  );

  /// Polls the slot at most once until the viewer writes an answer, decrypts
  /// it, and returns the compact answer JSON `{type, sdp, ts}`. Concurrent
  /// callers share the same result.
  Future<String> awaitAnswerSdp() => _answerFuture ??= _awaitAnswerSdp();

  /// Confirms the host side of the on-chain connection at most once.
  Future<void> confirm() => _confirmationFuture ??= _confirm();

  /// Stops [awaitAnswerSdp]'s poll loop before its next chain read. Call this
  /// on disconnect so a host who cancels mid-wait doesn't leave an unbounded
  /// background RPC poll running.
  void cancelWaiting() => _cancelWaiting();

  /// Runs host reclaim at most once. Concurrent lifecycle paths share the same
  /// future instead of submitting duplicate close transactions.
  Future<void> teardown() => _teardownFuture ??= _teardown();

  @override
  String toString() =>
      'PeerHostSession(connectionUrl: ${_redactInvite(connectionUrl)}, '
      'slotPda: $slotPda)';
}

String _redactInvite(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null) return '[redacted-url]';

  final query = <String, String>{};
  for (final entry in uri.queryParameters.entries) {
    query[entry.key] = switch (entry.key) {
      'prot' || 'bid' || 'ekey' => '[redacted]',
      _ => entry.value,
    };
  }

  return uri.replace(queryParameters: query.isEmpty ? null : query).toString();
}
