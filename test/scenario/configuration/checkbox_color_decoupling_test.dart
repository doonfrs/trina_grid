import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

/// Regression tests for issue #390.
///
/// Checkbox colors must not fall back to the cell-selection colors
/// ([TrinaGridStyleConfig.activatedColor] / [activatedBorderColor]). Hiding
/// selection by making those transparent must not make checkboxes disappear.
void main() {
  group('Checkbox colors are decoupled from selection colors (#390)', () {
    test(
      'transparent selection colors do not make checkbox colors transparent',
      () {
        const style = TrinaGridStyleConfig(
          activatedColor: Colors.transparent,
          activatedBorderColor: Colors.transparent,
        );

        expect(style.cellCheckedColor, isNot(Colors.transparent));
        expect(style.cellActiveColor, isNot(Colors.transparent));
        expect(style.columnCheckedColor, isNot(Colors.transparent));
        expect(style.columnActiveColor, isNot(Colors.transparent));
      },
    );

    test('default light style keeps the historical checkbox colors', () {
      const style = TrinaGridStyleConfig();

      expect(style.cellCheckedColor, const Color(0xFFDCF5FF));
      expect(style.columnCheckedColor, const Color(0xFFDCF5FF));
      expect(style.cellActiveColor, Colors.lightBlue);
      expect(style.columnActiveColor, Colors.lightBlue);
    });

    test('default dark style keeps the historical checkbox colors', () {
      const style = TrinaGridStyleConfig.dark();

      expect(style.cellCheckedColor, const Color(0xFF313131));
      expect(style.columnCheckedColor, const Color(0xFF313131));
      expect(style.cellActiveColor, const Color(0xFFFFFFFF));
      expect(style.columnActiveColor, const Color(0xFFFFFFFF));
    });

    test('explicitly provided checkbox colors are still honored', () {
      const style = TrinaGridStyleConfig(
        activatedColor: Colors.transparent,
        activatedBorderColor: Colors.transparent,
        cellCheckedColor: Colors.red,
        cellActiveColor: Colors.green,
        columnCheckedColor: Colors.orange,
        columnActiveColor: Colors.purple,
      );

      expect(style.cellCheckedColor, Colors.red);
      expect(style.cellActiveColor, Colors.green);
      expect(style.columnCheckedColor, Colors.orange);
      expect(style.columnActiveColor, Colors.purple);
    });
  });
}
