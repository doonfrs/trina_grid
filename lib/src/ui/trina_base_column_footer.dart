import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import 'ui.dart';

class TrinaBaseColumnFooter extends StatelessWidget
    implements TrinaVisibilityLayoutChild {
  final TrinaGridStateManager stateManager;

  final TrinaColumn column;

  TrinaBaseColumnFooter({required this.stateManager, required this.column})
    : super(key: column.key);

  @override
  double get width => column.width;

  @override
  double get startPosition => column.startPosition;

  @override
  bool get keepAlive => true;

  @override
  Widget build(BuildContext context) {
    final renderer = column.footerRenderer;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: column.backgroundColor,
        border: BorderDirectional(
          end: stateManager.style.enableColumnBorderVertical
              ? BorderSide(color: stateManager.style.borderColor, width: 1.0)
              : BorderSide.none,
        ),
      ),
      child: renderer == null
          ? const SizedBox()
          : renderer(
              TrinaColumnFooterRendererContext(
                column: column,
                stateManager: stateManager,
              ),
            ),
    );
  }
}
