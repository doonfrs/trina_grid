import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

typedef TrinaColumnValueFormatter = String Function(dynamic value);

typedef TrinaColumnRenderer =
    Widget Function(TrinaColumnRendererContext rendererContext);

typedef TrinaColumnFooterRenderer =
    Widget Function(TrinaColumnFooterRendererContext context);

/// Renderer for customizing the column title widget
typedef TrinaColumnTitleRenderer =
    Widget Function(TrinaColumnTitleRendererContext rendererContext);

/// It dynamically determines whether the cells of the column are in the edit state.
///
/// Once the [readOnly] value is set,
/// whether the cell is editable cannot be changed during runtime,
/// but if this callback is implemented,
/// it can be determined whether the cell can be edited or not according to the state of the cell.
typedef TrinaColumnCheckReadOnly = bool Function(TrinaRow row, TrinaCell cell);

class TrinaColumn {
  /// A title to be displayed on the screen.
  /// If a titleSpan value is set, the title value is not displayed.
  String title;

  /// Specifies the field name of the row to be connected to the column.
  String field;

  /// Set the column type.
  ///
  /// Text, number, select, date, time, etc.
  /// ex) TrinaColumnType.text(), TrinaColumnType.number() ...
  TrinaColumnType type;

  bool readOnly;

  double width;

  double minWidth;

  /// Customisable title padding.
  /// It takes precedence over defaultColumnTitlePadding in TrinaGridConfiguration.
  EdgeInsets? titlePadding;

  EdgeInsets? filterPadding;

  /// Customize the column with TextSpan or WidgetSpan instead of the column's title string.
  ///
  /// ```
  /// titleSpan: const TextSpan(
  ///   children: [
  ///     WidgetSpan(
  ///       child: Text(
  ///         '* ',
  ///         style: TextStyle(color: Colors.red),
  ///       ),
  ///     ),
  ///     TextSpan(text: 'column title'),
  ///   ],
  /// ),
  /// ```
  InlineSpan? titleSpan;

  /// Customisable cell padding.
  /// It takes precedence over defaultCellPadding in TrinaGridConfiguration.
  EdgeInsets? cellPadding;

  /// Text alignment in Cell. (Left, Right, Center)
  TrinaColumnTextAlign textAlign;

  /// Text alignment in Title. (Left, Right, Center)
  TrinaColumnTextAlign titleTextAlign;

  /// Freeze the column to the left and right.
  /// If the total width of the non-frozen column is 200 or less,
  /// it is processed to be unfreeze even if the frozen column is set.
  TrinaColumnFrozen frozen;

  /// Set column sorting.
  TrinaColumnSort sort;

  /// Formatter for display of cell values.
  TrinaColumnValueFormatter? formatter;

  /// Apply the formatter in the editing state.
  /// However, it is applied only when the cell is readonly
  /// or the text cannot be directly modified, such as in the form of select popup.
  bool applyFormatterInEditing;

  /// Background color of column title.
  Color? backgroundColor;

  /// Customize the widget in the default cell.
  ///
  /// ```dart
  /// renderer: (rendererContext) {
  ///  Color textColor = Colors.black;
  ///
  ///  if (rendererContext.cell.value == 'red') {
  ///    textColor = Colors.red;
  ///  } else if (rendererContext.cell.value == 'blue') {
  ///    textColor = Colors.blue;
  ///  } else if (rendererContext.cell.value == 'green') {
  ///    textColor = Colors.green;
  ///  }
  ///
  ///  return Text(
  ///    rendererContext.cell.value.toString(),
  ///    style: TextStyle(
  ///      color: textColor,
  ///      fontWeight: FontWeight.bold,
  ///    ),
  ///  );
  /// },
  /// ```
  ///
  /// Consider wrapping a RepaintBoundary widget
  /// if you are defining custom cells with high paint cost.
  TrinaColumnRenderer? renderer;

  /// A callback that returns a widget
  /// for expressing aggregate values at the bottom.
  ///
  /// ```dart
  /// footerRenderer: (rendererContext) {
  ///   return TrinaAggregateColumnFooter(
  ///     rendererContext: rendererContext,
  ///     type: TrinaAggregateColumnType.count,
  ///     numberFormat: NumberFormat('Checked : #,###.###'),
  ///     filter: (cell) => cell.row.checked == true,
  ///     alignment: Alignment.center,
  ///   );
  /// },
  /// ```
  TrinaColumnFooterRenderer? footerRenderer;

  /// If [TrinaAutoSizeMode] is enabled,
  /// column autoscaling is ignored if [suppressedAutoSize] is true.
  bool suppressedAutoSize;

  /// Change the position of the column by dragging the column title.
  bool enableColumnDrag;

  /// Change the position of the row by dragging the icon in the cell.
  bool enableRowDrag;

  /// A checkbox appears in the cell of the column.
  bool enableRowChecked;

  int rowCheckBoxGroupDepth;

  bool enableTitleChecked;

  bool Function(TrinaRow row)? disableRowCheckboxWhen;

  /// Sort rows by tapping on the column heading.
  bool enableSorting;

  /// Displays the right icon of the column title.
  ///
  /// The [TrinaGridConfiguration.columnContextIcon] icon appears.
  /// Tap this icon to bring up the context menu.
  ///
  /// If [enableDropToResize] is also activated,
  /// you can adjust the column width by dragging this icon.
  bool enableContextMenu;

  /// Display the right icon for drop to resize the column
  ///
  /// The [TrinaGridConfiguration.columnResizeIcon] icon appears.
  /// By dragging this icon to the left or right, the width of the column can be adjusted.
  /// Can't narrow down to less than [minWidth].
  /// Also, if [frozen] is set,
  /// it can be expanded only within the limit of the width of the frozen column.
  ///
  /// If [enableContextMenu] is enabled, the contextMenu icon appears.
  /// In this case, dragging the context menu icon adjusts the column width.
  bool enableDropToResize;

  /// Displays filter-related menus in the column context menu.
  /// Valid only when [enableContextMenu] is activated.
  bool enableFilterMenuItem;

  /// Displays Hide column menu in the column context menu.
  /// Valid only when [enableContextMenu] is activated.
  bool enableHideColumnMenuItem;

  /// Displays Set columns menu in the column context menu.
  /// Valid only when [enableContextMenu] is activated.
  bool enableSetColumnsMenuItem;

  bool enableAutoEditing;

  /// Entering the Enter key or tapping the cell enters the Editing mode.
  bool? enableEditingMode;

  /// Hide the column.
  bool hide;

  /// The widget of the filter column, this can be customized with the multiple constructors, defaults to a [TrinaFilterColumnWidgetDelegate.initial()]
  TrinaFilterColumnWidgetDelegate? filterWidgetDelegate;

  /// Optional validator function that returns an error message string if validation fails,
  /// or null if validation passes. This is called before the cell value is updated.
  final String? Function(dynamic value, TrinaValidationContext context)?
  validator;

  /// Custom renderer for the edit cell widget.
  /// This allows customizing the edit cell UI for this specific column.
  /// If provided, this takes precedence over the grid-level editCellRenderer.
  final Widget Function(
    Widget defaultEditCellWidget,
    TrinaCell cell,
    TextEditingController controller,
    FocusNode focusNode,
    Function(dynamic value)? handleSelected,
  )?
  editCellRenderer;

  /// Custom renderer for the column title.
  /// This allows complete customization of the column title UI.
  /// If provided, this takes precedence over the title, titleSpan, and other title-related properties.
  ///
  /// ```dart
  /// titleRenderer: (rendererContext) {
  ///   // Create a custom title with icon, text and using the context menu icon
  ///   return Container(
  ///     width: rendererContext.column.width,
  ///     height: rendererContext.height,
  ///     decoration: BoxDecoration(
  ///       gradient: LinearGradient(
  ///         colors: [Colors.blue.shade200, Colors.blue.shade500],
  ///         begin: Alignment.topLeft,
  ///         end: Alignment.bottomRight,
  ///       ),
  ///       border: Border(
  ///         right: BorderSide(
  ///           color: Colors.grey.shade300,
  ///           width: 1.0,
  ///         ),
  ///       ),
  ///     ),
  ///     padding: const EdgeInsets.symmetric(horizontal: 8.0),
  ///     child: Row(
  ///       children: [
  ///         Icon(Icons.star, color: Colors.amber),
  ///         const SizedBox(width: 4),
  ///         Expanded(
  ///           child: Text(
  ///             rendererContext.column.title,
  ///             style: TextStyle(
  ///               fontWeight: FontWeight.bold,
  ///               color: Colors.white,
  ///             ),
  ///             overflow: TextOverflow.ellipsis,
  ///           ),
  ///         ),
  ///         // Show filter icon if column is filtered
  ///         if (rendererContext.isFiltered)
  ///           IconButton(
  ///             icon: Icon(Icons.filter_alt, color: Colors.white),
  ///             onPressed: () {
  ///               rendererContext.stateManager.showFilterPopup(
  ///                 context,
  ///                 calledColumn: rendererContext.column,
  ///               );
  ///             },
  ///           ),
  ///         // Use the provided context menu icon if needed
  ///         if (rendererContext.showContextIcon)
  ///           rendererContext.contextMenuIcon,
  ///       ],
  ///     ),
  ///   );
  /// },
  /// ```
  TrinaColumnTitleRenderer? titleRenderer;

  /// Controls how the Enter key behaves in this column's filter.
  /// If null, it falls back to the grid's enterKeyAction configuration.
  final TrinaGridEnterKeyAction? filterEnterKeyAction;

  // Optional metadata to attach additional data to columns
  Map<String, dynamic>? metadata = {};

  TrinaColumn({
    required this.title,
    required this.field,
    required this.type,
    this.readOnly = false,
    TrinaColumnCheckReadOnly? checkReadOnly,
    this.width = TrinaGridSettings.columnWidth,
    this.minWidth = TrinaGridSettings.minColumnWidth,
    this.titlePadding,
    this.filterPadding,
    this.titleSpan,
    this.cellPadding,
    this.textAlign = TrinaColumnTextAlign.start,
    this.titleTextAlign = TrinaColumnTextAlign.start,
    this.frozen = TrinaColumnFrozen.none,
    this.sort = TrinaColumnSort.none,
    this.formatter,
    this.applyFormatterInEditing = false,
    this.backgroundColor,
    this.renderer,
    this.footerRenderer,
    this.titleRenderer,
    this.suppressedAutoSize = false,
    this.enableColumnDrag = true,
    this.enableRowDrag = false,
    this.enableRowChecked = false,
    this.rowCheckBoxGroupDepth = 0,
    this.enableTitleChecked = true,
    this.enableSorting = true,
    this.enableContextMenu = true,
    this.enableDropToResize = true,
    this.enableFilterMenuItem = true,
    this.enableHideColumnMenuItem = true,
    this.enableSetColumnsMenuItem = true,
    this.enableAutoEditing = false,
    this.enableEditingMode = true,
    this.hide = false,
    this.filterWidgetDelegate =
        const TrinaFilterColumnWidgetDelegate.textField(),
    this.disableRowCheckboxWhen,
    this.validator,
    this.editCellRenderer,
    this.filterEnterKeyAction,
    this.metadata,
  }) : _key = UniqueKey(),
       _checkReadOnly = checkReadOnly;

  final Key _key;

  final TrinaColumnCheckReadOnly? _checkReadOnly;

  Key get key => _key;

  bool get hasRenderer => renderer != null;

  bool get hasTitleRenderer => titleRenderer != null;

  bool get hasCheckReadOnly => _checkReadOnly != null;

  FocusNode? _filterFocusNode;

  FocusNode? get filterFocusNode {
    return _filterFocusNode;
  }

  TrinaFilterType? _defaultFilter;

  TrinaFilterType get defaultFilter =>
      _defaultFilter ?? const TrinaFilterTypeContains();

  bool get isShowRightIcon =>
      enableContextMenu || enableDropToResize || !sort.isNone;

  TrinaColumnGroup? group;

  String get titleWithGroup {
    if (group == null) {
      return title;
    }

    List<String> titleList = [title];

    if (group!.expandedColumn != true) {
      titleList.add(group!.title);
    }

    for (final g in group!.parents.toList()) {
      titleList.add(g.title);
    }

    return titleList.reversed.join(' ');
  }

  /// [startPosition] is the position value for the position of the column from the left.
  ///
  /// Updated when the [TrinaGridStateManager.updateVisibilityLayout] method is called.
  ///
  /// [startPosition] is used to determine the position to scroll left and right when moving the keyboard
  /// or whether the columns in the center area are displayed in the screen area.
  double startPosition = 0;

  bool checkReadOnly(TrinaRow row, TrinaCell cell) {
    return hasCheckReadOnly ? _checkReadOnly!(row, cell) : readOnly;
  }

  void setFilterFocusNode(FocusNode? node) {
    _filterFocusNode = node;
  }

  void setDefaultFilter(TrinaFilterType filter) {
    _defaultFilter = filter;
  }

  String formattedValueForType(dynamic value) {
    // Use the generic applyFormat method from the extension
    // This will handle all column types that implement TrinaColumnTypeHasFormat
    if (type.hasFormat) {
      return type.applyFormat(value);
    }

    if (type is TrinaColumnTypeBoolean) {
      switch (value) {
        case true:
          return (type as TrinaColumnTypeBoolean).trueText;
        case false:
          return (type as TrinaColumnTypeBoolean).falseText;
        default:
          return '';
      }
    }
    return value.toString();
  }

  String formattedValueForDisplay(dynamic value) {
    if (formatter != null) {
      return formatter!(value).toString();
    }

    return formattedValueForType(value);
  }

  String formattedValueForDisplayInEditing(dynamic value) {
    if (type is TrinaColumnTypeWithNumberFormat) {
      return value.toString().replaceFirst(
        '.',
        (type as TrinaColumnTypeWithNumberFormat)
            .numberFormat
            .symbols
            .DECIMAL_SEP,
      );
    } else if (type is TrinaColumnTypeBoolean) {
      switch (value) {
        case true:
          return (type as TrinaColumnTypeBoolean).trueText;
        case false:
          return (type as TrinaColumnTypeBoolean).falseText;
        default:
          return '';
      }
    }

    if (formatter != null) {
      final bool allowFormatting =
          readOnly || type.isSelect || type.isTime || type.isDate;

      if (applyFormatterInEditing && allowFormatting) {
        return formatter!(value).toString();
      }
    }

    return value.toString();
  }
}

class TrinaFilterColumnWidgetDelegate {
  const TrinaFilterColumnWidgetDelegate.textField({
    this.filterHintText,
    this.filterHintTextColor,
    this.filterSuffixIcon,
    this.onFilterSuffixTap,
    this.clearIcon = const Icon(Icons.clear),
    this.onClear,
  }) : filterWidgetBuilder = null,
       caseSensitive = null,
       isMultiItems = false;

  const TrinaFilterColumnWidgetDelegate.builder({this.filterWidgetBuilder})
    : filterSuffixIcon = null,
      onFilterSuffixTap = null,
      filterHintText = null,
      filterHintTextColor = null,
      clearIcon = const Icon(Icons.clear),
      onClear = null,
      caseSensitive = null,
      isMultiItems = false;

  const TrinaFilterColumnWidgetDelegate.multiItems({this.caseSensitive = true})
    : filterSuffixIcon = null,
      onFilterSuffixTap = null,
      filterHintText = null,
      filterHintTextColor = null,
      filterWidgetBuilder = null,
      clearIcon = const Icon(Icons.clear),
      onClear = null,
      isMultiItems = true;

  ///Set hint text for filter field
  final String? filterHintText;

  ///Set hint text color for filter field
  final Color? filterHintTextColor;

  ///Set suffix icon for filter field
  final Widget? filterSuffixIcon;

  /// Clear icon in the text field, if onClear is null, this will not appear
  final Widget clearIcon;

  /// If this is set, it will be called when the clear button is tapped, if this is null there won't be a clear icon
  final Function? onClear;

  /// Set a custom on tap event for the filter suffix icon
  final Function(
    FocusNode focusNode,
    TextEditingController controller,
    bool enabled,
    void Function(dynamic changed) handleOnChanged,
    TrinaGridStateManager stateManager,
  )?
  onFilterSuffixTap;

  final Widget Function(
    FocusNode focusNode,
    TextEditingController controller,
    bool enabled,
    void Function(dynamic changed) handleOnChanged,
    TrinaGridStateManager stateManager,
  )?
  filterWidgetBuilder;

  final bool? isMultiItems;

  final bool? caseSensitive;
}

class TrinaColumnRendererContext {
  final TrinaColumn column;

  final int rowIdx;

  final TrinaRow row;

  final TrinaCell cell;

  final TrinaGridStateManager stateManager;

  TrinaColumnRendererContext({
    required this.column,
    required this.rowIdx,
    required this.row,
    required this.cell,
    required this.stateManager,
  });
}

class TrinaColumnFooterRendererContext {
  final TrinaColumn column;

  final TrinaGridStateManager stateManager;

  TrinaColumnFooterRendererContext({
    required this.column,
    required this.stateManager,
  });
}

/// Context provided to the titleRenderer function
class TrinaColumnTitleRendererContext {
  /// The column being rendered
  final TrinaColumn column;

  /// The state manager instance
  final TrinaGridStateManager stateManager;

  /// The height of the column title
  final double height;

  /// Whether the context menu icon should be shown
  final bool showContextIcon;

  /// The default context menu icon widget, provided for convenience
  final Widget contextMenuIcon;

  /// Whether the column is filtered
  final bool isFiltered;

  /// Function to show the context menu
  final void Function(BuildContext context, Offset position)? showContextMenu;

  TrinaColumnTitleRendererContext({
    required this.column,
    required this.stateManager,
    required this.height,
    required this.showContextIcon,
    required this.contextMenuIcon,
    required this.isFiltered,
    this.showContextMenu,
  });
}

enum TrinaColumnTextAlign {
  start,
  left,
  center,
  right,
  end;

  TextAlign get value {
    switch (this) {
      case TrinaColumnTextAlign.start:
        return TextAlign.start;
      case TrinaColumnTextAlign.left:
        return TextAlign.left;
      case TrinaColumnTextAlign.center:
        return TextAlign.center;
      case TrinaColumnTextAlign.right:
        return TextAlign.right;
      case TrinaColumnTextAlign.end:
        return TextAlign.end;
    }
  }

  AlignmentGeometry get alignmentValue {
    switch (this) {
      case TrinaColumnTextAlign.start:
        return AlignmentDirectional.centerStart;
      case TrinaColumnTextAlign.left:
        return Alignment.centerLeft;
      case TrinaColumnTextAlign.center:
        return Alignment.center;
      case TrinaColumnTextAlign.right:
        return Alignment.centerRight;
      case TrinaColumnTextAlign.end:
        return AlignmentDirectional.centerEnd;
    }
  }

  bool get isStart => this == TrinaColumnTextAlign.start;

  bool get isLeft => this == TrinaColumnTextAlign.left;

  bool get isCenter => this == TrinaColumnTextAlign.center;

  bool get isRight => this == TrinaColumnTextAlign.right;

  bool get isEnd => this == TrinaColumnTextAlign.end;
}

enum TrinaColumnFrozen {
  none,
  start,
  end;

  bool get isNone {
    return this == TrinaColumnFrozen.none;
  }

  bool get isStart {
    return this == TrinaColumnFrozen.start;
  }

  bool get isEnd {
    return this == TrinaColumnFrozen.end;
  }

  bool get isFrozen {
    return this == TrinaColumnFrozen.start || this == TrinaColumnFrozen.end;
  }
}

enum TrinaColumnSort {
  none,
  ascending,
  descending;

  bool get isNone {
    return this == TrinaColumnSort.none;
  }

  bool get isAscending {
    return this == TrinaColumnSort.ascending;
  }

  bool get isDescending {
    return this == TrinaColumnSort.descending;
  }
}

/// Context object passed to column validators containing information about the validation
class TrinaValidationContext {
  /// The column being validated
  final TrinaColumn column;

  /// The row containing the cell being validated
  final TrinaRow row;

  /// The row index
  final int rowIdx;

  /// The previous value before the change
  final dynamic oldValue;

  /// The state manager instance
  final TrinaGridStateManager stateManager;

  const TrinaValidationContext({
    required this.column,
    required this.row,
    required this.rowIdx,
    required this.oldValue,
    required this.stateManager,
  });
}
