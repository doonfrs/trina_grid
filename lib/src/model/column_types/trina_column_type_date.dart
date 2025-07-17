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

  TrinaColumnTypeDate({
    this.defaultValue,
    this.startDate,
    this.endDate,
    required this.format,
    required this.headerFormat,
    required this.applyFormatOnInit,
    this.popupIcon,
  })  : dateFormat = intl.DateFormat(format),
        headerDateFormat = intl.DateFormat(headerFormat);

  @override
  final intl.DateFormat dateFormat;

  @override
  final intl.DateFormat headerDateFormat;

  @override
  bool isValid(dynamic value) {
    final parsedDate = dateFormat.tryParse(value.toString());

    if (parsedDate == null) {
      return false;
    }

    if (startDate != null && parsedDate.isBefore(startDate!)) {
      return false;
    }

    if (endDate != null && parsedDate.isAfter(endDate!)) {
      return false;
    }

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
    DateTime? dateFormatValue;

    try {
      dateFormatValue = dateFormat.parse(v.toString());
    } catch (e) {
      dateFormatValue = null;
    }

    return dateFormatValue;
  }

  @override
  String applyFormat(dynamic value) {
    final parseValue = DateTime.tryParse(value.toString());

    if (parseValue == null) {
      return '';
    }

    return dateFormat.format(DateTime.parse(value.toString()));
  }
}
