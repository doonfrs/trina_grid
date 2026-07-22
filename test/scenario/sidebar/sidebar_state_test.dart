import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/src/ui/ui.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../mock/shared_mocks.mocks.dart';

void main() {
  TrinaGridStateManager createStateManager({
    TrinaGridConfiguration configuration = const TrinaGridConfiguration(),
  }) {
    final columns = ColumnHelper.textColumn('col', count: 3, width: 150);
    final rows = RowHelper.count(5, columns);

    final stateManager = TrinaGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: MockFocusNode(),
      scroll: MockTrinaGridScrollController(),
      configuration: configuration,
    );

    stateManager.setEventManager(MockTrinaGridEventManager());
    stateManager.setLayout(const BoxConstraints(maxWidth: 500, maxHeight: 500));

    return stateManager;
  }

  group('Record sidebar state', () {
    test('is hidden by default and reads mode/width from configuration', () {
      final stateManager = createStateManager();

      expect(stateManager.isSidebarVisible, false);
      expect(stateManager.sidebarMode, TrinaGridSidebarMode.docked);
      expect(stateManager.sidebarWidth, 320);
    });

    test('reads defaults from a custom configuration', () {
      final stateManager = createStateManager(
        configuration: const TrinaGridConfiguration(
          sidebar: TrinaGridSidebarConfig(
            width: 400,
            mode: TrinaGridSidebarMode.floating,
          ),
        ),
      );

      expect(stateManager.sidebarMode, TrinaGridSidebarMode.floating);
      expect(stateManager.sidebarWidth, 400);
    });

    test('showSidebar makes it visible and can set the mode', () {
      final stateManager = createStateManager();

      stateManager.showSidebar(mode: TrinaGridSidebarMode.floating);

      expect(stateManager.isSidebarVisible, true);
      expect(stateManager.sidebarMode, TrinaGridSidebarMode.floating);
    });

    test('hideSidebar hides it', () {
      final stateManager = createStateManager();

      stateManager.showSidebar();
      expect(stateManager.isSidebarVisible, true);

      stateManager.hideSidebar();
      expect(stateManager.isSidebarVisible, false);
    });

    test('toggleSidebar flips visibility', () {
      final stateManager = createStateManager();

      stateManager.toggleSidebar();
      expect(stateManager.isSidebarVisible, true);

      stateManager.toggleSidebar();
      expect(stateManager.isSidebarVisible, false);
    });

    test('setSidebarMode and setSidebarWidth update the state', () {
      final stateManager = createStateManager();

      stateManager.setSidebarMode(TrinaGridSidebarMode.floating);
      expect(stateManager.sidebarMode, TrinaGridSidebarMode.floating);

      stateManager.setSidebarWidth(450);
      expect(stateManager.sidebarWidth, 450);
    });

    test('showSidebar is a no-op when the feature is disabled', () {
      final stateManager = createStateManager(
        configuration: const TrinaGridConfiguration(
          sidebar: TrinaGridSidebarConfig(enabled: false),
        ),
      );

      stateManager.showSidebar();
      expect(stateManager.isSidebarVisible, false);

      stateManager.toggleSidebar();
      expect(stateManager.isSidebarVisible, false);
    });

    test('notifies listeners when visibility changes', () {
      final stateManager = createStateManager();

      int notifyCount = 0;
      stateManager.addListener(() => notifyCount++);

      stateManager.showSidebar();
      expect(notifyCount, greaterThan(0));
    });
  });

  group('Record sidebar widget', () {
    testWidgets('docked panel appears and disappears on toggle', (
      tester,
    ) async {
      final columns = ColumnHelper.textColumn('col', count: 3, width: 150);
      final rows = RowHelper.count(5, columns);

      late TrinaGridStateManager stateManager;

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (event) => stateManager = event.stateManager,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Hidden by default.
      expect(find.text('Search for field...'), findsNothing);

      stateManager.showSidebar();
      await tester.pumpAndSettle();

      // The built-in record view (with its search box) is now shown.
      expect(find.text('Search for field...'), findsOneWidget);

      stateManager.hideSidebar();
      await tester.pumpAndSettle();

      expect(find.text('Search for field...'), findsNothing);
    });

    testWidgets('tapping a field shows the grid editor for that cell', (
      tester,
    ) async {
      final columns = ColumnHelper.textColumn('col', count: 3, width: 150);
      final rows = RowHelper.count(5, columns);

      late TrinaGridStateManager stateManager;

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (event) => stateManager = event.stateManager,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Establish a current row so the sidebar shows its fields.
      stateManager.setCurrentCell(stateManager.rows.first.cells['col0']!, 0);
      stateManager.showSidebar();
      await tester.pumpAndSettle();

      // Tap the second field's value box inside the sidebar.
      await tester.tap(find.byKey(const ValueKey('trina_sidebar_field_col1')));
      await tester.pumpAndSettle();

      // The tapped cell became the grid's current cell, and the sidebar
      // renders the grid's text editor for it. The grid's own editing state
      // stays off (otherwise the grid would render a duplicate editor).
      expect(stateManager.currentCell?.column.field, 'col1');
      expect(stateManager.isEditing, false);
      expect(find.byType(TrinaTextCell), findsOneWidget);

      // The display box for that field is replaced by the editor.
      expect(
        find.byKey(const ValueKey('trina_sidebar_field_col1')),
        findsNothing,
      );
    });
  });
}
