import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';
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
