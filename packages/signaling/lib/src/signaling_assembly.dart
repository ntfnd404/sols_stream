import 'package:signaling/src/application/signal_payload_codec.dart';
import 'package:signaling/src/application/signaling_chain_gateway.dart';
import 'package:signaling/src/application/signaling_reclaim_gateway.dart';
import 'package:signaling/src/application/solana_signaling.dart';
import 'package:signaling/src/data/crypto/aes_gcm_signal_payload_codec.dart';
import 'package:signaling/src/data/solana_program/solana_signaling_chain_gateway.dart';
import 'package:signaling/src/data/solana_program/solana_signaling_reclaim_gateway.dart';
import 'package:solana/solana.dart' show RpcClient;
import 'package:solana_wallet/solana_wallet.dart';

final class SignalingAssembly {
  final SolanaSignaling signaling;

  factory SignalingAssembly({
    required SolanaSigner signer,
    required WalletAccount account,
    required RpcClient reader,
  }) {
    final SignalingChainGateway chain = SolanaSignalingChainGateway(signer, reader);
    const SignalPayloadCodec codec = AesGcmSignalPayloadCodec();
    // Real reclaim over the signaling program: the host signs each close, and the
    // 1%-skim service wallet is resolved on-chain from `ProgramConfig` and cached
    // for the session (never a literal, never a caller-supplied value).
    final SignalingReclaimGateway reclaim = SolanaSignalingReclaimGateway(signer, chain);

    return SignalingAssembly._(
      signaling: SolanaSignaling(
        chain: chain,
        codec: codec,
        account: account,
        reclaim: reclaim,
      ),
    );
  }

  const SignalingAssembly._({required this.signaling});
}
