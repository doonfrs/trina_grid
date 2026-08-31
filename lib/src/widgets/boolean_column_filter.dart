import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:trina_grid/src/ui/widgets/ensure_shad_theme.dart';
import 'package:trina_grid/src/ui/widgets/trina_dropdown_menu.dart';
import 'package:trina_grid/src/widgets/filter_dropdown_field.dart';
import 'package:trina_grid/trina_grid.dart';

/// Column filter widget that replaces the text field with a dropdown
/// offering ALL / True / False options.
///
/// Selecting ALL clears the column filter. True and False keep rows whose
/// cell value is `true` or `false` respectively. It is used automatically
/// for boolean columns and can be forced on any column with
/// [TrinaFilterColumnWidgetDelegate.booleanSelect].
class BooleanColumnFilter extends StatefulWidget {
  const BooleanColumnFilter({
    super.key,
    required this.stateManager,
    required this.column,
    required this.focusNode,
    required this.menuController,
    required this.enabled,
    required this.filterValue,
    required this.allLabel,
    required this.trueLabel,
    required this.falseLabel,
    required this.onChanged,
  });

  final TrinaGridStateManager stateManager;

  final TrinaColumn column;

  final FocusNode focusNode;

  final MenuController menuController;

  final bool enabled;

  /// The raw filter value: '' (no filter), 'true', 'false' or any other
  /// string previously set through the filter popup or programmatically.
  final String filterValue;

  final String allLabel;

  final String trueLabel;

  final String falseLabel;

  /// Called with '' (clear), 'true' or 'false'.
  final void Function(String value) onChanged;

  @override
  State<BooleanColumnFilter> createState() => _BooleanColumnFilterState();
}

class _BooleanColumnFilterState extends State<BooleanColumnFilter> {
  static const double _itemHeight = 40.0;

  /// Vertical chrome the [MenuAnchor] adds outside the menu content,
  /// mirroring the cell editor menus.
  static const double _menuVerticalChrome = 16.0;

  static const double _minMenuWidth = 120.0;

  List<String> get _labels => [
    widget.allLabel,
    widget.trueLabel,
    widget.falseLabel,
  ];

  static const List<String> _values = ['', 'true', 'false'];

  String get _displayLabel {
    switch (widget.filterValue) {
      case '':
      case 'true':
      case 'false':
        return _labels[_values.indexOf(widget.filterValue)];
      default:
        return widget.filterValue;
    }
  }

  String? get _initialValue => _values.contains(widget.filterValue)
      ? _labels[_values.indexOf(widget.filterValue)]
      : null;

  double get _menuWidth =>
      widget.column.width < _minMenuWidth ? _minMenuWidth : widget.column.width;

  void _onItemSelected(String label) {
    widget.menuController.close();

    final index = _labels.indexOf(label);

    widget.onChanged(index == -1 ? '' : _values[index]);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.stateManager.configuration.style;

    return EnsureShadTheme(
      child: Builder(
        builder: (context) {
          final shadTheme = ShadTheme.of(context);
          final shadColors = shadTheme.colorScheme;

          return MenuAnchor(
            controller: widget.menuController,
            consumeOutsideTap: true,
            alignmentOffset: const Offset(0, 4),
            style: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(shadColors.popover),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: shadTheme.radius,
                  side: BorderSide(color: shadColors.border),
                ),
              ),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(vertical: 4),
              ),
              elevation: const WidgetStatePropertyAll(4),
              minimumSize: WidgetStatePropertyAll(Size(_menuWidth, 0)),
              maximumSize: WidgetStatePropertyAll(
                Size(
                  double.infinity,
                  _labels.length * _itemHeight + _menuVerticalChrome,
                ),
              ),
              alignment: Alignment.bottomLeft,
            ),
            menuChildren: [
              TrinaDropdownMenu<String>(
                items: _labels,
                onItemSelected: _onItemSelected,
                width: _menuWidth,
                initialValue: _initialValue,
                itemHeight: _itemHeight,
                maxHeight: _labels.length * _itemHeight,
              ),
            ],
            builder: (context, controller, child) {
              return FilterDropdownField(
                focusNode: widget.focusNode,
                enabled: widget.enabled,
                text: _displayLabel,
                isMenuOpen: controller.isOpen,
                onTap: () {
                  widget.stateManager.setKeepFocus(false);
                  controller.isOpen ? controller.close() : controller.open();
                },
                fillColor:
                    style.filterHeaderColor ??
                    (widget.enabled
                        ? style.cellColorInEditState
                        : style.cellColorInReadOnlyState),
                textStyle: style.cellTextStyle,
                borderColor: style.borderColor,
                activatedBorderColor: style.activatedBorderColor,
                inactivatedBorderColor: style.inactivatedBorderColor,
                iconColor: style.filterHeaderIconColor ?? style.iconColor,
              );
            },
          );
        },
      ),
    );
  }
}
