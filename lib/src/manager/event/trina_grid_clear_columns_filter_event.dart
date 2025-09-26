import 'package:trina_grid/trina_grid.dart';

/// Event to clear the provided columns there filter
class TrinaGridClearColumnsFilterEvent extends TrinaGridEvent {
  final Iterable<TrinaColumn>? columns;
  final int? debounceMilliseconds;
  final TrinaGridEventType? eventType;

  TrinaGridClearColumnsFilterEvent({
    this.columns,
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

  @override
  void handler(TrinaGridStateManager stateManager) {
    stateManager.setFilterWithFilterRows([]);
  }
}
