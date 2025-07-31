import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../../helper/test_helper_util.dart';

void main() {
  late List<TrinaColumn> defaultColumns;
  late List<TrinaRow> defaultRows;
  late TrinaGridStateManager stateManager;
  const ValueKey<String> sortableGestureKey = ValueKey(
    'ColumnTitleSortableGesture',
  );

  final columnTitleDraggableFinder = find.byType(
    TestHelperUtil.typeOf<Draggable<TrinaColumn>>(),
  );
  TrinaColumn buildColumn({
    double width = TrinaGridSettings.columnWidth,
    TrinaColumnSort sort = TrinaColumnSort.none,
    TrinaColumnFrozen frozen = TrinaColumnFrozen.none,
    bool enableSorting = true,
    bool enableColumnDrag = true,
    bool enableContextMenu = true,
    bool enableRowChecked = false,
    bool enableDropToResize = true,
    Widget Function(TrinaColumnTitleRendererContext)? titleRenderer,
    String? title,
  }) {
    return TrinaColumn(
      title: title ?? 'column title',
      field: 'column_field_name',
      titleRenderer: titleRenderer,
      type: TrinaColumnType.text(),
      width: width,
      frozen: frozen,
      sort: sort,
      enableSorting: enableSorting,
      enableColumnDrag: enableColumnDrag,
      enableContextMenu: enableContextMenu,
      enableDropToResize: enableDropToResize,
      enableRowChecked: enableRowChecked,
    );
  }

  TrinaRow buildRow(String columnTitle, {String? initialCellValue}) {
    return TrinaRow(
      cells: {
        columnTitle: TrinaCell(value: initialCellValue ?? 'value'),
      },
    );
  }

  Future<void> buildGrid(
    WidgetTester tester, {
    List<TrinaColumn>? columns,
    List<TrinaRow>? rows,
    TrinaGridConfiguration? configuration,
  }) async {
    defaultColumns = columns ?? [buildColumn()];
    defaultRows = rows ?? [buildRow(defaultColumns.first.field)];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrinaGrid(
            configuration: configuration ?? TrinaGridConfiguration(),
            columns: defaultColumns,
            rows: defaultRows,
            onLoaded: (event) {
              stateManager = event.stateManager;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('Column title should be displayed', (WidgetTester tester) async {
    await buildGrid(tester);
    expect(find.text('column title'), findsOneWidget);
  });

  testWidgets('ColumnIcon should be displayed', (WidgetTester tester) async {
    await buildGrid(tester);
    expect(find.byType(TrinaGridColumnIcon), findsOneWidget);
  });

  testWidgets(
      'When enableSorting is true (default), '
      'tapping title should change sort state', (WidgetTester tester) async {
    await buildGrid(tester);

    expect(stateManager.columns.first.sort, TrinaColumnSort.none);

    await tester.tap(find.byKey(sortableGestureKey));
    await tester.pumpAndSettle();

    expect(stateManager.columns.first.sort, TrinaColumnSort.ascending);

    await tester.tap(find.byKey(sortableGestureKey));
    await tester.pumpAndSettle();

    expect(stateManager.columns.first.sort, TrinaColumnSort.descending);
  });

  testWidgets(
    'When enableSorting is false, '
    'GestureDetector widget should not exist',
    (WidgetTester tester) async {
      final column = buildColumn(enableSorting: false);
      await buildGrid(tester, columns: [column]);
      expect(find.byKey(sortableGestureKey), findsNothing);
    },
  );

  testWidgets(
    'When enableContextMenu is false and enableDropToResize is false, '
    'ColumnIcon should not be displayed',
    (WidgetTester tester) async {
      final column = buildColumn(
        enableContextMenu: false,
        enableDropToResize: false,
      );
      await buildGrid(tester, columns: [column]);
      expect(find.byType(TrinaGridColumnIcon), findsNothing);
    },
  );

  testWidgets(
    'When enableContextMenu is true and enableDropToResize is true, '
    'ColumnIcon should be displayed',
    (WidgetTester tester) async {
      await buildGrid(tester);
      final found = find.byType(TrinaGridColumnIcon);
      final foundWidget = found.evaluate().first.widget as TrinaGridColumnIcon;
      expect(found, findsOneWidget);
      expect(foundWidget.icon, stateManager.style.columnContextIcon);
    },
  );

  testWidgets(
    'When enableContextMenu is true and enableDropToResize is false, '
    'ColumnIcon should be displayed',
    (WidgetTester tester) async {
      await buildGrid(
        tester,
      );
      final found = find.byType(TrinaGridColumnIcon);
      final foundWidget = found.evaluate().first.widget as TrinaGridColumnIcon;
      expect(found, findsOneWidget);
      expect(foundWidget.icon, stateManager.style.columnContextIcon);
    },
  );

  testWidgets(
    'When enableContextMenu is false and enableDropToResize is true, '
    'ColumnIcon should be displayed',
    (WidgetTester tester) async {
      final column = buildColumn(enableContextMenu: false);
      await buildGrid(tester, columns: [column]);
      final found = find.byType(TrinaGridColumnIcon);
      final foundWidget = found.evaluate().first.widget as TrinaGridColumnIcon;
      expect(found, findsOneWidget);
      expect(foundWidget.icon, stateManager.style.columnResizeIcon);
    },
  );
  group('Title size', () {
    testWidgets(
      'column title height should equal stateManager.columnHeight',
      (tester) async {
        await buildGrid(tester);

        final title = find.byType(TrinaColumnTitle);
        expect(title, findsOneWidget);
        final size = tester.getSize(title);
        expect(size.height, stateManager.style.columnHeight);
      },
    );
    testWidgets(
      'column title width should equal column.width',
      (tester) async {
        final column = buildColumn(width: 100);
        await buildGrid(tester, columns: [column]);

        final title = find.byType(TrinaColumnTitle);
        expect(title, findsOneWidget);
        final size = tester.getSize(title);
        expect(size.width, column.width);
      },
    );
    testWidgets(
      'WHEN enableColumnDrag is false, '
      'column title height should equal to stateManager.columnHeight',
      (tester) async {
        final column = buildColumn(enableColumnDrag: false);
        await buildGrid(tester, columns: [column]);

        final title = find.ancestor(
          of: find.text(column.title),
          matching: find.byType(Container),
        );
        expect(title, findsOneWidget);
        final size = tester.getSize(title);
        expect(size.height, stateManager.style.columnHeight);
      },
    );
  });

  group('enableColumnDrag', () {
    testWidgets(
      'WHEN Column has enableColumnDrag false '
      'THEN Draggable should not be visible',
      (tester) async {
        final column = buildColumn(enableColumnDrag: false);
        await buildGrid(tester, columns: [column]);
        expect(columnTitleDraggableFinder, findsNothing);
      },
    );

    testWidgets(
      'WHEN Column has enableColumnDrag true '
      'THEN Draggable should be visible',
      (tester) async {
        await buildGrid(tester);
        expect(columnTitleDraggableFinder, findsOneWidget);
      },
    );
  });
  group('enableRowChecked', () {
    final columnTitleCheckBox = find.descendant(
      of: find.byType(TrinaColumnTitle),
      matching: find.byType(Checkbox),
    );
    testWidgets(
      'When enableRowChecked is false, Checkbox widget should not be displayed',
      (tester) async {
        await buildGrid(tester);
        expect(columnTitleCheckBox, findsNothing);
      },
    );

    testWidgets(
      'When enableRowChecked is true, Checkbox widget should be displayed',
      (tester) async {
        final column = buildColumn(enableRowChecked: true);
        await buildGrid(tester, columns: [column]);
        expect(columnTitleCheckBox, findsOneWidget);
      },
    );

    testWidgets(
      'When enableRowChecked is true, tapping checkbox should toggle all rows',
      (tester) async {
        final column = buildColumn(enableRowChecked: true);
        await buildGrid(tester, columns: [column]);

        expect(stateManager.tristateCheckedRow, false);

        await tester.tap(columnTitleCheckBox);
        await tester.pumpAndSettle();

        expect(stateManager.tristateCheckedRow, true);

        await tester.tap(columnTitleCheckBox);
        await tester.pumpAndSettle();

        expect(stateManager.tristateCheckedRow, false);
      },
    );
  });

  group('Non-frozen column', () {
    Future<void> tapColumnMenu(WidgetTester tester) async {
      await buildGrid(tester);
      final columnIcon = find.byType(TrinaGridColumnIcon);
      final gesture = await tester.startGesture(tester.getCenter(columnIcon));
      await gesture.up();
      await tester.pumpAndSettle();
    }

    testWidgets('Default menu should be displayed', (tester) async {
      await tapColumnMenu(tester);
      expect(find.text('Freeze to start'), findsOneWidget);
      expect(find.text('Freeze to end'), findsOneWidget);
      expect(find.text('Auto fit'), findsOneWidget);
    });

    testWidgets('Tapping Freeze to start should freeze column', (tester) async {
      await buildGrid(tester);
      final columnIcon = find.byType(TrinaGridColumnIcon);
      await tester.tap(columnIcon);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Freeze to start'));
      await tester.pumpAndSettle();

      expect(stateManager.columns.first.frozen, TrinaColumnFrozen.start);
    });

    testWidgets('Tapping Freeze to end should freeze column', (tester) async {
      await buildGrid(tester);
      final columnIcon = find.byType(TrinaGridColumnIcon);
      await tester.tap(columnIcon);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Freeze to end'));
      await tester.pumpAndSettle();

      expect(stateManager.columns.first.frozen, TrinaColumnFrozen.end);
    });

    testWidgets('Tapping Auto fit should resize column', (tester) async {
      final column = buildColumn(width: 50);
      final row = buildRow(
        column.field,
        initialCellValue: 'long cell value',
      );
      await buildGrid(
        tester,
        columns: [column],
        rows: [row],
      );

      expect(stateManager.columns.first.width, 50);

      final columnIcon = find.byType(TrinaGridColumnIcon);
      await tester.tap(columnIcon);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Auto fit'));
      await tester.pumpAndSettle();

      expect(stateManager.columns.first.width, greaterThan(50.0));
    });
  });

  group('Frozen column at the start', () {
    Future<void> tapColumnMenu(WidgetTester tester) async {
      final column = buildColumn(frozen: TrinaColumnFrozen.start);
      await buildGrid(tester, columns: [column]);
      final columnIcon = find.byType(TrinaGridColumnIcon);
      final gesture = await tester.startGesture(tester.getCenter(columnIcon));
      await gesture.up();
      await tester.pumpAndSettle();
    }

    testWidgets('Frozen column menu should be displayed', (tester) async {
      await tapColumnMenu(tester);
      expect(find.text('Unfreeze'), findsOneWidget);
      expect(find.text('Freeze to start'), findsNothing);
      expect(find.text('Freeze to end'), findsNothing);
      expect(find.text('Auto fit'), findsOneWidget);
    });

    testWidgets('Tapping Unfreeze should unfreeze column', (tester) async {
      final column = buildColumn(frozen: TrinaColumnFrozen.start);
      await buildGrid(tester, columns: [column]);

      expect(stateManager.columns.first.frozen, TrinaColumnFrozen.start);

      final columnIcon = find.byType(TrinaGridColumnIcon);
      await tester.tap(columnIcon);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unfreeze'));
      await tester.pumpAndSettle();

      expect(stateManager.columns.first.frozen, TrinaColumnFrozen.none);
    });
  });
  group('Frozen column at the end', () {
    Future<void> tapColumnMenu(WidgetTester tester) async {
      final column = buildColumn(frozen: TrinaColumnFrozen.end);
      await buildGrid(tester, columns: [column]);
      final columnIcon = find.byType(TrinaGridColumnIcon);
      final gesture = await tester.startGesture(tester.getCenter(columnIcon));
      await gesture.up();
      await tester.pumpAndSettle();
    }

    testWidgets('Frozen column menu should be displayed', (tester) async {
      await tapColumnMenu(tester);
      expect(find.text('Unfreeze'), findsOneWidget);
      expect(find.text('Freeze to start'), findsNothing);
      expect(find.text('Freeze to end'), findsNothing);
      expect(find.text('Auto fit'), findsOneWidget);
    });

    testWidgets('Tapping Unfreeze should unfreeze column', (tester) async {
      final column = buildColumn(frozen: TrinaColumnFrozen.end);
      await buildGrid(tester, columns: [column]);

      expect(stateManager.columns.first.frozen, TrinaColumnFrozen.end);

      final columnIcon = find.byType(TrinaGridColumnIcon);
      await tester.tap(columnIcon);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unfreeze'));
      await tester.pumpAndSettle();

      expect(stateManager.columns.first.frozen, TrinaColumnFrozen.none);
    });
  });

  group('Drag a column', () {
    late List<TrinaColumn> columns;
    late List<TrinaRow> rows;
    setUp(() {
      columns = [
        TrinaColumn(title: 'col1', field: 'col1', type: TrinaColumnType.text()),
        TrinaColumn(title: 'col2', field: 'col2', type: TrinaColumnType.text()),
      ];
      rows = [
        TrinaRow(cells: {
          'col1': TrinaCell(value: 'v1'),
          'col2': TrinaCell(value: 'v2'),
        })
      ];
    });
    testWidgets(
      'When dragging and dropping to another column, columns should be moved.',
      (tester) async {
        await buildGrid(tester, columns: columns, rows: rows);

        expect(stateManager.columns.map((e) => e.field).toList(),
            ['col1', 'col2']);

        await tester.drag(find.text('col1'), const Offset(250, 0));

        await tester.pumpAndSettle();

        expect(stateManager.columns.map((e) => e.field).toList(),
            ['col2', 'col1']);
      },
    );
    testWidgets(
      'When dragging and dropping to the same column, moveColumn should not be called.',
      (tester) async {
        await buildGrid(tester, columns: columns, rows: rows);

        await tester.drag(find.text('col1'), const Offset(50, 0));

        await tester.pumpAndSettle();
        // assert columns order didn't change
        expect(stateManager.columns.map((e) => e.field).toList(),
            ['col1', 'col2']);
      },
    );
  });

  group('Drag a button to resize', () {
    testWidgets(
      'dragging right should increase column width',
      (tester) async {
        final column = buildColumn(width: 100);

        await buildGrid(
          tester,
          columns: [column],
        );

        expect(stateManager.columns.first.width, 100);

        final columnIcon = find.byType(TrinaGridColumnIcon);
        await tester.drag(columnIcon, const Offset(50.0, 0.0));
        await tester.pumpAndSettle();

        expect(stateManager.columns.first.width, greaterThan(100.0));
      },
    );

    testWidgets(
      'dragging left should decrease column width',
      (tester) async {
        final column = buildColumn(width: 100);
        await buildGrid(
          tester,
          columns: [column],
        );

        expect(stateManager.columns.first.width, 100);

        final columnIcon = find.byType(TrinaGridColumnIcon);
        await tester.drag(columnIcon, const Offset(-50.0, 0.0));
        await tester.pumpAndSettle();

        expect(stateManager.columns.first.width, lessThan(100.0));
      },
    );
  });

  group('configuration', () {
    testWidgets(
      'If enableColumnBorder is true, border should be set',
      (tester) async {
        await buildGrid(
          tester,
          configuration: const TrinaGridConfiguration(
            style: TrinaGridStyleConfig(
              enableColumnBorderVertical: true,
              borderColor: Colors.deepOrange,
            ),
          ),
        );

        final target = find.descendant(
          of: find.byKey(sortableGestureKey),
          matching: find.byType(DecoratedBox),
        );

        final container = target.evaluate().single.widget as DecoratedBox;
        final BoxDecoration decoration = container.decoration as BoxDecoration;
        final BorderDirectional border = decoration.border as BorderDirectional;

        expect(border.end.width, 1.0);
        expect(border.end.color, Colors.deepOrange);
      },
    );
    testWidgets(
      'If enableColumnBorder is false, border should not be set',
      (tester) async {
        await buildGrid(
          tester,
          configuration: const TrinaGridConfiguration(
            style: TrinaGridStyleConfig(
              enableColumnBorderVertical: false,
              borderColor: Colors.deepOrange,
            ),
          ),
        );

        expect(
          stateManager.configuration.style.enableColumnBorderVertical,
          false,
        );

        final target = find.descendant(
          of: find.byKey(sortableGestureKey),
          matching: find.byType(DecoratedBox),
        );

        final container = target.evaluate().single.widget as DecoratedBox;

        final BoxDecoration decoration = container.decoration as BoxDecoration;

        final BorderDirectional border = decoration.border as BorderDirectional;

        expect(border.end, BorderSide.none);
      },
    );

    testWidgets(
      'If columnAscendingIcon is set, the set icon should appear',
      (tester) async {
        final column = buildColumn(sort: TrinaColumnSort.ascending);

        await buildGrid(
          tester,
          columns: [column],
          configuration: const TrinaGridConfiguration(
            style: TrinaGridStyleConfig(
              columnAscendingIcon: Icon(
                Icons.arrow_upward,
                color: Colors.cyan,
              ),
            ),
          ),
        );

        final target = find.descendant(
          of: find.byType(TrinaColumnTitle),
          matching: find.byType(Icon),
        );

        final icon = target.evaluate().first.widget as Icon;

        expect(icon.icon, Icons.arrow_upward);
        expect(icon.color, Colors.cyan);
      },
    );
  });

  group('with titleRenderer', () {
    final customTitleWidget = Text('Custom Title');
    final originalTitleText = 'original title';

    testWidgets(
      'Custom title renderer should be used when provided',
      (WidgetTester tester) async {
        final column = buildColumn(
          title: originalTitleText,
          titleRenderer: (context) => customTitleWidget,
        );
        await buildGrid(tester, columns: [column]);

        expect(find.byWidget(customTitleWidget), findsOneWidget);
        expect(find.text(originalTitleText), findsNothing);
      },
    );

    testWidgets(
      'When enableSorting is true and titleRenderer is provided, '
      'tapping title should change sort state',
      (WidgetTester tester) async {
        final column = buildColumn(
          title: originalTitleText,
          titleRenderer: (context) => customTitleWidget,
        );
        await buildGrid(
          tester,
          columns: [column],
        );

        expect(stateManager.columns.first.sort, TrinaColumnSort.none);

        await tester.tap(find.byKey(sortableGestureKey));
        await tester.pumpAndSettle();

        expect(stateManager.columns.first.sort, TrinaColumnSort.ascending);
      },
    );
    testWidgets(
      'WHEN enableColumnDrag is false '
      'THEN Draggable should not be visible',
      (tester) async {
        final column = buildColumn(
          enableColumnDrag: false,
          title: originalTitleText,
          titleRenderer: (context) => customTitleWidget,
        );
        await buildGrid(
          tester,
          columns: [column],
        );
        // then

        expect(columnTitleDraggableFinder, findsNothing);
      },
    );
    testWidgets(
      'WHEN enableColumnDrag is true '
      'THEN Draggable should be visible',
      (tester) async {
        final column = buildColumn(
          enableColumnDrag: true,
          title: originalTitleText,
          titleRenderer: (context) => customTitleWidget,
        );
        await buildGrid(
          tester,
          columns: [column],
        );
        // then

        expect(columnTitleDraggableFinder, findsOneWidget);
      },
    );
    testWidgets(
        'When enableSorting is false and titleRender is provided, '
        'GestureDetector widget should not exist', (tester) async {
      final column = buildColumn(
        enableSorting: false,
        title: originalTitleText,
        titleRenderer: (context) => customTitleWidget,
      );
      await buildGrid(
        tester,
        columns: [column],
      );
      // given
      Finder gestureDetector = find.byKey(sortableGestureKey);

      // then
      expect(gestureDetector, findsNothing);
    });
    testWidgets(
      'column title height should equal stateManager.columnHeight',
      (tester) async {
        final column = buildColumn(
          enableColumnDrag: false,
          title: originalTitleText,
          titleRenderer: (context) => customTitleWidget,
        );
        await buildGrid(
          tester,
          columns: [column],
        );

        final title = find.byType(TrinaColumnTitle);
        expect(title, findsOneWidget);
        final size = tester.getSize(title);
        expect(size.height, stateManager.style.columnHeight);
      },
    );
    testWidgets(
      'WHEN enableColumnDrag is false, '
      'column title height should equal stateManager.columnHeight',
      (tester) async {
        final column = buildColumn(
          enableColumnDrag: false,
          title: originalTitleText,
          titleRenderer: (context) => customTitleWidget,
        );
        final height = 100.0;
        await buildGrid(
          tester,
          columns: [column],
          configuration: TrinaGridConfiguration(
            style: TrinaGridStyleConfig(columnHeight: height),
          ),
        );

        final title = find.byType(TrinaColumnTitle);
        expect(title, findsOneWidget);
        final size = tester.getSize(title);
        expect(size.height, height);
      },
    );
    testWidgets(
      'WHEN enableSorting is false, '
      'column title height should equal stateManager.columnHeight',
      (tester) async {
        final column = buildColumn(
          enableSorting: false,
          title: originalTitleText,
          titleRenderer: (context) => customTitleWidget,
        );
        final height = 100.0;
        await buildGrid(
          tester,
          columns: [column],
          configuration: TrinaGridConfiguration(
            style: TrinaGridStyleConfig(columnHeight: height),
          ),
        );

        final title = find.byType(TrinaColumnTitle);
        expect(title, findsOneWidget);
        final size = tester.getSize(title);
        expect(size.height, height);
      },
    );
  });
}
