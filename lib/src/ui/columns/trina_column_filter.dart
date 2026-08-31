import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/src/widgets/boolean_column_filter.dart';
import 'package:trina_grid/src/widgets/multi_line_column_filter.dart';
import 'package:trina_grid/src/widgets/multi_select_column_filter.dart';
import 'package:trina_grid/trina_grid.dart';

import '../ui.dart';

/// The widget mode the column filter renders, resolved from
/// [TrinaColumn.filterWidgetDelegate] and the column type.
enum _ColumnFilterMode { builder, multiItems, booleanSelect, multiSelect, text }

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

  /// Last value rendered by a dropdown filter mode, used to detect in-place
  /// mutations of the filter rows.
  String _dropdownFilterValue = '';

  bool _enabled = false;

  late final StreamSubscription _event;

  late final FocusNode _focusNode;

  late final TextEditingController _controller;

  /// Opens the dropdown of the boolean / multi-select filter modes.
  /// Also driven by Down / Enter / Space through [_handleOnKey].
  final MenuController _menuController = MenuController();

  _ColumnFilterMode get _filterMode {
    final delegate = widget.column.filterWidgetDelegate;

    if (delegate?.filterWidgetBuilder != null) {
      return _ColumnFilterMode.builder;
    }

    if (delegate?.isMultiItems == true) {
      return _ColumnFilterMode.multiItems;
    }

    if (delegate?.isBooleanSelect == true) {
      return _ColumnFilterMode.booleanSelect;
    }

    if (delegate?.isMultiSelect == true) {
      return _ColumnFilterMode.multiSelect;
    }

    // Any other explicitly set delegate (e.g. textField) opts out of the
    // automatic resolution below.
    if (delegate != null) {
      return _ColumnFilterMode.text;
    }

    final type = widget.column.type;

    if (type is TrinaColumnTypeBoolean) {
      return _ColumnFilterMode.booleanSelect;
    }

    if (type is TrinaColumnTypeSelect && type.enableColumnFilter) {
      return _ColumnFilterMode.multiSelect;
    }

    return _ColumnFilterMode.text;
  }

  bool get _isDropdownFilterMode {
    final mode = _filterMode;

    return mode == _ColumnFilterMode.booleanSelect ||
        mode == _ColumnFilterMode.multiSelect;
  }

  /// The items offered by the multi-select filter: the delegate items when
  /// provided, otherwise the values of a select column type.
  List<String> _resolveMultiSelectItems() {
    final delegateItems = widget.column.filterWidgetDelegate?.multiSelectItems;

    if (delegateItems != null) {
      return delegateItems;
    }

    final type = widget.column.type;

    if (type is TrinaColumnTypeSelect) {
      return type.items
          .map((item) => (type.itemToValue?.call(item) ?? item).toString())
          .toList();
    }

    return const <String>[];
  }

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
      color: stateManager.configuration.style.borderColor,
      width: 0.0,
    ),
    borderRadius: BorderRadius.zero,
  );

  InputBorder get _enabledBorder => OutlineInputBorder(
    borderSide: BorderSide(
      color: stateManager.configuration.style.activatedBorderColor,
      width: 0.0,
    ),
    borderRadius: BorderRadius.zero,
  );

  InputBorder get _disabledBorder => OutlineInputBorder(
    borderSide: BorderSide(
      color: stateManager.configuration.style.inactivatedBorderColor,
      width: 0.0,
    ),
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

    if (_isDropdownFilterMode) {
      // The filter rows are mutated in place by the change-filter event, so
      // track the raw value to detect external updates (e.g. a filter set
      // through the filter popup or programmatically).
      _dropdownFilterValue = update<String>(_dropdownFilterValue, _filterValue);
    }

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
    var keyManager = TrinaKeyManagerEvent(focusNode: node, event: event);

    // Dropdown filter modes: Down / Enter / Space toggles the dropdown
    // instead of moving the focus into the rows.
    if (_isDropdownFilterMode && _enabled) {
      final isMenuTriggerKey =
          keyManager.isDown || keyManager.isEnter || keyManager.isSpace;

      if (isMenuTriggerKey) {
        if (keyManager.isKeyUpEvent) {
          return KeyEventResult.handled;
        }

        _menuController.isOpen
            ? _menuController.close()
            : _menuController.open();

        return KeyEventResult.handled;
      }
    }

    // Check if column has a specific filter enter key action
    final enterKeyAction =
        widget.column.filterEnterKeyAction ??
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

    final handleMoveDown =
        (keyManager.isDown ||
            (keyManager.isEnter && !enterKeyAction.isNone) ||
            keyManager.isEsc) &&
        stateManager.refRows.isNotEmpty;

    final handleMoveHorizontal =
        keyManager.isTab ||
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
      var isCurrentColumn =
          widget
              .stateManager
              .refColumns[stateManager.columnIndexesByShowFrozen[trinaEvent
                  .cellPosition
                  .columnIdx!]]
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

  void _handleOnChanged(
    dynamic changed, {
    TrinaFilterType? filterType,
    bool immediate = false,
  }) {
    stateManager.eventManager!.addEvent(
      TrinaGridChangeColumnFilterEvent(
        column: widget.column,
        filterType: filterType ?? widget.column.defaultFilter,
        filterValue: changed,
        eventType: immediate
            ? TrinaGridEventType.normal
            : TrinaGridEventType.debounce,
        debounceMilliseconds: immediate
            ? 0
            : stateManager.configuration.columnFilter.debounceMilliseconds,
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
          children: [suffixIcon, clearIcon, SizedBox(width: 4)],
        );
      }
    }

    Widget? w = filterDelegate?.filterWidgetBuilder?.call(
      _focusNode,
      _controller,
      _enabled,
      _handleOnChanged,
      stateManager,
    );

    final mode = _filterMode;

    if (mode == _ColumnFilterMode.booleanSelect) {
      w = BooleanColumnFilter(
        stateManager: stateManager,
        column: widget.column,
        focusNode: _focusNode,
        menuController: _menuController,
        enabled: _enabled,
        filterValue: _filterValue,
        allLabel: stateManager.localeText.filterAll,
        trueLabel: stateManager.localeText.filterTrue,
        falseLabel: stateManager.localeText.filterFalse,
        onChanged: (value) => _handleOnChanged(
          value,
          filterType: const TrinaFilterTypeEquals(),
          immediate: true,
        ),
      );
    } else if (mode == _ColumnFilterMode.multiSelect) {
      final caseSensitive = filterDelegate?.caseSensitive ?? false;

      w = MultiSelectColumnFilter(
        stateManager: stateManager,
        column: widget.column,
        focusNode: _focusNode,
        menuController: _menuController,
        enabled: _enabled,
        filterValue: _filterValue,
        items: _resolveMultiSelectItems(),
        caseSensitive: caseSensitive,
        allLabel: stateManager.localeText.filterAll,
        selectAllLabel: stateManager.localeText.filterSelectAll,
        onChanged: (value) => _handleOnChanged(
          value,
          filterType: TrinaFilterTypeMultiItems(caseSensitive: caseSensitive),
          immediate: true,
        ),
      );
    } else if (mode == _ColumnFilterMode.multiItems) {
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
        keyboardType:
            filterDelegate?.keyboardType ??
            (widget.column.type is TrinaColumnTypeNumber ||
                    widget.column.type is TrinaColumnTypeCurrency ||
                    widget.column.type is TrinaColumnTypePercentage
                ? const TextInputType.numberWithOptions(decimal: true)
                : null),
        onTap: _handleOnTap,
        onChanged: _handleOnChanged,
        onEditingComplete: _handleOnEditingComplete,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          hintText:
              filterDelegate?.filterHintText ??
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

    return SizedBox(
      height: stateManager.columnFilterHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.filterHeaderColor,
          border: BorderDirectional(
            top: BorderSide(color: style.borderColor),
            end: style.enableColumnBorderVertical
                ? BorderSide(color: style.borderColor)
                : BorderSide.none,
          ),
        ),
        child: Padding(padding: _padding, child: w),
      ),
    );
  }
}
