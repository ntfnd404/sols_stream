import 'dart:async';

import 'package:http/http.dart' show ClientException;
import 'package:signaling/signaling.dart';
import 'package:signaling_solana/src/data/solana_program/solana_rpc_read_error_classifier.dart';
import 'package:solana/solana.dart';
import 'package:test/test.dart';

void main() {
  test('maps timeouts and connection failures to the transient marker', () async {
    for (final failure in <Exception>[
      TimeoutException('timeout'),
      ClientException('connection failed'),
    ]) {
      await expectLater(
        classifySolanaRpcRead<void>(() async => throw failure),
        throwsA(isA<TransientSignalingReadException>()),
      );
    }
  });

  test('maps only whitelisted JSON-RPC availability failures', () async {
    await expectLater(
      classifySolanaRpcRead<void>(
        () async => throw const JsonRpcException(
          'node unavailable',
          JsonRpcErrorCode.nodeUnhealthy,
          null,
        ),
      ),
      throwsA(isA<TransientSignalingReadException>()),
    );

    const scanFailure = JsonRpcException(
      'scan rejected',
      JsonRpcErrorCode.scanError,
      null,
    );
    await expectLater(
      classifySolanaRpcRead<void>(() async => throw scanFailure),
      throwsA(isA<SignalingReadFailureException>()),
    );
  });

  test('does not retry HTTP, malformed, or unknown provider failures', () async {
    const failures = <Exception>[
      HttpException(503, 'provider response'),
      FormatException('malformed JSON-RPC response'),
      JsonRpcException('unknown provider failure', -32000, null),
    ];

    for (final failure in failures) {
      await expectLater(
        classifySolanaRpcRead<void>(() async => throw failure),
        throwsA(
          isA<SignalingReadFailureException>().having(
            (error) => error.toString(),
            'safe representation',
            'SignalingReadFailureException',
          ),
        ),
      );
    }
  });

  test('preserves the provider stack trace without retaining its message', () async {
    const secret = 'https://rpc.example/?token=secret response-body';
    late StackTrace providerStack;

    try {
      await classifySolanaRpcRead<void>(() {
        providerStack = StackTrace.current;
        Error.throwWithStackTrace(Exception(secret), providerStack);
      });
      fail('Expected a terminal read failure');
    } on SignalingReadFailureException catch (error, stackTrace) {
      expect(error.toString(), isNot(contains(secret)));
      expect(stackTrace.toString(), providerStack.toString());
    }
  });

  test('does not mask programming errors', () async {
    final failure = StateError('programming defect');

    await expectLater(
      classifySolanaRpcRead<void>(() async => throw failure),
      throwsA(same(failure)),
    );
  });
}
