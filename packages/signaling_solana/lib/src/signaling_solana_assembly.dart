import 'package:signaling/signaling.dart';
import 'package:signaling_solana/src/data/solana_program/solana_protected_slot_gateway.dart';
import 'package:signaling_solana/src/data/solana_program/solana_signaling_chain_gateway.dart';
import 'package:signaling_solana/src/data/solana_program/solana_signaling_reclaim_gateway.dart';
import 'package:signaling_solana/src/data/solana_program/sols_stream_instruction_factory.dart';
import 'package:signaling_solana/src/data/solana_transaction_coordinator.dart';
import 'package:solana/solana.dart' show Ed25519HDPublicKey, RpcClient;
import 'package:solana_wallet/solana_wallet.dart';

final class SignalingSolanaAssembly {
  /// Canonical signaling service shared by Web, mobile, and desktop clients.
  final PeerSignaling peerSignaling;

  factory SignalingSolanaAssembly({
    required SolanaSigner signer,
    required SolanaFundingService fundingService,
    required RpcClient reader,
    required PeerInviteBase peerInviteBase,
    required KeyBrokerGateway broker,
    SignalingDiagnostics diagnostics = noOpSignalingDiagnostics,
  }) {
    final instructions = SolsStreamInstructionFactory();
    final transactions = SolanaTransactionCoordinator(
      signer: signer,
      funding: fundingService,
      diagnostics: diagnostics,
    );
    final fundedSigner = transactions.fundedSigner;
    final bypassSigner = transactions.bypassSigner;
    final publicKey = signer.publicKey;
    final identity = SignalingParticipantIdentity.fromPublicKey(
      publicKeyBytes: publicKey.bytes,
      addressEncoder: (bytes) => Ed25519HDPublicKey(bytes).toBase58(),
    );
    final SignalingChainGateway chain = SolanaSignalingChainGateway(
      fundedSigner,
      reader,
      cleanupSigner: bypassSigner,
      instructionFactory: instructions,
      diagnostics: diagnostics,
    );

    final SignalingReclaimGateway reclaim = SolanaSignalingReclaimGateway(
      bypassSigner,
      chain,
      instructionFactory: instructions,
      diagnostics: diagnostics,
    );

    final slots = SolanaProtectedSlotGateway(
      fundedSigner,
      reader,
      instructionFactory: instructions,
      diagnostics: diagnostics,
    );

    return SignalingSolanaAssembly._(
      peerSignaling: OnChainPeerSignaling(
        slots: slots,
        chain: chain,
        broker: broker,
        identity: identity,
        peerInviteBase: peerInviteBase,
        reclaim: reclaim,
        diagnostics: diagnostics,
      ),
    );
  }

  const SignalingSolanaAssembly._({
    required this.peerSignaling,
  });
}
