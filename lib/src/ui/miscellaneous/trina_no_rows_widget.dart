import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

import '../ui.dart';

class TrinaNoRowsWidget extends TrinaStatefulWidget {
  const TrinaNoRowsWidget({
    required this.stateManager,
    required this.child,
    super.key,
  });

  final TrinaGridStateManager stateManager;

  final Widget child;

  @override
  TrinaStateWithChange<TrinaNoRowsWidget> createState() =>
      _TrinaNoRowsWidgetState();
}

class _TrinaNoRowsWidgetState extends TrinaStateWithChange<TrinaNoRowsWidget> {
  bool _show = false;

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _show = update<bool>(
      _show,
      !stateManager.showLoading && stateManager.refRows.isEmpty,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _show ? widget.child : const SizedBox.shrink(),
    );
  }
}
