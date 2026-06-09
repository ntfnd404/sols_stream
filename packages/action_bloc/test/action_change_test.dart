import 'package:action_bloc/action_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActionChange', () {
    test('equal when previous and current match', () {
      const a = ActionChange<String>(previous: 'p', current: 'c');
      const b = ActionChange<String>(previous: 'p', current: 'c');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('not equal when current differs', () {
      const a = ActionChange<String>(previous: 'p', current: 'c1');
      const b = ActionChange<String>(previous: 'p', current: 'c2');

      expect(a, isNot(b));
    });

    test('not equal when previous differs', () {
      const a = ActionChange<String>(current: 'c');
      const b = ActionChange<String>(previous: 'p', current: 'c');

      expect(a, isNot(b));
    });

    test('previous defaults to null', () {
      const change = ActionChange<String>(current: 'c');

      expect(change.previous, isNull);
    });

    test('toString includes previous and current', () {
      const change = ActionChange<String>(previous: 'p', current: 'c');

      expect(change.toString(), 'ActionChange(previous: p, current: c)');
    });
  });
}
