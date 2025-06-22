import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../helper/column_helper.dart';
import '../helper/row_helper.dart';
import '../mock/shared_mocks.mocks.dart';

void main() {
  group('TrinaGridConfiguration selectingMode', () {
    test('should have default selectingMode as cell', () {
      const configuration = TrinaGridConfiguration();
      expect(configuration.selectingMode, TrinaGridSelectingMode.cell);
    });

    test('should allow setting selectingMode to row', () {
      const configuration = TrinaGridConfiguration(
        selectingMode: TrinaGridSelectingMode.row,
      );
      expect(configuration.selectingMode, TrinaGridSelectingMode.row);
    });

    test('should allow setting selectingMode to none', () {
      const configuration = TrinaGridConfiguration(
        selectingMode: TrinaGridSelectingMode.none,
      );
      expect(configuration.selectingMode, TrinaGridSelectingMode.none);
    });

    test('should include selectingMode in copyWith', () {
      const configuration = TrinaGridConfiguration();
      final copied = configuration.copyWith(
        selectingMode: TrinaGridSelectingMode.row,
      );
      expect(copied.selectingMode, TrinaGridSelectingMode.row);
    });

    test('should include selectingMode in equality comparison', () {
      const config1 = TrinaGridConfiguration(
        selectingMode: TrinaGridSelectingMode.cell,
      );
      const config2 = TrinaGridConfiguration(
        selectingMode: TrinaGridSelectingMode.cell,
      );
      const config3 = TrinaGridConfiguration(
        selectingMode: TrinaGridSelectingMode.row,
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('should apply selectingMode from configuration to state manager', () {
      final columns = ColumnHelper.textColumn('test', count: 1);
      final rows = RowHelper.count(1, columns);

      final stateManager = TrinaGridStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: MockFocusNode(),
        scroll: MockTrinaGridScrollController(),
        configuration: const TrinaGridConfiguration(
          selectingMode: TrinaGridSelectingMode.row,
        ),
      );

      stateManager.setEventManager(MockTrinaGridEventManager());

      expect(stateManager.selectingMode, TrinaGridSelectingMode.row);
    });

    test('should use configuration selectingMode in normal mode', () {
      final columns = ColumnHelper.textColumn('test', count: 1);
      final rows = RowHelper.count(1, columns);

      final stateManager = TrinaGridStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: MockFocusNode(),
        scroll: MockTrinaGridScrollController(),
        configuration: const TrinaGridConfiguration(
          selectingMode: TrinaGridSelectingMode.none,
        ),
        mode: TrinaGridMode.normal,
      );

      stateManager.setEventManager(MockTrinaGridEventManager());

      // Should use configuration value in normal mode
      expect(stateManager.selectingMode, TrinaGridSelectingMode.none);
    });
  });
}
