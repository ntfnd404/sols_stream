/// Thrown when one wallet attempts to occupy both host and viewer roles.
final class PeerSelfConnectionException implements Exception {
  const PeerSelfConnectionException();

  @override
  String toString() => 'PeerSelfConnectionException: host and viewer wallets must differ';
}
