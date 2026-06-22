import 'package:solana/encoder.dart' show Instruction;
import 'package:solana/solana.dart' show Ed25519HDPublicKey;
import 'package:solana_wallet/solana_wallet.dart' show SolanaSigner;

/// Records each `signAndSend` and optionally throws a scripted error per call so
/// tests can exercise the reclaim gateway's idempotency/retry classifier.
class RecordingSigner implements SolanaSigner {
  /// One entry per send: a non-null entry is thrown; `null` succeeds. Past the
  /// end, sends succeed.
  final List<Object?> failures;

  /// Instruction lists passed to each `signAndSend`, in order.
  final List<List<Instruction>> sent = [];

  final Ed25519HDPublicKey _publicKey;
  int _call = 0;

  @override
  Ed25519HDPublicKey get publicKey => _publicKey;

  RecordingSigner(this._publicKey, {this.failures = const []});

  @override
  Future<String> signAndSend(List<Instruction> instructions) async {
    sent.add(instructions);
    final i = _call++;
    final failure = i < failures.length ? failures[i] : null;
    if (failure != null) throw failure;

    return 'sig$i';
  }
}
