import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/src/widgets/multi_line_column_filter.dart';
import 'package:trina_grid/trina_grid.dart';

import '../ui.dart';

class TrinaColumnFilter extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  final TrinaColumn column;

  TrinaColumnFilter({
    required this.stateManager,
    required this.column,
    Key? key,
  }) : super(key: ValueKey('column_filter_${column.key}'));

  @override
  TrinaColumnFilterState createState() => TrinaColumnFilterState();
}

class TrinaColumnFilterState extends TrinaStateWithChange<TrinaColumnFilter> {
  List<TrinaRow> _filterRows = [];

  String _text = '';

  bool _enabled = false;

  late final StreamSubscription _event;

  late final FocusNode _focusNode;

  late final TextEditingController _controller;

  String get _filterValue {
    return _filterRows.isEmpty
        ? ''
        : _filterRows.first.cells[FilterHelper.filterFieldValue]!.value
            .toString();
  }

  bool get _hasCompositeFilter {
    return _filterRows.length > 1 ||
        stateManager
            .filterRowsByField(FilterHelper.filterFieldAllColumns)
            .isNotEmpty;
  }

  InputBorder get _border => OutlineInputBorder(
        borderSide: BorderSide(
            color: stateManager.configuration.style.borderColor, width: 0.0),
        borderRadius: BorderRadius.zero,
      );

  InputBorder get _enabledBorder => OutlineInputBorder(
        borderSide: BorderSide(
            color: stateManager.configuration.style.activatedBorderColor,
            width: 0.0),
        borderRadius: BorderRadius.zero,
      );

  InputBorder get _disabledBorder => OutlineInputBorder(
        borderSide: BorderSide(
            color: stateManager.configuration.style.inactivatedBorderColor,
            width: 0.0),
        borderRadius: BorderRadius.zero,
      );

  Color get _textFieldColor =>
      stateManager.configuration.style.filterHeaderColor ??
      (_enabled
          ? stateManager.configuration.style.cellColorInEditState
          : stateManager.configuration.style.cellColorInReadOnlyState);

  EdgeInsets get _padding =>
      widget.column.filterPadding ??
      stateManager.configuration.style.defaultColumnFilterPadding;

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  initState() {
    super.initState();

    _focusNode = FocusNode(onKeyEvent: _handleOnKey);

    widget.column.setFilterFocusNode(_focusNode);

    _controller = TextEditingController(text: _filterValue);

    _event = stateManager.eventManager!.listener(_handleFocusFromRows);

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  dispose() {
    _event.cancel();

    _controller.dispose();

    _focusNode.dispose();

    super.dispose();
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _filterRows = update<List<TrinaRow>>(
      _filterRows,
      stateManager.filterRowsByField(widget.column.field),
      compare: listEquals,
    );

    if (_focusNode.hasPrimaryFocus != true) {
      _text = update<String>(_text, _filterValue);

      if (changed) {
        _controller.text = _text;
      }
    }

    _enabled = update<bool>(
      _enabled,
      widget.column.enableFilterMenuItem && !_hasCompositeFilter,
    );
  }

  void _moveDown({required bool focusToPreviousCell}) {
    if (!focusToPreviousCell || stateManager.currentCell == null) {
      stateManager.setCurrentCell(
        stateManager.refRows.first.cells[widget.column.field],
        0,
        notify: false,
      );

      stateManager.scrollByDirection(TrinaMoveDirection.down, 0);
    }

    stateManager.setKeepFocus(true, notify: false);

    stateManager.gridFocusNode.requestFocus();

    stateManager.notifyListeners();
  }

  KeyEventResult _handleOnKey(FocusNode node, KeyEvent event) {
    var keyManager = TrinaKeyManagerEvent(
      focusNode: node,
      event: event,
    );

    // Check if column has a specific filter enter key action
    final enterKeyAction = widget.column.filterEnterKeyAction ??
        stateManager.configuration.enterKeyAction;

    if (enterKeyAction.isNone) {
      return KeyEventResult.ignored;
    }

    if (keyManager.isKeyUpEvent) {
      return KeyEventResult.handled;
    }
    // If it's Enter key and the action is none, handle it here
    if (keyManager.isEnter && enterKeyAction.isNone) {
      return KeyEventResult.ignored;
    }

    final handleMoveDown = (keyManager.isDown ||
            (keyManager.isEnter && !enterKeyAction.isNone) ||
            keyManager.isEsc) &&
        stateManager.refRows.isNotEmpty;

    final handleMoveHorizontal = keyManager.isTab ||
        (_controller.text.isEmpty && keyManager.isHorizontal);

    final skip = !(handleMoveDown || handleMoveHorizontal || keyManager.isF3);

    if (skip) {
      if (keyManager.isUp) {
        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    }

    if (handleMoveDown) {
      _moveDown(focusToPreviousCell: keyManager.isEsc);
    } else if (handleMoveHorizontal) {
      stateManager.nextFocusOfColumnFilter(
        widget.column,
        reversed: keyManager.isLeft || keyManager.isShiftPressed,
      );
    } else if (keyManager.isF3) {
      stateManager.showFilterPopup(
        _focusNode.context!,
        calledColumn: widget.column,
        onClosed: () {
          stateManager.setKeepFocus(true, notify: false);
          _focusNode.requestFocus();
        },
      );
    }

    return KeyEventResult.handled;
  }

  void _handleFocusFromRows(TrinaGridEvent trinaEvent) {
    if (!_enabled) {
      return;
    }

    if (trinaEvent is TrinaGridCannotMoveCurrentCellEvent &&
        trinaEvent.direction.isUp) {
      var isCurrentColumn = widget
              .stateManager
              .refColumns[stateManager.columnIndexesByShowFrozen[
                  trinaEvent.cellPosition.columnIdx!]]
              .key ==
          widget.column.key;

      if (isCurrentColumn) {
        stateManager.clearCurrentCell(notify: false);
        stateManager.setKeepFocus(false);
        _focusNode.requestFocus();
      }
    }
  }

  void _handleOnTap() {
    stateManager.setKeepFocus(false);
  }

  void _handleOnChanged(dynamic changed) {
    stateManager.eventManager!.addEvent(
      TrinaGridChangeColumnFilterEvent(
        column: widget.column,
        filterType: widget.column.defaultFilter,
        filterValue: changed,
        eventType: TrinaGridEventType.debounce,
        debounceMilliseconds:
            stateManager.configuration.columnFilter.debounceMilliseconds,
      ),
    );
  }

  void _handleOnEditingComplete() {
    // empty for ignore event of OnEditingComplete.
  }

  @override
  Widget build(BuildContext context) {
    final style = stateManager.style;
    final filterDelegate = widget.column.filterWidgetDelegate;

    Widget? suffixIcon;

    if (filterDelegate?.filterSuffixIcon != null) {
      suffixIcon = InkWell(
        onTap: () {
          filterDelegate?.onFilterSuffixTap?.call(
            _focusNode,
            _controller,
            _enabled,
            _handleOnChanged,
            stateManager,
          );
        },
        child: filterDelegate?.filterSuffixIcon,
      );
    }

    final clearIcon = InkWell(
      onTap: () {
        _controller.clear();
        _handleOnChanged(_controller.text);
        filterDelegate?.onClear?.call();
      },
      child: filterDelegate?.clearIcon,
    );

    if (filterDelegate?.onClear != null) {
      if (suffixIcon == null) {
        suffixIcon = clearIcon;
      } else {
        suffixIcon = Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            suffixIcon,
            clearIcon,
            SizedBox(width: 4),
          ],
        );
      }
    }

    Widget? w = filterDelegate?.filterWidgetBuilder?.call(
        _focusNode, _controller, _enabled, _handleOnChanged, stateManager);

    if (filterDelegate?.isMultiItems == true) {
      w = MultiLineColumnFilter(
        focusNode: _focusNode,
        controller: _controller,
        handleOnChanged: _handleOnChanged,
        stateManager: stateManager,
      );
    } else {
      w ??= TextField(
        focusNode: _focusNode,
        controller: _controller,
        enabled: _enabled,
        style: style.cellTextStyle,
        onTap: _handleOnTap,
        onChanged: _handleOnChanged,
        onEditingComplete: _handleOnEditingComplete,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          hintText: filterDelegate?.filterHintText ??
              (_enabled ? widget.column.defaultFilter.title : ''),
          filled: true,
          hintStyle: TextStyle(color: filterDelegate?.filterHintTextColor),
          fillColor: _textFieldColor,
          border: _border,
          enabledBorder: _border,
          disabledBorder: _disabledBorder,
          focusedBorder: _enabledBorder,
          contentPadding: const EdgeInsets.all(5),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.filterHeaderColor,
        border: BorderDirectional(
          top: BorderSide(color: style.borderColor),
          end: style.enableColumnBorderVertical
              ? BorderSide(color: style.borderColor)
              : BorderSide.none,
        ),
      ),
      child: w,
    );
  }
}
