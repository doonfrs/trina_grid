import 'package:flutter/material.dart';
import 'package:trina_grid/src/helper/trina_general_helper.dart';
import 'package:trina_grid/src/ui/cells/trina_text_cell.dart';
import 'package:trina_grid/trina_grid.dart';

class TrinaColumnTypeText
    with TrinaColumnTypeDefaultMixin
    implements TrinaColumnType {
  @override
  final dynamic defaultValue;

  const TrinaColumnTypeText({this.defaultValue});

  @override
  bool isValid(dynamic value) {
    return value is String || value is num;
  }

  @override
  int compare(dynamic a, dynamic b) {
    return TrinaGeneralHelper.compareWithNull(
      a,
      b,
      () => a.toString().compareTo(b.toString()),
    );
  }

  @override
  dynamic makeCompareValue(dynamic v) {
    return v.toString();
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
