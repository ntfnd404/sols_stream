import 'package:signaling_solana/src/generated/sols_stream_solana.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

final class SolsStreamWireAdapter {
  const SolsStreamWireAdapter();

  SolsStreamAddress toGeneratedAddress(Ed25519HDPublicKey address) => SolsStreamAddress.fromBytes(address.bytes);

  Ed25519HDPublicKey toSolanaAddress(SolsStreamAddress address) => Ed25519HDPublicKey(address.bytes);

  Instruction toSolanaInstruction(SolsStreamInstruction instruction) => Instruction(
    programId: toSolanaAddress(instruction.programAddress),
    accounts: instruction.accounts
        .map(
          (account) => account.isWritable
              ? AccountMeta.writeable(
                  pubKey: toSolanaAddress(account.address),
                  isSigner: account.isSigner,
                )
              : AccountMeta.readonly(
                  pubKey: toSolanaAddress(account.address),
                  isSigner: account.isSigner,
                ),
        )
        .toList(growable: false),
    data: ByteArray(instruction.data),
  );
}

final class SolanaPdaDeriver implements SolsStreamPdaDeriver {
  final SolsStreamWireAdapter wireAdapter;

  const SolanaPdaDeriver({
    this.wireAdapter = const SolsStreamWireAdapter(),
  });

  @override
  Future<SolsStreamPdaResult> derive({
    required SolsStreamAddress programAddress,
    required List<List<int>> seeds,
  }) async {
    final programId = wireAdapter.toSolanaAddress(programAddress);
    final flattened = seeds.expand((seed) => seed).toList(growable: false);
    for (var bump = 255; bump >= 0; bump--) {
      try {
        final address = await Ed25519HDPublicKey.createProgramAddress(
          seeds: [...flattened, bump],
          programId: programId,
        );

        return SolsStreamPdaResult(
          address: wireAdapter.toGeneratedAddress(address),
          bump: bump,
        );
      } on FormatException {
        // Continue until the canonical off-curve bump is found.
      }
    }
    throw const FormatException('Unable to derive a Solana program address.');
  }
}
