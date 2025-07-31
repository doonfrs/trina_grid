import 'package:flutter/material.dart';

/// Used as the default widget for popup cells when in editing state.
class TrinaDefaultPopupCellEditingWidget extends StatelessWidget {
  /// Creates a [TrinaDefaultPopupCellEditingWidget].
  ///
  /// [controller] controls the text displayed in the field.
  /// [onTap] is called when the field is tapped.
  /// [popupMenuIcon] optionally overrides the default icon.
  const TrinaDefaultPopupCellEditingWidget({
    super.key,
    required this.controller,
    required this.onTap,
    this.popupMenuIcon,
  });

  /// The controller for the text field.
  final TextEditingController controller;

  /// Called when the field is tapped.
  final void Function() onTap;

  /// The icon to display as the popup menu indicator.
  final IconData? popupMenuIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      controller: controller,
      mouseCursor: SystemMouseCursors.click,
      readOnly: true,
      decoration: InputDecoration(
        border: InputBorder.none,
        suffixIcon: popupMenuIcon != null
            ? MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Icon(popupMenuIcon),
              )
            : null,
      ),
    );
  }
}
