import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

/// Columns whose minWidth is far wider than their titles need, the shape that
/// makes minFitContentWidth matter.
List<TrinaColumn> _wideMinWidthColumns() {
  return Iterable<int>.generate(2).map((e) {
    return TrinaColumn(
      title: 'title$e',
      field: 'title$e',
      width: 400,
      minWidth: 400,
      type: TrinaColumnType.text(),
    );
  }).toList();
}

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

    test('When TrinaAutoSizeMode is fitContent, should return '
        'TrinaAutoSizeFitContent', () {
      final columns = ColumnHelper.textColumn('title', count: 5);

      final stateManager = TrinaGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockTrinaGridScrollController(),
        configuration: const TrinaGridConfiguration(
          columnSize: TrinaGridColumnSizeConfig(
            autoSizeMode: TrinaAutoSizeMode.fitContent,
          ),
        ),
      );

      final helper = stateManager.getColumnsAutoSizeHelper(
        columns: columns,
        maxWidth: 500,
      );

      expect(helper, isA<TrinaAutoSizeFitContent>());
    });

    test('When fitContent sizes columns, a column should shrink to its content '
        'even though minWidth is far wider', () {
      // minWidth doubles as the drag limit and is often set well above the
      // width the content needs, so minFitContentWidth overrides it.
      final columns = _wideMinWidthColumns();

      final stateManager = TrinaGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockTrinaGridScrollController(),
        configuration: const TrinaGridConfiguration(
          columnSize: TrinaGridColumnSizeConfig(
            autoSizeMode: TrinaAutoSizeMode.fitContent,
            minFitContentWidth: 30,
          ),
        ),
      );

      // A tight width, so there is nothing left over to share and the fitted
      // width is what lands on the column.
      stateManager
          .getColumnsAutoSizeHelper(columns: columns, maxWidth: 100)
          .update();

      // No rows, so only the titles are measured, and those need far less than
      // the 400 minWidth would have allowed.
      expect(columns[0].width, lessThan(400));
      expect(columns[1].width, lessThan(400));
    });

    test('When fitContent leaves width over, the columns should fill it', () {
      final columns = _wideMinWidthColumns();

      final stateManager = TrinaGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockTrinaGridScrollController(),
        configuration: const TrinaGridConfiguration(
          columnSize: TrinaGridColumnSizeConfig(
            autoSizeMode: TrinaAutoSizeMode.fitContent,
            minFitContentWidth: 30,
          ),
        ),
      );

      stateManager
          .getColumnsAutoSizeHelper(columns: columns, maxWidth: 2000)
          .update();

      expect(columns[0].width + columns[1].width, closeTo(2000, 0.01));
    });

    test('When a column has a renderer, minFitContentWidth should not apply '
        'and its own minWidth should be the floor', () {
      // The renderer can draw anything, and the measuring only sees the cell
      // value, so shrinking such a column below the width its author declared
      // clips whatever the renderer paints.
      final columns = _wideMinWidthColumns();
      columns[0].renderer = (context) => const SizedBox();

      final stateManager = TrinaGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockTrinaGridScrollController(),
        configuration: const TrinaGridConfiguration(
          columnSize: TrinaGridColumnSizeConfig(
            autoSizeMode: TrinaAutoSizeMode.fitContent,
            minFitContentWidth: 30,
          ),
        ),
      );

      stateManager
          .getColumnsAutoSizeHelper(columns: columns, maxWidth: 100)
          .update();

      expect(columns[0].width, 400);
      // The column without a renderer is still measured and fitted.
      expect(columns[1].width, lessThan(400));
    });

    test('When fitContent sizes columns and minFitContentWidth is not set, '
        'minWidth should still be the floor', () {
      final columns = _wideMinWidthColumns();

      final stateManager = TrinaGridStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: MockFocusNode(),
        scroll: MockTrinaGridScrollController(),
        configuration: const TrinaGridConfiguration(
          columnSize: TrinaGridColumnSizeConfig(
            autoSizeMode: TrinaAutoSizeMode.fitContent,
          ),
        ),
      );

      stateManager
          .getColumnsAutoSizeHelper(columns: columns, maxWidth: 800)
          .update();

      expect(columns[0].width, 400);
      expect(columns[1].width, 400);
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
