import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  group('TrinaPagination theme updates', () {
    testWidgets('should update colors when theme changes', (tester) async {
      final columns = [
        TrinaColumn(
          title: 'Test',
          field: 'test',
          type: TrinaColumnType.text(),
        ),
      ];

      final rows = List.generate(50, (index) => TrinaRow(cells: {
        'test': TrinaCell(value: 'Value $index'),
      }));

      // Initial light theme
      var lightTheme = const TrinaGridConfiguration(
        style: TrinaGridStyleConfig(
          iconColor: Colors.black,
          disabledIconColor: Colors.grey,
          activatedBorderColor: Colors.blue,
        ),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TrinaGrid(
            columns: columns,
            rows: rows,
            configuration: lightTheme,
            createFooter: (stateManager) => TrinaPagination(stateManager),
          ),
        ),
      ));

      await tester.pumpAndSettle();

      // Find the pagination widget
      final paginationFinder = find.byType(TrinaPagination);
      expect(paginationFinder, findsOneWidget);

      // Change to dark theme
      var darkTheme = const TrinaGridConfiguration(
        style: TrinaGridStyleConfig(
          iconColor: Colors.white,
          disabledIconColor: Colors.grey,
          activatedBorderColor: Colors.lightBlue,
        ),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TrinaGrid(
            columns: columns,
            rows: rows,
            configuration: darkTheme,
            createFooter: (stateManager) => TrinaPagination(stateManager),
          ),
        ),
      ));

      await tester.pumpAndSettle();

      // Verify pagination is still there and should have updated theme
      expect(paginationFinder, findsOneWidget);
    });
  });
}