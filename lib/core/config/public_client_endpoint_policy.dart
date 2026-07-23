import 'package:sols_stream/core/config/configuration_error.dart';

/// Security policy for endpoints compiled into the client application.
final class PublicClientEndpointPolicy {
  const PublicClientEndpointPolicy._();

  static Uri parse({
    required String key,
    required String value,
    required PublicClientEndpointKind kind,
  }) {
    final uri = Uri.tryParse(value.trim());
    final hasRootPath = uri != null && (uri.path.isEmpty || uri.path == '/');
    final isValid =
        uri != null &&
        uri.isAbsolute &&
        uri.hasAuthority &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.userInfo.isEmpty &&
        !uri.hasQuery &&
        !uri.hasFragment &&
        (kind != PublicClientEndpointKind.rpc || hasRootPath);
    if (!isValid) {
      throw ConfigurationError(
        'Invalid $key. Expected a public HTTP or HTTPS endpoint without '
        'embedded credentials, query, or fragment.',
      );
    }

    return uri;
  }
}

enum PublicClientEndpointKind { rpc, faucet }
