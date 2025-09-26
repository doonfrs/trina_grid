import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  group('getColumnsAutoSizeHelper', () {
    test('When columns is empty, assertion should be thrown', () {
      final stateManager = TrinaGridStateManager(
        columns: [],
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockTrinaGridScrollController(),
        configuration: const TrinaGridConfiguration(
          columnSize: TrinaGridColumnSizeConfig(
            autoSizeMode: TrinaAutoSizeMode.equal,
          ),
        ),
      );

      expect(() {
        stateManager.getColumnsAutoSizeHelper(columns: [], maxWidth: 500);
      }, throwsAssertionError);
    });

    test('When TrinaAutoSizeMode is none, assertion should be thrown', () {
      final columns = ColumnHelper.textColumn('title', count: 5);

      final stateManager = TrinaGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockTrinaGridScrollController(),
        configuration: const TrinaGridConfiguration(
          columnSize: TrinaGridColumnSizeConfig(
            autoSizeMode: TrinaAutoSizeMode.none,
          ),
        ),
      );

      expect(() {
        stateManager.getColumnsAutoSizeHelper(columns: columns, maxWidth: 500);
      }, throwsAssertionError);
    });

    test('When TrinaAutoSizeMode is equal, should return TrinaAutoSize', () {
      final columns = ColumnHelper.textColumn('title', count: 5);

      final stateManager = TrinaGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockTrinaGridScrollController(),
        configuration: const TrinaGridConfiguration(
          columnSize: TrinaGridColumnSizeConfig(
            autoSizeMode: TrinaAutoSizeMode.equal,
          ),
        ),
      );

      final helper = stateManager.getColumnsAutoSizeHelper(
        columns: columns,
        maxWidth: 500,
      );

      expect(helper, isA<TrinaAutoSize>());
    });

    test('When TrinaAutoSizeMode is scale, should return TrinaAutoSize', () {
      final columns = ColumnHelper.textColumn('title', count: 5);

      final stateManager = TrinaGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockTrinaGridScrollController(),
        configuration: const TrinaGridConfiguration(
          columnSize: TrinaGridColumnSizeConfig(
            autoSizeMode: TrinaAutoSizeMode.scale,
          ),
        ),
      );

      final helper = stateManager.getColumnsAutoSizeHelper(
        columns: columns,
        maxWidth: 500,
      );

      expect(helper, isA<TrinaAutoSize>());
    });
  });

  group('getColumnsResizeHelper', () {
    test('When TrinaResizeMode is none, assertion should be thrown', () {
      final columns = ColumnHelper.textColumn('title', count: 5);

      final stateManager = TrinaGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockTrinaGridScrollController(),
        configuration: const TrinaGridConfiguration(
          columnSize: TrinaGridColumnSizeConfig(
            resizeMode: TrinaResizeMode.none,
          ),
        ),
      );

      expect(() {
        stateManager.getColumnsResizeHelper(
          columns: columns,
          column: columns.first,
          offset: 10,
        );
      }, throwsAssertionError);
    });

    test('When TrinaResizeMode is normal, assertion should be thrown', () {
      final columns = ColumnHelper.textColumn('title', count: 5);

      final stateManager = TrinaGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockTrinaGridScrollController(),
        configuration: const TrinaGridConfiguration(
          columnSize: TrinaGridColumnSizeConfig(
            resizeMode: TrinaResizeMode.normal,
          ),
        ),
      );

      expect(() {
        stateManager.getColumnsResizeHelper(
          columns: columns,
          column: columns.first,
          offset: 10,
        );
      }, throwsAssertionError);
    });

    test('When columns is empty, assertion should be thrown', () {
      final columns = <TrinaColumn>[];

      final stateManager = TrinaGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockTrinaGridScrollController(),
        configuration: const TrinaGridConfiguration(
          columnSize: TrinaGridColumnSizeConfig(
            resizeMode: TrinaResizeMode.normal,
          ),
        ),
      );

      expect(() {
        stateManager.getColumnsResizeHelper(
          columns: columns,
          column: ColumnHelper.textColumn('title').first,
          offset: 10,
        );
      }, throwsAssertionError);
    });
  });
}
