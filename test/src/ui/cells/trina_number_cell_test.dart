import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../../helper/trina_widget_test_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  group('TrinaNumberCell', () {
    late TrinaGridStateManager stateManager;

    buildWidget({
      dynamic number = 0,
      bool negative = true,
      String format = '#,###',
      bool applyFormatOnInit = true,
      bool allowFirstDot = false,
      String locale = 'en_US',
    }) {
      return TrinaWidgetTestHelper('build number cell.', (tester) async {
        Intl.defaultLocale = locale;

        stateManager = MockTrinaGridStateManager();

        when(
          stateManager.configuration,
        ).thenReturn(const TrinaGridConfiguration());

        when(stateManager.isEditing).thenReturn(true);

        when(stateManager.keepFocus).thenReturn(true);

        when(
          stateManager.keyManager,
        ).thenReturn(TrinaGridKeyManager(stateManager: stateManager));

        final TrinaColumn column = TrinaColumn(
          title: 'column title',
          field: 'column_field_name',
          type: TrinaColumnType.number(
            negative: negative,
            format: format,
            applyFormatOnInit: applyFormatOnInit,
            allowFirstDot: allowFirstDot,
          ),
        );

        when(stateManager.currentColumn).thenReturn(column);

        final TrinaCell cell = TrinaCell(value: number);

        final TrinaRow row = TrinaRow(cells: {'column_field_name': cell});

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaNumberCell(
                stateManager: stateManager,
                cell: cell,
                column: column,
                row: row,
              ),
            ),
          ),
        );
      });
    }

    buildWidget(
      number: 0,
      negative: true,
      format: '#,###',
      applyFormatOnInit: true,
      allowFirstDot: false,
    ).test('Default value 0 should be displayed', (tester) async {
      expect(find.text('0'), findsOneWidget);
    });

    buildWidget(
      number: 1234.02,
      negative: true,
      format: '#,###',
      applyFormatOnInit: true,
      allowFirstDot: false,
    ).test('When locale is default, 1234.02 should be displayed', (
      tester,
    ) async {
      expect(find.text('1234.02'), findsOneWidget);
    });

    buildWidget(
      number: 1234.02,
      negative: true,
      format: '#,###.##',
      applyFormatOnInit: true,
      allowFirstDot: false,
      locale: 'da_DK',
    ).test('When locale is Danish (using comma), 1234,02 should be displayed', (
      tester,
    ) async {
      expect(find.text('1234,02'), findsOneWidget);
    });
  });

  group('DecimalTextInputFormatter', () {
    updatedValue({
      required String oldValue,
      required String newValue,
      required int decimalRange,
      required bool activatedNegativeValues,
      required bool allowFirstDot,
      String decimalSeparator = '.',
    }) {
      final oldText = TextEditingValue(text: oldValue);

      final newText = TextEditingValue(text: newValue);

      final formatter = DecimalTextInputFormatter(
        decimalRange: decimalRange,
        activatedNegativeValues: activatedNegativeValues,
        allowFirstDot: allowFirstDot,
        decimalSeparator: decimalSeparator,
      );

      return formatter.formatEditUpdate(oldText, newText).text;
    }

    test('When decimalRange is 2 and decimalSeparator is comma, '
        'input of 123.01 should return 0', () {
      expect(
        updatedValue(
          oldValue: '0',
          newValue: '123.01',
          decimalRange: 2,
          activatedNegativeValues: true,
          allowFirstDot: false,
          decimalSeparator: ',',
        ),
        '0',
      );
    });

    test('When decimalRange is 2 and decimalSeparator is comma, '
        'input of 123,01 should return 123,01', () {
      expect(
        updatedValue(
          oldValue: '0',
          newValue: '123,01',
          decimalRange: 2,
          activatedNegativeValues: true,
          allowFirstDot: false,
          decimalSeparator: ',',
        ),
        '123,01',
      );
    });

    test('When decimalRange is 0 and decimalSeparator is comma, '
        'input of 123,01 should return 123', () {
      expect(
        updatedValue(
          oldValue: '123',
          newValue: '123,01',
          decimalRange: 0,
          activatedNegativeValues: true,
          allowFirstDot: false,
          decimalSeparator: ',',
        ),
        '123',
      );
    });

    test('When decimalRange is 2, input of 0.12 should return 0.12', () {
      expect(
        updatedValue(
          oldValue: '0',
          newValue: '0.12',
          decimalRange: 2,
          activatedNegativeValues: true,
          allowFirstDot: false,
        ),
        '0.12',
      );
    });

    test('When decimalRange is 2, input of 0.123 should return 0', () {
      expect(
        updatedValue(
          oldValue: '0',
          newValue: '0.123',
          decimalRange: 2,
          activatedNegativeValues: true,
          allowFirstDot: false,
        ),
        '0',
      );
    });

    test(
      'When activatedNegativeValues is true, input of -0.12 should return -0.12',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '-0.12',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: false,
          ),
          '-0.12',
        );
      },
    );

    test(
      'When activatedNegativeValues is false, input of -0.12 should return 0',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '-0.12',
            decimalRange: 2,
            activatedNegativeValues: false,
            allowFirstDot: false,
          ),
          '0',
        );
      },
    );

    test('When activatedNegativeValues is true and allowFirstDot is false, '
        'input of .0.12 should return 0', () {
      expect(
        updatedValue(
          oldValue: '0',
          newValue: '.0.12',
          decimalRange: 2,
          activatedNegativeValues: true,
          allowFirstDot: false,
        ),
        '0',
      );
    });

    test('When activatedNegativeValues is true and allowFirstDot is true, '
        'input of .0.12 should return .0.12', () {
      expect(
        updatedValue(
          oldValue: '0',
          newValue: '.0.12',
          decimalRange: 2,
          activatedNegativeValues: true,
          allowFirstDot: true,
        ),
        '.0.12',
      );
    });

    test('When activatedNegativeValues is true and allowFirstDot is true, '
        'input of ..0.12 should return 0', () {
      expect(
        updatedValue(
          oldValue: '0',
          newValue: '..0.12',
          decimalRange: 2,
          activatedNegativeValues: true,
          allowFirstDot: true,
        ),
        '0',
      );
    });

    test('When activatedNegativeValues is true and allowFirstDot is true, '
        'input of -.0.12 should return 0', () {
      expect(
        updatedValue(
          oldValue: '0',
          newValue: '-.0.12',
          decimalRange: 2,
          activatedNegativeValues: true,
          allowFirstDot: true,
        ),
        '0',
      );
    });
  });
}
