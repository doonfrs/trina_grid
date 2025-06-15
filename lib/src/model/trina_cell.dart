import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

typedef TrinaCellRenderer = Widget Function(
    TrinaCellRendererContext rendererContext);

/// A unique value to indicate that the cell value is `null`.
final _nullValue = UniqueKey();

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
  /// Creates a cell with an optional initial value, key, renderer, and onChanged callback.
  ///
  /// The [value] parameter sets the initial value of the cell.
  /// The [key] parameter provides a unique identifier for the cell.
  /// The [renderer] parameter allows for custom rendering of the cell.
  /// The [onChanged] parameter allows for cell-level control over value changes.
  TrinaCell({dynamic value, Key? key, this.renderer, this.onChanged})
      : _key = key ?? UniqueKey(),
        _value = value,
        _originalValue = value,
        _oldValue = null;

  final Key _key;

  dynamic _value;

  final dynamic _originalValue;

  /// Stores the old value when change tracking is enabled
  dynamic _oldValue;

  dynamic _valueForSorting;

  /// Custom renderer for this specific cell.
  /// If provided, this will be used instead of the column renderer.
  final TrinaCellRenderer? renderer;

  /// Callback that is triggered when this specific cell's value is changed.
  /// This allows for cell-level control over value changes.
  final TrinaOnChangedEventCallback? onChanged;

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
    return _oldValue == _nullValue ? null : _oldValue;
  }

  /// Returns true if the cell has uncommitted changes
  bool get isDirty {
    return _oldValue != null && _value != _oldValue;
  }

  /// Commit changes by clearing the old value
  void commitChanges() {
    _oldValue = null;
  }

  /// Revert changes by restoring the old value
  void revertChanges() {
    if (_oldValue != null) {
      _value = _oldValue == _nullValue ? null : _oldValue;
      _oldValue = null;
    }
  }

  set value(dynamic changed) {
    if (_value == changed) {
      return;
    }
    if (changed == _oldValue) {
      _oldValue = null;
    }

    _value = changed;
  }

  /// Helper method to store the old value when change tracking is enabled
  void trackChange() {
    _oldValue ??= _value ?? _nullValue;
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

_assertUnInitializedCell(bool flag) {
  assert(
    flag,
    'TrinaCell is not initialized.'
    'When adding a column or row, if it is not added through TrinaGridStateManager, '
    'TrinaCell does not set the necessary information at runtime.'
    'If you add a column or row through TrinaGridStateManager and this error occurs, '
    'please contact Github issue.',
  );
}
