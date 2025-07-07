import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../helper/column_helper.dart';
import '../helper/row_helper.dart';
import '../mock/shared_mocks.mocks.dart';

void main() {
  group('TrinaGridConfiguration selectingMode', () {
    test('should have default selectingMode as cellWithCtrl', () {
      const configuration = TrinaGridConfiguration();
      expect(configuration.selectingMode, TrinaGridSelectingMode.cellWithCtrl);
    });

    test('should include selectingMode in copyWith', () {
      const configuration = TrinaGridConfiguration();
      final copied = configuration.copyWith(
        selectingMode: TrinaGridSelectingMode.rowWithSingleTap,
      );
      expect(copied.selectingMode, TrinaGridSelectingMode.rowWithSingleTap);
    });

    test('should include selectingMode in equality comparison', () {
      const config1 = TrinaGridConfiguration(
        selectingMode: TrinaGridSelectingMode.cellWithCtrl,
      );
      const config2 = TrinaGridConfiguration(
        selectingMode: TrinaGridSelectingMode.cellWithCtrl,
      );
      const config3 = TrinaGridConfiguration(
        selectingMode: TrinaGridSelectingMode.rowWithCtrl,
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
          selectingMode: TrinaGridSelectingMode.rowWithSingleTap,
        ),
      );

      stateManager.setEventManager(MockTrinaGridEventManager());

      expect(
          stateManager.selectingMode, TrinaGridSelectingMode.rowWithSingleTap);
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
          selectingMode: TrinaGridSelectingMode.disabled,
        ),
        mode: TrinaGridMode.normal,
      );

      stateManager.setEventManager(MockTrinaGridEventManager());

      // Should use configuration value in normal mode
      expect(stateManager.selectingMode, TrinaGridSelectingMode.disabled);
    });
  });
}
