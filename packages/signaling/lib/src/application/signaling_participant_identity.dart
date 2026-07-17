import 'dart:typed_data';

/// Participant identity required by the signaling protocol.
///
/// Provider adapters must derive both representations from the same public
/// key. The byte representation is copied so callers cannot mutate ownership
/// checks after construction.
final class SignalingParticipantIdentity {
  final String address;
  final Uint8List _publicKeyBytes;

  SignalingParticipantIdentity.fromPublicKey({
    required List<int> publicKeyBytes,
    required String Function(List<int> publicKeyBytes) addressEncoder,
  }) : _publicKeyBytes = Uint8List.fromList(publicKeyBytes),
       address = addressEncoder(List<int>.unmodifiable(publicKeyBytes)) {
    if (address.isEmpty) {
      throw ArgumentError.value(address, 'address', 'must not be empty');
    }
    if (publicKeyBytes.isEmpty) {
      throw ArgumentError.value(
        publicKeyBytes,
        'publicKeyBytes',
        'must not be empty',
      );
    }
  }

  Uint8List get publicKeyBytes => Uint8List.fromList(_publicKeyBytes);
}
