import 'package:meta/meta.dart';
import 'package:signaling/key_broker_assembly.dart';
import 'package:sols_stream/core/config/configuration_error.dart';
import 'package:sols_stream/core/security/redactor.dart';

@immutable
final class KeyBrokerEnvironment {
  final KeyBrokerConfig config;

  static const String _modeKey = 'KEY_BROKER_MODE';
  static const String _urlKey = 'KEY_BROKER_URL';
  static const String _modeRaw = String.fromEnvironment(_modeKey);
  static const String _urlRaw = String.fromEnvironment(_urlKey);

  const KeyBrokerEnvironment({required this.config});

  static KeyBrokerEnvironment fromDartDefines() => fromValues(
    mode: _modeRaw,
    url: _urlRaw,
  );

  @visibleForTesting
  static KeyBrokerEnvironment fromValues({
    required String mode,
    String? url,
  }) {
    final normalizedMode = mode.trim();
    final normalizedUrl = url?.trim();
    switch (normalizedMode) {
      case 'local':
        if (normalizedUrl != null && normalizedUrl.isNotEmpty) {
          throw const ConfigurationError(
            '$_urlKey must not be configured for local key broker mode.',
          );
        }

        return const KeyBrokerEnvironment(
          config: LocalKeyBrokerConfig(),
        );
      case 'http':
        if (normalizedUrl == null || normalizedUrl.isEmpty) {
          throw const ConfigurationError(
            '$_modeKey=http requires $_urlKey.',
          );
        }
        final uri = Uri.tryParse(normalizedUrl);
        final hasRootPath = uri != null && (uri.path.isEmpty || uri.path == '/');
        if (uri == null ||
            uri.scheme != 'https' ||
            !uri.hasAuthority ||
            uri.userInfo.isNotEmpty ||
            uri.hasQuery ||
            uri.hasFragment ||
            !hasRootPath) {
          throw ConfigurationError(
            'Invalid $_urlKey: "${Redactor.redactUrl(normalizedUrl)}". '
            'Expected an HTTPS origin without credentials, path, query, or '
            'fragment.',
          );
        }

        return KeyBrokerEnvironment(
          config: HttpKeyBrokerConfig(endpoint: uri),
        );
      default:
        throw const ConfigurationError(
          'Invalid or missing $_modeKey. Expected local or http.',
        );
    }
  }
}
