import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:solana_wallet/solana_signer.dart';
import 'package:solana_wallet/src/data/solana_wallet.dart';
import 'package:test/test.dart';

import 'mocks/mock_funding_gateway.dart';
import 'mocks/mock_rpc_client.dart';

LatestBlockhashResult _blockhash(String value) => LatestBlockhashResult(
  context: Context(slot: BigInt.zero),
  value: LatestBlockhash(
    blockhash: value,
    lastValidBlockHeight: 10,
  ),
);

SignatureStatusesResult _confirmedStatus() => SignatureStatusesResult(
  context: Context(slot: BigInt.zero),
  value: [
    const SignatureStatus(
      slot: 1,
      confirmationStatus: Commitment.confirmed,
    ),
  ],
);

void main() {
  late Ed25519HDKeyPair keypair;
  late MockRpcClient rpc;
  late MockFundingGateway funding;
  late SolanaWallet wallet;

  setUp(() async {
    keypair = await Ed25519HDKeyPair.random();
    rpc = MockRpcClient();
    funding = MockFundingGateway();
    wallet = SolanaWallet(keypair, rpc, funding);
  });

  test('exposes the address derived from its signer public key', () {
    expect(wallet.address, keypair.publicKey.toBase58());
  });

  test('delegates funding for its own derived address', () async {
    when(() => funding.ensureFunded(any())).thenAnswer((_) async => true);

    expect(await wallet.ensureFunded(), isTrue);
    verify(() => funding.ensureFunded(keypair.publicKey.toBase58())).called(1);
  });

  test('signs, sends once, and returns only after confirmation', () async {
    when(
      () => rpc.getLatestBlockhash(commitment: Commitment.confirmed),
    ).thenAnswer((_) async => _blockhash(keypair.publicKey.toBase58()));
    when(
      () => rpc.sendTransaction(
        any(),
        preflightCommitment: Commitment.confirmed,
      ),
    ).thenAnswer((_) async => 'ignored-rpc-id');
    late String observedSignature;
    when(
      () => rpc.getSignatureStatuses(
        any(),
        searchTransactionHistory: false,
      ),
    ).thenAnswer((invocation) async {
      final signatures = invocation.positionalArguments.single as List<String>;
      observedSignature = signatures.single;

      return _confirmedStatus();
    });

    final signature = await wallet.signAndSend(const []);

    expect(signature, observedSignature);
    verify(
      () => rpc.sendTransaction(
        any(),
        preflightCommitment: Commitment.confirmed,
      ),
    ).called(1);
  });

  test('returns structured preflight rejection without polling', () async {
    when(
      () => rpc.getLatestBlockhash(commitment: Commitment.confirmed),
    ).thenAnswer((_) async => _blockhash(keypair.publicKey.toBase58()));
    when(
      () => rpc.sendTransaction(
        any(),
        preflightCommitment: Commitment.confirmed,
      ),
    ).thenThrow(
      const JsonRpcException(
        'simulation failed',
        JsonRpcErrorCode.sendTransactionPreflightFailure,
        {
          'err': {
            'InstructionError': <Object>[
              2,
              {'Custom': 6023},
            ],
          },
          'logs': ['Program log: AnchorError'],
        },
      ),
    );

    await expectLater(
      wallet.signAndSend(const []),
      throwsA(
        isA<SolanaTransactionException>()
            .having(
              (error) => error.kind,
              'kind',
              SolanaTransactionFailureKind.submissionRejected,
            )
            .having((error) => error.signature, 'signature', isNotNull)
            .having((error) => error.failedInstructionIndex, 'index', 2)
            .having((error) => error.customProgramErrorCode, 'code', 6023)
            .having(
              (error) => error.transactionError,
              'transaction error',
              TransactionError.instructionError,
            )
            .having(
              (error) => error.logs,
              'logs',
              ['Program log: AnchorError'],
            ),
      ),
    );
    verifyNever(
      () => rpc.getSignatureStatuses(
        any(),
        searchTransactionHistory: false,
      ),
    );
  });

  test('preserves a structured non-instruction preflight error', () async {
    when(
      () => rpc.getLatestBlockhash(commitment: Commitment.confirmed),
    ).thenAnswer((_) async => _blockhash(keypair.publicKey.toBase58()));
    when(
      () => rpc.sendTransaction(
        any(),
        preflightCommitment: Commitment.confirmed,
      ),
    ).thenThrow(
      const JsonRpcException(
        'account missing',
        JsonRpcErrorCode.sendTransactionPreflightFailure,
        {'err': 'AccountNotFound', 'logs': <String>[]},
      ),
    );

    await expectLater(
      wallet.signAndSend(const []),
      throwsA(
        isA<SolanaTransactionException>().having(
          (error) => error.transactionError,
          'transaction error',
          TransactionError.accountNotFound,
        ),
      ),
    );
  });

  test('reports a non-preflight RPC response as submission rejection', () async {
    when(
      () => rpc.getLatestBlockhash(commitment: Commitment.confirmed),
    ).thenAnswer((_) async => _blockhash(keypair.publicKey.toBase58()));
    when(
      () => rpc.sendTransaction(
        any(),
        preflightCommitment: Commitment.confirmed,
      ),
    ).thenThrow(
      const JsonRpcException(
        'signature verification failed',
        JsonRpcErrorCode.transactionSignatureVerificationFailure,
        null,
      ),
    );

    await expectLater(
      wallet.signAndSend(const []),
      throwsA(
        isA<SolanaTransactionException>().having(
          (error) => error.kind,
          'kind',
          SolanaTransactionFailureKind.submissionRejected,
        ),
      ),
    );
    verifyNever(
      () => rpc.getSignatureStatuses(
        any(),
        searchTransactionHistory: false,
      ),
    );
  });

  test('treats BlockhashNotFound as safely expired', () async {
    when(
      () => rpc.getLatestBlockhash(commitment: Commitment.confirmed),
    ).thenAnswer((_) async => _blockhash(keypair.publicKey.toBase58()));
    when(
      () => rpc.sendTransaction(
        any(),
        preflightCommitment: Commitment.confirmed,
      ),
    ).thenThrow(
      const JsonRpcException(
        'blockhash expired',
        JsonRpcErrorCode.sendTransactionPreflightFailure,
        {'err': 'BlockhashNotFound'},
      ),
    );

    await expectLater(
      wallet.signAndSend(const []),
      throwsA(
        isA<SolanaTransactionException>().having(
          (error) => error.kind,
          'kind',
          SolanaTransactionFailureKind.expired,
        ),
      ),
    );
  });

  test('observes AlreadyProcessed instead of rejecting it', () async {
    when(
      () => rpc.getLatestBlockhash(commitment: Commitment.confirmed),
    ).thenAnswer((_) async => _blockhash(keypair.publicKey.toBase58()));
    when(
      () => rpc.sendTransaction(
        any(),
        preflightCommitment: Commitment.confirmed,
      ),
    ).thenThrow(
      const JsonRpcException(
        'already processed',
        JsonRpcErrorCode.sendTransactionPreflightFailure,
        {'err': 'AlreadyProcessed'},
      ),
    );
    when(
      () => rpc.getSignatureStatuses(
        any(),
        searchTransactionHistory: false,
      ),
    ).thenAnswer((_) async => _confirmedStatus());

    expect(await wallet.signAndSend(const []), isNotEmpty);
  });

  test('observes the same signature after send transport failure', () async {
    when(
      () => rpc.getLatestBlockhash(commitment: Commitment.confirmed),
    ).thenAnswer((_) async => _blockhash(keypair.publicKey.toBase58()));
    when(
      () => rpc.sendTransaction(
        any(),
        preflightCommitment: Commitment.confirmed,
      ),
    ).thenThrow(TimeoutException('send response lost'));
    when(
      () => rpc.getSignatureStatuses(
        any(),
        searchTransactionHistory: false,
      ),
    ).thenAnswer((_) async => _confirmedStatus());

    final signature = await wallet.signAndSend(const []);

    expect(signature, isNotEmpty);
    verify(
      () => rpc.sendTransaction(
        any(),
        preflightCommitment: Commitment.confirmed,
      ),
    ).called(1);
  });

  test('reports transport before signing without sending', () async {
    when(
      () => rpc.getLatestBlockhash(commitment: Commitment.confirmed),
    ).thenThrow(TimeoutException('blockhash'));

    await expectLater(
      wallet.signAndSend(const []),
      throwsA(
        isA<SolanaTransactionException>()
            .having(
              (error) => error.kind,
              'kind',
              SolanaTransactionFailureKind.transport,
            )
            .having((error) => error.signature, 'signature', isNull),
      ),
    );
    verifyNever(
      () => rpc.sendTransaction(
        any(),
        preflightCommitment: Commitment.confirmed,
      ),
    );
  });
}
