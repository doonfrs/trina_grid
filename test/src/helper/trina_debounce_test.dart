import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  group('TrinaDebounce', () {
    test('duration is 1ms, '
        '1ms duration, '
        '10 callbacks, '
        '1 call', () async {
      const duration = Duration(milliseconds: 1);
      final debounce = TrinaDebounce(duration: duration);
      int count = 0;
      callback() => ++count;

      for (final _ in List.generate(10, (i) => i)) {
        debounce.debounce(callback: callback);
      }

      await Future.delayed(duration);

      expect(count, 1);
    });

    test('duration is 1ms, '
        '2ms duration, '
        '10 callbacks, '
        '2 calls', () async {
      const duration = Duration(milliseconds: 1);
      final debounce = TrinaDebounce(duration: duration);
      int count = 0;
      callback() => ++count;

      for (final i in List.generate(10, (i) => i)) {
        debounce.debounce(callback: callback);
        if (i == 4) await Future.delayed(duration);
      }

      await Future.delayed(duration);

      expect(count, 2);
    });
  });

  group('TrinaDebounceByHashCode', () {
    test('duration is 1ms, '
        '1ms duration, '
        '10 callbacks, '
        '1 call', () async {
      const duration = Duration(milliseconds: 1);
      final debounce = TrinaDebounceByHashCode(duration: duration);
      String testString = 'test';
      int count = 0;

      for (final _ in List.generate(10, (i) => i)) {
        if (!debounce.isDebounced(hashCode: testString.hashCode)) {
          ++count;
        }
      }

      await Future.delayed(duration);

      expect(count, 1);
    });

    test('duration is 1ms, '
        '2ms duration, '
        '10 callbacks, '
        '2 calls', () async {
      const duration = Duration(milliseconds: 1);
      final debounce = TrinaDebounceByHashCode(duration: duration);
      String testString = 'test';
      int count = 0;

      for (final i in List.generate(10, (i) => i)) {
        if (!debounce.isDebounced(hashCode: testString.hashCode)) {
          ++count;
        }
        if (i == 4) await Future.delayed(duration);
      }

      await Future.delayed(duration);

      expect(count, 2);
    });

    test('duration is 1ms, '
        '1ms duration, '
        '10 callbacks, '
        '2 calls', () async {
      const duration = Duration(milliseconds: 1);
      final debounce = TrinaDebounceByHashCode(duration: duration);
      String testString = 'test';
      int count = 0;

      for (final i in List.generate(10, (i) => i)) {
        if (!debounce.isDebounced(hashCode: testString.hashCode)) {
          ++count;
        }

        if (i == 4) testString = 'changed test';
      }

      await Future.delayed(duration);

      expect(count, 2);
    });
  });
}
