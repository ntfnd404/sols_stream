import 'package:flutter/foundation.dart';

/// Formats an untrusted failure without rendering its message or provider data.
final class SafeErrorFormatter {
  final SafeDiagnosticDetail detail;

  const SafeErrorFormatter({required this.detail});

  factory SafeErrorFormatter.forCurrentBuild() => const SafeErrorFormatter(
    detail: kReleaseMode ? SafeDiagnosticDetail.release : SafeDiagnosticDetail.development,
  );

  String format(
    Object error, {
    required SafeDiagnosticContext context,
    Type? componentType,
    StackTrace? stackTrace,
  }) {
    final description = '${context.code} ${context.label}';
    if (detail == SafeDiagnosticDetail.release) return description;

    final component = componentType == null ? '' : ' component=$componentType';
    final typedDescription = '$description$component: ${error.runtimeType}';

    return stackTrace == null ? typedDescription : '$typedDescription\n$stackTrace';
  }
}

enum SafeDiagnosticContext {
  rootZone('APP-ROOT-001', 'Root zone'),
  blocObserver('APP-BLOC-001', 'BLoC'),
  walletBalance('WALLET-READ-001', 'Wallet balance');

  const SafeDiagnosticContext(this.code, this.label);

  final String code;
  final String label;
}

enum SafeDiagnosticDetail { development, release }

final safeErrorFormatter = SafeErrorFormatter.forCurrentBuild();
