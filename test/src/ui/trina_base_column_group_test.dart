import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';
import 'package:rxdart/rxdart.dart';

import '../../helper/column_helper.dart';
import '../../helper/trina_widget_test_helper.dart';
import '../../mock/shared_mocks.mocks.dart';

void main() {
  MockTrinaGridStateManager? stateManager;

  late PublishSubject<TrinaNotifierEvent> subject;

  const columnHeight = TrinaGridSettings.rowHeight;

  final resizingNotifier = ChangeNotifier();

  setUp(() {
    stateManager = MockTrinaGridStateManager();

    subject = PublishSubject<TrinaNotifierEvent>();

    const configuration = TrinaGridConfiguration();

    when(stateManager!.configuration).thenReturn(configuration);

    when(stateManager!.style).thenReturn(configuration.style);

    when(stateManager!.streamNotifier).thenAnswer((_) => subject);

    when(stateManager!.resizingChangeNotifier).thenReturn(resizingNotifier);

    when(stateManager!.showFrozenColumn).thenReturn(false);

    when(stateManager!.textDirection).thenReturn(TextDirection.ltr);

    when(stateManager!.isRTL).thenReturn(false);

    when(stateManager!.columnGroupDepth(any)).thenAnswer((realInvocation) {
      return TrinaColumnGroupHelper.maxDepth(
        columnGroupList:
            realInvocation.positionalArguments[0] as List<TrinaColumnGroup>,
      );
    });

    when(
      stateManager!.separateLinkedGroup(
        columnGroupList: anyNamed('columnGroupList'),
        columns: anyNamed('columns'),
      ),
    ).thenAnswer((realInvocation) {
      return TrinaColumnGroupHelper.separateLinkedGroup(
        columnGroupList:
            realInvocation.namedArguments[const Symbol('columnGroupList')]
                as List<TrinaColumnGroup>,
        columns:
            realInvocation.namedArguments[const Symbol('columns')]
                as List<TrinaColumn>,
      );
    });
  });

  tearDown(() {
    subject.close();
  });

  buildWidget({
    required TrinaColumnGroupPair columnGroup,
    required int depth,
    bool showColumnFilter = false,
    bool isFilteredColumn = false,
  }) {
    return TrinaWidgetTestHelper('build base column group.', (tester) async {
      when(stateManager!.columnHeight).thenReturn(columnHeight);
      when(stateManager!.showColumnFilter).thenReturn(showColumnFilter);
      when(stateManager!.isFilteredColumn(any)).thenReturn(isFilteredColumn);
      when(stateManager!.columnFilterHeight).thenReturn(columnHeight);
      when(stateManager!.rowHeight).thenReturn(45);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: SizedBox(
              width: 1920,
              height: 1080,
              child: TrinaBaseColumnGroup(
                stateManager: stateManager!,
                columnGroup: columnGroup,
                depth: depth,
              ),
            ),
          ),
        ),
      );
    });
  }

  buildWidget(
    columnGroup: TrinaColumnGroupPair(
      group: TrinaColumnGroup(
        title: 'column group title',
        fields: ['column1'],
        expandedColumn: true,
      ),
      columns: ColumnHelper.textColumn('column', count: 1, start: 1),
    ),
    depth: 1,
  ).test('When expandedColumn is true and depth is 1, '
      'TrinaBaseColumn columnTitleHeight should be columnHeight * 2', (
    tester,
  ) async {
    final baseColumn = find.byType(TrinaBaseColumn);

    final baseColumnWidget =
        baseColumn.first.evaluate().first.widget as TrinaBaseColumn;

    expect(baseColumn, findsOneWidget);

    expect(baseColumnWidget.columnTitleHeight, columnHeight * 2);
  });

  buildWidget(
    columnGroup: TrinaColumnGroupPair(
      group: TrinaColumnGroup(
        title: 'column group title',
        fields: ['column1'],
        expandedColumn: true,
      ),
      columns: ColumnHelper.textColumn('column', count: 1, start: 1),
    ),
    depth: 3,
  ).test('When expandedColumn is true and depth is 3, '
      'TrinaBaseColumn columnTitleHeight should be columnHeight * 4', (
    tester,
  ) async {
    final baseColumn = find.byType(TrinaBaseColumn);

    final baseColumnWidget =
        baseColumn.first.evaluate().first.widget as TrinaBaseColumn;

    expect(baseColumn, findsOneWidget);

    expect(baseColumnWidget.columnTitleHeight, columnHeight * 4);
  });

  buildWidget(
    columnGroup: TrinaColumnGroupPair(
      group: TrinaColumnGroup(
        title: 'column group title',
        fields: ['column1'],
        expandedColumn: false,
      ),
      columns: ColumnHelper.textColumn('column', count: 1, start: 1),
    ),
    depth: 1,
  ).test('When expandedColumn is false, '
      'group title should be displayed', (tester) async {
    final groupTitle = find.text('column group title');

    final columnTitle = find.text('column1');

    expect(groupTitle, findsOneWidget);

    expect(columnTitle, findsOneWidget);
  });

  buildWidget(
    columnGroup: TrinaColumnGroupPair(
      group: TrinaColumnGroup(
        title: 'column group title',
        fields: ['column1'],
        expandedColumn: false,
      ),
      columns: ColumnHelper.textColumn('column', count: 1, start: 1),
    ),
    depth: 3,
  ).test('When expandedColumn is false and depth is 3, '
      'group title widget height should be 3 * columnHeight', (tester) async {
    final groupTitle = find.text('column group title');

    final groupTitleWidget =
        find
                .ancestor(of: groupTitle, matching: find.byType(SizedBox))
                .first
                .evaluate()
                .first
                .widget
            as SizedBox;

    final columnTitle = find.text('column1');

    expect(groupTitle, findsOneWidget);

    expect(columnTitle, findsOneWidget);

    expect(groupTitleWidget.height, columnHeight * 3);
  });

  buildWidget(
    columnGroup: TrinaColumnGroupPair(
      group: TrinaColumnGroup(
        title: 'column group title',
        fields: ['column1'],
        expandedColumn: true,
      ),
      columns: ColumnHelper.textColumn('column', count: 1, start: 1),
    ),
    depth: 1,
  ).test('When expandedColumn is true, '
      'group title should not be displayed', (tester) async {
    final groupTitle = find.text('column group title');

    final columnTitle = find.text('column1');

    expect(groupTitle, findsNothing);

    expect(columnTitle, findsOneWidget);
  });

  buildWidget(
    columnGroup: TrinaColumnGroupPair(
      group: TrinaColumnGroup(
        title: 'main group',
        children: [
          TrinaColumnGroup(title: 'group a', fields: ['column1']),
          TrinaColumnGroup(
            title: 'group b',
            children: [
              TrinaColumnGroup(
                title: 'group b-1',
                fields: ['column2', 'column3'],
              ),
              TrinaColumnGroup(
                title: 'group b-2',
                fields: ['column4'],
                expandedColumn: true,
              ),
              TrinaColumnGroup(
                title: 'group b-3',
                children: [
                  TrinaColumnGroup(title: 'group b-3-1', fields: ['column5']),
                  TrinaColumnGroup(title: 'group b-3-2', fields: ['column6']),
                ],
              ),
            ],
          ),
        ],
        expandedColumn: false,
      ),
      columns: ColumnHelper.textColumn('column', count: 6, start: 1),
    ),
    depth: 4,
  ).test('All titles should be displayed except for expandedColumn group b-2', (
    tester,
  ) async {
    expect(find.text('main group'), findsOneWidget);
    expect(find.text('group a'), findsOneWidget);
    expect(find.text('group b'), findsOneWidget);
    expect(find.text('group b-1'), findsOneWidget);
    expect(find.text('group b-3'), findsOneWidget);
    expect(find.text('group b-3-1'), findsOneWidget);
    expect(find.text('group b-3-2'), findsOneWidget);

    expect(find.text('group b-2'), findsNothing);
  });
}
