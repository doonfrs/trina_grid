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

  // Cache for editCellRenderer callback result
  Widget? _cachedEditCellWidget;
  dynamic _cachedCellValueForEditRenderer;

  KeyEventResult handleOpeningPopupWithKeyboard(
    FocusNode node,
    KeyEvent event,
    bool isPopupOpen,
  ) {
    final trinaKeyEvent = TrinaKeyManagerEvent(focusNode: node, event: event);

    // Trigger onKeyPressed callback if it exists
    if (widget.cell.onKeyPressed != null && !trinaKeyEvent.isKeyUpEvent) {
      final keyEvent = TrinaGridOnKeyEvent(
        column: widget.column,
        row: widget.row,
        rowIdx: widget.stateManager.refRows.indexOf(widget.row),
        cell: widget.cell,
        event: event,
        isEnter: trinaKeyEvent.isEnter,
        isEscape: trinaKeyEvent.isEsc,
        isTab: trinaKeyEvent.isTab,
        isShiftPressed: trinaKeyEvent.isShiftPressed,
        isCtrlPressed: trinaKeyEvent.isCtrlPressed,
        isAltPressed: trinaKeyEvent.isAltPressed,
        logicalKey: event.logicalKey,
        currentValue: textController.text,
      );

      widget.cell.onKeyPressed!(keyEvent);
    }

    // If the column is readOnly, do not open the popup.
    if (widget.column.readOnly) {
      node.unfocus();
      return KeyEventResult.ignored;
    }

    if (trinaKeyEvent.isF2 || trinaKeyEvent.isSpace) {
      if (!isPopupOpen) {
        openPopup(context);
      }

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
    final customRenderer =
        widget.column.editCellRenderer ?? widget.stateManager.editCellRenderer;
    if (customRenderer != null) {
      // Cache the editCellRenderer result to avoid excessive callback executions
      if (_cachedCellValueForEditRenderer != widget.cell.value ||
          _cachedEditCellWidget == null) {
        _cachedCellValueForEditRenderer = widget.cell.value;
        _cachedEditCellWidget = customRenderer(
          defaultEditWidget,
          widget.cell,
          textController,
          textFocus,
          handleSelected,
        );
      }
      return _cachedEditCellWidget!;
    }
    return defaultEditWidget;
  }
}
