import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:trina_grid/src/ui/widgets/ensure_shad_theme.dart';
import 'package:trina_grid/src/widgets/filter_dropdown_field.dart';
import 'package:trina_grid/trina_grid.dart';

/// Column filter widget that replaces the text field with a dropdown of
/// checkboxes, one per item, plus a "Select all" tristate toggle.
///
/// Every check/uncheck immediately re-filters the grid (live filtering).
/// The selected items are joined with a newline into the filter value and
/// compared with [TrinaFilterTypeMultiItems]; an empty selection clears the
/// filter. It is used automatically for select columns (with
/// [TrinaColumnTypeSelect.enableColumnFilter] enabled) and can be forced on
/// any column with [TrinaFilterColumnWidgetDelegate.multiSelect].
class MultiSelectColumnFilter extends StatefulWidget {
  const MultiSelectColumnFilter({
    super.key,
    required this.stateManager,
    required this.column,
    required this.focusNode,
    required this.menuController,
    required this.enabled,
    required this.filterValue,
    required this.items,
    required this.caseSensitive,
    required this.allLabel,
    required this.selectAllLabel,
    required this.onChanged,
  });

  final TrinaGridStateManager stateManager;

  final TrinaColumn column;

  final FocusNode focusNode;

  final MenuController menuController;

  final bool enabled;

  /// The raw filter value: newline or comma separated selected items,
  /// possibly set through the filter popup or programmatically.
  final String filterValue;

  final List<String> items;

  final bool caseSensitive;

  final String allLabel;

  final String selectAllLabel;

  /// Called with the selected items joined by a newline,
  /// or '' when the selection is empty.
  final void Function(String value) onChanged;

  @override
  State<MultiSelectColumnFilter> createState() =>
      _MultiSelectColumnFilterState();
}

class _MultiSelectColumnFilterState extends State<MultiSelectColumnFilter> {
  static const double _itemHeight = 40.0;

  static const double _selectAllHeaderHeight = 44.0;

  static const double _maxMenuHeight = 300.0;

  static const double _minMenuWidth = 180.0;

  /// Vertical chrome the [MenuAnchor] adds outside the menu content,
  /// mirroring the cell editor menus.
  static const double _menuVerticalChrome = 16.0;

  Set<String> _toLowerCaseSet(Iterable<String> values) =>
      values.map((e) => e.trim().toLowerCase()).toSet();

  /// The currently selected items, resolved against [MultiSelectColumnFilter.items]
  /// so the checkbox state and the filter value stay in sync even when the
  /// value was set externally.
  Set<String> get _selectedItems {
    final raw = widget.filterValue
        .split(RegExp(r'[\n,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);

    if (widget.caseSensitive) {
      return raw.toSet();
    }

    final lowerCased = _toLowerCaseSet(raw);

    return widget.items
        .where((item) => lowerCased.contains(item.trim().toLowerCase()))
        .toSet();
  }

  bool _isSelected(String item) {
    if (widget.caseSensitive) {
      return _selectedItems.contains(item);
    }

    return _toLowerCaseSet(_selectedItems).contains(item.toLowerCase());
  }

  bool? get _selectAllValue {
    if (widget.items.isEmpty || _selectedItems.isEmpty) {
      return false;
    }

    return _selectedItems.length == widget.items.length ? true : null;
  }

  double get _menuWidth =>
      widget.column.width < _minMenuWidth ? _minMenuWidth : widget.column.width;

  double get _menuContentHeight {
    final height =
        widget.items.length * _itemHeight + _selectAllHeaderHeight + 1.0;

    return height > _maxMenuHeight ? _maxMenuHeight : height;
  }

  String get _displayText {
    final selected = widget.items.where(_isSelected).toList();

    if (selected.isEmpty) {
      return widget.allLabel;
    }

    return selected.join(', ');
  }

  void _emitSelection(Set<String> selected) {
    // Preserve the items order instead of the order the user toggled in.
    final ordered = widget.items.where(selected.contains).toList();

    widget.onChanged(ordered.join('\n'));
  }

  void _toggleItem(String item, bool checked) {
    final selected = widget.items.where(_isSelected).toSet();

    checked ? selected.add(item) : selected.remove(item);

    _emitSelection(selected);
  }

  void _toggleSelectAll() {
    final allSelected =
        _selectedItems.length == widget.items.length && widget.items.isNotEmpty;

    _emitSelection(allSelected ? <String>{} : widget.items.toSet());
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
                Size(double.infinity, _maxMenuHeight + _menuVerticalChrome),
              ),
              alignment: Alignment.bottomLeft,
            ),
            menuChildren: [
              SizedBox(
                width: _menuWidth,
                height: _menuContentHeight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSelectAllHeader(style),
                    const Divider(height: 1),
                    Expanded(child: _buildItemList(style)),
                  ],
                ),
              ),
            ],
            builder: (context, controller, child) {
              return FilterDropdownField(
                focusNode: widget.focusNode,
                enabled: widget.enabled,
                text: _displayText,
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
                suffixIcon: _buildClearButton(style),
              );
            },
          );
        },
      ),
    );
  }

  Widget? _buildClearButton(TrinaGridStyleConfig style) {
    if (_selectedItems.isEmpty) {
      return null;
    }

    return SizedBox(
      width: 30,
      child: Opacity(
        opacity: 0.5,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: widget.enabled ? () => widget.onChanged('') : null,
          icon: Icon(
            Icons.clear,
            size: 16,
            color: style.filterHeaderIconColor ?? style.iconColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectAllHeader(TrinaGridStyleConfig style) {
    return SizedBox(
      height: _selectAllHeaderHeight,
      child: InkWell(
        onTap: widget.enabled ? _toggleSelectAll : null,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  widget.selectAllLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style.cellTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildCheckbox(
              style: style,
              value: _selectAllValue,
              tristate: true,
              onChanged: (_) => _toggleSelectAll(),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList(TrinaGridStyleConfig style) {
    if (widget.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(widget.allLabel, style: style.cellTextStyle),
        ),
      );
    }

    return ListView.builder(
      primary: false,
      itemExtent: _itemHeight,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];

        return _buildItemRow(style, item);
      },
    );
  }

  Widget _buildItemRow(TrinaGridStyleConfig style, String item) {
    final checked = _isSelected(item);

    return InkWell(
      onTap: widget.enabled ? () => _toggleItem(item, !checked) : null,
      child: Row(
        children: [
          _buildCheckbox(
            style: style,
            value: checked,
            tristate: false,
            onChanged: (changed) => _toggleItem(item, changed ?? false),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style.cellTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox({
    required TrinaGridStyleConfig style,
    required bool? value,
    required bool tristate,
    required void Function(bool? changed) onChanged,
  }) {
    return SizedBox(
      width: _itemHeight,
      child: Center(
        child: TrinaScaledCheckbox(
          value: value,
          handleOnChanged: widget.enabled ? onChanged : null,
          tristate: tristate,
          scale: 0.9,
          unselectedColor: style.cellUnselectedColor,
          activeColor: style.cellActiveColor,
          checkColor: style.cellCheckedColor,
          side: style.cellCheckedSide,
        ),
      ),
    );
  }
}
