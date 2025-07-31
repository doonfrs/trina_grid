import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

abstract class PopupCell extends StatefulWidget {
  final TrinaGridStateManager stateManager;

  final TrinaCell cell;

  final TrinaColumn column;

  final TrinaRow row;

  const PopupCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });
}

abstract interface class PopupCellProps {
  IconData? get popupMenuIcon;

  void openPopup(BuildContext context);
  void closePopup(BuildContext context);

  abstract final Widget defaultEditWidget;
}

mixin PopupCellState<T extends PopupCell> on State<T>
    implements PopupCellProps {
  late final TextEditingController textController;
  late final FocusNode textFocus;

  KeyEventResult handleOpeningPopupWithKeyboard(
    FocusNode node,
    KeyEvent event,
    bool isPopupOpen,
  ) {
    final trinaKeyEvent = TrinaKeyManagerEvent(focusNode: node, event: event);

    // If the column is readOnly, do not open the popup.
    if (widget.column.readOnly) {
      node.unfocus();
      return KeyEventResult.ignored;
    }

    if (trinaKeyEvent.isF2 || trinaKeyEvent.isSpace) {
      isPopupOpen ? null : openPopup(context);

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  initState() {
    super.initState();

    textController = TextEditingController()
      ..text = widget.column.formattedValueForDisplayInEditing(
        widget.cell.value,
      );

    textFocus = FocusNode();
  }

  @override
  void dispose() {
    textController.dispose();
    textFocus.dispose();
    super.dispose();
  }

  void handleSelected(dynamic value) {
    widget.stateManager.handleAfterSelectingRow(widget.cell, value);

    textController.text = widget.column.formattedValueForDisplayInEditing(
      widget.cell.value,
    );

    widget.stateManager.setEditing(false);

    if (!widget.stateManager.configuration.enableMoveDownAfterSelecting) {
      textFocus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stateManager.keepFocus) {
      textFocus.requestFocus();
    }
    if (widget.column.editCellRenderer != null) {
      return widget.column.editCellRenderer!(
        defaultEditWidget,
        widget.cell,
        textController,
        textFocus,
        handleSelected,
      );
    } else if (widget.stateManager.editCellRenderer != null) {
      return widget.stateManager.editCellRenderer!(
        defaultEditWidget,
        widget.cell,
        textController,
        textFocus,
        handleSelected,
      );
    }
    return defaultEditWidget;
  }
}
