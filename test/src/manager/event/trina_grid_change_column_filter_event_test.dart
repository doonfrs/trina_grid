import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late MockTrinaGridStateManager stateManager;
  late TrinaColumn column;

  setUp(() {
    stateManager = MockTrinaGridStateManager();

    column = TrinaColumn(
      title: 'column title',
      field: 'column_field_name',
      type: TrinaColumnType.text(),
    );
  });

  test(
    'When the column has no filter row, a new one is appended with the given type and value',
    () {
      when(stateManager.filterRowsByField(column.field)).thenReturn([]);
      when(stateManager.filterRows).thenReturn([]);

      final capturedRows = <List<TrinaRow>>[];

      when(stateManager.setFilterWithFilterRows(any)).thenAnswer((invocation) {
        capturedRows.add(
          invocation.positionalArguments.single as List<TrinaRow>,
        );
      });

      TrinaGridChangeColumnFilterEvent(
        column: column,
        filterType: const TrinaFilterTypeEquals(),
        filterValue: 'abc',
      ).handler(stateManager);

      expect(capturedRows, hasLength(1));
      expect(capturedRows.single, hasLength(1));
      expect(
        capturedRows.single.first.cells[FilterHelper.filterFieldValue]!.value,
        'abc',
      );
      expect(
        capturedRows.single.first.cells[FilterHelper.filterFieldType]!.value,
        isA<TrinaFilterTypeEquals>(),
      );
    },
  );

  test(
    'When the column already has a filter row, both its value and type are updated',
    () {
      final existing = FilterHelper.createFilterRow(
        columnField: column.field,
        filterType: const TrinaFilterTypeContains(),
        filterValue: 'old',
      );

      when(stateManager.filterRowsByField(column.field)).thenReturn([existing]);
      when(stateManager.filterRows).thenReturn([existing]);

      TrinaGridChangeColumnFilterEvent(
        column: column,
        filterType: const TrinaFilterTypeMultiItems(),
        filterValue: 'swimming\ngym',
      ).handler(stateManager);

      expect(
        existing.cells[FilterHelper.filterFieldValue]!.value,
        'swimming\ngym',
      );
      expect(
        existing.cells[FilterHelper.filterFieldType]!.value,
        isA<TrinaFilterTypeMultiItems>(),
      );

      verify(stateManager.setFilterWithFilterRows([existing])).called(1);
    },
  );
}
