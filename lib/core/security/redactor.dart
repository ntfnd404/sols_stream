// ignore_for_file: avoid_classes_with_only_static_members

abstract final class Redactor {
  static final _secretQueryKeys = <String>{
    'authorization',
    'bearer',
    'bid',
    'credential',
    'ekey',
    'passphrase',
    'password',
    'protectedkey',
    'prot',
    'secret',
    'token',
  };

  static String redactText(String value) {
    var result = value;
    result = result.replaceAllMapped(
      RegExp(r'(Authorization:\s*)(Bearer|Basic)\s+[A-Za-z0-9._~+/=-]+', caseSensitive: false),
      (match) => '${match[1]}${match[2]} [redacted]',
    );
    result = result.replaceAllMapped(
      RegExp(r'\b(Bearer|Basic)\s+[A-Za-z0-9._~+/=-]+', caseSensitive: false),
      (match) => '${match[1]} [redacted]',
    );
    result = result.replaceAllMapped(
      RegExp(r'\b(prot|passphrase|protectedKey|credential|token|secret|password|ekey)=([^&\s]+)', caseSensitive: false),
      (match) => '${match[1]}=[redacted]',
    );

    return _redactUrls(result);
  }

  static String redactUrl(String value) => _redactUri(Uri.tryParse(value)) ?? '[redacted-url]';

  static String _redactUrls(String value) => value.replaceAllMapped(
    RegExp(r'((?:sols|https?)://[^\s]+)'),
    (match) => _redactUri(Uri.tryParse(match[1]!)) ?? '[redacted-url]',
  );

  static String? _redactUri(Uri? uri) {
    if (uri == null) return null;

    final redactedQuery = <String, String>{};
    for (final entry in uri.queryParameters.entries) {
      final key = entry.key.toLowerCase();
      redactedQuery[entry.key] = _secretQueryKeys.contains(key) ? '[redacted]' : entry.value;
    }

    final safeUri = uri.replace(
      userInfo: uri.userInfo.isEmpty ? null : 'redacted',
      queryParameters: redactedQuery.isEmpty ? null : redactedQuery,
    );

    return safeUri.toString();
  }
}
