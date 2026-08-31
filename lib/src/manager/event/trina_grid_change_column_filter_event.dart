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

    // Update both the value and the type of the existing filter row.
    // The type must be refreshed as well, otherwise a row previously created
    // with a different type (e.g. Contains via the filter popup or a
    // programmatic setColumnFilter call) would keep comparing with the old
    // semantics.
    foundFilterRows.first.cells[FilterHelper.filterFieldValue]!.value =
        filterValue;
    foundFilterRows.first.cells[FilterHelper.filterFieldType]!.value =
        filterType;

    return stateManager.filterRows;
  }

  @override
  void handler(TrinaGridStateManager stateManager) {
    stateManager.setFilterWithFilterRows(_getFilterRows(stateManager));
  }
}
