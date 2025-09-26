import 'package:trina_grid/trina_grid.dart';

/// Event called when the value of the TextField
/// that handles the filter under the column changes.
class TrinaGridChangeColumnFilterEvent extends TrinaGridEvent {
  final TrinaColumn column;
  final TrinaFilterType filterType;
  final dynamic filterValue;
  final int? debounceMilliseconds;
  final TrinaGridEventType? eventType;

  TrinaGridChangeColumnFilterEvent({
    required this.column,
    required this.filterType,
    required this.filterValue,
    this.debounceMilliseconds,
    this.eventType,
  }) : super(
         type: eventType ?? TrinaGridEventType.normal,
         duration: Duration(
           milliseconds:
               debounceMilliseconds?.abs() ??
               TrinaGridSettings.debounceMillisecondsForColumnFilter,
         ),
       );

  List<TrinaRow> _getFilterRows(TrinaGridStateManager? stateManager) {
    List<TrinaRow> foundFilterRows = stateManager!.filterRowsByField(
      column.field,
    );

    if (foundFilterRows.isEmpty) {
      return [
        ...stateManager.filterRows,
        FilterHelper.createFilterRow(
          columnField: column.field,
          filterType: filterType,
          filterValue: filterValue,
        ),
      ];
    }

    foundFilterRows.first.cells[FilterHelper.filterFieldValue]!.value =
        filterValue;

    return stateManager.filterRows;
  }

  @override
  void handler(TrinaGridStateManager stateManager) {
    stateManager.setFilterWithFilterRows(_getFilterRows(stateManager));
  }
}
