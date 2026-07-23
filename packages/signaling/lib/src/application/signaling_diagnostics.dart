/// Receives secret-free signaling lifecycle events.
///
/// Implementations must not include SDP, ICE candidates, capability URLs,
/// protected keys, passphrases, credentials, or raw exception messages.
typedef SignalingDiagnostics = void Function(String event);

void noOpSignalingDiagnostics(String _) {}
