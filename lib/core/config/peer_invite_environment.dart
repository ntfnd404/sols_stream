import 'package:meta/meta.dart';
import 'package:signaling/signaling.dart';
import 'package:sols_stream/core/config/configuration_error.dart';
import 'package:sols_stream/core/security/redactor.dart';

@immutable
final class PeerInviteEnvironment {
  final PeerInviteBase base;

  Uri get url => base.uri;

  static const String _urlKey = 'PEER_INVITE_BASE_URL';
  static const String _urlRaw = String.fromEnvironment(_urlKey);

  factory PeerInviteEnvironment({required Uri url}) {
    try {
      return PeerInviteEnvironment._(
        const PeerInviteCodec().parseBase(url),
      );
    } on FormatException {
      throw const ConfigurationError(
        'Invalid PEER_INVITE_BASE_URL contract.',
      );
    }
  }

  const PeerInviteEnvironment._(this.base);

  static PeerInviteEnvironment fromDartDefines() {
    final value = _urlRaw.trim();
    if (value.isEmpty) {
      throw const ConfigurationError(
        'Missing required peer invite configuration key: '
        'PEER_INVITE_BASE_URL. '
        'Run Flutter with --dart-define-from-file=config/<env>.env.',
      );
    }

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority || (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw ConfigurationError(
        'Invalid $_urlKey: "${Redactor.redactUrl(value)}". '
        'Expected an absolute http or https URL.',
      );
    }

    return PeerInviteEnvironment(url: uri);
  }
}
