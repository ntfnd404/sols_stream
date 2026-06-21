import 'package:signaling/src/application/signaling_chain_gateway.dart';

/// Encodes and decodes the `sols://` connection URL.
///
/// Pure application-layer serialiser — knows nothing about Solana RPC or
/// on-chain operations. Possession of a decoded [ConnectionParams.prot] grants
/// full decrypt capability for that slot; see the Security model in the README.
class ConnectionUrlCodec {
  const ConnectionUrlCodec();

  /// Builds a shareable `sols://connect?...` URL.
  String build({
    required String hostAddress,
    required int roomNonce,
    required int slotNonce,
    required String prot,
  }) =>
      Uri(
        scheme: 'sols',
        host: 'connect',
        queryParameters: {
          'host': hostAddress,
          'rn': roomNonce.toString(),
          'sn': slotNonce.toString(),
          'prot': prot,
          'mode': 'p2p',
        },
      ).toString();

  /// Parses a `sols://` URL. Throws [FormatException] if a required parameter
  /// is missing.
  ConnectionParams parse(String url) {
    final uri = Uri.parse(url);

    String required(String name) {
      final value = uri.queryParameters[name];
      if (value == null || value.isEmpty) {
        throw FormatException('Missing required connection URL parameter: $name');
      }

      return value;
    }

    return ConnectionParams(
      hostAddress: required('host'),
      roomNonce: int.parse(required('rn')),
      slotNonce: int.parse(required('sn')),
      prot: required('prot'),
    );
  }
}
