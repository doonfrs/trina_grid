import 'package:flutter/material.dart';

/// A compact, read-only field that visually matches the text filter field
/// of the filter row and anchors a dropdown menu.
///
/// Used by the boolean ([BooleanColumnFilter]) and the multi-select
/// ([MultiSelectColumnFilter]) column filter dropdowns.
class FilterDropdownField extends StatelessWidget {
  const FilterDropdownField({
    super.key,
    required this.focusNode,
    required this.enabled,
    required this.text,
    required this.isMenuOpen,
    required this.onTap,
    required this.fillColor,
    required this.textStyle,
    required this.borderColor,
    required this.activatedBorderColor,
    required this.inactivatedBorderColor,
    required this.iconColor,
    this.suffixIcon,
  });

  final FocusNode focusNode;

  final bool enabled;

  /// The text to display. When empty the field is left blank, matching the
  /// behavior of the text filter field without a hint.
  final String text;

  final bool isMenuOpen;

  final VoidCallback onTap;

  final Color fillColor;

  final TextStyle? textStyle;

  final Color borderColor;

  final Color activatedBorderColor;

  final Color inactivatedBorderColor;

  final Color iconColor;

  /// An additional icon shown before the dropdown arrow,
  /// e.g. a clear-selection button.
  final Widget? suffixIcon;

  InputBorder _border(Color color) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 0.0),
    borderRadius: BorderRadius.zero,
  );

  @override
  Widget build(BuildContext context) {
    final border = _border(borderColor);

    final effectiveTextStyle = textStyle ?? DefaultTextStyle.of(context).style;

    return IgnorePointer(
      ignoring: !enabled,
      child: Focus(
        focusNode: focusNode,
        child: InkWell(
          onTap: onTap,
          child: InputDecorator(
            isFocused: isMenuOpen,
            isEmpty: false,
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor,
              border: border,
              enabledBorder: border,
              disabledBorder: _border(inactivatedBorderColor),
              focusedBorder: _border(activatedBorderColor),
              contentPadding: const EdgeInsets.all(5),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (suffixIcon != null) ...[
                    suffixIcon!,
                    const SizedBox(width: 4),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: AnimatedRotation(
                      turns: isMenuOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: iconColor.withValues(alpha: enabled ? 1.0 : 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: enabled
                  ? effectiveTextStyle
                  : effectiveTextStyle.copyWith(
                      color: effectiveTextStyle.color?.withValues(alpha: 0.5),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
