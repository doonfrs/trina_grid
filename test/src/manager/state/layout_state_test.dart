import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/trina_widget_test_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  group('Property value tests.', () {
    late TrinaGridStateManager stateManager;

    TrinaGridEventManager eventManager;

    List<TrinaColumn> columns;

    List<TrinaRow> rows;

    makeFrozenColumnByMaxWidth(String description, double maxWidth) {
      return TrinaWidgetTestHelper('With frozen columns and $description', (
        tester,
      ) async {
        columns = [
          ...ColumnHelper.textColumn(
            'left',
            count: 1,
            frozen: TrinaColumnFrozen.start,
            width: 150,
          ),
          ...ColumnHelper.textColumn('body', count: 3, width: 150),
          ...ColumnHelper.textColumn(
            'right',
            count: 1,
            frozen: TrinaColumnFrozen.end,
            width: 150,
          ),
        ];

        rows = RowHelper.count(10, columns);

        eventManager = MockTrinaGridEventManager();

        stateManager = TrinaGridStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: MockFocusNode(),
          scroll: MockTrinaGridScrollController(),
        );

        stateManager.setEventManager(eventManager);
        stateManager.setLayout(
          BoxConstraints(maxWidth: maxWidth, maxHeight: 500),
        );
        stateManager.setGridGlobalOffset(Offset.zero);
      });
    }

    final hasFrozenColumnAndWidthEnough = makeFrozenColumnByMaxWidth(
      'when width is sufficient',
      600,
    );

    hasFrozenColumnAndWidthEnough.test(
      'bodyLeftOffset value should be left frozen column width + 1',
      (tester) async {
        expect(
          stateManager.bodyLeftOffset,
          stateManager.leftFrozenColumnsWidth + 1,
        );
      },
    );

    hasFrozenColumnAndWidthEnough.test(
      'bodyRightOffset value should be right frozen column width + 1',
      (tester) async {
        expect(
          stateManager.bodyRightOffset,
          stateManager.rightFrozenColumnsWidth + 1,
        );
      },
    );

    hasFrozenColumnAndWidthEnough.test(
      'bodyLeftScrollOffset value should match',
      (tester) async {
        expect(
          stateManager.bodyLeftScrollOffset,
          stateManager.gridGlobalOffset!.dx +
              stateManager.configuration.style.gridPadding +
              stateManager.configuration.style.gridBorderWidth +
              TrinaGridSettings.offsetScrollingFromEdge,
        );
      },
    );

    hasFrozenColumnAndWidthEnough.test(
      'bodyRightScrollOffset value should match',
      (tester) async {
        expect(
          stateManager.bodyRightScrollOffset,
          (stateManager.gridGlobalOffset!.dx + stateManager.maxWidth!) -
              TrinaGridSettings.offsetScrollingFromEdge,
        );
      },
    );

    final hasFrozenColumnAndWidthNotEnough = makeFrozenColumnByMaxWidth(
      'when width is insufficient',
      450,
    );

    hasFrozenColumnAndWidthNotEnough.test('bodyLeftOffset value should be 0', (
      tester,
    ) async {
      expect(stateManager.bodyLeftOffset, 0);
    });

    hasFrozenColumnAndWidthNotEnough.test('bodyRightOffset value should be 0', (
      tester,
    ) async {
      expect(stateManager.bodyRightOffset, 0);
    });

    hasFrozenColumnAndWidthNotEnough.test(
      'bodyLeftScrollOffset value should match',
      (tester) async {
        expect(
          stateManager.bodyLeftScrollOffset,
          stateManager.gridGlobalOffset!.dx +
              stateManager.configuration.style.gridPadding +
              stateManager.configuration.style.gridBorderWidth +
              TrinaGridSettings.offsetScrollingFromEdge,
        );
      },
    );

    hasFrozenColumnAndWidthNotEnough.test(
      'bodyRightScrollOffset value should match',
      (tester) async {
        expect(
          stateManager.bodyRightScrollOffset,
          (stateManager.gridGlobalOffset!.dx + stateManager.maxWidth!) -
              TrinaGridSettings.offsetScrollingFromEdge,
        );
      },
    );
  });
}
