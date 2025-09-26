import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:rxdart/rxdart.dart';

import '../../helper/trina_widget_test_helper.dart';
import '../../helper/test_helper_util.dart';
import '../../mock/shared_mocks.mocks.dart';

void main() {
  late MockTrinaGridStateManager stateManager;

  late PublishSubject<TrinaNotifierEvent> subject;

  setUp(() {
    stateManager = MockTrinaGridStateManager();
    subject = PublishSubject<TrinaNotifierEvent>();

    when(stateManager.configuration).thenReturn(const TrinaGridConfiguration());

    when(stateManager.footerHeight).thenReturn(45);

    when(stateManager.streamNotifier).thenAnswer((_) => subject);
  });

  tearDown(() {
    subject.close();
  });

  group('Rendering', () {
    buildWidget({int page = 1, int totalPage = 1, int? pageSizeToMove}) {
      return TrinaWidgetTestHelper('Tap cell', (tester) async {
        when(stateManager.page).thenReturn(page);
        when(stateManager.totalPage).thenReturn(totalPage);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: TrinaPagination(
                stateManager,
                pageSizeToMove: pageSizeToMove,
              ),
            ),
          ),
        );
      });
    }

    buildWidget().test('The page number should be rendered.', (tester) async {
      expect(find.text('1'), findsOneWidget);
    });

    buildWidget().test(
      'Four IconButton should be rendered. (First, Previous, Next, Last buttons)',
      (tester) async {
        expect(find.byType(IconButton), findsNWidgets(4));
      },
    );

    buildWidget(totalPage: 3).test(
      'When totalPage is 3, 3 TextButtons should be rendered.',
      (tester) async {
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(3));
      },
    );

    buildWidget(totalPage: 10).test(
      'When width is 449, 1 TextButton should be rendered.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 449,
          height: TrinaGridSettings.rowHeight,
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(1));
      },
    );

    buildWidget(totalPage: 10).test(
      'When width is 450, 3 TextButtons should be rendered.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 450,
          height: TrinaGridSettings.rowHeight,
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(3));
      },
    );

    buildWidget(totalPage: 10).test(
      'When width is 549, 3 TextButtons should be rendered.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 549,
          height: TrinaGridSettings.rowHeight,
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(3));
      },
    );

    buildWidget(totalPage: 10).test(
      'When width is 550, 5 TextButtons should be rendered.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 550,
          height: TrinaGridSettings.rowHeight,
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(5));
      },
    );

    buildWidget(totalPage: 10).test(
      'When width is 649, 5 TextButtons should be rendered.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 649,
          height: TrinaGridSettings.rowHeight,
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(5));
      },
    );

    buildWidget(totalPage: 10).test(
      'When width is 650, 7 TextButtons should be rendered.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 650,
          height: TrinaGridSettings.rowHeight,
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('6'), findsOneWidget);
        expect(find.text('7'), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(7));
      },
    );

    buildWidget(totalPage: 10).test(
      'When width is 1280, 7 TextButtons should be rendered.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 1280,
          height: TrinaGridSettings.rowHeight,
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('6'), findsOneWidget);
        expect(find.text('7'), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(7));
      },
    );

    buildWidget(totalPage: 10).test(
      'When the next page button is tapped, setPage should be called with 8.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 1280,
          height: TrinaGridSettings.rowHeight,
        );

        await tester.tap(find.byIcon(Icons.navigate_next));

        verify(stateManager.setPage(8)).called(1);
      },
    );

    buildWidget(totalPage: 10, pageSizeToMove: 1).test(
      'When pageSizeToMove is 1, the next page button is tapped, setPage should be called with 2.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 1280,
          height: TrinaGridSettings.rowHeight,
        );

        await tester.tap(find.byIcon(Icons.navigate_next));

        verify(stateManager.setPage(2)).called(1);
      },
    );

    buildWidget(page: 5, totalPage: 10, pageSizeToMove: 1).test(
      'When pageSizeToMove is 1, the previous page button is tapped, setPage should be called with 4.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 1280,
          height: TrinaGridSettings.rowHeight,
        );

        await tester.tap(find.byIcon(Icons.navigate_before));

        verify(stateManager.setPage(4)).called(1);
      },
    );
  });
}
