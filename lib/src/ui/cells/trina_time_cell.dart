import 'package:flutter/material.dart';
import 'package:trina_grid/src/ui/miscellaneous/trina_popup_cell_state_with_custom_popup.dart';
import 'package:trina_grid/src/ui/widgets/trina_time_picker.dart';
import 'package:trina_grid/trina_grid.dart';

import 'popup_cell.dart';

class TrinaTimeCell extends StatefulWidget implements PopupCell {
  @override
  final TrinaGridStateManager stateManager;

  @override
  final TrinaCell cell;

  @override
  final TrinaColumn column;

  @override
  final TrinaRow row;

  const TrinaTimeCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  TrinaTimeCellState createState() => TrinaTimeCellState();
}

class TrinaTimeCellState
    extends TrinaPopupCellStateWithCustomPopup<TrinaTimeCell> {
  @override
  IconData? get popupMenuIcon => _column.popupIcon;

  late TimeOfDay selectedTime = TimeOfDay(
    hour: int.tryParse(cellHour) ?? 0,
    minute: int.tryParse(cellMinute) ?? 0,
  );

  TrinaColumnTypeTime get _column => widget.column.type.time;

  String _getTimeString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  List<String> get timeDigits => (widget.cell.value ?? _column.defaultValue)
      .toString()
      .split(':')
      .toList();

  String get cellHour => timeDigits.first.padLeft(2, '0');

  String get cellMinute => timeDigits.last.padLeft(2, '0');

  @override
  late final Widget popupContent;

  late final selectedTimeIsValid = ValueNotifier<bool>(true);

  @override
  dispose() {
    selectedTimeIsValid.dispose();
    super.dispose();
  }

  @override
  void initState() {
    popupContent = _PopupContent(
      initialTime: selectedTime,
      minTime: _column.minTime,
      maxTime: _column.maxTime,
      selectedTimeIsValid: selectedTimeIsValid,
      onEnterKeyEvent: (time) {
        if (_column.saveAndClosePopupWithEnter) {
          handleSelected(_getTimeString(time));
          Navigator.of(context).pop();
        }
      },
      onOkButtonPressed: () {
        handleSelected(_getTimeString(selectedTime));
        Navigator.of(context).pop();
      },
      onChanged: (time) => selectedTime = time,
      autoFocusMode: _column.autoFocusMode,
    );
    super.initState();
  }
}

class _PopupContent extends StatelessWidget {
  const _PopupContent({
    this.onEnterKeyEvent,
    required this.initialTime,
    required this.minTime,
    required this.maxTime,
    required this.autoFocusMode,
    required this.onChanged,
    required this.onOkButtonPressed,
    required this.selectedTimeIsValid,
  });

  /// {@macro TrinaTimePicker.initialTime}
  final TimeOfDay initialTime;

  /// {@macro TrinaTimePicker.minTime}
  final TimeOfDay minTime;

  /// {@macro TrinaTimePicker.maxTime}
  final TimeOfDay maxTime;

  /// {@macro TrinaTimePicker.autoFocusMode}
  final TrinaTimePickerAutoFocusMode autoFocusMode;

  /// {@macro TrinaTimePicker.onChanged}
  final void Function(TimeOfDay time) onChanged;

  /// {@macro TrinaTimePicker.onEnterKeyEvent}
  final void Function(TimeOfDay time)? onEnterKeyEvent;

  final void Function()? onOkButtonPressed;

  final ValueNotifier<bool> selectedTimeIsValid;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 250,
        maxHeight: 180,
      ),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Stack(
        fit: StackFit.loose,
        children: [
          Positioned.fill(
            bottom: 26,
            child: TrinaTimePicker(
              autoFocusMode: autoFocusMode,
              initialTime: initialTime,
              onEnterKeyEvent: onEnterKeyEvent,
              onChanged: onChanged,
              onValidationChanged: (isValid) =>
                  selectedTimeIsValid.value = isValid,
              minTime: minTime,
              maxTime: maxTime,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder(
                    valueListenable: selectedTimeIsValid,
                    builder: (context, isValid, _) {
                      return TextButton(
                        onPressed: isValid ? onOkButtonPressed : null,
                        child: const Text('OK'),
                      );
                    },
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
