import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:trina_grid/trina_grid.dart';

/// Class for setting shortcut actions.
///
/// Defaults to [TrinaGridShortcut.defaultActions] if not passing [actions].
class TrinaGridShortcut {
  const TrinaGridShortcut({
    Map<ShortcutActivator, TrinaGridShortcutAction>? actions,
  }) : _actions = actions;

  /// Custom shortcuts and actions.
  ///
  /// When the shortcut set in [ShortcutActivator] is input,
  /// the [TrinaGridShortcutAction.execute] method is executed.
  Map<ShortcutActivator, TrinaGridShortcutAction> get actions =>
      _actions ?? defaultActions;

  final Map<ShortcutActivator, TrinaGridShortcutAction>? _actions;

  /// If the shortcut registered in [actions] matches,
  /// the action for the shortcut is executed.
  ///
  /// If there is no matching shortcut and returns false ,
  /// the default shortcut behavior is processed.
  bool handle({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
    required HardwareKeyboard state,
  }) {
    for (final action in actions.entries) {
      if (action.key.accepts(keyEvent.event, state)) {
        action.value.execute(keyEvent: keyEvent, stateManager: stateManager);
        return true;
      }
    }

    return false;
  }

  static final Map<ShortcutActivator, TrinaGridShortcutAction>
  defaultActions = {
    // Move cell focus
    LogicalKeySet(LogicalKeyboardKey.arrowLeft):
        const TrinaGridActionMoveCellFocus(TrinaMoveDirection.left),
    LogicalKeySet(LogicalKeyboardKey.arrowRight):
        const TrinaGridActionMoveCellFocus(TrinaMoveDirection.right),
    LogicalKeySet(LogicalKeyboardKey.arrowUp):
        const TrinaGridActionMoveCellFocus(TrinaMoveDirection.up),
    LogicalKeySet(LogicalKeyboardKey.arrowDown):
        const TrinaGridActionMoveCellFocus(TrinaMoveDirection.down),
    // Move selected cell focus
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowLeft):
        const TrinaGridActionMoveSelectedCellFocus(TrinaMoveDirection.left),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowRight):
        const TrinaGridActionMoveSelectedCellFocus(TrinaMoveDirection.right),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowUp):
        const TrinaGridActionMoveSelectedCellFocus(TrinaMoveDirection.up),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.arrowDown):
        const TrinaGridActionMoveSelectedCellFocus(TrinaMoveDirection.down),
    // Move cell focus by page vertically
    LogicalKeySet(LogicalKeyboardKey.pageUp):
        const TrinaGridActionMoveCellFocusByPage(TrinaMoveDirection.up),
    LogicalKeySet(LogicalKeyboardKey.pageDown):
        const TrinaGridActionMoveCellFocusByPage(TrinaMoveDirection.down),
    // Move cell focus by page vertically
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.pageUp):
        const TrinaGridActionMoveSelectedCellFocusByPage(TrinaMoveDirection.up),
    LogicalKeySet(
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.pageDown,
    ): const TrinaGridActionMoveSelectedCellFocusByPage(
      TrinaMoveDirection.down,
    ),
    // Move page when pagination is enabled
    LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.pageUp):
        const TrinaGridActionMoveCellFocusByPage(TrinaMoveDirection.left),
    LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.pageDown):
        const TrinaGridActionMoveCellFocusByPage(TrinaMoveDirection.right),
    // Default tab key action
    LogicalKeySet(LogicalKeyboardKey.tab): const TrinaGridActionDefaultTab(),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab):
        const TrinaGridActionDefaultTab(),
    // Default enter key action
    LogicalKeySet(LogicalKeyboardKey.enter):
        const TrinaGridActionDefaultEnterKey(),
    LogicalKeySet(LogicalKeyboardKey.numpadEnter):
        const TrinaGridActionDefaultEnterKey(),
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.enter):
        const TrinaGridActionDefaultEnterKey(),
    // Default escape key action
    LogicalKeySet(LogicalKeyboardKey.escape):
        const TrinaGridActionDefaultEscapeKey(),
    // Move cell focus to edge
    LogicalKeySet(LogicalKeyboardKey.home):
        const TrinaGridActionMoveCellFocusToEdge(TrinaMoveDirection.left),
    LogicalKeySet(LogicalKeyboardKey.end):
        const TrinaGridActionMoveCellFocusToEdge(TrinaMoveDirection.right),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.home):
        const TrinaGridActionMoveCellFocusToEdge(TrinaMoveDirection.up),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.end):
        const TrinaGridActionMoveCellFocusToEdge(TrinaMoveDirection.down),
    // Move selected cell focus to edge
    LogicalKeySet(
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.home,
    ): const TrinaGridActionMoveSelectedCellFocusToEdge(
      TrinaMoveDirection.left,
    ),
    LogicalKeySet(
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.end,
    ): const TrinaGridActionMoveSelectedCellFocusToEdge(
      TrinaMoveDirection.right,
    ),
    LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.home,
    ): const TrinaGridActionMoveSelectedCellFocusToEdge(
      TrinaMoveDirection.up,
    ),
    LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.end,
    ): const TrinaGridActionMoveSelectedCellFocusToEdge(
      TrinaMoveDirection.down,
    ),
    // Set editing
    LogicalKeySet(LogicalKeyboardKey.f2): const TrinaGridActionSetEditing(),
    // Focus to column filter
    LogicalKeySet(LogicalKeyboardKey.f3):
        const TrinaGridActionFocusToColumnFilter(),
    // Toggle column sort
    LogicalKeySet(LogicalKeyboardKey.f4):
        const TrinaGridActionToggleColumnSort(),
    // Copy the values of cells
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyC):
        const TrinaGridActionCopyValues(),
    // Paste values from clipboard
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV):
        const TrinaGridActionPasteValues(),
    // Select all cells or rows
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyA):
        const TrinaGridActionSelectAll(),
  };
}
