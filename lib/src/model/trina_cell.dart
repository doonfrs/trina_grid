import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

typedef TrinaCellRenderer = Widget Function(
    TrinaCellRendererContext rendererContext);

class TrinaCellRendererContext {
  final TrinaColumn column;

  final int rowIdx;

  final TrinaRow row;

  final TrinaCell cell;

  final TrinaGridStateManager stateManager;

  TrinaCellRendererContext({
    required this.column,
    required this.rowIdx,
    required this.row,
    required this.cell,
    required this.stateManager,
  });
}

class TrinaCell {
  /// Creates a cell with an optional initial value, key, renderer, onChanged callback, and onKeyPressed callback.
  ///
  /// The [value] parameter sets the initial value of the cell.
  /// The [key] parameter provides a unique identifier for the cell.
  /// The [renderer] parameter allows for custom rendering of the cell.
  /// The [onChanged] parameter allows for cell-level control over value changes.
  /// The [onKeyPressed] parameter allows for capturing keyboard events in the cell.
  TrinaCell({dynamic value, Key? key, this.renderer, this.onChanged, this.onKeyPressed, this.padding})
      : _key = key ?? UniqueKey(),
        _value = value,
        _originalValue = value,
        _oldValue = null;

  final Key _key;

  dynamic _value;

  final dynamic _originalValue;

  /// Stores the old value when change tracking is enabled
  dynamic _oldValue;

  /// Whether or not we are tracking changes
  bool _isTracking = false;

  dynamic _valueForSorting;

  /// Custom renderer for this specific cell.
  /// If provided, this will be used instead of the column renderer.
  final TrinaCellRenderer? renderer;

  /// Callback that is triggered when this specific cell's value is changed.
  /// This allows for cell-level control over value changes.
  final TrinaOnChangedEventCallback? onChanged;

  /// Callback that is triggered when a key is pressed in this specific cell.
  /// This allows for capturing keyboard events like Enter, Tab, Escape, etc.
  final TrinaOnKeyPressedEventCallback? onKeyPressed;

  /// Custom padding for this specific cell.
  /// If provided, this will override the column padding and default padding.
  final EdgeInsets? padding;

  /// Returns true if this cell has a custom renderer.
  bool get hasRenderer => renderer != null;

  /// Set initial value according to [TrinaColumn] setting.
  ///
  /// [setColumn] is called when [TrinaGridStateManager.initializeRows] is called.
  /// When [setColumn] is called, this value is changed to `true` according to the column setting.
  /// If this value is `true` when the getter of [TrinaCell.value] is called,
  /// it calls [_applyFormatOnInit] to update the value according to the format.
  /// [_applyFormatOnInit] is called once, and if [setColumn] is not called again,
  /// it is not called anymore.
  bool _needToApplyFormatOnInit = false;

  TrinaColumn? _column;

  TrinaRow? _row;

  Key get key => _key;

  bool get initialized => _column != null && _row != null;

  TrinaColumn get column {
    _assertUnInitializedCell(_column != null);

    return _column!;
  }

  TrinaRow get row {
    _assertUnInitializedCell(_row != null);

    return _row!;
  }

  dynamic get value {
    if (_needToApplyFormatOnInit) {
      _applyFormatOnInit();
    }

    return _value;
  }

  dynamic get originalValue {
    return _originalValue;
  }

  /// Returns the old value before the change
  dynamic get oldValue {
    return _oldValue;
  }

  /// Returns true if the cell has uncommitted changes
  bool get isDirty {
    // The logic is now simple: are we tracking, and are the values different?
    return _isTracking && _value != _oldValue;
  }

  /// Commit changes by accepting the new value and stopping tracking.
  void commitChanges() {
    _oldValue = null;
    _isTracking = false;
  }

  /// Revert changes by restoring the old value and stopping tracking.
  void revertChanges() {
    if (_isTracking) {
      // Only revert if a change was being tracked
      _value = _oldValue;
      _oldValue = null;
      _isTracking = false;
    }
  }

  set value(dynamic changed) {
    if (_value == changed) {
      return;
    }
    _value = changed;
  }

  /// Helper method to store the old value when change tracking is enabled
  void trackChange() {
    if (!_isTracking) {
      _isTracking = true;
      _oldValue = _value;
    }
  }

  dynamic get valueForSorting {
    _valueForSorting ??= _getValueForSorting();

    return _valueForSorting;
  }

  void setColumn(TrinaColumn column) {
    _column = column;
    _valueForSorting = _getValueForSorting();
    _needToApplyFormatOnInit = _column?.type.applyFormatOnInit == true;
  }

  void setRow(TrinaRow row) {
    _row = row;
  }

  dynamic _getValueForSorting() {
    if (_column == null) {
      return _value;
    }

    if (_needToApplyFormatOnInit) {
      _applyFormatOnInit();
    }

    return _column!.type.makeCompareValue(_value);
  }

  void _applyFormatOnInit() {
    _value = _column!.type.applyFormat(_value);

    if (_column!.type is TrinaColumnTypeWithNumberFormat) {
      _value = (_column!.type as TrinaColumnTypeWithNumberFormat).toNumber(
        _value,
      );
    }

    _needToApplyFormatOnInit = false;
  }
}

void _assertUnInitializedCell(bool flag) {
  assert(
    flag,
    'TrinaCell is not initialized.'
    'When adding a column or row, if it is not added through TrinaGridStateManager, '
    'TrinaCell does not set the necessary information at runtime.'
    'If you add a column or row through TrinaGridStateManager and this error occurs, '
    'please contact Github issue.',
  );
}
