import 'package:meta/meta.dart';
import 'package:sols_stream/core/config/configuration_error.dart';
import 'package:sols_stream/core/security/redactor.dart';

@immutable
final class RpcEnvironment {
  final Uri url;

  static const String _urlKey = 'SOLANA_RPC_URL';

  // Compile-time dart-define values. All String.fromEnvironment calls live
  // here so they are evaluated at compile time.
  static const String _urlRaw = String.fromEnvironment(_urlKey);

  const RpcEnvironment({
    required this.url,
  });

  static RpcEnvironment fromDartDefines() {
    final url = _requiredUrl(_urlKey, _urlRaw);

    return RpcEnvironment(url: _validatedUrl(_urlKey, url));
  }

  static String _requiredUrl(String key, String raw) {
    final value = _normalize(raw);
    if (value == null) {
      throw ConfigurationError(
        'Missing required RPC configuration key: $key. '
        'Run Flutter with --dart-define-from-file=config/<env>.env.',
      );
    }

    return value;
  }

  static String? _normalize(String? v) {
    final t = v?.trim();
    if (t == null || t.isEmpty) return null;

    return t;
  }

  static Uri _validatedUrl(String key, String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority || (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw ConfigurationError(
        'Invalid $key: "${Redactor.redactUrl(value)}". '
        'Expected an absolute http or https URL. '
        'Run Flutter with --dart-define-from-file=config/<env>.env.',
      );
    }

    return uri;
  }
}
