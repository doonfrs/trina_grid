import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/row_helper.dart';

void main() {
  group('titleWithGroup', () {
    test('When group is null'
        'then titleWithGroup should be title.', () {
      final column = TrinaColumn(
        title: 'column',
        field: 'column',
        type: TrinaColumnType.text(),
      );

      expect(column.group, null);
      expect(column.titleWithGroup, 'column');
    });

    test('When group has one element'
        'then titleWithGroup should be group name and column name.', () {
      final column = TrinaColumn(
        title: 'column',
        field: 'column',
        type: TrinaColumnType.text(),
      );

      column.group = TrinaColumnGroup(title: 'group', fields: ['column']);

      expect(column.titleWithGroup, 'group column');
    });

    test('When group has multiple elements'
        'then titleWithGroup should be group name and column name.', () {
      final column = TrinaColumn(
        title: 'column',
        field: 'column',
        type: TrinaColumnType.text(),
      );

      final group = TrinaColumnGroup(title: 'groupA2-1', fields: ['column']);

      TrinaColumnGroup(
        title: 'groupA',
        children: [
          TrinaColumnGroup(title: 'groupA1', fields: ['DUMMY_COLUMN']),
          TrinaColumnGroup(title: 'groupA2', children: [group]),
        ],
      );

      column.group = group;

      expect(column.titleWithGroup, 'groupA groupA2 groupA2-1 column');
    });

    test('When group has multiple elements'
        'and expandedColumn is true'
        'then titleWithGroup should be group name and column name.', () {
      final column = TrinaColumn(
        title: 'column',
        field: 'column',
        type: TrinaColumnType.text(),
      );

      final group = TrinaColumnGroup(
        title: 'groupA2-1',
        fields: ['column'],
        expandedColumn: true,
      );

      TrinaColumnGroup(
        title: 'groupA',
        children: [
          TrinaColumnGroup(title: 'groupA1', fields: ['DUMMY_COLUMN']),
          TrinaColumnGroup(title: 'groupA2', children: [group]),
        ],
      );

      column.group = group;

      expect(column.titleWithGroup, 'groupA groupA2 column');
    });
  });

  group('TrinaColumnTextAlign', () {
    test('isStart', () {
      // given
      const TrinaColumnTextAlign textAlign = TrinaColumnTextAlign.start;
      // when
      // then
      expect(textAlign.isStart, isTrue);
    });

    test('isLeft', () {
      // given
      const TrinaColumnTextAlign textAlign = TrinaColumnTextAlign.left;
      // when
      // then
      expect(textAlign.isLeft, isTrue);
    });

    test('isCenter', () {
      // given
      const TrinaColumnTextAlign textAlign = TrinaColumnTextAlign.center;
      // when
      // then
      expect(textAlign.isCenter, isTrue);
    });

    test('isRight', () {
      // given
      const TrinaColumnTextAlign textAlign = TrinaColumnTextAlign.right;
      // when
      // then
      expect(textAlign.isRight, isTrue);
    });

    test('isEnd', () {
      // given
      const TrinaColumnTextAlign textAlign = TrinaColumnTextAlign.end;
      // when
      // then
      expect(textAlign.isEnd, isTrue);
    });

    test('value is TextAlign.start', () {
      // given
      const TrinaColumnTextAlign textAlign = TrinaColumnTextAlign.start;
      // when
      // then
      expect(textAlign.value, TextAlign.start);
    });

    test('value is TextAlign.left', () {
      // given
      const TrinaColumnTextAlign textAlign = TrinaColumnTextAlign.left;
      // when
      // then
      expect(textAlign.value, TextAlign.left);
    });

    test('value is TextAlign.center', () {
      // given
      const TrinaColumnTextAlign textAlign = TrinaColumnTextAlign.center;
      // when
      // then
      expect(textAlign.value, TextAlign.center);
    });

    test('value is TextAlign.right', () {
      // given
      const TrinaColumnTextAlign textAlign = TrinaColumnTextAlign.right;
      // when
      // then
      expect(textAlign.value, TextAlign.right);
    });

    test('value is TextAlign.end', () {
      // given
      const TrinaColumnTextAlign textAlign = TrinaColumnTextAlign.end;
      // when
      // then
      expect(textAlign.value, TextAlign.end);
    });

    test('alignmentValue is AlignmentDirectional.centerStart', () {
      // given
      const TrinaColumnTextAlign textAlign = TrinaColumnTextAlign.start;
      // when
      // then
      expect(textAlign.alignmentValue, AlignmentDirectional.centerStart);
    });

    test('alignmentValue is Alignment.centerLeft', () {
      // given
      const TrinaColumnTextAlign textAlign = TrinaColumnTextAlign.left;
      // when
      // then
      expect(textAlign.alignmentValue, Alignment.centerLeft);
    });

    test('alignmentValue is Alignment.center', () {
      // given
      const TrinaColumnTextAlign textAlign = TrinaColumnTextAlign.center;
      // when
      // then
      expect(textAlign.alignmentValue, Alignment.center);
    });

    test('alignmentValue is Alignment.centerRight', () {
      // given
      const TrinaColumnTextAlign textAlign = TrinaColumnTextAlign.right;
      // when
      // then
      expect(textAlign.alignmentValue, Alignment.centerRight);
    });

    test('alignmentValue is AlignmentDirectional.centerEnd', () {
      // given
      const TrinaColumnTextAlign textAlign = TrinaColumnTextAlign.end;
      // when
      // then
      expect(textAlign.alignmentValue, AlignmentDirectional.centerEnd);
    });
  });

  group('TrinaColumnSort', () {
    test('isNone', () {
      // given
      const TrinaColumnSort columnSort = TrinaColumnSort.none;
      // when
      // then
      expect(columnSort.isNone, isTrue);
    });

    test('isAscending', () {
      // given
      const TrinaColumnSort columnSort = TrinaColumnSort.ascending;
      // when
      // then
      expect(columnSort.isAscending, isTrue);
    });

    test('isDescending', () {
      // given
      const TrinaColumnSort columnSort = TrinaColumnSort.descending;
      // when
      // then
      expect(columnSort.isDescending, isTrue);
    });
  });

  group('TrinaColumnTypeText 의 defaultValue', () {
    test('When defaultValue is set'
        'then defaultValue should be set.', () {
      final TrinaColumnTypeText column =
          TrinaColumnType.text(defaultValue: 'default') as TrinaColumnTypeText;

      expect(column.defaultValue, 'default');
    });

    test('When defaultValue is set'
        'then defaultValue should be set.', () {
      final TrinaColumnTypeNumber column =
          TrinaColumnType.number(defaultValue: 123) as TrinaColumnTypeNumber;

      expect(column.defaultValue, 123);
    });

    test('When defaultValue is set'
        'then defaultValue should be set.', () {
      final TrinaColumnTypeSelect column =
          TrinaColumnType.select(<String>['One'], defaultValue: 'One')
              as TrinaColumnTypeSelect;

      expect(column.defaultValue, 'One');
    });

    test('When defaultValue is set'
        'then defaultValue should be set.', () {
      final TrinaColumnTypeDate column =
          TrinaColumnType.date(defaultValue: DateTime.parse('2020-01-01'))
              as TrinaColumnTypeDate;

      expect(column.defaultValue, DateTime.parse('2020-01-01'));
    });

    test('When defaultValue is set'
        'then defaultValue should be set.', () {
      final TrinaColumnTypeTime column =
          TrinaColumnType.time(defaultValue: '20:30') as TrinaColumnTypeTime;

      expect(column.defaultValue, '20:30');
    });
  });

  group('TrinaColumnTypeText', () {
    test('text', () {
      final TrinaColumnTypeText textColumn =
          TrinaColumnType.text() as TrinaColumnTypeText;
      expect(textColumn.text, textColumn);
    });

    test('time', () {
      final TrinaColumnTypeText textColumn =
          TrinaColumnType.text() as TrinaColumnTypeText;
      expect(() {
        textColumn.time;
      }, throwsA(isA<TypeError>()));
    });

    group('isValid', () {
      test('When value is string'
          'then isValid should be true.', () {
        final TrinaColumnTypeText textColumn =
            TrinaColumnType.text() as TrinaColumnTypeText;
        expect(textColumn.isValid('text'), isTrue);
      });

      test('When value is number'
          'then isValid should be true.', () {
        final TrinaColumnTypeText textColumn =
            TrinaColumnType.text() as TrinaColumnTypeText;
        expect(textColumn.isValid(1234), isTrue);
      });

      test('When value is empty'
          'then isValid should be true.', () {
        final TrinaColumnTypeText textColumn =
            TrinaColumnType.text() as TrinaColumnTypeText;
        expect(textColumn.isValid(''), isTrue);
      });

      test('When value is null'
          'then isValid should be false.', () {
        final TrinaColumnTypeText textColumn =
            TrinaColumnType.text() as TrinaColumnTypeText;
        expect(textColumn.isValid(null), isFalse);
      });
    });

    group('compare', () {
      test('When value1 is less than value2'
          'then compare should return -1.', () {
        final TrinaColumnTypeText textColumn =
            TrinaColumnType.text() as TrinaColumnTypeText;
        expect(textColumn.compare('가', '나'), -1);
      });

      test('When value1 is greater than value2'
          'then compare should return 1.', () {
        final TrinaColumnTypeText textColumn =
            TrinaColumnType.text() as TrinaColumnTypeText;
        expect(textColumn.compare('나', '가'), 1);
      });

      test('When value1 is equal to value2'
          'then compare should return 0.', () {
        final TrinaColumnTypeText textColumn =
            TrinaColumnType.text() as TrinaColumnTypeText;
        expect(textColumn.compare('가', '가'), 0);
      });
    });
  });

  group('TrinaColumnTypeNumber', () {
    group('locale', () {
      test('numberFormat should have the default locale set.', () {
        final TrinaColumnTypeNumber numberColumn =
            TrinaColumnType.number() as TrinaColumnTypeNumber;
        expect(numberColumn.numberFormat.locale, 'en_US');
      });

      test('numberFormat should have the denmark locale set.', () {
        final TrinaColumnTypeNumber numberColumn =
            TrinaColumnType.number(locale: 'da_DK') as TrinaColumnTypeNumber;
        expect(numberColumn.numberFormat.locale, 'da');
      });

      test('numberFormat should have the korea locale set.', () {
        final TrinaColumnTypeNumber numberColumn =
            TrinaColumnType.number(locale: 'ko_KR') as TrinaColumnTypeNumber;
        expect(numberColumn.numberFormat.locale, 'ko');
      });
    });

    group('isValid', () {
      test('When value is string'
          'then isValid should be false.', () {
        final TrinaColumnTypeNumber numberColumn =
            TrinaColumnType.number() as TrinaColumnTypeNumber;
        expect(numberColumn.isValid('text'), isFalse);
      });

      test('When value is number'
          'then isValid should be true.', () {
        final TrinaColumnTypeNumber numberColumn =
            TrinaColumnType.number() as TrinaColumnTypeNumber;
        expect(numberColumn.isValid(123), isTrue);
      });

      test('When value is negative'
          'then isValid should be true.', () {
        final TrinaColumnTypeNumber numberColumn =
            TrinaColumnType.number() as TrinaColumnTypeNumber;
        expect(numberColumn.isValid(-123), isTrue);
      });

      test('When negative is false'
          'and value is negative'
          'then isValid should be false.', () {
        final TrinaColumnTypeNumber numberColumn =
            TrinaColumnType.number(negative: false) as TrinaColumnTypeNumber;
        expect(numberColumn.isValid(-123), isFalse);
      });
    });

    group('compare', () {
      test('When value1 is less than value2'
          'then compare should return -1.', () {
        final TrinaColumnTypeNumber column =
            TrinaColumnType.number() as TrinaColumnTypeNumber;
        expect(column.compare(1, 2), -1);
      });

      test('When value1 is greater than value2'
          'then compare should return 1.', () {
        final TrinaColumnTypeNumber column =
            TrinaColumnType.number() as TrinaColumnTypeNumber;
        expect(column.compare(2, 1), 1);
      });

      test('When value1 is equal to value2'
          'then compare should return 0.', () {
        final TrinaColumnTypeNumber column =
            TrinaColumnType.number() as TrinaColumnTypeNumber;
        expect(column.compare(1, 1), 0);
      });
    });
  });

  group('TrinaColumnTypeSelect', () {
    group('isValid', () {
      test('When item is in items'
          'then isValid should be true.', () {
        final TrinaColumnTypeSelect selectColumn =
            TrinaColumnType.select(<String>['A', 'B', 'C'])
                as TrinaColumnTypeSelect;
        expect(selectColumn.isValid('A'), isTrue);
      });

      test('When item is not in items'
          'then isValid should be false.', () {
        final TrinaColumnTypeSelect selectColumn =
            TrinaColumnType.select(<String>['A', 'B', 'C'])
                as TrinaColumnTypeSelect;
        expect(selectColumn.isValid('D'), isFalse);
      });
    });

    group('compare', () {
      test('When value1 is less than value2'
          'then compare should return -1.', () {
        final TrinaColumnTypeSelect column =
            TrinaColumnType.select(<String>['One', 'Two', 'Three'])
                as TrinaColumnTypeSelect;
        expect(column.compare('Two', 'Three'), -1);
      });

      test('When value1 is greater than value2'
          'then compare should return 1.', () {
        final TrinaColumnTypeSelect column =
            TrinaColumnType.select(<String>['One', 'Two', 'Three'])
                as TrinaColumnTypeSelect;
        expect(column.compare('Three', 'Two'), 1);
      });

      test('When value1 is equal to value2'
          'then compare should return 0.', () {
        final TrinaColumnTypeSelect column =
            TrinaColumnType.select(<String>['One', 'Two', 'Three'])
                as TrinaColumnTypeSelect;
        expect(column.compare('Two', 'Two'), 0);
      });
    });
  });

  group('TrinaColumnTypeDate', () {
    group('isValid', () {
      test('When value is not date'
          'then isValid should be false.', () {
        final TrinaColumnTypeDate dateColumn =
            TrinaColumnType.date() as TrinaColumnTypeDate;
        expect(dateColumn.isValid('Not a date'), isFalse);
      });

      test('When value is date'
          'then isValid should be true.', () {
        final TrinaColumnTypeDate dateColumn =
            TrinaColumnType.date() as TrinaColumnTypeDate;
        expect(dateColumn.isValid('2020-01-01'), isTrue);
      });

      test('When value is date'
          'and startDate is not null'
          'and value is less than startDate'
          'then isValid should be false.', () {
        final TrinaColumnTypeDate dateColumn =
            TrinaColumnType.date(startDate: DateTime.parse('2020-02-01'))
                as TrinaColumnTypeDate;
        expect(dateColumn.isValid('2020-01-01'), isFalse);
      });

      test('When value is date'
          'and startDate is not null'
          'and value is equal to startDate'
          'then isValid should be true.', () {
        final TrinaColumnTypeDate dateColumn =
            TrinaColumnType.date(startDate: DateTime.parse('2020-02-01'))
                as TrinaColumnTypeDate;
        expect(dateColumn.isValid('2020-02-01'), isTrue);
      });

      test('When value is date'
          'and startDate is not null'
          'and value is greater than startDate'
          'then isValid should be true.', () {
        final TrinaColumnTypeDate dateColumn =
            TrinaColumnType.date(startDate: DateTime.parse('2020-02-01'))
                as TrinaColumnTypeDate;
        expect(dateColumn.isValid('2020-02-03'), isTrue);
      });

      test('When value is date'
          'and endDate is not null'
          'and value is less than endDate'
          'then isValid should be true.', () {
        final TrinaColumnTypeDate dateColumn =
            TrinaColumnType.date(endDate: DateTime.parse('2020-02-01'))
                as TrinaColumnTypeDate;
        expect(dateColumn.isValid('2020-01-01'), isTrue);
      });

      test('When value is date'
          'and endDate is not null'
          'and value is equal to endDate'
          'then isValid should be true.', () {
        final TrinaColumnTypeDate dateColumn =
            TrinaColumnType.date(endDate: DateTime.parse('2020-02-01'))
                as TrinaColumnTypeDate;
        expect(dateColumn.isValid('2020-02-01'), isTrue);
      });

      test('When value is date'
          'and endDate is not null'
          'and value is greater than endDate'
          'then isValid should be false.', () {
        final TrinaColumnTypeDate dateColumn =
            TrinaColumnType.date(endDate: DateTime.parse('2020-02-01'))
                as TrinaColumnTypeDate;
        expect(dateColumn.isValid('2020-02-03'), isFalse);
      });

      test('When value is date'
          'and startDate is not null'
          'and endDate is not null'
          'and value is in range'
          'then isValid should be true.', () {
        final TrinaColumnTypeDate dateColumn =
            TrinaColumnType.date(
                  startDate: DateTime.parse('2020-02-01'),
                  endDate: DateTime.parse('2020-02-05'),
                )
                as TrinaColumnTypeDate;
        expect(dateColumn.isValid('2020-02-03'), isTrue);
      });

      test('When value is date'
          'and startDate is not null'
          'and endDate is not null'
          'and value is less than startDate'
          'then isValid should be false.', () {
        final TrinaColumnTypeDate dateColumn =
            TrinaColumnType.date(
                  startDate: DateTime.parse('2020-02-01'),
                  endDate: DateTime.parse('2020-02-05'),
                )
                as TrinaColumnTypeDate;
        expect(dateColumn.isValid('2020-01-03'), isFalse);
      });

      test('When value is date'
          'and startDate is not null'
          'and endDate is not null'
          'and value is greater than endDate'
          'then isValid should be false.', () {
        final TrinaColumnTypeDate dateColumn =
            TrinaColumnType.date(
                  startDate: DateTime.parse('2020-02-01'),
                  endDate: DateTime.parse('2020-02-05'),
                )
                as TrinaColumnTypeDate;
        expect(dateColumn.isValid('2020-02-06'), isFalse);
      });
    });

    group('compare', () {
      test('When value1 is less than value2'
          'then compare should return -1.', () {
        final TrinaColumnTypeDate column =
            TrinaColumnType.date() as TrinaColumnTypeDate;
        expect(column.compare('2019-12-30', '2020-01-01'), -1);
      });

      // When the date format is applied, the behavior of the column's compare function is different from the intended behavior.
      // You need to change the format when calling the compare function. The compare function converts the format appropriately
      // and the format change is processed when the function is called from outside.
      test('12/30/2019, 01/01/2020 in case 1', () {
        final TrinaColumnTypeDate column =
            TrinaColumnType.date(format: 'MM/dd/yyyy') as TrinaColumnTypeDate;
        expect(column.compare('12/30/2019', '01/01/2020'), 1);
      });

      test('When value1 is greater than value2'
          'then compare should return 1.', () {
        final TrinaColumnTypeDate column =
            TrinaColumnType.date() as TrinaColumnTypeDate;
        expect(column.compare('2020-01-01', '2019-12-30'), 1);
      });

      // When the date format is applied, the behavior of the column's compare function is different from the intended behavior.
      // You need to change the format when calling the compare function. The compare function converts the format appropriately
      // and the format change is processed when the function is called from outside.
      test('01/01/2020, 12/30/2019 in case 2', () {
        final TrinaColumnTypeDate column =
            TrinaColumnType.date(format: 'MM/dd/yyyy') as TrinaColumnTypeDate;
        expect(column.compare('01/01/2020', '12/30/2019'), -1);
      });

      test('When value1 is equal to value2'
          'then compare should return 0.', () {
        final TrinaColumnTypeDate column =
            TrinaColumnType.date() as TrinaColumnTypeDate;
        expect(column.compare('2020-01-01', '2020-01-01'), 0);
      });

      test('When value1 is equal to value2'
          'then compare should return 0.', () {
        final TrinaColumnTypeDate column =
            TrinaColumnType.date(format: 'MM/dd/yyyy') as TrinaColumnTypeDate;
        expect(column.compare('01/01/2020', '01/01/2020'), 0);
      });
    });
  });

  group('TrinaColumnTypeTime', () {
    group('isValid', () {
      test('When value is not time'
          'then isValid should be false.', () {
        final TrinaColumnTypeTime timeColumn =
            TrinaColumnType.time() as TrinaColumnTypeTime;
        expect(timeColumn.isValid('24:00'), isFalse);
      });

      test('When value is not time'
          'then isValid should be false.', () {
        final TrinaColumnTypeTime timeColumn =
            TrinaColumnType.time() as TrinaColumnTypeTime;
        expect(timeColumn.isValid('00:60'), isFalse);
      });

      test('When value is not time'
          'then isValid should be false.', () {
        final TrinaColumnTypeTime timeColumn =
            TrinaColumnType.time() as TrinaColumnTypeTime;
        expect(timeColumn.isValid('24:60'), isFalse);
      });

      test('When value is time'
          'then isValid should be true.', () {
        final TrinaColumnTypeTime timeColumn =
            TrinaColumnType.time() as TrinaColumnTypeTime;
        expect(timeColumn.isValid('00:00'), isTrue);
      });

      test('When value is time'
          'then isValid should be true.', () {
        final TrinaColumnTypeTime timeColumn =
            TrinaColumnType.time() as TrinaColumnTypeTime;
        expect(timeColumn.isValid('00:59'), isTrue);
      });

      test('When value is time'
          'then isValid should be true.', () {
        final TrinaColumnTypeTime timeColumn =
            TrinaColumnType.time() as TrinaColumnTypeTime;
        expect(timeColumn.isValid('23:00'), isTrue);
      });

      test('When value is time'
          'then isValid should be true.', () {
        final TrinaColumnTypeTime timeColumn =
            TrinaColumnType.time() as TrinaColumnTypeTime;
        expect(timeColumn.isValid('23:59'), isTrue);
      });
    });
  });

  group('formattedValueForType', () {
    test('When column type is number'
        'then formatted value should be formatted by default format.', () {
      final TrinaColumn column = TrinaColumn(
        title: 'number column',
        field: 'number_column',
        type: TrinaColumnType.number(), // 기본 포멧 (#,###)
      );

      expect(column.formattedValueForType(12345), '12,345');
    });

    test('When column type is number'
        'then formatted value should be formatted by default format.', () {
      final TrinaColumn column = TrinaColumn(
        title: 'number column',
        field: 'number_column',
        type: TrinaColumnType.number(), // 기본 포멧 (#,###)
      );

      expect(column.formattedValueForType(12345678), '12,345,678');
    });

    test('When column type is not number'
        'then formatted value should not be formatted by default format.', () {
      final TrinaColumn column = TrinaColumn(
        title: 'number column',
        field: 'number_column',
        type: TrinaColumnType.text(), // 기본 포멧 (#,###)
      );

      expect(column.formattedValueForType('12345'), '12345');
    });

    test('When column type is currency'
        'then formatted value should be formatted by currency format.', () {
      final TrinaColumn column = TrinaColumn(
        title: 'currency column',
        field: 'currency_column',
        type: TrinaColumnType.currency(symbol: '\$', decimalDigits: 2),
      );

      expect(column.formattedValueForType(12345.67), '\$12,345.67');
    });

    test('When column type is percentage'
        'then formatted value should be formatted by percentage format.', () {
      final TrinaColumn column = TrinaColumn(
        title: 'percentage column',
        field: 'percentage_column',
        type: TrinaColumnType.percentage(decimalDigits: 1, showSymbol: true),
      );

      expect(column.formattedValueForType(0.42), '42.0%');
    });

    test('When column type is date'
        'then formatted value should be formatted by date format.', () {
      final TrinaColumn column = TrinaColumn(
        title: 'date column',
        field: 'date_column',
        type: TrinaColumnType.date(format: 'yyyy-MM-dd'),
      );

      expect(column.formattedValueForType('2023-12-25'), '2023-12-25');
    });

    test('When column type is dateTime'
        'then formatted value should be formatted by dateTime format.', () {
      final TrinaColumn column = TrinaColumn(
        title: 'dateTime column',
        field: 'dateTime_column',
        type: TrinaColumnType.dateTime(format: 'yyyy-MM-dd HH:mm'),
      );

      expect(
        column.formattedValueForType('2023-12-25 14:30:00'),
        '2023-12-25 14:30',
      );
    });

    test('When column type is boolean'
        'then formatted value should be formatted by boolean text.', () {
      final TrinaColumn column = TrinaColumn(
        title: 'boolean column',
        field: 'boolean_column',
        type: TrinaColumnType.boolean(
          trueText: 'Active',
          falseText: 'Inactive',
        ),
      );

      expect(column.formattedValueForType(true), 'Active');
      expect(column.formattedValueForType(false), 'Inactive');
      expect(column.formattedValueForType(null), '');
    });
  });

  group('formattedValueForDisplay', () {
    test('When formatter is null'
        'then formatted value should be formatted by default format.', () {
      final TrinaColumn column = TrinaColumn(
        title: 'number column',
        field: 'number_column',
        type: TrinaColumnType.number(), // 기본 포멧 (#,###)
      );

      expect(column.formattedValueForDisplay(12345), '12,345');
    });

    test('When formatter is not null'
        'then formatted value should be formatted by formatter.', () {
      final TrinaColumn column = TrinaColumn(
        title: 'number column',
        field: 'number_column',
        type: TrinaColumnType.number(), // 기본 포멧 (#,###)
        formatter: (dynamic value) => '\$ $value',
      );

      expect(column.formattedValueForDisplay(12345), '\$ 12345');
    });
  });

  group('checkReadOnly', () {
    makeColumn({
      required bool readOnly,
      TrinaColumnCheckReadOnly? checkReadOnly,
    }) {
      return TrinaColumn(
        title: 'title',
        field: 'field',
        type: TrinaColumnType.text(),
        readOnly: readOnly,
        checkReadOnly: checkReadOnly,
      );
    }

    makeRow(TrinaColumn column) {
      return RowHelper.count(1, [column]).first;
    }

    test('When readOnly is false'
        'and checkReadOnly is null'
        'then checkReadOnly should return false.', () {
      final column = makeColumn(readOnly: false);

      expect(column.readOnly, false);
    });

    test('When readOnly is true'
        'and checkReadOnly is null'
        'then checkReadOnly should return true.', () {
      final column = makeColumn(readOnly: true);

      expect(column.readOnly, true);
    });

    test('When readOnly is false'
        'and checkReadOnly is not null'
        'then checkReadOnly should return true.', () {
      final column = makeColumn(readOnly: false, checkReadOnly: (_, _) => true);

      final row = makeRow(column);

      final cell = row.cells['field'];

      expect(column.checkReadOnly(row, cell!), true);
    });

    test('When readOnly is true'
        'and checkReadOnly is not null'
        'then checkReadOnly should return false.', () {
      final column = makeColumn(readOnly: true, checkReadOnly: (_, _) => false);

      final row = makeRow(column);

      final cell = row.cells['field'];

      expect(column.checkReadOnly(row, cell!), false);
    });
  });

  group('formattedValueForDisplayInEditing', () {
    group('When column type is not TrinaColumnTypeWithNumberFormat', () {
      test('When formatter is not null'
          'and readOnly is true'
          'then formatted value should be formatted by formatter.', () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          applyFormatterInEditing: true,
          readOnly: true,
          type: TrinaColumnType.text(),
          formatter: (s) => '$s changed',
        );

        expect(
          column.formattedValueForDisplayInEditing('original'),
          'original changed',
        );
      });

      test('When readOnly is false'
          'and formatter is not null'
          'and type is select'
          'then formatted value should be formatted by formatter.', () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          applyFormatterInEditing: true,
          readOnly: false,
          type: TrinaColumnType.select(['one', 'two', 'three']),
          formatter: (s) => '$s changed',
        );

        expect(
          column.formattedValueForDisplayInEditing('original'),
          'original changed',
        );
      });

      test('When readOnly is false'
          'and formatter is not null'
          'and type is time'
          'then formatted value should be formatted by formatter.', () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          applyFormatterInEditing: true,
          readOnly: false,
          type: TrinaColumnType.time(),
          formatter: (s) => '$s changed',
        );

        expect(
          column.formattedValueForDisplayInEditing('original'),
          'original changed',
        );
      });

      test('When readOnly is false'
          'and formatter is not null'
          'and type is date'
          'then formatted value should be formatted by formatter.', () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          applyFormatterInEditing: true,
          readOnly: false,
          type: TrinaColumnType.date(),
          formatter: (s) => '$s changed',
        );

        expect(
          column.formattedValueForDisplayInEditing('original'),
          'original changed',
        );
      });

      test('When readOnly is false'
          'and formatter is not null'
          'and type is date'
          'then formatted value should be formatted by formatter.', () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          applyFormatterInEditing: true,
          readOnly: false,
          type: TrinaColumnType.date(),
          formatter: (s) => '$s changed',
        );

        expect(
          column.formattedValueForDisplayInEditing('original'),
          'original changed',
        );
      });

      test('When readOnly is false'
          'and formatter is not null'
          'and applyFormatterInEditing is false'
          'then formatted value should not be formatted by formatter.', () {
        final column = TrinaColumn(
          title: 'column',
          field: 'column',
          applyFormatterInEditing: false,
          readOnly: true,
          type: TrinaColumnType.text(),
          formatter: (s) => '$s changed',
        );

        expect(
          column.formattedValueForDisplayInEditing('original'),
          'original',
        );
      });
    });
  });
}
