import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';
import 'package:trina_grid/src/widgets/boolean_column_filter.dart';
import 'package:trina_grid/src/widgets/filter_dropdown_field.dart';
import 'package:trina_grid/src/widgets/multi_select_column_filter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../matcher/trina_object_matcher.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late MockTrinaGridStateManager stateManager;
  late PublishSubject<TrinaNotifierEvent> subject;
  MockTrinaGridEventManager? eventManager;
  MockStreamSubscription<TrinaGridEvent> streamSubscription;

  setUp(() {
    stateManager = MockTrinaGridStateManager();
    eventManager = MockTrinaGridEventManager();
    streamSubscription = MockStreamSubscription();
    subject = PublishSubject<TrinaNotifierEvent>();

    const configuration = TrinaGridConfiguration();
    when(stateManager.eventManager).thenReturn(eventManager);
    when(stateManager.configuration).thenReturn(configuration);
    when(stateManager.style).thenReturn(configuration.style);
    when(stateManager.streamNotifier).thenAnswer((_) => subject);
    when(stateManager.localeText).thenReturn(const TrinaGridLocaleText());
    when(stateManager.filterRowsByField(any)).thenReturn([]);
    when(
      stateManager.columnHeight,
    ).thenReturn(stateManager.configuration.style.columnHeight);
    when(
      stateManager.columnFilterHeight,
    ).thenReturn(stateManager.configuration.style.columnFilterHeight);

    when(eventManager!.listener(any)).thenReturn(streamSubscription);
  });

  tearDown(() {
    subject.close();
  });

  testWidgets('Tapping TextField should call setKeepFocus with false', (
    WidgetTester tester,
  ) async {
    // given
    final TrinaColumn column = TrinaColumn(
      title: 'column title',
      field: 'column_field_name',
      type: TrinaColumnType.text(),
    );

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaColumnFilter(stateManager: stateManager, column: column),
        ),
      ),
    );

    // then
    await tester.tap(find.byType(TextField));

    verify(stateManager.setKeepFocus(false)).called(1);
  });

  testWidgets(
    'Entering text in TextField should trigger TrinaChangeColumnFilterEvent',
    (WidgetTester tester) async {
      // given
      final TrinaColumn column = TrinaColumn(
        title: 'column title',
        field: 'column_field_name',
        type: TrinaColumnType.text(),
      );

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaColumnFilter(
              stateManager: stateManager,
              column: column,
            ),
          ),
        ),
      );

      // then
      await tester.enterText(find.byType(TextField), 'abc');

      verify(
        eventManager!.addEvent(
          argThat(
            TrinaObjectMatcher<TrinaGridChangeColumnFilterEvent>(
              rule: (object) {
                return object.column.field == column.field &&
                    object.filterType.runtimeType == TrinaFilterTypeContains &&
                    object.filterValue == 'abc';
              },
            ),
          ),
        ),
      ).called(1);
    },
  );

  group('filter widget mode', () {
    Future<void> buildColumnFilter(
      WidgetTester tester,
      TrinaColumn column,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TrinaColumnFilter(
              stateManager: stateManager,
              column: column,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
    }

    testWidgets('A boolean column should render the boolean filter', (
      tester,
    ) async {
      await buildColumnFilter(
        tester,
        TrinaColumn(
          title: 'is_active',
          field: 'is_active',
          type: TrinaColumnType.boolean(),
        ),
      );

      expect(find.byType(BooleanColumnFilter), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('A select column should render the multi-select filter', (
      tester,
    ) async {
      await buildColumnFilter(
        tester,
        TrinaColumn(
          title: 'hobby',
          field: 'hobby',
          type: TrinaColumnType.select(['swimming', 'gym']),
        ),
      );

      expect(find.byType(MultiSelectColumnFilter), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets(
      'A select column with enableColumnFilter false should render the text field',
      (tester) async {
        await buildColumnFilter(
          tester,
          TrinaColumn(
            title: 'hobby',
            field: 'hobby',
            type: TrinaColumnType.select([
              'swimming',
              'gym',
            ], enableColumnFilter: false),
          ),
        );

        expect(find.byType(MultiSelectColumnFilter), findsNothing);
        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      'An explicit textField delegate should opt a boolean column out of the boolean filter',
      (tester) async {
        await buildColumnFilter(
          tester,
          TrinaColumn(
            title: 'is_active',
            field: 'is_active',
            type: TrinaColumnType.boolean(),
            filterWidgetDelegate:
                const TrinaFilterColumnWidgetDelegate.textField(),
          ),
        );

        expect(find.byType(BooleanColumnFilter), findsNothing);
        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      'A booleanSelect delegate should force the boolean filter on a text column',
      (tester) async {
        await buildColumnFilter(
          tester,
          TrinaColumn(
            title: 'name',
            field: 'name',
            type: TrinaColumnType.text(),
            filterWidgetDelegate:
                const TrinaFilterColumnWidgetDelegate.booleanSelect(),
          ),
        );

        expect(find.byType(BooleanColumnFilter), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
      },
    );

    testWidgets(
      'A multiSelect delegate should force the multi-select filter on a text column',
      (tester) async {
        await buildColumnFilter(
          tester,
          TrinaColumn(
            title: 'name',
            field: 'name',
            type: TrinaColumnType.text(),
            filterWidgetDelegate:
                const TrinaFilterColumnWidgetDelegate.multiSelect(
                  multiSelectItems: ['a', 'b'],
                ),
          ),
        );

        expect(find.byType(MultiSelectColumnFilter), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
      },
    );

    testWidgets(
      'Down / Enter keys should toggle the boolean filter dropdown',
      (tester) async {
        final column = TrinaColumn(
          title: 'is_active',
          field: 'is_active',
          type: TrinaColumnType.boolean(),
        );

        await buildColumnFilter(tester, column);

        // The Down / Enter / Space keys toggle the dropdown through the
        // shared focus node instead of moving the focus into the rows.
        final field = find.descendant(
          of: find.byType(FilterDropdownField),
          matching: find.byWidgetPredicate(
            (widget) => widget is Focus && widget.focusNode != null,
          ),
        );

        final focusNode = tester.widget<Focus>(field).focusNode!;

        focusNode.requestFocus();
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(find.text('True'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(find.text('True'), findsNothing);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        expect(find.text('True'), findsOneWidget);
      },
    );

    testWidgets(
      'A boolean filter selection should dispatch an immediate Equals event',
      (tester) async {
        final column = TrinaColumn(
          title: 'is_active',
          field: 'is_active',
          type: TrinaColumnType.boolean(),
        );

        await buildColumnFilter(tester, column);

        await tester.tap(
          find.descendant(
            of: find.byType(BooleanColumnFilter),
            matching: find.byIcon(Icons.arrow_drop_down),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('True'));
        await tester.pumpAndSettle();

        verify(
          eventManager!.addEvent(
            argThat(
              TrinaObjectMatcher<TrinaGridChangeColumnFilterEvent>(
                rule: (object) {
                  return object.column.field == column.field &&
                      object.filterType.runtimeType == TrinaFilterTypeEquals &&
                      object.filterValue == 'true' &&
                      object.type == TrinaGridEventType.normal;
                },
              ),
            ),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'A multi-select filter toggle should dispatch an immediate MultiItems event',
      (tester) async {
        final column = TrinaColumn(
          title: 'hobby',
          field: 'hobby',
          type: TrinaColumnType.select(['swimming', 'gym']),
        );

        await buildColumnFilter(tester, column);

        await tester.tap(
          find.descendant(
            of: find.byType(MultiSelectColumnFilter),
            matching: find.byIcon(Icons.arrow_drop_down),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('swimming'));
        await tester.pumpAndSettle();

        verify(
          eventManager!.addEvent(
            argThat(
              TrinaObjectMatcher<TrinaGridChangeColumnFilterEvent>(
                rule: (object) {
                  return object.column.field == column.field &&
                      object.filterType.runtimeType ==
                          TrinaFilterTypeMultiItems &&
                      object.filterValue == 'swimming' &&
                      object.type == TrinaGridEventType.normal;
                },
              ),
            ),
          ),
        ).called(1);
      },
    );
  });

  group('enabled', () {
    testWidgets(
      'If enableFilterMenuItem is false, TextField should be disabled',
      (WidgetTester tester) async {
        // given
        final TrinaColumn column = TrinaColumn(
          title: 'column title',
          field: 'column_field_name',
          type: TrinaColumnType.text(),
          enableFilterMenuItem: false,
        );

        // when
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaColumnFilter(
                stateManager: stateManager,
                column: column,
              ),
            ),
          ),
        );

        // then
        var textField = find.byType(TextField);

        var textFieldWidget = textField.evaluate().first.widget as TextField;

        expect(textFieldWidget.enabled, isFalse);
      },
    );

    testWidgets(
      'If enableFilterMenuItem is true and filterRows.length is 2 or more, TextField should be disabled',
      (WidgetTester tester) async {
        // given
        final TrinaColumn column = TrinaColumn(
          title: 'column title',
          field: 'column_field_name',
          type: TrinaColumnType.text(),
          enableFilterMenuItem: true,
        );

        when(stateManager.filterRowsByField('column_field_name')).thenReturn([
          FilterHelper.createFilterRow(columnField: 'column_field_name'),
          FilterHelper.createFilterRow(columnField: 'column_field_name'),
        ]);

        // when
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaColumnFilter(
                stateManager: stateManager,
                column: column,
              ),
            ),
          ),
        );

        // then
        var textField = find.byType(TextField);

        var textFieldWidget = textField.evaluate().first.widget as TextField;

        expect(textFieldWidget.enabled, isFalse);
      },
    );

    testWidgets(
      'If enableFilterMenuItem is true and filterRows.length is less than 2 and filterRows contains filterFieldAllColumns, TextField should be disabled',
      (WidgetTester tester) async {
        // given
        final TrinaColumn column = TrinaColumn(
          title: 'column title',
          field: 'column_field_name',
          type: TrinaColumnType.text(),
          enableFilterMenuItem: true,
        );

        when(stateManager.filterRowsByField(any)).thenReturn([
          FilterHelper.createFilterRow(
            columnField: FilterHelper.filterFieldAllColumns,
          ),
        ]);

        // when
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaColumnFilter(
                stateManager: stateManager,
                column: column,
              ),
            ),
          ),
        );

        // then
        var textField = find.byType(TextField);

        var textFieldWidget = textField.evaluate().first.widget as TextField;

        expect(textFieldWidget.enabled, isFalse);
      },
    );

    testWidgets(
      'If enableFilterMenuItem is true and filterRows.length is less than 2 and filterRows does not contain filterFieldAllColumns, TextField should be enabled',
      (WidgetTester tester) async {
        // given
        final TrinaColumn column = TrinaColumn(
          title: 'column title',
          field: 'column_field_name',
          type: TrinaColumnType.text(),
          enableFilterMenuItem: true,
        );

        when(stateManager.filterRowsByField('column_field_name')).thenReturn([
          FilterHelper.createFilterRow(columnField: 'column_field_name'),
        ]);

        when(
          stateManager.filterRowsByField(FilterHelper.filterFieldAllColumns),
        ).thenReturn([]);

        // when
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaColumnFilter(
                stateManager: stateManager,
                column: column,
              ),
            ),
          ),
        );

        // then
        var textField = find.byType(TextField);

        var textFieldWidget = textField.evaluate().first.widget as TextField;

        expect(textFieldWidget.enabled, isTrue);
      },
    );
  });
}
