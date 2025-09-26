import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/trina_base_column_footer.dart';

import '../../mock/shared_mocks.mocks.dart';

void main() {
  late MockTrinaGridStateManager stateManager;

  late TrinaGridConfiguration configuration;

  buildWidget({
    required WidgetTester tester,
    required TrinaColumn column,
    bool enableColumnBorderVertical = true,
  }) async {
    stateManager = MockTrinaGridStateManager();

    configuration = TrinaGridConfiguration(
      style: TrinaGridStyleConfig(
        enableColumnBorderVertical: enableColumnBorderVertical,
      ),
    );

    when(stateManager.configuration).thenReturn(configuration);
    when(stateManager.style).thenReturn(configuration.style);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaBaseColumnFooter(
            stateManager: stateManager,
            column: column,
          ),
        ),
      ),
    );
  }

  testWidgets(
    'When footerRenderer is not provided, SizedBox should be rendered',
    (tester) async {
      final column = TrinaColumn(
        title: 'column',
        field: 'column',
        type: TrinaColumnType.number(),
      );

      await buildWidget(tester: tester, column: column);

      expect(find.byType(SizedBox), findsOneWidget);
    },
  );

  testWidgets(
    'When footerRenderer is provided, the provided widget should be rendered',
    (tester) async {
      final column = TrinaColumn(
        title: 'column',
        field: 'column',
        type: TrinaColumnType.number(),
        footerRenderer: (ctx) {
          return const Text('footerRenderer');
        },
      );

      await buildWidget(tester: tester, column: column);

      expect(find.text('footerRenderer'), findsOneWidget);
    },
  );

  testWidgets(
    'Border.end should be rendered (enableColumnBorderVertical default is true)',
    (tester) async {
      final column = TrinaColumn(
        title: 'column',
        field: 'column',
        type: TrinaColumnType.number(),
      );

      await buildWidget(tester: tester, column: column);

      final DecoratedBox box =
          find.byType(DecoratedBox).first.evaluate().first.widget
              as DecoratedBox;

      final decoration = box.decoration as BoxDecoration;

      final border = decoration.border as BorderDirectional;

      expect(border.end.width, 1.0);
      expect(border.end.color, stateManager.style.borderColor);

      expect(border.top, BorderSide.none);
      expect(border.bottom, BorderSide.none);
      expect(border.start, BorderSide.none);
    },
  );

  testWidgets(
    'When enableColumnBorderVertical is false, border.end should not be rendered',
    (tester) async {
      final column = TrinaColumn(
        title: 'column',
        field: 'column',
        type: TrinaColumnType.number(),
      );

      await buildWidget(
        tester: tester,
        column: column,
        enableColumnBorderVertical: false,
      );

      final DecoratedBox box =
          find.byType(DecoratedBox).first.evaluate().first.widget
              as DecoratedBox;

      final decoration = box.decoration as BoxDecoration;

      final border = decoration.border as BorderDirectional;

      expect(border.top, BorderSide.none);
      expect(border.bottom, BorderSide.none);
      expect(border.start, BorderSide.none);
      expect(border.end, BorderSide.none);
    },
  );

  testWidgets('Column backgroundColor should be applied', (tester) async {
    final column = TrinaColumn(
      title: 'column',
      field: 'column',
      type: TrinaColumnType.number(),
      backgroundColor: Colors.blue,
    );

    await buildWidget(
      tester: tester,
      column: column,
      enableColumnBorderVertical: false,
    );

    final DecoratedBox box =
        find.byType(DecoratedBox).first.evaluate().first.widget as DecoratedBox;

    final decoration = box.decoration as BoxDecoration;

    expect(decoration.color, Colors.blue);
  });
}
