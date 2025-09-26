import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/src/ui/columns/trina_column_filter.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';

/// Test action that can simulate different behaviors
class TestShortcutAction extends TrinaGridShortcutAction {
  TestShortcutAction({
    this.shouldThrow = false,
    this.actionName = 'TestAction',
  });

  final bool shouldThrow;
  final String actionName;
  bool wasExecuted = false;

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {
    wasExecuted = true;
    if (shouldThrow) {
      throw Exception('Simulated execution failure in $actionName');
    }
    // This action always "handles" if it doesn't throw
  }
}

void main() {
  Future<TrinaGridStateManager> pumpTrinaGrid(
    WidgetTester tester,
    TrinaGridShortcut shortcut, {
    List<TrinaColumn>? columns,
    List<TrinaRow>? rows,
    bool autoFocusGrid = false,
    CreateHeaderCallBack? headerBuilder,
    CreateFooterCallBack? footerBuilder,
    TrinaGridConfiguration? configuration,
  }) async {
    late TrinaGridStateManager stateManager;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrinaGrid(
            columns:
                columns ??
                [
                  TrinaColumn(
                    title: 'Test Column',
                    field: 'test',
                    type: TrinaColumnType.text(),
                  ),
                ],
            rows:
                rows ??
                [
                  TrinaRow(cells: {'test': TrinaCell(value: 'test')}),
                ],
            createHeader: headerBuilder,
            createFooter: footerBuilder,
            onLoaded: (event) {
              stateManager = event.stateManager;
              if (autoFocusGrid) {
                event.stateManager.setKeepFocus(true);
              }
            },
            configuration: (configuration ?? const TrinaGridConfiguration())
                .copyWith(shortcut: shortcut),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return stateManager;
  }

  Future<void> setFirstCellAsCurrent(
    WidgetTester tester,
    TrinaGridStateManager stateManager,
  ) async {
    stateManager.setCurrentCell(stateManager.rows.first.cells['test'], 0);
    await tester.pump();
  }

  testWidgets('Alt + character combos should not start editing', (
    WidgetTester tester,
  ) async {
    // given
    final stateManager = await pumpTrinaGrid(tester, const TrinaGridShortcut());
    await setFirstCellAsCurrent(tester, stateManager);

    // when
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();

    // then
    expect(stateManager.isEditing, false);
  });

  testWidgets('AltGr + character combos should not start editing', (
    WidgetTester tester,
  ) async {
    // given
    final stateManager = await pumpTrinaGrid(tester, const TrinaGridShortcut());
    await setFirstCellAsCurrent(tester, stateManager);

    // when
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altRight);
    await tester.pumpAndSettle();

    // then
    expect(stateManager.isEditing, false);
  });
  group('Shortcut Handling Verification Tests', () {
    testWidgets('Registered shortcut should be handled properly', (
      tester,
    ) async {
      final testAction = TestShortcutAction(actionName: 'F1Action');

      final shortcut = TrinaGridShortcut(
        actions: {LogicalKeySet(LogicalKeyboardKey.f1): testAction},
      );

      await pumpTrinaGrid(tester, shortcut, autoFocusGrid: true);

      // Send F1 key
      await tester.sendKeyEvent(LogicalKeyboardKey.f1);
      await tester.pump();

      // Verify the shortcut was executed
      expect(testAction.wasExecuted, true);
    });

    testWidgets('Unregistered shortcut should be ignored', (tester) async {
      final testAction = TestShortcutAction(actionName: 'F1Action');

      final shortcut = TrinaGridShortcut(
        actions: {LogicalKeySet(LogicalKeyboardKey.f1): testAction},
      );

      await pumpTrinaGrid(tester, shortcut);

      // Focus the grid
      await tester.tap(find.byType(TrinaGrid));
      await tester.pump();

      // Send F2 key (not registered)
      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await tester.pump();

      // Verify the action was not executed
      expect(testAction.wasExecuted, false);
    });
    testWidgets(
      'When primary focus is in the grid header, unregistered shortcuts should be ignored',
      (tester) async {
        // given
        final testAction = TestShortcutAction(actionName: 'F1Action');

        final shortcut = TrinaGridShortcut(
          actions: {LogicalKeySet(LogicalKeyboardKey.f1): testAction},
        );
        final focusNode = FocusNode();

        await pumpTrinaGrid(
          tester,
          shortcut,
          autoFocusGrid: false,
          headerBuilder: (stateManager) =>
              TextField(focusNode: focusNode, autofocus: true),
        );

        // when
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.pump();

        // assert
        expect(testAction.wasExecuted, false);
      },
    );
    testWidgets(
      'When primary focus is in the grid footer, unregistered shortcuts should be ignored',
      (tester) async {
        // given
        final testAction = TestShortcutAction(actionName: 'F1Action');

        final shortcut = TrinaGridShortcut(
          actions: {LogicalKeySet(LogicalKeyboardKey.f1): testAction},
        );
        final focusNode = FocusNode();

        await pumpTrinaGrid(
          tester,
          shortcut,
          autoFocusGrid: false,
          footerBuilder: (_) =>
              TextField(focusNode: focusNode, autofocus: true),
        );

        // when
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.pump();

        // assert
        expect(testAction.wasExecuted, false);
      },
    );

    testWidgets('Multiple shortcuts should work independently', (tester) async {
      final f1Action = TestShortcutAction(actionName: 'F1Action');
      final f2Action = TestShortcutAction(actionName: 'F2Action');

      final shortcut = TrinaGridShortcut(
        actions: {
          LogicalKeySet(LogicalKeyboardKey.f1): f1Action,
          LogicalKeySet(LogicalKeyboardKey.f2): f2Action,
        },
      );

      await pumpTrinaGrid(tester, shortcut, autoFocusGrid: true);

      // Send F1 key
      await tester.sendKeyEvent(LogicalKeyboardKey.f1);
      await tester.pump();

      expect(f1Action.wasExecuted, true);
      expect(f2Action.wasExecuted, false);

      // Send F2 key
      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await tester.pump();

      expect(f2Action.wasExecuted, true);
    });

    testWidgets('Shortcut with modifier keys should work', (tester) async {
      final testAction = TestShortcutAction(actionName: 'CtrlFAction');

      final shortcut = TrinaGridShortcut(
        actions: {
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
              testAction,
        },
      );

      await pumpTrinaGrid(tester, shortcut, autoFocusGrid: true);

      // Send Ctrl+F
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();

      expect(testAction.wasExecuted, true);
    });

    testWidgets(
      'Grid should ignore shortcuts when widget outside of the grid has the focus',
      (tester) async {
        final testAction = TestShortcutAction(actionName: 'F1Action');

        final shortcut = TrinaGridShortcut(
          actions: {LogicalKeySet(LogicalKeyboardKey.f1): testAction},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  // Another focusable widget
                  TextField(autofocus: true),
                  Expanded(
                    child: TrinaGrid(
                      columns: [
                        TrinaColumn(
                          title: 'Test',
                          field: 'test',
                          type: TrinaColumnType.text(),
                        ),
                      ],
                      rows: [
                        TrinaRow(cells: {'test': TrinaCell(value: 'test')}),
                      ],
                      configuration: TrinaGridConfiguration(shortcut: shortcut),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Send F1 key while text field is focused
        await tester.sendKeyEvent(LogicalKeyboardKey.f1);
        await tester.pump();

        // Grid should not handle the shortcut when not focused
        expect(testAction.wasExecuted, false);
      },
    );

    testWidgets(
      'it should not handle character key event when `TrinaColumnFilter` is focused',
      (tester) async {
        final stateManager = await pumpTrinaGrid(
          tester,
          TrinaGridShortcut(),
          autoFocusGrid: true,
        );
        stateManager.setShowColumnFilter(true);
        await tester.pumpAndSettle();

        await setFirstCellAsCurrent(tester, stateManager);

        final filterTextField = find.descendant(
          of: find.byType(TrinaColumnFilter),
          matching: find.byType(TextField),
        );

        await tester.enterText(filterTextField, 'filter');
        await tester.pump();
        expect(find.widgetWithText(TextField, 'filter'), findsOneWidget);
        expect(stateManager.currentCell?.value, 'test');
      },
    );

    testWidgets('it should not handle character key event '
        'when a `TextField` in gird footer is focused', (tester) async {
      final stateManager = await pumpTrinaGrid(
        tester,
        TrinaGridShortcut(),
        autoFocusGrid: true,
        footerBuilder: (stateManager) =>
            TextField(key: Key('footerTextField'), autofocus: true),
      );

      await setFirstCellAsCurrent(tester, stateManager);
      await tester.enterText(find.byKey(Key('footerTextField')), 'NEW');

      expect(stateManager.currentCell?.value, 'test');
      expect(find.widgetWithText(TextField, 'NEW'), findsOneWidget);
    });
  });

  group('Edge Cases', () {
    testWidgets('Multiple actions for same key should handle first matching', (
      tester,
    ) async {
      final action1 = TestShortcutAction(actionName: 'FirstAction');

      // Note: In practice, you shouldn't have multiple actions for the same key
      // But this tests the behavior if it happens
      final shortcut = TrinaGridShortcut(
        actions: {
          LogicalKeySet(LogicalKeyboardKey.f1): action1,
          // This would overwrite the first one in a real Map
        },
      );

      await pumpTrinaGrid(tester, shortcut, autoFocusGrid: true);

      await tester.sendKeyEvent(LogicalKeyboardKey.f1);
      await tester.pump();

      expect(action1.wasExecuted, true);
    });
  });

  group('Custom Shortcut Test', () {
    testWidgets(
      'When a custom shortcut is defined, it should be triggered on the specified key combination',
      (tester) async {
        final testAction = TestShortcutAction();

        final shortcut = TrinaGridShortcut(
          actions: {LogicalKeySet(LogicalKeyboardKey.enter): testAction},
        );

        final columns = ColumnHelper.textColumn('column', count: 5);
        final rows = RowHelper.count(30, columns);

        await pumpTrinaGrid(
          tester,
          shortcut,
          columns: columns,
          rows: rows,
          autoFocusGrid: true,
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(testAction.wasExecuted, isTrue);
      },
    );

    testWidgets(
      'When a cell is focused and Control + C is pressed, the default action should be executed',
      (tester) async {
        String? copied;

        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall methodCall) async {
            if (methodCall.method == 'Clipboard.setData') {
              final data = methodCall.arguments as Map<String, dynamic>;
              copied = data['text'] as String?;
            }
            return null;
          },
        );

        const shortcut = TrinaGridShortcut();

        final columns = ColumnHelper.textColumn('column', count: 5);
        final rows = RowHelper.count(30, columns);
        final stateManager = await pumpTrinaGrid(
          tester,
          shortcut,
          columns: columns,
          rows: rows,
          autoFocusGrid: true,
        );

        stateManager.setCurrentCell(rows[0].cells['column0'], 0);
        await tester.pump();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        expect(copied, 'column0 value 0');
      },
    );

    testWidgets(
      'When a cell is focused and Control + C action is redefined, the default action should not be executed',
      (tester) async {
        String? copied;

        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall methodCall) async {
            if (methodCall.method == 'Clipboard.setData') {
              final data = methodCall.arguments as Map<String, dynamic>;
              copied = data['text'] as String?;
            }
            return null;
          },
        );

        final testAction = TestShortcutAction();

        final shortcut = TrinaGridShortcut(
          actions: {
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyC):
                testAction,
          },
        );

        final columns = ColumnHelper.textColumn('column', count: 5);
        final rows = RowHelper.count(30, columns);
        final stateManager = await pumpTrinaGrid(
          tester,
          shortcut,
          columns: columns,
          rows: rows,
          autoFocusGrid: true,
        );

        stateManager.setCurrentCell(rows[0].cells['column0'], 0);
        await tester.pump();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        expect(copied, null);
        expect(testAction.wasExecuted, isTrue);
      },
    );
  });
}
