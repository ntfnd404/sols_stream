import 'package:signaling/src/application/signal_payload_codec.dart';
import 'package:signaling/src/application/signaling_chain_gateway.dart';
import 'package:signaling/src/application/solana_signaling.dart';
import 'package:signaling/src/data/crypto/aes_gcm_signal_payload_codec.dart';
import 'package:signaling/src/data/solana_program/solana_signaling_chain_gateway.dart';
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

    // `reclaim` is left at its default Null Object (UnsupportedSignalingReclaimGateway):
    // the program's close/reclaim instructions are not yet known (need the IDL).
    // Wire a real SignalingReclaimGateway here once they are.
    return SignalingAssembly._(
      signaling: SolanaSignaling(
        chain: chain,
        codec: codec,
        account: account,
      ),
    );
  }

  const SignalingAssembly._({required this.signaling});
}
