import 'package:flutter/foundation.dart';
import 'package:sols_stream/core/config/configuration_error.dart';

@immutable
final class RpcEnvironment {
  final String url;
  final String airdropUrl;
  final String faucetUrl;

  static const String _urlKey = 'SOLANA_RPC_URL';
  static const String _airdropUrlKey = 'SOLANA_AIRDROP_RPC_URL';
  static const String _faucetUrlKey = 'SOLANA_FAUCET_URL';

  // Compile-time dart-define values. All String.fromEnvironment calls live
  // here so they are evaluated at compile time.
  static const String _urlRaw = String.fromEnvironment(_urlKey);
  static const String _airdropUrlRaw = String.fromEnvironment(_airdropUrlKey);
  static const String _faucetUrlRaw = String.fromEnvironment(_faucetUrlKey);

  Uri get faucetUri => Uri.parse(faucetUrl);

  const RpcEnvironment({
    required this.url,
    required this.airdropUrl,
    required this.faucetUrl,
  });

  static RpcEnvironment fromDartDefines() {
    final url = _requiredUrl(_urlKey, _urlRaw);
    final airdropUrl = _requiredUrl(_airdropUrlKey, _airdropUrlRaw);
    final faucetUrl = _requiredUrl(_faucetUrlKey, _faucetUrlRaw);

    return RpcEnvironment(
      url: _validatedUrl(_urlKey, url),
      airdropUrl: _validatedUrl(_airdropUrlKey, airdropUrl),
      faucetUrl: _validatedUrl(_faucetUrlKey, faucetUrl),
    );
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

  static String _validatedUrl(String key, String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority || (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw ConfigurationError(
        'Invalid $key: "$value". '
        'Expected an absolute http or https URL. '
        'Run Flutter with --dart-define-from-file=config/<env>.env.',
      );
    }

    return value;
  }
}
