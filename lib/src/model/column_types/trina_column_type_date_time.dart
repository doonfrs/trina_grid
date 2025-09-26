import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:trina_grid/src/helper/trina_general_helper.dart';
import 'package:trina_grid/src/model/trina_column_type_has_date_format.dart';
import 'package:trina_grid/src/model/trina_column_type_has_popup_icon.dart';
import 'package:trina_grid/src/ui/cells/trina_date_time_cell.dart';
import 'package:trina_grid/trina_grid.dart';

class TrinaColumnTypeDateTime
    with TrinaColumnTypeDefaultMixin
    implements
        TrinaColumnType,
        TrinaColumnTypeHasFormat<String>,
        TrinaColumnTypeHasDateFormat,
        TrinaColumnTypeHasPopupIcon {
  @override
  final dynamic defaultValue;

  final DateTime? startDate;

  final DateTime? endDate;

  @override
  final String format;

  @override
  final String headerFormat;

  @override
  final bool applyFormatOnInit;

  @override
  final IconData? popupIcon;

  TrinaColumnTypeDateTime({
    this.defaultValue,
    this.startDate,
    this.endDate,
    required this.format,
    required this.headerFormat,
    required this.applyFormatOnInit,
    this.popupIcon,
  }) : dateFormat = intl.DateFormat(format),
       headerDateFormat = intl.DateFormat(headerFormat);

  @override
  final intl.DateFormat dateFormat;

  @override
  final intl.DateFormat headerDateFormat;

  @override
  bool isValid(dynamic value) {
    if (value == null) return true;

    DateTime? parsedDateTime;
    if (value is DateTime) {
      parsedDateTime = value;
    } else {
      parsedDateTime = dateFormat.tryParse(value.toString());
    }

    if (parsedDateTime == null) return false;

    if (startDate != null && parsedDateTime.isBefore(startDate!)) return false;

    if (endDate != null && parsedDateTime.isAfter(endDate!)) return false;

    return true;
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
    if (v == null) return null;
    if (v is DateTime) return v;
    return dateFormat.tryParse(v.toString()) ?? DateTime.tryParse(v.toString());
  }

  @override
  String applyFormat(dynamic value) {
    if (value == null) return '';

    DateTime? date;
    if (value is DateTime) {
      date = value;
    } else {
      date =
          dateFormat.tryParse(value.toString()) ??
          DateTime.tryParse(value.toString());
    }

    if (date == null) return '';

    return dateFormat.format(date);
  }

  @override
  Widget buildCell(
    TrinaGridStateManager stateManager,
    TrinaCell cell,
    TrinaColumn column,
    TrinaRow row,
  ) {
    return TrinaDateTimeCell(
      stateManager: stateManager,
      cell: cell,
      column: column,
      row: row,
    );
  }
}
