/// Parses the canonical HTTP(S) P2P invite contract.
class PeerInviteCodec {
  const PeerInviteCodec();

  /// Validates the canonical viewer-invite base before it enters application
  /// state. Host-specific parameters are added only by [buildViewerInvite].
  PeerInviteBase parseBase(Uri uri) {
    const allowedParameters = <String>{'intent', 'role'};
    final query = uri.queryParametersAll;
    if (!_hasCanonicalLocation(uri) ||
        query.keys.any((key) => !allowedParameters.contains(key)) ||
        query.values.any((values) => values.length != 1) ||
        query['intent']?.single != 'p2p' ||
        query['role']?.single != 'viewer') {
      throw const FormatException(
        'Unsupported peer invite base URL contract.',
      );
    }

    return PeerInviteBase._(uri);
  }

  /// Builds a canonical viewer invite from an already validated [base].
  Uri buildViewerInvite({
    required PeerInviteBase base,
    required String hostAddress,
    required bool isPublic,
  }) {
    if (hostAddress.isEmpty) {
      throw const FormatException('Peer invite host address is empty.');
    }
    final uri = base.uri.replace(
      queryParameters: {
        ...base.uri.queryParameters,
        'host': hostAddress,
        'public': isPublic ? '1' : '0',
      },
    );
    parse(uri);

    return uri;
  }

  /// Parses [uri], rejecting unknown, duplicate, or incomplete parameters.
  PeerInvite parse(Uri uri) {
    const allowedParameters = <String>{
      'intent',
      'role',
      'host',
      'public',
    };
    final query = uri.queryParametersAll;
    if (!_hasCanonicalLocation(uri) ||
        query.keys.any((key) => !allowedParameters.contains(key)) ||
        query.values.any((values) => values.length != 1) ||
        query['intent']?.single != 'p2p' ||
        query['role']?.single != 'viewer') {
      throw const FormatException(
        'Unsupported peer invite URL contract.',
      );
    }
    final host = query['host']?.single;
    if (host == null || host.isEmpty) {
      throw const FormatException(
        'Missing required peer invite URL parameter: host',
      );
    }
    final publicValue = query['public']?.single;
    if (publicValue != '0' && publicValue != '1') {
      throw const FormatException(
        'Missing or invalid peer invite URL parameter: public',
      );
    }

    return PeerInvite(
      hostAddress: host,
      isPublic: publicValue == '1',
    );
  }

  bool _hasCanonicalLocation(Uri uri) =>
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.hasAuthority &&
      uri.userInfo.isEmpty &&
      !uri.hasFragment &&
      uri.path == '/home';
}

/// Canonical base URI from which viewer invites may be built.
final class PeerInviteBase {
  final Uri uri;

  const PeerInviteBase._(this.uri);

  @override
  String toString() => uri.toString();
}

/// Validated parameters decoded from a canonical P2P invite.
final class PeerInvite {
  final String hostAddress;
  final bool isPublic;

  const PeerInvite({
    required this.hostAddress,
    required this.isPublic,
  });
}
