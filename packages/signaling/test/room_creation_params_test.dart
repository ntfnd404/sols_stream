import 'package:signaling/signaling.dart';
import 'package:test/test.dart';

RoomCreationParams _params({
  String title = 'room',
  int category = 0,
  int accessMode = 0,
  int connectionMode = 1,
  int pricePerMinute = 0,
  int pricePerSession = 0,
}) => RoomCreationParams(
  title: title,
  category: category,
  accessMode: accessMode,
  connectionMode: connectionMode,
  pricePerMinute: pricePerMinute,
  pricePerSession: pricePerSession,
);

void main() {
  group('RoomCreationParams', () {
    test('p2pFree is a public, free P2P room', () {
      const params = RoomCreationParams.p2pFree();

      expect(params.accessMode, 0);
      // connectionMode=1 matches JS CONNECTION_MODE.P2P (program-client.js:104).
      expect(params.connectionMode, 1);
      expect(params.pricePerMinute, 0);
      expect(params.pricePerSession, 0);
    });

    test('accepts valid params', () {
      final params = _params(title: 'paid', pricePerMinute: 5000);

      expect(params.title, 'paid');
      expect(params.pricePerMinute, 5000);
    });

    test('rejects an empty title', () {
      expect(() => _params(title: ''), throwsArgumentError);
    });

    test('rejects an over-long title', () {
      expect(
        () => _params(title: 'x' * (RoomCreationParams.maxTitleLength + 1)),
        throwsArgumentError,
      );
    });

    test('measures the title limit in UTF-8 bytes', () {
      expect(
        () => _params(title: '😀' * 17),
        throwsArgumentError,
      );
      expect(
        () => _params(title: '😀' * 16),
        returnsNormally,
      );
    });

    test('rejects a code field outside the u8 range', () {
      expect(() => _params(accessMode: 256), throwsArgumentError);
      expect(() => _params(connectionMode: -1), throwsArgumentError);
      expect(() => _params(category: 999), throwsArgumentError);
    });

    test('rejects a negative price', () {
      expect(() => _params(pricePerMinute: -1), throwsArgumentError);
      expect(() => _params(pricePerSession: -1), throwsArgumentError);
    });
  });
}
