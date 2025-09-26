// ignore_for_file: slash_for_doc_comments

import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

/**
  2022. 11 Calendar
  Sun Mon Tue Wed Thu Fri Sat
            1   2   3   4   5
  6   7    8   9  10  11  12
  13  14  15  16  17  18  19
 */
void main() {
  group('moveToFirstWeekday', () {
    test(
      'When the date is 2022.11.6(Sun), 2022.11.6(Sun) should be returned.',
      () {
        final sampleDate = DateTime(2022, 11, 6);
        final expectedDate = DateTime(2022, 11, 6);
        expect(
          TrinaDateTimeHelper.moveToFirstWeekday(sampleDate),
          expectedDate,
        );
      },
    );

    test(
      'When the date is 2022.11.7(Mon), 2022.11.6(Sun) should be returned.',
      () {
        final sampleDate = DateTime(2022, 11, 7);
        final expectedDate = DateTime(2022, 11, 6);
        expect(
          TrinaDateTimeHelper.moveToFirstWeekday(sampleDate),
          expectedDate,
        );
      },
    );

    test(
      'When the date is 2022.11.11(Fri), 2022.11.6(Sun) should be returned.',
      () {
        final sampleDate = DateTime(2022, 11, 11);
        final expectedDate = DateTime(2022, 11, 6);
        expect(
          TrinaDateTimeHelper.moveToFirstWeekday(sampleDate),
          expectedDate,
        );
      },
    );
  });

  group('moveToLastWeekday', () {
    test(
      'When the date is 2022.11.6(Sun), 2022.11.12(Sat) should be returned.',
      () {
        final sampleDate = DateTime(2022, 11, 6);
        final expectedDate = DateTime(2022, 11, 12);
        expect(TrinaDateTimeHelper.moveToLastWeekday(sampleDate), expectedDate);
      },
    );

    test(
      'When the date is 2022.11.9(Wed), 2022.11.12(Sat) should be returned.',
      () {
        final sampleDate = DateTime(2022, 11, 9);
        final expectedDate = DateTime(2022, 11, 12);
        expect(TrinaDateTimeHelper.moveToLastWeekday(sampleDate), expectedDate);
      },
    );

    test(
      'When the date is 2022.11.12(Sat), 2022.11.12(Sat) should be returned.',
      () {
        final sampleDate = DateTime(2022, 11, 12);
        final expectedDate = DateTime(2022, 11, 12);
        expect(TrinaDateTimeHelper.moveToLastWeekday(sampleDate), expectedDate);
      },
    );
  });

  group('isValidRangeInMonth', () {
    test('When start and end are null, true should be returned.', () {
      final date = DateTime(2022, 11, 12);
      expect(
        TrinaDateTimeHelper.isValidRangeInMonth(
          date: date,
          start: null,
          end: null,
        ),
        true,
      );
    });

    test('When start is 2022.11.11 and date is 2022.11.12, '
        'true should be returned.', () {
      final date = DateTime(2022, 11, 12);
      final start = DateTime(2022, 11, 11);
      expect(
        TrinaDateTimeHelper.isValidRangeInMonth(
          date: date,
          start: start,
          end: null,
        ),
        true,
      );
    });

    test('When end is 2022.11.12 and date is 2022.11.12, '
        'true should be returned.', () {
      final date = DateTime(2022, 11, 12);
      final end = DateTime(2022, 11, 13);
      expect(
        TrinaDateTimeHelper.isValidRangeInMonth(
          date: date,
          start: null,
          end: end,
        ),
        true,
      );
    });

    test('When start is 2022.11.13 and date is 2022.11.12, '
        'true should be returned.', () {
      final date = DateTime(2022, 11, 12);
      final start = DateTime(2022, 11, 13);
      expect(
        TrinaDateTimeHelper.isValidRangeInMonth(
          date: date,
          start: start,
          end: null,
        ),
        true,
      );
    });

    test('When end is 2022.11.11 and date is 2022.11.12, '
        'true should be returned.', () {
      final date = DateTime(2022, 11, 12);
      final end = DateTime(2022, 11, 11);
      expect(
        TrinaDateTimeHelper.isValidRangeInMonth(
          date: date,
          start: null,
          end: end,
        ),
        true,
      );
    });

    test('When start is 2022.10.13 and date is 2022.11.12, '
        'true should be returned.', () {
      final date = DateTime(2022, 11, 12);
      final start = DateTime(2022, 10, 13);
      expect(
        TrinaDateTimeHelper.isValidRangeInMonth(
          date: date,
          start: start,
          end: null,
        ),
        true,
      );
    });

    test('When end is 2022.12.13 and date is 2022.11.12, '
        'true should be returned.', () {
      final date = DateTime(2022, 11, 12);
      final end = DateTime(2022, 12, 13);
      expect(
        TrinaDateTimeHelper.isValidRangeInMonth(
          date: date,
          start: null,
          end: end,
        ),
        true,
      );
    });

    test('When start is 2022.12.13 and date is 2022.11.12, '
        'false should be returned.', () {
      final date = DateTime(2022, 11, 12);
      final start = DateTime(2022, 12, 13);
      expect(
        TrinaDateTimeHelper.isValidRangeInMonth(
          date: date,
          start: start,
          end: null,
        ),
        false,
      );
    });

    test('When end is 2022.10.13 and date is 2022.11.12, '
        'false should be returned.', () {
      final date = DateTime(2022, 11, 12);
      final end = DateTime(2022, 10, 13);
      expect(
        TrinaDateTimeHelper.isValidRangeInMonth(
          date: date,
          start: null,
          end: end,
        ),
        false,
      );
    });
  });
}
