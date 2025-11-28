import 'package:trina_grid/trina_grid.dart';

/// Event issued when columns are hidden or shown.
class TrinaGridColumnHiddenEvent extends TrinaGridEvent {
  TrinaGridColumnHiddenEvent({required this.columns, required this.isHidden});

  /// The columns that were hidden or shown.
  final List<TrinaColumn> columns;

  /// Whether the columns are hidden (true) or shown (false).
  final bool isHidden;

  @override
  void handler(TrinaGridStateManager stateManager) {}
}
