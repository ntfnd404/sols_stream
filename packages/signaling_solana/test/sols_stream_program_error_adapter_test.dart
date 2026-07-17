import 'package:signaling_solana/src/data/solana_program/sols_stream_program_error_adapter.dart';
import 'package:signaling_solana/src/generated/sols_stream_solana.dart';
import 'package:solana/solana.dart';
import 'package:solana_wallet/solana_signer.dart';
import 'package:test/test.dart';

void main() {
  const adapter = SolsStreamProgramErrorAdapter();

  test('decodes structured confirmation custom code', () {
    final error = adapter.decode(
      SolanaTransactionException.failedOnChain(
        signature: 'signature',
        failedInstructionIndex: 1,
        customProgramErrorCode: 6023,
        logs: const ['Program log: custom program error: 0x1787'],
      ),
    );

    expect(error, isA<SolsStreamDepositMismatchException>());
    expect(error?.signature, 'signature');
    expect(error?.rawLogs, hasLength(1));
  });

  test('decodes JsonRpcException logs before falling back to payload code', () {
    final error = adapter.decode(
      const JsonRpcException(
        'failed',
        -32002,
        {
          'err': {
            'InstructionError': [
              0,
              {'Custom': 6006},
            ],
          },
          'logs': ['Program log: AnchorError. Error Number: 6006'],
        },
      ),
    );

    expect(error, isA<SolsStreamRoomAlreadyEndedException>());
  });

  test('preserves unknown custom codes', () {
    final error = adapter.decode(
      const JsonRpcException(
        'failed',
        -32002,
        {
          'InstructionError': [
            0,
            {'Custom': 6999},
          ],
        },
      ),
    );

    expect(error, isA<SolsStreamUnknownProgramException>());
    expect(error?.code, 6999);
  });

  test('returns null for failures without a program code or logs', () {
    expect(adapter.decode(StateError('network')), isNull);
  });
}
