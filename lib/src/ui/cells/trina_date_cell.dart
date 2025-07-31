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

  late DateTime? selectedTime = _column.dateFormat.tryParse(widget.cell.value);

  @override
  Widget get popupContent {
    return _PopupContent(
      onDateChanged: (DateTime value) {
        selectedTime = value;
      },
      onOkButtonPressed: () {
        if (selectedTime != null) {
          handleSelected(_column.dateFormat.format(selectedTime!));
          closePopup(context);
        }
      },
      initialDate: selectedTime,
      firstDate: _column.startDate,
      lastDate: _column.endDate,
    );
  }
}

class _PopupContent extends StatelessWidget {
  final void Function() onOkButtonPressed;
  final void Function(DateTime) onDateChanged;

  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const _PopupContent({
    required this.onOkButtonPressed,
    required this.onDateChanged,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320, maxHeight: 370),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: TrinaDatePicker(
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
              onDateChanged: onDateChanged,
            ),
          ),
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
                    onPressed: onOkButtonPressed,
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
