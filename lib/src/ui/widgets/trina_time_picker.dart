import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trina_grid/src/trina_grid_enums.dart';

class TrinaTimePicker extends StatefulWidget {
  TrinaTimePicker({
    super.key,
    required this.initialTime,
    required this.onChanged,
    this.onEnterKeyEvent,
    this.onValidationChanged,
    this.autoFocusMode = TrinaTimePickerAutoFocusMode.hourField,
    this.minTime = const TimeOfDay(hour: 0, minute: 0),
    this.maxTime = const TimeOfDay(hour: 23, minute: 59),
    this.hourFocusNode,
    this.minuteFocusNode,
    this.invalidHourText,
    this.invalidMinuteText,
    this.maxTimeErrorText,
    this.minTimeErrorText,
  }) : assert(
          minTime.isBefore(maxTime) || maxTime.isAtSameTimeAs(minTime),
          'minTime must be before or at the same time as maxTime',
        );

  /// {@template TrinaTimePicker.initialTime}
  ///
  /// The initial time to display.
  /// {@endtemplate}
  final TimeOfDay initialTime;

  /// {@template TrinaTimePicker.onChanged}
  ///
  /// Called when the time is changed by the user.
  /// {@endtemplate}
  final void Function(TimeOfDay time) onChanged;

  /// {@template TrinaTimePicker.autoFocusMode}
  ///
  /// Controls which field (hour/minute) is auto-focused.
  /// {@endtemplate}
  final TrinaTimePickerAutoFocusMode autoFocusMode;

  /// {@template TrinaTimePicker.onEnterKeyEvent}
  ///
  /// Called when the Enter key is pressed.
  /// {@endtemplate}
  final void Function(TimeOfDay time)? onEnterKeyEvent;

  /// Called when the validation status of the time picker changes.
  ///
  /// The [isValid] parameter indicates whether the currently entered time
  /// is valid according to the specified constraints.
  final void Function(bool isValid)? onValidationChanged;

  /// {@template TrinaTimePicker.minTime}
  ///
  /// The minimum time that can be selected.
  /// {@endtemplate}
  final TimeOfDay minTime;

  /// {@template TrinaTimePicker.maxTime}
  ///
  /// The maximum time that can be selected.
  /// {@endtemplate}
  final TimeOfDay maxTime;

  /// Optional [FocusNode] for the hour input field.
  final FocusNode? hourFocusNode;

  /// Optional [FocusNode] for the minute input field.
  final FocusNode? minuteFocusNode;

  /// Custom error text displayed when the hour input is invalid
  /// (e.g., not a number, out of 0-23 range).
  final String? invalidHourText;

  /// Custom error text displayed when the minute input is invalid
  /// (e.g., not a number, out of 0-59 range).
  final String? invalidMinuteText;

  /// Custom error text displayed when the selected time exceeds [maxTime].
  final String? maxTimeErrorText;

  /// Custom error text displayed when the selected time is before [minTime].
  final String? minTimeErrorText;

  @override
  State<TrinaTimePicker> createState() => _TrinaTimePickerState();
}

class _TrinaTimePickerState extends State<TrinaTimePicker> {
  late TimeOfDay currentTime;
  late final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    currentTime = _getValidInitialTime(widget.initialTime);

    if (_isTimeInRange(widget.initialTime) == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onValidationChanged?.call(false);
      });
    }
  }

  TimeOfDay _getValidInitialTime(TimeOfDay initialTime) {
    return _isTimeInRange(initialTime) ? initialTime : widget.minTime;
  }

  /// Updates the hour value and notifies listeners.
  void _updateHour(int hour) {
    if (currentTime.tryReplacing(hour: hour) case TimeOfDay newTime
        when _isTimeInRange(newTime)) {
      currentTime = newTime;
      widget.onChanged(currentTime);
    }
  }

  /// Updates the minute value and notifies listeners.
  void _updateMinute(int minute) {
    if (currentTime.tryReplacing(minute: minute) case TimeOfDay newTime
        when _isTimeInRange(newTime)) {
      currentTime = newTime;
      widget.onChanged(currentTime);
    }
  }

  bool _isTimeInRange(TimeOfDay? time) {
    if (time == null) {
      return false;
    }
    return (time.isBefore(widget.maxTime) && time.isAfter(widget.minTime)) ||
        time.isAtSameTimeAs(widget.minTime) ||
        time.isAtSameTimeAs(widget.maxTime);
  }

  /// Handles the Enter key event, validating the form and calling the callback.
  void _onEnterKeyEvent() {
    if (formKey.currentState?.validate() ?? false) {
      widget.onEnterKeyEvent?.call(currentTime);
    }
  }

  String getMinTimeErrorText(BuildContext context) {
    return widget.minTimeErrorText ??
        'Min time is ${widget.minTime.format(context)}';
  }

  String getMaxTimeErrorText(BuildContext context) {
    return widget.maxTimeErrorText ??
        'Max time is ${widget.maxTime.format(context)}';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      onChanged: () {
        widget.onValidationChanged?.call(
          formKey.currentState?.validate() ?? false,
        );
      },
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimeDigitInput(
            focusNode: widget.hourFocusNode,
            label: 'Hour',
            autoFocus: widget.autoFocusMode.isHour,
            initialValue: currentTime.hour,
            onChanged: _updateHour,
            onEnterKeyEvent: (_) => _onEnterKeyEvent(),
            textInputAction: widget.autoFocusMode.isEnabled
                ? widget.autoFocusMode.isHour
                    ? TextInputAction.next
                    : TextInputAction.done
                : null,
            isValidTime: (hour) {
              return _isTimeInRange(currentTime.tryReplacing(hour: hour));
            },
            validator: (value) {
              final hourInt = int.tryParse(value);
              if (hourInt == null || hourInt < 0 || hourInt > 23) {
                return widget.invalidHourText ??
                    'Hour must be between 0 and 23';
              }
              if (currentTime.tryReplacing(hour: hourInt)
                  case TimeOfDay newTime) {
                if (newTime.isBefore(widget.minTime)) {
                  return getMinTimeErrorText(context);
                } else if (newTime.isAfter(widget.maxTime)) {
                  return getMaxTimeErrorText(context);
                }
              }
              return null;
            },
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: Center(child: Text(':', style: TextStyle(fontSize: 35))),
          ),
          _TimeDigitInput(
            focusNode: widget.minuteFocusNode,
            label: 'Minute',
            initialValue: currentTime.minute,
            onChanged: _updateMinute,
            autoFocus: widget.autoFocusMode.isMinute,
            onEnterKeyEvent: (_) => _onEnterKeyEvent(),
            textInputAction: widget.autoFocusMode.isEnabled
                ? widget.autoFocusMode.isMinute
                    ? TextInputAction.next
                    : TextInputAction.done
                : null,
            isValidTime: (minute) =>
                _isTimeInRange(currentTime.tryReplacing(minute: minute)),
            validator: (value) {
              final minuteInt = int.tryParse(value);

              if (minuteInt == null || minuteInt < 0 || minuteInt > 59) {
                return widget.invalidMinuteText ??
                    'Minute must be between 0 and 59';
              }
              if (currentTime.tryReplacing(minute: minuteInt)
                  case TimeOfDay newTime) {
                if (newTime.isBefore(widget.minTime)) {
                  return getMinTimeErrorText(context);
                } else if (newTime.isAfter(widget.maxTime)) {
                  return getMaxTimeErrorText(context);
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

/// Internal widget for digit input (hour or minute) in the time picker.
class _TimeDigitInput extends StatefulWidget {
  /// Creates a [_TimeDigitInput].
  const _TimeDigitInput({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    required this.autoFocus,
    required this.isValidTime,
    required this.validator,
    this.textInputAction,
    this.onEnterKeyEvent,
    this.focusNode,
  });

  /// The label for the input field ("Hour" or "Minute").
  final String label;

  /// The initial value for the field.
  final int initialValue;

  /// Called when the value changes.
  final void Function(int value) onChanged;

  /// A callback function that determines if a given integer value is a valid time.
  final bool Function(int value) isValidTime;

  final String? Function(String value) validator;

  /// Whether this field should be auto-focused.
  final bool autoFocus;

  /// The input action for the field.
  final TextInputAction? textInputAction;

  /// Called when the Enter key is pressed.
  final void Function(String value)? onEnterKeyEvent;

  /// Optional [FocusNode] for this input field.
  final FocusNode? focusNode;

  @override
  State<_TimeDigitInput> createState() => _TimeDigitInputState();
}

class _TimeDigitInputState extends State<_TimeDigitInput> {
  late final controller = TextEditingController(
    text: widget.initialValue.toString().padLeft(2, '0'),
  );

  late final ValueNotifier<String?> _errorTextNotifier;

  @override
  void initState() {
    super.initState();
    _errorTextNotifier = ValueNotifier<String?>(null);
  }

  @override
  void dispose() {
    controller.dispose();
    _errorTextNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 0,
            child: CallbackShortcuts(
              bindings: {
                LogicalKeySet(LogicalKeyboardKey.enter): () {
                  FocusScope.of(context).nextFocus();
                  widget.onEnterKeyEvent?.call(controller.text.padLeft(2, '0'));
                },
                LogicalKeySet(LogicalKeyboardKey.arrowUp): () {
                  final currentValue = int.tryParse(controller.text) ?? 0;
                  final nextValue = currentValue + 1;
                  if (widget.isValidTime(nextValue)) {
                    controller.text = nextValue.toString().padLeft(2, '0');
                    widget.onChanged(nextValue);
                  }
                },
                LogicalKeySet(LogicalKeyboardKey.arrowDown): () {
                  final currentValue = int.tryParse(controller.text) ?? 0;
                  final prevValue = currentValue - 1;

                  if (widget.isValidTime(prevValue)) {
                    controller.text = prevValue.toString().padLeft(2, '0');
                    widget.onChanged(prevValue);
                  }
                },
              },
              child: TextFormField(
                focusNode: widget.focusNode,
                controller: controller,
                onChanged: (value) {
                  if (int.tryParse(value) case int parsedValue) {
                    widget.onChanged(parsedValue);
                  }
                },
                validator: (value) {
                  if (value == null) {
                    _errorTextNotifier.value = 'Invalid value';
                    return null;
                  }
                  final error = widget.validator(value);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _errorTextNotifier.value = error;
                  });
                  return error;
                },
                maxLength: 2,
                textInputAction: widget.textInputAction,
                maxLines: 1,
                autofocus: widget.autoFocus,
                canRequestFocus: true,
                errorBuilder: (context, errorText) => SizedBox.shrink(),
                buildCounter: (
                  context, {
                  required currentLength,
                  required isFocused,
                  required maxLength,
                }) {
                  return null;
                },
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  helperText: widget.label,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  filled: true,
                  isDense: true,
                  hoverColor: colorScheme.inverseSurface.withAlpha(20),
                  fillColor: colorScheme.inverseSurface.withAlpha(10),
                ),
                style: TextStyle(fontSize: 26, color: colorScheme.onSurface),
              ),
            ),
          ),
          Flexible(
            child: ValueListenableBuilder<String?>(
              valueListenable: _errorTextNotifier,
              builder: (context, errorText, child) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    child: errorText != null
                        ? Text(
                            errorText,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                            textAlign: TextAlign.center,
                          )
                        : SizedBox(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension on TimeOfDay {
  /// Attempts to create a new [TimeOfDay] instance by replacing the hour or minute.
  ///
  /// Returns `null` if the resulting hour or minute would be out of their valid ranges.
  TimeOfDay? tryReplacing({int? hour, int? minute}) {
    final hourInBounds =
        hour == null || hour >= 0 && hour < TimeOfDay.hoursPerDay;
    final minuteInBounds =
        minute == null || minute >= 0 && minute < TimeOfDay.minutesPerHour;

    if (hourInBounds && minuteInBounds) {
      return replacing(hour: hour, minute: minute);
    }
    return null;
  }
}
