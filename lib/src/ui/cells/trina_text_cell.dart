import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

import 'text_cell.dart';

class TrinaTextCell extends StatefulWidget implements TextCell {
  @override
  final TrinaGridStateManager stateManager;

  @override
  final TrinaCell cell;

  @override
  final TrinaColumn column;

  @override
  final TrinaRow row;

  const TrinaTextCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  TrinaTextCellState createState() => TrinaTextCellState();
}

class TrinaTextCellState extends State<TrinaTextCell>
    with TextCellState<TrinaTextCell> {}
