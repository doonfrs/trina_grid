import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trina_grid/src/helper/platform_helper.dart';
import 'package:trina_grid/trina_grid.dart';

abstract class TextCell extends StatefulWidget {
  final TrinaGridStateManager stateManager;

  final TrinaCell cell;

  final TrinaColumn column;

  final TrinaRow row;

  const TextCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });
}

abstract class TextFieldProps {
  TextInputType get keyboardType;

  List<TextInputFormatter>? get inputFormatters;
}

mixin TextCellState<T extends TextCell> on State<T> implements TextFieldProps {
  dynamic _initialCellValue;

  final _textController = TextEditingController();

  final TrinaDebounceByHashCode _debounce = TrinaDebounceByHashCode();

  late final FocusNode cellFocus;

  late _CellEditingStatus _cellEditingStatus;

  @override
  TextInputType get keyboardType => TextInputType.text;

  @override
  List<TextInputFormatter>? get inputFormatters => [];

  String get formattedValue =>
      widget.column.formattedValueForDisplayInEditing(widget.cell.value);

  @override
  void initState() {
    super.initState();

    cellFocus = FocusNode(onKeyEvent: _handleOnKey);

    cellFocus.addListener(() {
      if (!cellFocus.hasFocus) {
        _handleOnComplete();
      }
    });

    widget.stateManager.setTextEditingController(_textController);

    _textController.text = formattedValue;

    _initialCellValue = _textController.text;

    _cellEditingStatus = _CellEditingStatus.init;

    _textController.addListener(() {
      _handleOnChanged(_textController.text.toString());
    });
  }

  @override
  void dispose() {
    /**
     * Saves the changed value when moving a cell while text is being input.
     * if user do not press enter key, onEditingComplete is not called and the value is not saved.
     */
    if (_cellEditingStatus.isChanged) {
      _changeValue();
    }

    if (!widget.stateManager.isEditing ||
        widget.stateManager.currentColumn?.enableEditingMode != true) {
      widget.stateManager.setTextEditingController(null);
    }

    _debounce.dispose();

    _textController.dispose();

    cellFocus.dispose();

    super.dispose();
  }

  void _restoreText() {
    if (_cellEditingStatus.isNotChanged) {
      return;
    }

    _textController.text = _initialCellValue.toString();

    widget.stateManager.changeCellValue(
      widget.stateManager.currentCell!,
      _initialCellValue,
      notify: false,
    );
  }

  bool _moveHorizontal(TrinaKeyManagerEvent keyManager) {
    if (!keyManager.isHorizontal) {
      return false;
    }

    if (widget.column.readOnly == true) {
      return true;
    }

    final selection = _textController.selection;

    if (selection.baseOffset != selection.extentOffset) {
      return false;
    }

    if (selection.baseOffset == 0 && keyManager.isLeft) {
      return true;
    }

    final textLength = _textController.text.length;

    if (selection.baseOffset == textLength && keyManager.isRight) {
      return true;
    }

    return false;
  }

  void _changeValue() {
    if (formattedValue == _textController.text) {
      return;
    }

    widget.stateManager.changeCellValue(widget.cell, _textController.text);

    _textController.text = formattedValue;

    _initialCellValue = _textController.text;

    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );

    _cellEditingStatus = _CellEditingStatus.updated;
  }

  void _handleOnChanged(String value) {
    _cellEditingStatus = formattedValue != value.toString()
        ? _CellEditingStatus.changed
        : _initialCellValue.toString() == value.toString()
            ? _CellEditingStatus.init
            : _CellEditingStatus.updated;
  }

  void _handleOnComplete() {
    final old = _textController.text;

    _changeValue();

    _handleOnChanged(old);

    PlatformHelper.onMobile(() {
      widget.stateManager.setKeepFocus(false);
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  KeyEventResult _handleOnKey(FocusNode node, KeyEvent event) {
    var keyManager = TrinaKeyManagerEvent(focusNode: node, event: event);

    if (keyManager.isKeyUpEvent) {
      return KeyEventResult.handled;
    }

    final skip = !(keyManager.isVertical ||
        _moveHorizontal(keyManager) ||
        keyManager.isEsc ||
        keyManager.isTab ||
        keyManager.isF3 ||
        keyManager.isEnter);

    // Movement and enter key, non-editable cell left and right movement, etc. key input is propagated to text field.
    if (skip) {
      return widget.stateManager.keyManager!.eventResult.skip(
        KeyEventResult.ignored,
      );
    }

    if (_debounce.isDebounced(
      hashCode: _textController.text.hashCode,
      ignore: !kIsWeb,
    )) {
      return KeyEventResult.handled;
    }

    // Enter key is propagated to grid focus handler.
    if (keyManager.isEnter) {
      _handleOnComplete();
      return KeyEventResult.ignored;
    }

    // ESC is propagated to grid focus handler.
    if (keyManager.isEsc) {
      _restoreText();
    }

    // KeyManager is delegated to handle the event.
    widget.stateManager.keyManager!.subject.add(keyManager);

    // All events are handled and event propagation is stopped.
    return KeyEventResult.handled;
  }

  void _handleOnTap() {
    widget.stateManager.setKeepFocus(true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stateManager.keepFocus) {
      cellFocus.requestFocus();
    }

    Widget w = TextField(
      focusNode: cellFocus,
      controller: _textController,
      readOnly: widget.column.checkReadOnly(widget.row, widget.cell),
      onChanged: _handleOnChanged,
      onEditingComplete: _handleOnComplete,
      onSubmitted: (_) => _handleOnComplete(),
      onTap: _handleOnTap,
      style: widget.stateManager.configuration.style.cellTextStyle,
      decoration: const InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide.none),
        contentPadding: EdgeInsets.zero,
      ),
      maxLines: 1,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textAlignVertical: TextAlignVertical.center,
      textAlign: widget.column.textAlign.value,
    );

    // Use column-level editCellRenderer if available, otherwise fall back to grid-level
    if (widget.column.editCellRenderer != null) {
      w = widget.column.editCellRenderer!(
        w,
        widget.cell,
        _textController,
        cellFocus,
        null,
      );
    } else if (widget.stateManager.editCellRenderer != null) {
      w = widget.stateManager.editCellRenderer!(
        w,
        widget.cell,
        _textController,
        cellFocus,
        null,
      );
    }

    return w;
  }
}

enum _CellEditingStatus {
  init,
  changed,
  updated;

  bool get isNotChanged {
    return _CellEditingStatus.changed != this;
  }

  bool get isChanged {
    return _CellEditingStatus.changed == this;
  }

  bool get isUpdated {
    return _CellEditingStatus.updated == this;
  }
}
