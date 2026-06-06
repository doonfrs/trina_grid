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
    debugPrint('[Shortcut] Checking shortcut for key event: ${keyEvent.event}');

    for (final action in actions.entries) {
      if (action.key.accepts(keyEvent.event, state)) {
        debugPrint(
          '[Shortcut] Matched shortcut: ${action.key}, executing action: ${action.value.runtimeType}',
        );
        action.value.execute(keyEvent: keyEvent, stateManager: stateManager);
        return true;
      }
    }

    debugPrint('[Shortcut] No matching shortcut found');
    return false;
  }

  static final Map<ShortcutActivator, TrinaGridShortcutAction>
  defaultActions = {
    // Move cell focus
    SingleActivator(LogicalKeyboardKey.arrowLeft):
        const TrinaGridActionMoveCellFocus(TrinaMoveDirection.left),
    SingleActivator(LogicalKeyboardKey.arrowRight):
        const TrinaGridActionMoveCellFocus(TrinaMoveDirection.right),
    SingleActivator(LogicalKeyboardKey.arrowUp):
        const TrinaGridActionMoveCellFocus(TrinaMoveDirection.up),
    SingleActivator(LogicalKeyboardKey.arrowDown):
        const TrinaGridActionMoveCellFocus(TrinaMoveDirection.down),
    // Move selected cell focus
    SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true):
        const TrinaGridActionMoveSelectedCellFocus(TrinaMoveDirection.left),
    SingleActivator(LogicalKeyboardKey.arrowRight, shift: true):
        const TrinaGridActionMoveSelectedCellFocus(TrinaMoveDirection.right),
    SingleActivator(LogicalKeyboardKey.arrowUp, shift: true):
        const TrinaGridActionMoveSelectedCellFocus(TrinaMoveDirection.up),
    SingleActivator(LogicalKeyboardKey.arrowDown, shift: true):
        const TrinaGridActionMoveSelectedCellFocus(TrinaMoveDirection.down),
    // Move cell focus by page vertically
    SingleActivator(LogicalKeyboardKey.pageUp):
        const TrinaGridActionMoveCellFocusByPage(TrinaMoveDirection.up),
    SingleActivator(LogicalKeyboardKey.pageDown):
        const TrinaGridActionMoveCellFocusByPage(TrinaMoveDirection.down),
    // Move selected cell focus by page vertically
    SingleActivator(LogicalKeyboardKey.pageUp, shift: true):
        const TrinaGridActionMoveSelectedCellFocusByPage(TrinaMoveDirection.up),
    SingleActivator(
      LogicalKeyboardKey.pageDown,
      shift: true,
    ): const TrinaGridActionMoveSelectedCellFocusByPage(
      TrinaMoveDirection.down,
    ),
    // Move page when pagination is enabled
    SingleActivator(LogicalKeyboardKey.pageUp, alt: true):
        const TrinaGridActionMoveCellFocusByPage(TrinaMoveDirection.left),
    SingleActivator(LogicalKeyboardKey.pageDown, alt: true):
        const TrinaGridActionMoveCellFocusByPage(TrinaMoveDirection.right),
    // Default tab key action
    SingleActivator(LogicalKeyboardKey.tab): const TrinaGridActionDefaultTab(),
    SingleActivator(LogicalKeyboardKey.tab, shift: true):
        const TrinaGridActionDefaultTab(),
    // Default enter key action
    SingleActivator(LogicalKeyboardKey.enter):
        const TrinaGridActionDefaultEnterKey(),
    SingleActivator(LogicalKeyboardKey.numpadEnter):
        const TrinaGridActionDefaultEnterKey(),
    SingleActivator(LogicalKeyboardKey.enter, shift: true):
        const TrinaGridActionDefaultEnterKey(),
    // Default escape key action
    SingleActivator(LogicalKeyboardKey.escape):
        const TrinaGridActionDefaultEscapeKey(),
    // Move cell focus to edge
    SingleActivator(LogicalKeyboardKey.home):
        const TrinaGridActionMoveCellFocusToEdge(TrinaMoveDirection.left),
    SingleActivator(LogicalKeyboardKey.end):
        const TrinaGridActionMoveCellFocusToEdge(TrinaMoveDirection.right),
    SingleActivator(LogicalKeyboardKey.home, control: true):
        const TrinaGridActionMoveCellFocusToEdge(TrinaMoveDirection.up),
    SingleActivator(LogicalKeyboardKey.end, control: true):
        const TrinaGridActionMoveCellFocusToEdge(TrinaMoveDirection.down),
    // Move selected cell focus to edge
    SingleActivator(
      LogicalKeyboardKey.home,
      shift: true,
    ): const TrinaGridActionMoveSelectedCellFocusToEdge(
      TrinaMoveDirection.left,
    ),
    SingleActivator(
      LogicalKeyboardKey.end,
      shift: true,
    ): const TrinaGridActionMoveSelectedCellFocusToEdge(
      TrinaMoveDirection.right,
    ),
    SingleActivator(LogicalKeyboardKey.home, control: true, shift: true):
        const TrinaGridActionMoveSelectedCellFocusToEdge(TrinaMoveDirection.up),
    SingleActivator(
      LogicalKeyboardKey.end,
      control: true,
      shift: true,
    ): const TrinaGridActionMoveSelectedCellFocusToEdge(
      TrinaMoveDirection.down,
    ),
    // Set editing
    SingleActivator(LogicalKeyboardKey.f2): const TrinaGridActionSetEditing(),
    // Focus to column filter
    SingleActivator(LogicalKeyboardKey.f3):
        const TrinaGridActionFocusToColumnFilter(),
    // Toggle column sort
    SingleActivator(LogicalKeyboardKey.f4):
        const TrinaGridActionToggleColumnSort(),
    // Copy the values of cells
    SingleActivator(LogicalKeyboardKey.keyC, control: true):
        const TrinaGridActionCopyValues(),
    // Copy the values of cells (Mac)
    SingleActivator(LogicalKeyboardKey.keyC, meta: true):
        const TrinaGridActionCopyValues(),
    // Paste values from clipboard
    SingleActivator(LogicalKeyboardKey.keyV, control: true):
        const TrinaGridActionPasteValues(),
    // Paste values from clipboard (Mac)
    SingleActivator(LogicalKeyboardKey.keyV, meta: true):
        const TrinaGridActionPasteValues(),
    // Select all cells or rows
    SingleActivator(LogicalKeyboardKey.keyA, control: true):
        const TrinaGridActionSelectAll(),
    // Select all cells or rows (Mac)
    SingleActivator(LogicalKeyboardKey.keyA, meta: true):
        const TrinaGridActionSelectAll(),
  };
}
