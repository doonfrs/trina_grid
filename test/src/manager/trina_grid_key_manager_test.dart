import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../helper/trina_widget_test_helper.dart';
import '../../helper/row_helper.dart';
import '../../mock/shared_mocks.mocks.dart';

void main() {
  late MockTrinaGridStateManager stateManager;

  TrinaGridConfiguration configuration;

  late FocusNode keyboardFocusNode;

  setUp(() {
    stateManager = MockTrinaGridStateManager();
    configuration = const TrinaGridConfiguration();
    when(stateManager.configuration).thenReturn(configuration);
    when(stateManager.keyPressed).thenReturn(TrinaGridKeyPressed());
    when(stateManager.rowTotalHeight).thenReturn(
      RowHelper.resolveRowTotalHeight(stateManager.configuration.style),
    );
    when(stateManager.localeText).thenReturn(const TrinaGridLocaleText());
    when(stateManager.gridFocusNode).thenReturn(FocusNode());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);

    keyboardFocusNode = FocusNode();
  });

  testWidgets(
    'Ctrl + C',
    (WidgetTester tester) async {
      // given
      final TrinaGridKeyManager keyManager = TrinaGridKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: KeyboardListener(
              onKeyEvent: (event) {
                keyManager.subject.add(TrinaKeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: const TextField(),
            ),
          ),
        ),
      );

      when(stateManager.isEditing).thenReturn(false);
      when(stateManager.currentSelectingText).thenReturn('copied');

      String? copied;

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          copied = (await methodCall.arguments['text']).toString();
        }
        return null;
      });

      // when
      keyboardFocusNode.requestFocus();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      expect(copied, 'copied');
    },
  );

  testWidgets(
    'Ctrl + C - when isEditing is true, the currentSelectingText value is not copied to the clipboard.',
    (WidgetTester tester) async {
      // given
      final TrinaGridKeyManager keyManager = TrinaGridKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: KeyboardListener(
              onKeyEvent: (event) {
                keyManager.subject.add(TrinaKeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: const TextField(),
            ),
          ),
        ),
      );

      when(stateManager.currentSelectingText).thenReturn('copied');

      when(stateManager.isEditing).thenReturn(true);
      expect(stateManager.isEditing, true);

      String? copied;

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          copied = (await methodCall.arguments['text']).toString();
        }
        return null;
      });

      // when
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      expect(copied, isNull);
    },
  );

  testWidgets(
    'Ctrl + V - pasteCellValue should be called.',
    (WidgetTester tester) async {
      // given
      final TrinaGridKeyManager keyManager = TrinaGridKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: KeyboardListener(
              onKeyEvent: (event) {
                keyManager.subject.add(TrinaKeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: const TextField(),
            ),
          ),
        ),
      );

      when(stateManager.currentCell).thenReturn(TrinaCell(value: 'test'));
      when(stateManager.isEditing).thenReturn(false);

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.getData') {
          return const <String, dynamic>{'text': 'pasted'};
        }
        return null;
      });

      // when
      keyboardFocusNode.requestFocus();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      expect(stateManager.currentCell, isNotNull);
      expect(stateManager.isEditing, false);
      verify(stateManager.pasteCellValue([
        ['pasted']
      ])).called(1);
    },
  );

  testWidgets(
    'Ctrl + V - currentCell is null, pasteCellValue should not be called.',
    (WidgetTester tester) async {
      // given
      final TrinaGridKeyManager keyManager = TrinaGridKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: KeyboardListener(
              onKeyEvent: (event) {
                keyManager.subject.add(TrinaKeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: const TextField(),
            ),
          ),
        ),
      );

      when(stateManager.currentCell).thenReturn(null);
      when(stateManager.isEditing).thenReturn(false);

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.getData') {
          return const <String, dynamic>{'text': 'pasted'};
        }
        return null;
      });

      // when
      keyboardFocusNode.requestFocus();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      expect(stateManager.currentCell, null);
      expect(stateManager.isEditing, false);
      verifyNever(stateManager.pasteCellValue([
        ['pasted']
      ]));
    },
  );

  testWidgets(
    'Ctrl + V - isEditing is true, pasteCellValue should not be called.',
    (WidgetTester tester) async {
      // given
      final TrinaGridKeyManager keyManager = TrinaGridKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: KeyboardListener(
              onKeyEvent: (event) {
                keyManager.subject.add(TrinaKeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: const TextField(),
            ),
          ),
        ),
      );

      when(stateManager.currentCell).thenReturn(TrinaCell(value: 'test'));
      when(stateManager.isEditing).thenReturn(true);

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.getData') {
          return const <String, dynamic>{'text': 'pasted'};
        }
        return null;
      });

      // when
      keyboardFocusNode.requestFocus();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      expect(stateManager.currentCell, isNotNull);
      expect(stateManager.isEditing, true);
      verifyNever(stateManager.pasteCellValue([
        ['pasted']
      ]));
    },
  );

  group('_handleHomeEnd', () {
    final withKeyboardListener =
        TrinaWidgetTestHelper('Key input test', (tester) async {
      final TrinaGridKeyManager keyManager = TrinaGridKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: KeyboardListener(
              onKeyEvent: (event) {
                keyManager.subject.add(TrinaKeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: const TextField(),
            ),
          ),
        ),
      );

      // when
      keyboardFocusNode.requestFocus();

      await tester.pumpAndSettle();
    });

    withKeyboardListener.test('home', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.home);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.home);

      // then
      verify(stateManager
              .moveCurrentCellToEdgeOfColumns(TrinaMoveDirection.left))
          .called(1);
    });

    withKeyboardListener.test('home + shift', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.home);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.home);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

      // then
      verify(stateManager
              .moveSelectingCellToEdgeOfColumns(TrinaMoveDirection.left))
          .called(1);
    });

    withKeyboardListener.test('home + ctrl', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.home);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.home);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      verify(stateManager.moveCurrentCellToEdgeOfRows(TrinaMoveDirection.up))
          .called(1);
    });

    withKeyboardListener.test('home + ctrl + shift', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.home);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.home);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

      // then
      verify(stateManager.moveSelectingCellToEdgeOfRows(TrinaMoveDirection.up))
          .called(1);
    });

    withKeyboardListener.test('end', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.end);

      // then
      verify(stateManager
              .moveCurrentCellToEdgeOfColumns(TrinaMoveDirection.right))
          .called(1);
    });

    withKeyboardListener.test('end + shift', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

      // then
      verify(stateManager
              .moveSelectingCellToEdgeOfColumns(TrinaMoveDirection.right))
          .called(1);
    });

    withKeyboardListener.test('end + ctrl', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      verify(stateManager.moveCurrentCellToEdgeOfRows(TrinaMoveDirection.down))
          .called(1);
    });

    withKeyboardListener.test('end + ctrl + shift', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.end);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

      // then
      verify(stateManager
              .moveSelectingCellToEdgeOfRows(TrinaMoveDirection.down))
          .called(1);
    });
  });

  group('_handlePageUpDown', () {
    final withKeyboardListener =
        TrinaWidgetTestHelper('Key sinput test', (tester) async {
      final TrinaGridKeyManager keyManager = TrinaGridKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      when(stateManager.rowContainerHeight).thenReturn(230);
      when(stateManager.currentRowIdx).thenReturn(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: KeyboardListener(
              onKeyEvent: (event) {
                keyManager.subject.add(TrinaKeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: const TextField(),
            ),
          ),
        ),
      );

      // when
      keyboardFocusNode.requestFocus();

      await tester.pumpAndSettle();
    });

    withKeyboardListener.test('pageUp', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.pageUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.pageUp);

      // then
      verify(stateManager.moveCurrentCellByRowIdx(-5, TrinaMoveDirection.up))
          .called(1);
    });

    withKeyboardListener.test('pageUp + shift', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.pageUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.pageUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

      // then
      verify(stateManager.moveSelectingCellByRowIdx(-5, TrinaMoveDirection.up))
          .called(1);
    });

    withKeyboardListener.test('pageDown', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.pageDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.pageDown);

      // then
      verify(stateManager.moveCurrentCellByRowIdx(5, TrinaMoveDirection.down))
          .called(1);
    });

    withKeyboardListener.test('pageDown + shift', (tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.pageDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.pageDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

      // then
      verify(stateManager.moveSelectingCellByRowIdx(5, TrinaMoveDirection.down))
          .called(1);
    });
  });
  group('_handleDefaultActions', () {
    late TrinaGridKeyManager keyManager;
    setUp(() {
      keyManager = TrinaGridKeyManager(stateManager: stateManager);
      keyManager.init();
    });
    Future<void> buildAndFocus(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: KeyboardListener(
              onKeyEvent: (event) {
                keyManager.subject.add(TrinaKeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: const TextField(),
            ),
          ),
        ),
      );
      keyboardFocusNode.requestFocus();
      // Ensures the focus has been processed.
      await tester.pump();
    }

    group('_handleCharacter', () {
      testWidgets(
        'When isEditing is false and currentCell != null, '
        'setEditing(true) should be called',
        (WidgetTester tester) async {
          await tester.runAsync(() async {
            await buildAndFocus(tester);

            // given
            when(stateManager.isEditing).thenReturn(false);
            when(stateManager.currentCell).thenReturn(TrinaCell(value: 'test'));

            // when
            await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
            await tester.pump();

            // then
            verify(stateManager.setEditing(true)).called(1);
          });
        },
      );
      testWidgets(
        'When isEditing is true, '
        'CurrentCell != null, '
        'setEditing should not be called',
        (WidgetTester tester) async {
          await buildAndFocus(tester); // setup

          // given
          when(stateManager.isEditing).thenReturn(true);
          when(stateManager.currentCell).thenReturn(TrinaCell(value: 'test'));

          // when
          await tester.sendKeyEvent(LogicalKeyboardKey.keyA);

          // then
          verifyNever(stateManager.setEditing(any));
        },
      );
      testWidgets(
        'When CurrentCell is null, '
        'no calls should be made',
        (WidgetTester tester) async {
          await buildAndFocus(tester); // setup

          // given
          when(stateManager.currentCell).thenReturn(null);

          // when
          await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
          // then
          verifyNever(stateManager.setEditing(any));
          verifyNever(stateManager.textEditingController);
        },
      );
    });
    group('when a modifier key is pressed with a character', () {
      testWidgets(
        'When alt is pressed, '
        'no calls should be made',
        (WidgetTester tester) async {
          await buildAndFocus(tester); // setup

          // when
          await tester.sendKeyDownEvent(LogicalKeyboardKey.alt);
          await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.alt);
          await tester.pump();
          // then
          verifyNever(stateManager.setEditing(any));
        },
      );
      testWidgets(
        'When ctrl is pressed, '
        'no calls should be made',
        (WidgetTester tester) async {
          await buildAndFocus(tester); // setup

          // when
          await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
          await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
          await tester.pump();

          // then
          verifyNever(stateManager.setEditing(any));
        },
      );
      testWidgets(
        'When shift is pressed, '
        'event should be handled',
        (WidgetTester tester) async {
          await tester.runAsync(
            () async {
              await buildAndFocus(tester); // setup

              when(stateManager.isEditing).thenReturn(false);
              when(stateManager.currentCell)
                  .thenReturn(TrinaCell(value: 'test'));
              // when
              await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
              await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
              await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
              await tester.pumpAndSettle();
              // then
              verify(stateManager.setEditing(true)).called(1);
            },
          );
        },
      );
    });
  });
}
