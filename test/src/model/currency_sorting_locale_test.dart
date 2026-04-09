import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  group('Currency column sorting with locale', () {
    test('should sort negative values correctly with pt_BR locale', () {
      final currencyType = TrinaColumnType.currency(
        locale: 'pt_BR',
        decimalDigits: 2,
        format: '###,###.##',
        negative: true,
      );

      // These values were reported as incorrectly sorted in issue #337
      final values = [-20000.00, -2892.19, -2919.49];

      // Sort ascending using the column type's compare method
      values.sort((a, b) => currencyType.currency.compare(a, b));

      expect(values, [-20000.00, -2919.49, -2892.19]);
    });

    test('should sort positive values correctly with pt_BR locale', () {
      final currencyType = TrinaColumnType.currency(
        locale: 'pt_BR',
        decimalDigits: 2,
        format: '###,###.##',
      );

      final values = [1234.56, 100.00, 999.99];

      values.sort((a, b) => currencyType.currency.compare(a, b));

      expect(values, [100.00, 999.99, 1234.56]);
    });

    test(
      'should sort mixed positive and negative values with pt_BR locale',
      () {
        final currencyType = TrinaColumnType.currency(
          locale: 'pt_BR',
          decimalDigits: 2,
          format: '###,###.##',
          negative: true,
        );

        final values = [100.00, -5000.00, 200.50, -100.25];

        values.sort((a, b) => currencyType.currency.compare(a, b));

        expect(values, [-5000.00, -100.25, 100.00, 200.50]);
      },
    );

    test(
      'should sort correctly with de_DE locale (comma decimal separator)',
      () {
        final currencyType = TrinaColumnType.currency(
          locale: 'de_DE',
          decimalDigits: 2,
          negative: true,
        );

        final values = [-20000.00, -2892.19, -2919.49, 500.00];

        values.sort((a, b) => currencyType.currency.compare(a, b));

        expect(values, [-20000.00, -2919.49, -2892.19, 500.00]);
      },
    );

    test('should sort correctly with en_US locale (dot decimal separator)', () {
      final currencyType = TrinaColumnType.currency(
        locale: 'en_US',
        decimalDigits: 2,
        negative: true,
      );

      final values = [-20000.00, -2892.19, -2919.49, 500.00];

      values.sort((a, b) => currencyType.currency.compare(a, b));

      expect(values, [-20000.00, -2919.49, -2892.19, 500.00]);
    });
  });
}
