import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

abstract class IGridState {
  GlobalKey get gridKey;

  TrinaGridKeyManager? get keyManager;

  TrinaGridEventManager? get eventManager;

  TrinaGridConfiguration get configuration;

  TrinaGridMode get mode;

  TrinaOnChangedEventCallback? get onChanged;

  TrinaOnSelectedEventCallback? get onSelected;

  TrinaOnSortedEventCallback? get onSorted;

  TrinaOnRowCheckedEventCallback? get onRowChecked;

  TrinaOnRowDoubleTapEventCallback? get onRowDoubleTap;

  TrinaOnRowSecondaryTapEventCallback? get onRowSecondaryTap;

  TrinaOnRowEnterEventCallback? get onRowEnter;

  TrinaOnRowExitEventCallback? get onRowExit;

  TrinaOnRowsMovedEventCallback? get onRowsMoved;

  TrinaOnBeforeActiveCellChangeEventCallback? get onBeforeActiveCellChange;

  TrinaOnActiveCellChangedEventCallback? get onActiveCellChanged;

  TrinaOnColumnsMovedEventCallback? get onColumnsMoved;

  TrinaColumnMenuDelegate get columnMenuDelegate;

  CreateHeaderCallBack? get createHeader;

  CreateFooterCallBack? get createFooter;

  TrinaSelectDateCallBack? get selectDateCallback;

  TrinaGridLocaleText get localeText;

  TrinaGridStyleConfig get style;

  /// To delegate sort handling in the [TrinaInfinityScrollRows] or [TrinaLazyPagination] widget
  /// Whether to override the default sort processing.
  /// If this value is true,
  /// the default sorting processing of [TrinaGrid] is ignored and only events are issued.
  /// [TrinaGridChangeColumnSortEvent]
  bool get sortOnlyEvent;

  /// To delegate filtering processing in the [TrinaInfinityScrollRows] or [TrinaLazyPagination] widget
  /// Whether to override the default filtering processing.
  /// If this value is true,
  /// the default filtering processing of [TrinaGrid] is ignored and only events are issued.
  /// [TrinaGridSetColumnFilterEvent]
  bool get filterOnlyEvent;

  void setKeyManager(TrinaGridKeyManager keyManager);

  void setEventManager(TrinaGridEventManager eventManager);

  void setConfiguration(
    TrinaGridConfiguration configuration, {
    bool updateLocale = true,
    bool applyColumnFilter = true,
  });

  void setGridMode(TrinaGridMode mode);

  void resetCurrentState({bool notify = true});

  /// Event occurred after selecting Row in Select mode.
  void handleOnSelected();

  /// Set whether to ignore the default sort processing and issue only events.
  /// [TrinaGridChangeColumnSortEvent]
  void setSortOnlyEvent(bool flag);

  /// Set whether to ignore the basic filtering process and issue only events.
  /// [TrinaGridSetColumnFilterEvent]
  void setFilterOnlyEvent(bool flag);
}

class _State {
  TrinaGridKeyManager? _keyManager;

  TrinaGridEventManager? _eventManager;

  TrinaGridConfiguration? _configuration;

  TrinaGridMode _mode = TrinaGridMode.normal;

  bool _sortOnlyEvent = false;

  bool _filterOnlyEvent = false;
}

mixin GridState implements ITrinaGridState {
  final _State _state = _State();

  @override
  TrinaGridKeyManager? get keyManager => _state._keyManager;

  @override
  TrinaGridEventManager? get eventManager => _state._eventManager;

  @override
  TrinaGridConfiguration get configuration => _state._configuration!;

  @override
  TrinaGridMode get mode => _state._mode;

  @override
  TrinaGridLocaleText get localeText => configuration.localeText;

  @override
  TrinaGridStyleConfig get style => configuration.style;

  @override
  bool get sortOnlyEvent => _state._sortOnlyEvent;

  @override
  bool get filterOnlyEvent => _state._filterOnlyEvent;

  @override
  void setKeyManager(TrinaGridKeyManager? keyManager) {
    _state._keyManager = keyManager;
  }

  @override
  void setEventManager(TrinaGridEventManager? eventManager) {
    _state._eventManager = eventManager;
  }

  @override
  void setConfiguration(
    TrinaGridConfiguration configuration, {
    bool updateLocale = true,
    bool applyColumnFilter = true,
  }) {
    if (_state._configuration == configuration) return;

    _state._configuration = configuration;

    if (updateLocale) {
      _state._configuration!.updateLocale();
    }

    if (applyColumnFilter) {
      _state._configuration!.applyColumnFilter(refColumns.originalList);
    }

    // Apply selectingMode from configuration for modes that allow it
    if (mode == TrinaGridMode.normal ||
        mode == TrinaGridMode.readOnly ||
        mode == TrinaGridMode.popup) {
      setSelectingMode(configuration.selectingMode, notify: false);
    }
  }

  @override
  void setGridMode(TrinaGridMode mode) {
    if (_state._mode == mode) return;

    _state._mode = mode;

    TrinaGridSelectingMode selectingMode;

    switch (mode) {
      case TrinaGridMode.normal:
      case TrinaGridMode.readOnly:
      case TrinaGridMode.popup:
        selectingMode = configuration.selectingMode;
        break;
      case TrinaGridMode.select:
      case TrinaGridMode.selectWithOneTap:
        selectingMode = TrinaGridSelectingMode.none;
        break;
      case TrinaGridMode.multiSelect:
        selectingMode = TrinaGridSelectingMode.row;
        break;
    }

    setSelectingMode(selectingMode);

    resetCurrentState();
  }

  @override
  void resetCurrentState({bool notify = true}) {
    clearCurrentCell(notify: false);

    clearCurrentSelecting(notify: false);

    setEditing(false, notify: false);

    notifyListeners(notify, resetCurrentState.hashCode);
  }

  @override
  void handleOnSelected() {
    _handleSelectCheckRowBehavior();
    // Allow onSelected callback to fire in normal mode as well as select modes
    if ((mode.isSelectMode || mode.isNormal) && onSelected != null) {
      onSelected!(
        TrinaGridOnSelectedEvent(
          row: currentRow,
          rowIdx: currentRowIdx,
          cell: currentCell,
          // Include currentSelectingRows when we have row selection in any mode
          selectedRows:
              (mode.isMultiSelectMode || (mode.isNormal && selectingMode.isRow))
              ? currentSelectingRows
              : null,
        ),
      );
    }
  }

  void _handleSelectCheckRowBehavior() {
    final stateManager = eventManager?.stateManager;
    if (currentRow == null || stateManager == null) return;
    final checkedRowsViaSelect = stateManager.checkedRowsViaSelect;
    switch (configuration.rowSelectionCheckBoxBehavior) {
      case TrinaGridRowSelectionCheckBoxBehavior.none:
        break;
      case TrinaGridRowSelectionCheckBoxBehavior.checkRow:
        stateManager.setRowChecked(currentRow!, true, checkedViaSelect: true);
        break;
      case TrinaGridRowSelectionCheckBoxBehavior.toggleCheckRow:
        if (checkedRowsViaSelect.contains(currentRow)) {
          stateManager.setRowChecked(
            currentRow!,
            (!(currentRow?.checked ?? false)),
            checkedViaSelect: true,
          );
        } else {
          eventManager!.stateManager.setRowChecked(
            currentRow!,
            (!(currentRow?.checked ?? true)),
            checkedViaSelect: true,
          );
        }
        break;
      case TrinaGridRowSelectionCheckBoxBehavior.singleRowCheck:
        for (var row in checkedRowsViaSelect) {
          row.setChecked(false);
        }
        currentRow!.setChecked(true, viaSelect: true);
        stateManager.notifyListeners();
        break;
      case TrinaGridRowSelectionCheckBoxBehavior.toggleSingleRowCheck:
        for (var row in checkedRowsViaSelect) {
          row.setChecked(false);
        }
        if (checkedRowsViaSelect.contains(currentRow)) {
          currentRow!.setChecked(false, viaSelect: false);
        } else {
          currentRow!.setChecked(true, viaSelect: true);
        }
        stateManager.notifyListeners();
        break;
    }
  }

  @override
  void setSortOnlyEvent(bool flag) {
    _state._sortOnlyEvent = flag;
  }

  @override
  void setFilterOnlyEvent(bool flag) {
    _state._filterOnlyEvent = flag;
  }
}
