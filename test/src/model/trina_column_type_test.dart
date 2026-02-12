import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  group('text', () {
    const textTypeColumn = TrinaColumnTypeText();

    test(
      'When accessing the text property, a TypeError should not be thrown.',
      () {
        expect(() => textTypeColumn.text, isNot(throwsA(isA<TypeError>())));
      },
    );

    test(
      'When accessing the number property, a TypeError should be thrown.',
      () {
        expect(() => textTypeColumn.number, throwsA(isA<TypeError>()));
      },
    );

    test(
      'When accessing the currency property, a TypeError should be thrown.',
      () {
        expect(() => textTypeColumn.currency, throwsA(isA<TypeError>()));
      },
    );

    test(
      'When accessing the select property, a TypeError should be thrown.',
      () {
        expect(() => textTypeColumn.asSelect(), throwsA(isA<TypeError>()));
      },
    );

    test('When accessing the date property, a TypeError should be thrown.', () {
      expect(() => textTypeColumn.date, throwsA(isA<TypeError>()));
    });

    test('When accessing the time property, a TypeError should be thrown.', () {
      expect(() => textTypeColumn.time, throwsA(isA<TypeError>()));
    });
  });

  group('custom', () {
    const customType = TrinaColumnTypeCustom();

    test(
      'When accessing the custom property, a TypeError should not be thrown.',
      () {
        expect(() => customType.custom, isNot(throwsA(isA<TypeError>())));
      },
    );

    test(
      'When accessing the text property, a TypeError should be thrown.',
      () {
        expect(() => customType.text, throwsA(isA<TypeError>()));
      },
    );

    test(
      'When accessing the number property, a TypeError should be thrown.',
      () {
        expect(() => customType.number, throwsA(isA<TypeError>()));
      },
    );

    group('isValid', () {
      test('should return true for any value by default', () {
        expect(customType.isValid('hello'), isTrue);
        expect(customType.isValid(42), isTrue);
        expect(customType.isValid({'key': 'value'}), isTrue);
        expect(customType.isValid(null), isTrue);
        expect(customType.isValid([1, 2, 3]), isTrue);
      });

      test('should use custom validator when provided', () {
        final validated = TrinaColumnTypeCustom(
          isValid: (value) => value is Map,
        );
        expect(validated.isValid({'key': 'value'}), isTrue);
        expect(validated.isValid('not a map'), isFalse);
        expect(validated.isValid(42), isFalse);
      });
    });

    group('compare', () {
      test('should compare using toString by default', () {
        expect(customType.compare('apple', 'banana'), lessThan(0));
        expect(customType.compare('banana', 'apple'), greaterThan(0));
        expect(customType.compare('apple', 'apple'), 0);
      });

      test('should use custom comparator when provided', () {
        final compared = TrinaColumnTypeCustom(
          compare: (a, b) => (a as int).compareTo(b as int),
        );
        expect(compared.compare(1, 2), lessThan(0));
        expect(compared.compare(2, 1), greaterThan(0));
        expect(compared.compare(1, 1), 0);
      });

      test('When a is null and b is not null, -1 should be returned.', () {
        expect(customType.compare(null, 'a'), -1);
      });

      test('When b is null and a is not null, 1 should be returned.', () {
        expect(customType.compare('a', null), 1);
      });

      test('When both are null, 0 should be returned.', () {
        expect(customType.compare(null, null), 0);
      });
    });

    group('toDisplayString', () {
      test('should use toString by default', () {
        expect(customType.toDisplayString(42), '42');
        expect(customType.toDisplayString('hello'), 'hello');
      });

      test('should use custom callback when provided', () {
        final displayed = TrinaColumnTypeCustom(
          toDisplayString: (value) => 'Custom: $value',
        );
        expect(displayed.toDisplayString(42), 'Custom: 42');
        expect(displayed.toDisplayString('hello'), 'Custom: hello');
      });
    });

    test('defaultValue should be null when not specified', () {
      expect(customType.defaultValue, isNull);
    });

    test('defaultValue should match the provided value', () {
      final withDefault = TrinaColumnTypeCustom(
        defaultValue: {'name': 'test'},
      );
      expect(withDefault.defaultValue, {'name': 'test'});
    });

    test('makeCompareValue should return the raw value', () {
      final obj = {'key': 'value'};
      expect(customType.makeCompareValue(obj), same(obj));
    });
  });

  group('time', () {
    group('isValid', () {
      test('should return true for valid time strings within range', () {
        final columnType = TrinaColumnType.time(
          minTime: const TimeOfDay(hour: 9, minute: 0),
          maxTime: const TimeOfDay(hour: 17, minute: 0),
        );
        expect(columnType.time.isValid('10:30'), isTrue);
        expect(columnType.time.isValid('09:00'), isTrue);
        expect(columnType.time.isValid('17:00'), isTrue);
      });

      test('should return false for invalid time format', () {
        final columnType = TrinaColumnType.time();
        expect(columnType.time.isValid('1030'), isFalse);
        expect(columnType.time.isValid('25:00'), isFalse);
        expect(columnType.time.isValid('10:65'), isFalse);
        expect(columnType.time.isValid('abc'), isFalse);
        expect(columnType.time.isValid(null), isFalse);
      });

      test('should return false for time strings out of min/max range', () {
        final columnType = TrinaColumnType.time(
          minTime: const TimeOfDay(hour: 10, minute: 0),
          maxTime: const TimeOfDay(hour: 12, minute: 0),
        );
        expect(columnType.time.isValid('09:59'), isFalse);
        expect(columnType.time.isValid('12:01'), isFalse);
      });
    });
    group('compare', () {
      final timeColumn = TrinaColumnTypeTime();

      test('When the values are the same, 0 should be returned.', () {
        expect(timeColumn.compare('00:00', '00:00'), 0);
      });

      test('When a is greater than b, 1 should be returned.', () {
        expect(timeColumn.compare('12:00', '00:00'), 1);
      });

      test('When b is greater than a, -1 should be returned.', () {
        expect(timeColumn.compare('12:00', '24:00'), -1);
      });

      test('When a is null and b is not null, -1 should be returned.', () {
        expect(timeColumn.compare(null, '00:00'), -1);
      });

      test('When b is null and a is not null, 1 should be returned.', () {
        expect(timeColumn.compare('00:00', null), 1);
      });
    });
  });
}
