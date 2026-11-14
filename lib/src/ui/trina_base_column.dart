import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

import 'ui.dart';

class TrinaBaseColumn extends TrinaStatefulWidget
    implements TrinaVisibilityLayoutChild {
  final TrinaGridStateManager stateManager;

  final TrinaColumn column;

  final double? columnTitleHeight;

  TrinaBaseColumn({
    required this.stateManager,
    required this.column,
    this.columnTitleHeight,
  }) : super(key: column.key);

  @override
  TrinaBaseColumnState createState() => TrinaBaseColumnState();

  @override
  double get width => column.width;

  @override
  double get startPosition => column.startPosition;

  @override
  bool get keepAlive => false;
}

class TrinaBaseColumnState extends TrinaStateWithChange<TrinaBaseColumn> {
  bool _showColumnFilter = false;

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _showColumnFilter = update<bool>(
      _showColumnFilter,
      stateManager.showColumnFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: _showColumnFilter ? stateManager.columnFilterHeight : 0,
          child: TrinaColumnTitle(
            stateManager: stateManager,
            column: widget.column,
            height: widget.columnTitleHeight ?? stateManager.columnHeight,
          ),
        ),
        if (_showColumnFilter)
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: TrinaColumnFilter(
              stateManager: stateManager,
              column: widget.column,
            ),
          ),
      ],
    );
  }
}
