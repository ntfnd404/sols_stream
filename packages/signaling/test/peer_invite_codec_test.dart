import 'package:signaling/signaling.dart';
import 'package:test/test.dart';

void main() {
  const codec = PeerInviteCodec();
  const host = '5Ej2kRPgjzySXLGaVH3gTJLurbFf1USKndfoRkkAcWCX';
  final minimalUri = Uri.parse(
    'https://p2p.sols.stream/home?intent=p2p&role=viewer'
    '&host=$host&public=1',
  );

  group('PeerInviteCodec.parse', () {
    test('parses the canonical public invite', () {
      final params = codec.parse(minimalUri);

      expect(params.hostAddress, host);
      expect(params.isPublic, isTrue);
    });

    test('throws when host is missing', () {
      expect(
        () => codec.parse(
          Uri.parse(
            'https://p2p.sols.stream/home?intent=p2p'
            '&role=viewer&public=1',
          ),
        ),
        throwsFormatException,
      );
    });

    test('rejects legacy and incomplete route contracts', () {
      final invalidUris = [
        'https:/home?intent=p2p&role=viewer&host=$host&public=1',
        'https://user@p2p.sols.stream/home?intent=p2p&role=viewer&host=$host&public=1',
        '${minimalUri.toString()}#fragment',
        'sols://connect?host=$host&rn=1&sn=2&prot=x',
        'https://p2p.sols.stream/home?intent=joinRoom&host=$host&public=1',
        'https://p2p.sols.stream/home?intent=p2p&host=$host&public=1',
        'https://p2p.sols.stream/home?intent=p2p&role=publisher&host=$host&public=1',
        'https://p2p.sols.stream/home?intent=p2p&role=viewer&host=$host',
        '${minimalUri.toString()}&mode=p2p',
        '${minimalUri.toString()}&unexpected=value',
        '${minimalUri.toString()}&intent=p2p',
        '${minimalUri.toString()}&role=viewer',
        '${minimalUri.toString()}&host=$host',
        '${minimalUri.toString()}&public=1',
      ].map(Uri.parse);

      for (final uri in invalidUris) {
        expect(() => codec.parse(uri), throwsFormatException);
      }
    });
  });

  group('PeerInviteCodec base and builder', () {
    final baseUri = Uri.parse(
      'https://p2p.sols.stream/home?intent=p2p&role=viewer',
    );

    test('builds a final invite only from a validated base', () {
      final base = codec.parseBase(baseUri);
      final invite = codec.buildViewerInvite(
        base: base,
        hostAddress: host,
        isPublic: true,
      );

      expect(codec.parse(invite).hostAddress, host);
      expect(invite.queryParameters['public'], '1');
    });

    test('rejects host-specific, unknown, and duplicate base parameters', () {
      final invalid = [
        '$baseUri&host=$host',
        '$baseUri&public=1',
        '$baseUri&mode=p2p',
        '$baseUri&intent=p2p',
      ];

      for (final value in invalid) {
        expect(
          () => codec.parseBase(Uri.parse(value)),
          throwsFormatException,
        );
      }
    });
  });
}
