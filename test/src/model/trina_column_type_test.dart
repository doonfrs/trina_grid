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
        expect(() => textTypeColumn.select, throwsA(isA<TypeError>()));
      },
    );

    test('When accessing the date property, a TypeError should be thrown.', () {
      expect(() => textTypeColumn.date, throwsA(isA<TypeError>()));
    });

    test('When accessing the time property, a TypeError should be thrown.', () {
      expect(() => textTypeColumn.time, throwsA(isA<TypeError>()));
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
