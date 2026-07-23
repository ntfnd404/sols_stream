import 'package:streaming/src/hls_auth_config.dart';

final class HlsSource {
  final Uri uri;
  final HlsAuthConfig auth;

  const HlsSource({
    required this.uri,
    this.auth = const HlsAuthConfig(),
  });

  @override
  String toString() => 'HlsSource(uri: ${uri.replace(query: uri.hasQuery ? '[redacted]' : null)}, auth: $auth)';
}
