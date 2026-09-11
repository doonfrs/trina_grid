import 'package:trina_grid/trina_grid.dart';

/// Event called when the value of the TextField
/// that handles the filter under the column changes.
class TrinaGridChangeColumnFilterEvent extends TrinaGridEvent {
  final TrinaColumn column;
  final TrinaFilterType filterType;
  final dynamic filterValue;
  final int? debounceMilliseconds;
  final TrinaGridEventType? eventType;

  /// Whether [filterType] also replaces the type of an existing filter row.
  ///
  /// Defaults to false so the filter field only edits the value: a type the
  /// user picked in the filter popup, or set through
  /// [TrinaGridStateManager.setColumnFilter], survives typing in the column
  /// filter field.
  ///
  /// The dropdown filter widgets set this to true, because the value they
  /// send is only meaningful with the type they send it with.
  final bool updateFilterType;

  TrinaGridChangeColumnFilterEvent({
    required this.column,
    required this.filterType,
    required this.filterValue,
    this.debounceMilliseconds,
    this.eventType,
    this.updateFilterType = false,
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

    // The type is only refreshed when the sender asks for it. A row created
    // with another type (e.g. Contains through the filter popup, or a
    // programmatic setColumnFilter call) would otherwise keep comparing with
    // the old semantics for the dropdown filters, while the text field must
    // leave the type the user chose alone.
    if (updateFilterType) {
      foundFilterRows.first.cells[FilterHelper.filterFieldType]!.value =
          filterType;
    }

    return stateManager.filterRows;
  }

  @override
  void handler(TrinaGridStateManager stateManager) {
    stateManager.setFilterWithFilterRows(_getFilterRows(stateManager));
  }
}
