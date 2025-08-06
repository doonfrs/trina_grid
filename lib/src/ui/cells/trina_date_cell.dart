import 'package:flutter/material.dart';
import 'package:trina_grid/src/ui/widgets/trina_date_picker.dart';
import 'package:trina_grid/src/ui/miscellaneous/trina_popup_cell_state_with_custom_popup.dart';
import 'package:trina_grid/trina_grid.dart';

import 'popup_cell.dart';

class TrinaDateCell extends StatefulWidget implements PopupCell {
  @override
  final TrinaGridStateManager stateManager;

  @override
  final TrinaCell cell;

  @override
  final TrinaColumn column;

  @override
  final TrinaRow row;

  const TrinaDateCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  TrinaDateCellState createState() => TrinaDateCellState();
}

class TrinaDateCellState
    extends TrinaPopupCellStateWithCustomPopup<TrinaDateCell> {
  @override
  IconData? get popupMenuIcon => widget.column.type.date.popupIcon;

  TrinaColumnTypeDate get _column => widget.column.type.date;

  late DateTime? selectedDate = _column.dateFormat.tryParse(widget.cell.value);

  void onDateChanged(DateTime? value) {
    final currentDate = selectedDate?.copyWith();
    selectedDate = value;

    final onlyYearWasChanged = currentDate?.year != value?.year &&
        currentDate?.month == value?.month &&
        currentDate?.day == value?.day;

    if (onlyYearWasChanged) {
      return;
    }
    if (_column.closePopupOnSelection) {
      callHandleSelected(value);
    }
  }

  void callHandleSelected(DateTime? value) {
    if (value == null) return;
    handleSelected(_column.dateFormat.format(value));
    closePopup(context);
  }

  @override
  Widget get popupContent {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320, maxHeight: 370),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: TrinaDatePicker(
              initialDate: selectedDate,
              firstDate: _column.startDate,
              lastDate: _column.endDate,
              onDateChanged: onDateChanged,
            ),
          ),
          if (!_column.closePopupOnSelection)
            Flexible(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () => callHandleSelected(selectedDate),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
