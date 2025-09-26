import 'package:trina_grid/trina_grid.dart';

/// Event called when a row is dragged.
class TrinaGridDragRowsEvent extends TrinaGridEvent {
  final List<TrinaRow> rows;
  final int targetIdx;

  TrinaGridDragRowsEvent({required this.rows, required this.targetIdx});

  @override
  void handler(TrinaGridStateManager stateManager) async {
    stateManager.moveRowsByIndex(rows, targetIdx);
  }
}
