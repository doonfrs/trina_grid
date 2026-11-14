import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

/// Used as the default widget for popup cells when in editing state.
class TrinaDefaultPopupCellEditingWidget extends StatelessWidget {
  /// Creates a [TrinaDefaultPopupCellEditingWidget].
  ///
  /// [controller] controls the text displayed in the field.
  /// [onTap] is called when the field is tapped.
  /// [popupMenuIcon] optionally overrides the default icon.
  /// [stateManager] provides access to grid configuration for styling.
  const TrinaDefaultPopupCellEditingWidget({
    super.key,
    required this.controller,
    required this.onTap,
    this.popupMenuIcon,
    this.stateManager,
  });

  /// The controller for the text field.
  final TextEditingController controller;

  /// Called when the field is tapped.
  final void Function() onTap;

  /// The icon to display as the popup menu indicator.
  final IconData? popupMenuIcon;

  /// The state manager for accessing grid configuration.
  final TrinaGridStateManager? stateManager;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: TextFormField(
        onTap: onTap,
        controller: controller,
        mouseCursor: SystemMouseCursors.click,
        readOnly: true,
        style: stateManager?.configuration.style.cellTextStyle,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
          suffixIcon: popupMenuIcon != null
              ? MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(popupMenuIcon),
                )
              : null,
        ),
      ),
    );
  }
}
