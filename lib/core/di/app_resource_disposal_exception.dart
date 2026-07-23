/// A resource-disposal error paired with the stack trace where it occurred.
typedef AppResourceDisposalFailure = ({
  Object error,
  StackTrace stackTrace,
});

/// Aggregates failures raised while releasing application resources.
///
/// The failure order matches disposal order. Error messages are deliberately
/// omitted from [toString] so diagnostics cannot accidentally expose resource
/// details or secrets.
final class AppResourceDisposalException implements Exception {
  /// Individual failures with their original stack traces.
  final List<AppResourceDisposalFailure> failures;

  /// Combined diagnostic trace containing every disposal failure.
  final StackTrace combinedStackTrace;

  /// Creates a non-empty immutable aggregate of [failures].
  ///
  /// Throws [ArgumentError] when no failures are supplied.
  factory AppResourceDisposalException(
    Iterable<AppResourceDisposalFailure> failures,
  ) {
    final values = List<AppResourceDisposalFailure>.unmodifiable(failures);
    if (values.isEmpty) {
      throw ArgumentError.value(
        failures,
        'failures',
        'must contain at least one disposal failure',
      );
    }

    final combinedStackTrace = StackTrace.fromString(
      values.indexed
          .map(
            (entry) =>
                '--- disposal failure ${entry.$1 + 1}: '
                '${entry.$2.error.runtimeType} ---\n'
                '${entry.$2.stackTrace}',
          )
          .join('\n'),
    );

    return AppResourceDisposalException._(
      values,
      combinedStackTrace,
    );
  }

  AppResourceDisposalException._(
    this.failures,
    this.combinedStackTrace,
  );

  @override
  String toString() => 'AppResourceDisposalException(${failures.length} failures)';
}
