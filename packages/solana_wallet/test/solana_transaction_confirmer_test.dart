import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart' show TransactionError;
import 'package:solana_wallet/solana_signer.dart';
import 'package:solana_wallet/src/data/solana_transaction_confirmer.dart';
import 'package:test/test.dart';

import 'mocks/mock_rpc_client.dart';

SignatureStatusesResult _statuses(SignatureStatus? status) => SignatureStatusesResult(
  context: Context(slot: BigInt.zero),
  value: [status],
);

SignatureStatus _status(
  Commitment confirmationStatus, {
  Map<String, dynamic>? error,
}) => SignatureStatus(
  slot: 1,
  confirmationStatus: confirmationStatus,
  err: error,
);

void main() {
  late MockRpcClient rpc;

  setUp(() {
    rpc = MockRpcClient();
  });

  test('waits through processed status until confirmed', () async {
    var requestCount = 0;
    when(
      () => rpc.getSignatureStatuses(
        ['signature'],
        searchTransactionHistory: false,
      ),
    ).thenAnswer(
      (_) async => _statuses(
        requestCount++ == 0 ? _status(Commitment.processed) : _status(Commitment.confirmed),
      ),
    );
    when(
      () => rpc.getBlockHeight(commitment: Commitment.confirmed),
    ).thenAnswer((_) async => 5);

    await SolanaTransactionConfirmer(
      rpc,
      pollInterval: Duration.zero,
    ).confirm(signature: 'signature', lastValidBlockHeight: 10);

    verify(
      () => rpc.getSignatureStatuses(
        ['signature'],
        searchTransactionHistory: false,
      ),
    ).called(2);
  });

  test('accepts finalized transaction status', () async {
    when(
      () => rpc.getSignatureStatuses(
        ['signature'],
        searchTransactionHistory: false,
      ),
    ).thenAnswer((_) async => _statuses(_status(Commitment.finalized)));

    await SolanaTransactionConfirmer(rpc).confirm(
      signature: 'signature',
      lastValidBlockHeight: 10,
    );
  });

  test('continues polling after a transport failure', () async {
    var requestCount = 0;
    when(
      () => rpc.getSignatureStatuses(
        ['signature'],
        searchTransactionHistory: false,
      ),
    ).thenAnswer((_) async {
      if (requestCount++ == 0) throw TimeoutException('rpc');

      return _statuses(_status(Commitment.confirmed));
    });
    when(
      () => rpc.getBlockHeight(commitment: Commitment.confirmed),
    ).thenAnswer((_) async => 5);

    await SolanaTransactionConfirmer(
      rpc,
      pollInterval: Duration.zero,
    ).confirm(signature: 'signature', lastValidBlockHeight: 10);
  });

  test('throws structured failed-on-chain details', () async {
    when(
      () => rpc.getSignatureStatuses(
        ['signature'],
        searchTransactionHistory: false,
      ),
    ).thenAnswer(
      (_) async => _statuses(
        _status(
          Commitment.confirmed,
          error: {
            'InstructionError': <Object>[
              2,
              {'Custom': 6023},
            ],
          },
        ),
      ),
    );

    await expectLater(
      SolanaTransactionConfirmer(
        rpc,
        logsTimeout: Duration.zero,
      ).confirm(signature: 'signature', lastValidBlockHeight: 10),
      throwsA(
        isA<SolanaTransactionException>()
            .having(
              (error) => error.kind,
              'kind',
              SolanaTransactionFailureKind.failedOnChain,
            )
            .having((error) => error.signature, 'signature', 'signature')
            .having((error) => error.failedInstructionIndex, 'index', 2)
            .having((error) => error.customProgramErrorCode, 'code', 6023)
            .having(
              (error) => error.transactionError,
              'transaction error',
              TransactionError.instructionError,
            )
            .having(
              (error) => error.toString(),
              'sanitized message',
              isNot(contains('6023')),
            ),
      ),
    );
  });

  test('expires only after a successful history miss', () async {
    when(
      () => rpc.getSignatureStatuses(
        ['signature'],
        searchTransactionHistory: false,
      ),
    ).thenAnswer((_) async => _statuses(null));
    when(
      () => rpc.getBlockHeight(commitment: Commitment.confirmed),
    ).thenAnswer((_) async => 11);
    when(
      () => rpc.getSignatureStatuses(
        ['signature'],
        searchTransactionHistory: true,
      ),
    ).thenAnswer((_) async => _statuses(null));

    await expectLater(
      SolanaTransactionConfirmer(rpc).confirm(
        signature: 'signature',
        lastValidBlockHeight: 10,
      ),
      throwsA(
        isA<SolanaTransactionException>()
            .having(
              (error) => error.kind,
              'kind',
              SolanaTransactionFailureKind.expired,
            )
            .having((error) => error.signature, 'signature', 'signature'),
      ),
    );
  });

  test('accepts a historical status after recent-cache expiry', () async {
    when(
      () => rpc.getSignatureStatuses(
        ['signature'],
        searchTransactionHistory: false,
      ),
    ).thenAnswer((_) async => _statuses(null));
    when(
      () => rpc.getBlockHeight(commitment: Commitment.confirmed),
    ).thenAnswer((_) async => 11);
    when(
      () => rpc.getSignatureStatuses(
        ['signature'],
        searchTransactionHistory: true,
      ),
    ).thenAnswer((_) async => _statuses(_status(Commitment.finalized)));

    await SolanaTransactionConfirmer(rpc).confirm(
      signature: 'signature',
      lastValidBlockHeight: 10,
    );
  });

  test('retries history lookup failure instead of reporting expiry', () async {
    var historyCount = 0;
    when(
      () => rpc.getSignatureStatuses(
        ['signature'],
        searchTransactionHistory: false,
      ),
    ).thenAnswer((_) async => _statuses(null));
    when(
      () => rpc.getBlockHeight(commitment: Commitment.confirmed),
    ).thenAnswer((_) async => 11);
    when(
      () => rpc.getSignatureStatuses(
        ['signature'],
        searchTransactionHistory: true,
      ),
    ).thenAnswer((_) async {
      if (historyCount++ == 0) throw TimeoutException('rpc');

      return _statuses(null);
    });

    await expectLater(
      SolanaTransactionConfirmer(
        rpc,
        pollInterval: Duration.zero,
      ).confirm(signature: 'signature', lastValidBlockHeight: 10),
      throwsA(
        isA<SolanaTransactionException>().having(
          (error) => error.kind,
          'kind',
          SolanaTransactionFailureKind.expired,
        ),
      ),
    );
    expect(historyCount, 2);
  });

  test('rejects invalid timing configuration', () {
    expect(
      () => SolanaTransactionConfirmer(
        rpc,
        maxObservationDuration: Duration.zero,
      ),
      throwsArgumentError,
    );
    expect(
      () => SolanaTransactionConfirmer(
        rpc,
        pollInterval: const Duration(milliseconds: -1),
      ),
      throwsArgumentError,
    );
    expect(
      () => SolanaTransactionConfirmer(
        rpc,
        logsTimeout: const Duration(milliseconds: -1),
      ),
      throwsArgumentError,
    );
  });
}
