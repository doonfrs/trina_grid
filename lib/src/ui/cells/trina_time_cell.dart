import 'package:flutter/material.dart';
import 'package:trina_grid/src/helper/platform_helper.dart';
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

  late TimeOfDay selectedTime;

  TrinaColumnTypeTime get _column => widget.column.type.time;

  String _getTimeString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

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
    selectedTime = _parseInitialTime();
    popupContent = _PopupContent(
      initialTime: selectedTime,
      minTime: _column.minTime,
      maxTime: _column.maxTime,
      selectedTimeIsValid: selectedTimeIsValid,
      localeText: widget.stateManager.configuration.localeText,
      onEnterKeyEvent: (time) {
        if (_column.saveAndClosePopupWithEnter) {
          handleSelected(_getTimeString(time));
          closePopup(context);
        }
      },
      onOkButtonPressed: () {
        handleSelected(_getTimeString(selectedTime));
        closePopup(context);
      },
      onCancelButtonPressed: () => closePopup(context),
      onChanged: (time) => selectedTime = time,
      autoFocusMode: _column.autoFocusMode,
    );
    super.initState();
  }

  TimeOfDay _parseInitialTime() {
    final timeString = widget.cell.value?.toString() ?? '';
    final parts = timeString.split(':');

    final hour = int.tryParse(parts.first) ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;

    return TimeOfDay(hour: hour, minute: minute);
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
    required this.onCancelButtonPressed,
    required this.localeText,
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

  final void Function()? onCancelButtonPressed;

  final ValueNotifier<bool> selectedTimeIsValid;
  final TrinaGridLocaleText localeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 270, maxHeight: 190),
      child: Stack(
        fit: StackFit.loose,
        children: [
          Positioned.fill(
            top: 12,
            child: TrinaTimePicker(
              autoFocusMode: autoFocusMode,
              initialTime: initialTime,
              onEnterKeyEvent: onEnterKeyEvent,
              onChanged: onChanged,
              onValidationChanged: (isValid) =>
                  selectedTimeIsValid.value = isValid,
              minTime: minTime,
              maxTime: maxTime,
              invalidHourText: localeText.timePickerInvalidHourMessage,
              invalidMinuteText: localeText.timePickerInvalidMinuteMessage,
              minTimeErrorText: localeText.timePickerMinTimeMessage,
              maxTimeErrorText: localeText.timePickerMaxTimeMessage,
            ),
          ),
          Positioned(
            bottom: 10,
            right: 0,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onCancelButtonPressed,
                    child: Text(localeText.paginationCancelButton),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder(
                    valueListenable: selectedTimeIsValid,
                    builder: (context, isValid, _) {
                      return TextButton(
                        onPressed: isValid ? onOkButtonPressed : null,
                        child: Text(localeText.multiLineFilterOkButton),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          if (PlatformHelper.isDesktop)
            Positioned(
              left: 22,
              bottom: 16,
              child: const Tooltip(
                message: 'You can scroll to increment/decrement',
                child: Icon(Icons.info_outline, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}
