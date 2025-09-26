import 'package:flutter/material.dart';
import 'package:trina_grid/src/helper/trina_general_helper.dart';
import 'package:trina_grid/src/model/trina_column_type_has_popup_icon.dart';
import 'package:trina_grid/src/ui/cells/trina_time_cell.dart';
import 'package:trina_grid/trina_grid.dart';

class TrinaColumnTypeTime
    with TrinaColumnTypeDefaultMixin
    implements TrinaColumnType, TrinaColumnTypeHasPopupIcon {
  @override
  final dynamic defaultValue;

  @override
  final IconData? popupIcon;

  final TrinaTimePickerAutoFocusMode autoFocusMode;

  final bool saveAndClosePopupWithEnter;

  final TimeOfDay minTime;

  final TimeOfDay maxTime;

  static const defaultMinTime = TimeOfDay(hour: 0, minute: 0);

  static const defaultMaxTime = TimeOfDay(hour: 23, minute: 59);

  TrinaColumnTypeTime({
    this.defaultValue,
    this.popupIcon,
    this.autoFocusMode = TrinaTimePickerAutoFocusMode.hourField,
    this.saveAndClosePopupWithEnter = true,
    this.minTime = defaultMinTime,
    this.maxTime = defaultMaxTime,
  }) : assert(
         maxTime.isAfter(minTime) || maxTime.isAtSameTimeAs(minTime),
         'maxTime must be after or at the same time as minTime',
       );

  static final _timeFormat = RegExp(r'^([0-1]?\d|2[0-3]):[0-5]\d$');

  @override
  bool isValid(dynamic value) {
    if (value == null) return false;
    final String timeString = value.toString();
    if (!_timeFormat.hasMatch(timeString)) {
      return false;
    }

    final parts = timeString.split(':');
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return false;
    }

    final TimeOfDay time = TimeOfDay(hour: hour, minute: minute);

    return (time.isAfter(minTime) && time.isBefore(maxTime)) ||
        time.isAtSameTimeAs(minTime) ||
        time.isAtSameTimeAs(maxTime);
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
    return v;
  }

  @override
  Widget buildCell(
    TrinaGridStateManager stateManager,
    TrinaCell cell,
    TrinaColumn column,
    TrinaRow row,
  ) {
    return TrinaTimeCell(
      stateManager: stateManager,
      cell: cell,
      column: column,
      row: row,
    );
  }
}
