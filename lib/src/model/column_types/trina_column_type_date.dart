import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:trina_grid/src/helper/trina_general_helper.dart';
import 'package:trina_grid/src/model/trina_column_type_has_date_format.dart';
import 'package:trina_grid/src/model/trina_column_type_has_popup_icon.dart';
import 'package:trina_grid/trina_grid.dart';

class TrinaColumnTypeDate
    with TrinaColumnTypeDefaultMixin
    implements
        TrinaColumnType,
        TrinaColumnTypeHasFormat<String>,
        TrinaColumnTypeHasDateFormat,
        TrinaColumnTypeHasPopupIcon {
  final DateTime? startDate;

  final DateTime? endDate;

  final bool closePopupOnSelection;

  @override
  final dynamic defaultValue;

  @override
  final String format;

  @override
  final String headerFormat;

  @override
  final bool applyFormatOnInit;

  @override
  final IconData? popupIcon;

  TrinaColumnTypeDate({
    this.defaultValue,
    this.startDate,
    this.endDate,
    required this.format,
    required this.headerFormat,
    required this.applyFormatOnInit,
    this.popupIcon,
    this.closePopupOnSelection = false,
  })  : dateFormat = intl.DateFormat(format),
        headerDateFormat = intl.DateFormat(headerFormat);

  @override
  final intl.DateFormat dateFormat;

  @override
  final intl.DateFormat headerDateFormat;

  @override
  bool isValid(dynamic value) {
    if (value == null) return true;

    DateTime? parsedDate;
    if (value is DateTime) {
      parsedDate = value;
    } else {
      parsedDate = dateFormat.tryParse(value.toString());
    }

    if (parsedDate == null) return false;

    if (startDate != null && parsedDate.isBefore(startDate!)) return false;

    if (endDate != null && parsedDate.isAfter(endDate!)) return false;

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
      date = dateFormat.tryParse(value.toString()) ??
          DateTime.tryParse(value.toString());
    }

    if (date == null) return '';

    return dateFormat.format(date);
  }
}
