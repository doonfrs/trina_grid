import 'package:flutter/material.dart';

/// A widget for picking a date, it uses [CalendarDatePicker] internally.
///
/// [initialDate], [firstDate], and [lastDate] control the date range and selection.
/// [onDateChanged] is called when the user selects a date.
class TrinaDatePicker extends StatelessWidget {
  /// The initially selected date.
  final DateTime? initialDate;

  /// The earliest selectable date.
  final DateTime? firstDate;

  /// The latest selectable date.
  final DateTime? lastDate;

  /// Callback when the date is changed by the user.
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<DateTime>? onDisplayedMonthChanged;

  /// Creates a [TrinaDatePicker].
  const TrinaDatePicker({
    this.initialDate,
    this.firstDate,
    this.lastDate,
    required this.onDateChanged,
    this.onDisplayedMonthChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        datePickerTheme: DatePickerThemeData(
          dayShape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          )),
        ),
      ),
      child: CalendarDatePicker(
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(2000),
        lastDate: lastDate ?? DateTime(2030),
        onDateChanged: onDateChanged,
        onDisplayedMonthChanged: onDisplayedMonthChanged,
      ),
    );
  }
}
