/// Formats an untrusted failure without rendering its potentially sensitive
/// message or provider payload.
///
/// [context] must be an allowlisted constant or a type name. Do not pass
/// provider, user-controlled, or payload-derived text.
String formatSafeError(
  Object error, {
  String? context,
  StackTrace? stackTrace,
}) {
  final prefix = context == null ? '' : '$context: ';
  final description = '$prefix${error.runtimeType}';

  return stackTrace == null ? description : '$description\n$stackTrace';
}
