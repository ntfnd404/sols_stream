import 'package:flutter_test/flutter_test.dart';
import 'package:sols_stream/core/security/redactor.dart';

void main() {
  group('Redactor', () {
    test('redacts capability query parameters', () {
      final value = Redactor.redactText(
        'sols://connect?host=abc&prot=secret&mode=p2p '
        'https://p2p.sols.stream/home?intent=p2p&role=viewer'
        '&host=abc&ekey=secret&bid=broker',
      );

      expect(value, contains('prot=%5Bredacted%5D'));
      expect(value, contains('ekey=%5Bredacted%5D'));
      expect(value, contains('bid=%5Bredacted%5D'));
      expect(value, isNot(contains('secret')));
      expect(value, isNot(contains('broker')));
    });

    test('redacts authorization values', () {
      final value = Redactor.redactText(
        'Authorization: Bearer abc.def token=secret credential=turn-secret',
      );

      expect(value, contains('Authorization: Bearer [redacted]'));
      expect(value, contains('token=[redacted]'));
      expect(value, contains('credential=[redacted]'));
      expect(value, isNot(contains('abc.def')));
      expect(value, isNot(contains('turn-secret')));
    });
  });
}
