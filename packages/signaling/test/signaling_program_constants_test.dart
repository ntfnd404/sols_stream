import 'package:signaling/src/data/solana_program/signaling_program_constants.dart';
import 'package:test/test.dart';

void main() {
  group('SignalingProgramConstants discriminators', () {
    const all = <String, List<int>>{
      'discCreateRoom': SignalingProgramConstants.discCreateRoom,
      'discOpenSlot': SignalingProgramConstants.discOpenSlot,
      'discClaimSlot': SignalingProgramConstants.discClaimSlot,
      'discWriteOffer': SignalingProgramConstants.discWriteOffer,
      'discWriteAnswer': SignalingProgramConstants.discWriteAnswer,
      'discConfirmConnection': SignalingProgramConstants.discConfirmConnection,
      'discHeartbeat': SignalingProgramConstants.discHeartbeat,
      'discCloseConnectSlot': SignalingProgramConstants.discCloseConnectSlot,
      'discEndRoom': SignalingProgramConstants.discEndRoom,
      'discCloseRoom': SignalingProgramConstants.discCloseRoom,
      'discCleanupStaleRoom': SignalingProgramConstants.discCleanupStaleRoom,
      'discCleanupExpiredSlot': SignalingProgramConstants.discCleanupExpiredSlot,
      'discRoomAccount': SignalingProgramConstants.discRoomAccount,
      'discUserAccount': SignalingProgramConstants.discUserAccount,
      'discProgramConfigAccount': SignalingProgramConstants.discProgramConfigAccount,
    };

    test('every discriminator is exactly 8 bytes', () {
      for (final entry in all.entries) {
        expect(entry.value, hasLength(8), reason: entry.key);
      }
    });

    test('every byte is a valid u8 (0..255)', () {
      for (final entry in all.entries) {
        for (final b in entry.value) {
          expect(b, inInclusiveRange(0, 255), reason: entry.key);
        }
      }
    });

    test('all discriminators are distinct', () {
      final seen = <String, String>{};
      for (final entry in all.entries) {
        final key = entry.value.join(',');
        expect(seen.containsKey(key), isFalse,
            reason: '${entry.key} collides with ${seen[key]}');
        seen[key] = entry.key;
      }
    });

    test('existing six are byte-identical (regression guard)', () {
      expect(SignalingProgramConstants.discCreateRoom, [130, 166, 32, 2, 247, 120, 178, 53]);
      expect(SignalingProgramConstants.discOpenSlot, [200, 199, 43, 201, 133, 53, 221, 183]);
      expect(SignalingProgramConstants.discClaimSlot, [110, 60, 180, 109, 39, 35, 5, 140]);
      expect(SignalingProgramConstants.discWriteOffer, [50, 36, 220, 142, 101, 119, 205, 194]);
      expect(SignalingProgramConstants.discWriteAnswer, [229, 79, 107, 103, 29, 50, 93, 119]);
      expect(SignalingProgramConstants.discConfirmConnection, [219, 162, 27, 145, 211, 2, 134, 122]);
    });
  });
}
