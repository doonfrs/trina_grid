import 'package:flutter/material.dart';
import 'package:trina_grid/src/helper/trina_general_helper.dart';
import 'package:trina_grid/src/ui/cells/trina_text_cell.dart';
import 'package:trina_grid/trina_grid.dart';

class TrinaColumnTypeCustom
    with TrinaColumnTypeDefaultMixin
    implements TrinaColumnType {
  @override
  final dynamic defaultValue;

  final bool Function(dynamic value)? _isValidCallback;

  final int Function(dynamic a, dynamic b)? _compareCallback;

  final String Function(dynamic value)? _toDisplayStringCallback;

  const TrinaColumnTypeCustom({
    this.defaultValue,
    bool Function(dynamic value)? isValid,
    int Function(dynamic a, dynamic b)? compare,
    String Function(dynamic value)? toDisplayString,
  })  : _isValidCallback = isValid,
        _compareCallback = compare,
        _toDisplayStringCallback = toDisplayString;

  String toDisplayString(dynamic value) {
    if (_toDisplayStringCallback != null) {
      return _toDisplayStringCallback(value);
    }
    return value.toString();
  }

  @override
  bool isValid(dynamic value) {
    if (_isValidCallback != null) {
      return _isValidCallback(value);
    }
    return true;
  }

  @override
  int compare(dynamic a, dynamic b) {
    return TrinaGeneralHelper.compareWithNull(
      a,
      b,
      () {
        if (_compareCallback != null) {
          return _compareCallback(a, b);
        }
        return a.toString().compareTo(b.toString());
      },
    );
  }

  @override
  dynamic makeCompareValue(dynamic v) {
    return v;
  }

  @override
  Widget buildCell(
    TrinaGridStateManager stateManager,
    TrinaCell cell,
    TrinaColumn column,
    TrinaRow row,
  ) {
    return TrinaTextCell(
      stateManager: stateManager,
      cell: cell,
      column: column,
      row: row,
    );
  }
}
