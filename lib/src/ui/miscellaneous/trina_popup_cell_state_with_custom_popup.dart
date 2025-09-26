import 'package:trina_grid/src/ui/cells/popup_cell.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/src/widgets/trina_popup.dart';

/// Abstract state for popup cells that use a [TrinaPopup] to display the popup.
abstract class TrinaPopupCellStateWithCustomPopup<T extends PopupCell>
    extends State<T>
    with PopupCellState<T> {
  /// Notifier for popup visibility state.
  late final popupVisibilityNotifier = ValueNotifier<bool>(false);

  /// Key for the popup anchor.
  late final popupKey = GlobalKey<TrinaPopupState>();

  @override
  late final Widget defaultEditWidget;

  @override
  void initState() {
    super.initState();

    defaultEditWidget = _CustomPopup(
      popupKey: popupKey,
      initialValue: widget.cell.value.toString(),
      isDarkMode: widget.stateManager.style.isDarkStyle,
      popupContent: popupContent,
      textFocus: textFocus,
      popupMenuIcon: popupMenuIcon,
      cellTextStyle: widget.stateManager.configuration.style.cellTextStyle,
      onOpenPopup: () => openPopup(context),
      onBeforePopup: () => popupVisibilityNotifier.value = true,
      onAfterPopup: (selectedValue) {
        popupVisibilityNotifier.value = false;
        onPopupClosed.call(selectedValue);
      },
      onKeyEvent: (node, event) => handleOpeningPopupWithKeyboard(
        node,
        event,
        popupVisibilityNotifier.value,
      ),
    );
  }

  @override
  void dispose() {
    popupVisibilityNotifier.dispose();
    super.dispose();
  }

  @override
  void closePopup(BuildContext context) {
    Navigator.maybePop(context);
  }

  @override
  void openPopup(BuildContext context) {
    if (widget.column.readOnly) {
      return;
    }
    popupKey.currentState?.show();
  }

  /// The widget to display as the popup content.
  Widget get popupContent;

  /// Called when the popup is closed.
  ///
  /// Used by subclasses to get the result of [Navigator.pop].
  void onPopupClosed(dynamic value) {}
}

class _CustomPopup extends StatelessWidget {
  const _CustomPopup({
    required this.isDarkMode,
    required this.popupContent,
    required this.textFocus,
    required this.popupMenuIcon,
    required this.cellTextStyle,
    required this.onOpenPopup,
    required this.onBeforePopup,
    required this.onAfterPopup,
    required this.onKeyEvent,
    required this.initialValue,
    required this.popupKey,
  });

  final bool isDarkMode;
  final Widget popupContent;
  final FocusNode textFocus;
  final IconData? popupMenuIcon;
  final TextStyle cellTextStyle;
  final void Function() onOpenPopup;
  final void Function() onBeforePopup;
  final void Function(dynamic value) onAfterPopup;
  final KeyEventResult Function(FocusNode, KeyEvent) onKeyEvent;
  final String initialValue;
  final GlobalKey popupKey;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(
      context,
    ).copyWith(brightness: isDarkMode ? Brightness.dark : Brightness.light);
    final colorScheme = themeData.colorScheme;

    return Focus(
      autofocus: true,
      focusNode: textFocus,
      onKeyEvent: onKeyEvent,
      child: TrinaPopup(
        anchorKey: popupKey,
        position: TrinaPopupPosition.auto,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        arrowColor: colorScheme.inverseSurface,
        barrierColor: colorScheme.inverseSurface.withAlpha(10),
        onBeforePopup: onBeforePopup,
        onAfterPopup: onAfterPopup,
        // We have to wrap the content with a [Theme] so
        // widgets inside the popup will use the app's [Theme].
        content: Theme(
          data: themeData,
          child: Material(type: MaterialType.transparency, child: popupContent),
        ),
        rootNavigator: true,
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          child: TextFormField(
            onTap: onOpenPopup,
            ignorePointers: false,
            mouseCursor: SystemMouseCursors.click,
            readOnly: true,
            initialValue: initialValue,
            style: cellTextStyle,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              suffixIcon: popupMenuIcon != null ? Icon(popupMenuIcon) : null,
            ),
          ),
        ),
      ),
    );
  }
}
