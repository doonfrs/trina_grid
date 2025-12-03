import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

class TrinaGridConfiguration {
  /// When you select a value in the pop-up grid, it moves down.
  final bool enableMoveDownAfterSelecting;

  /// Moves the current cell when focus reaches the left or right edge in the edit state.
  final bool enableMoveHorizontalInEditing;

  /// Automatically selects the first row when in selection mode.
  final bool enableAutoSelectFirstRow;

  /// [TrinaGridRowSelectionCheckBoxBehavior.none]
  /// Selecting a row does nothing to its checkbox
  ///
  /// [TrinaGridRowSelectionCheckBoxBehavior.checkRow]
  /// Automatically enables the checkbox of the selected rows
  ///
  /// [TrinaGridRowSelectionCheckBoxBehavior.toggleCheckRow]
  /// Automatically toggles the checkbox of the selected rows
  ///
  /// [TrinaGridRowSelectionCheckBoxBehavior.singleRowCheck]
  /// Automatically enabels the checkbox of a selected row (if another row is checked via select, the previous one is unchecked)
  ///
  /// [TrinaGridRowSelectionCheckBoxBehavior.singleRowCheck]
  /// Automatically toggles the checkbox of a selected row (if another row is checked via select, the previous one is unchecked)
  ///
  /// Important: Only works with mode: TrinaGridMode.selectWithOneTap,
  final TrinaGridRowSelectionCheckBoxBehavior rowSelectionCheckBoxBehavior;

  /// [TrinaEnterKeyAction.EditingAndMoveDown]
  /// It switches to the editing state, and moves down in the editing state.
  ///
  /// [TrinaEnterKeyAction.EditingAndMoveRight]
  /// It switches to the editing state, and moves to the right in the editing state.
  ///
  /// [TrinaEnterKeyAction.ToggleEditing]
  /// The editing state is toggled and cells are not moved.
  ///
  /// [TrinaEnterKeyAction.None]
  /// There is no action.
  final TrinaGridEnterKeyAction enterKeyAction;

  /// Tab key action type.
  ///
  /// [TrinaGridTabKeyAction.normal]
  /// {@macro trina_grid_tab_key_action_normal}
  ///
  /// [TrinaGridTabKeyAction.moveToNextOnEdge]
  /// {@macro trina_grid_tab_key_action_moveToNextOnEdge}
  final TrinaGridTabKeyAction tabKeyAction;

  /// Set the mode to select cells or rows.
  ///
  /// [TrinaGridSelectingMode.cell] selects each cell.
  /// [TrinaGridSelectingMode.row] selects row by row.
  /// [TrinaGridSelectingMode.none] does nothing.
  ///
  /// Note: This setting may be overridden by the grid mode:
  /// - In [TrinaGridMode.select] or [TrinaGridMode.selectWithOneTap],
  ///   it's forced to [TrinaGridSelectingMode.none]
  /// - In [TrinaGridMode.multiSelect], it's forced to [TrinaGridSelectingMode.row]
  final TrinaGridSelectingMode selectingMode;

  /// Set custom shortcut keys.
  ///
  /// Refer to the code below to redefine the action of a specific key
  /// or add a new shortcut action.
  /// The example code below overrides the enter key behavior.
  ///
  /// ```dart
  /// shortcut: TrinaGridShortcut(
  ///   actions: {
  ///     ...TrinaGridShortcut.defaultActions,
  ///     LogicalKeySet(LogicalKeyboardKey.enter): CustomEnterKeyAction(),
  ///   },
  /// ),
  ///
  /// class CustomEnterKeyAction extends TrinaGridShortcutAction {
  ///   @override
  ///   void execute({
  ///     required TrinaKeyManagerEvent keyEvent,
  ///     required TrinaGridStateManager stateManager,
  ///   }) {
  ///     print('Pressed enter key.');
  ///   }
  /// }
  /// ```
  final TrinaGridShortcut shortcut;

  /// Set borders of [TrinaGrid] and columns, cells, and rows.
  final TrinaGridStyleConfig style;

  /// Customise scrollbars for desktop usage
  final TrinaGridScrollbarConfig scrollbar;

  /// Customise filter of columns
  final TrinaGridColumnFilterConfig columnFilter;

  /// Automatically adjust the column width or set the width change condition.
  final TrinaGridColumnSizeConfig columnSize;

  final TrinaGridLocaleText localeText;

  /// Display total number of rows in pagination footer.
  ///
  /// Default is true.
  /// This applies to both [TrinaPagination] and [TrinaLazyPagination].
  final bool paginationShowTotalRows;

  /// Enable "Go to page" functionality in pagination footer.
  ///
  /// Default is true.
  /// Shows a button to open a dialog for jumping to a specific page.
  /// This applies to both [TrinaPagination] and [TrinaLazyPagination].
  final bool paginationEnableGotoPage;

  /// Enable click-and-drag selection without requiring long press.
  ///
  /// When true, clicking and dragging immediately starts range selection.
  /// Works only when [selectingMode] is [TrinaGridSelectingMode.cell].
  ///
  /// Default is false (preserves existing long-press behavior for backward compatibility).
  final bool enableDragSelection;

  /// Enable Ctrl+Click to toggle individual cells in multi-select.
  ///
  /// When true in cell mode, Ctrl+Click adds/removes individual cells.
  /// Click without modifiers clears individual selections.
  /// Works only when [selectingMode] is [TrinaGridSelectingMode.cell].
  ///
  /// Default is false.
  final bool enableCtrlClickMultiSelect;

  /// Duration to wait before activating drag selection (hold time).
  ///
  /// When [enableDragSelection] is true, users must press and hold for this
  /// duration before dragging to select cells. This prevents conflict with
  /// drag-to-scroll behavior.
  ///
  /// Recommended values:
  /// - 100ms for responsive feel (may conflict with fast scrolling)
  /// - 200ms for balanced experience (default)
  /// - 300ms for clear distinction from scrolling
  ///
  /// Note: If your app uses drag-to-scroll, consider disabling it in
  /// [scrollbar.dragDevices] to avoid gesture conflicts.
  ///
  /// Default is Duration(milliseconds: 200).
  final Duration dragSelectionDelayDuration;

  /// Separator used between cell values when copying to clipboard.
  ///
  /// When null (default), uses tab character '\t' for spreadsheet compatibility.
  /// Can be customized to use other separators like comma ',' for CSV format.
  final String? copyPasteCellSeparator;

  /// Separator used between rows when copying to clipboard.
  ///
  /// When null (default), uses platform-specific line endings:
  /// - Windows: '\r\n' (CRLF)
  /// - macOS/Linux: '\n' (LF)
  /// Can be customized to use a specific separator.
  final String? copyPasteLineSeparator;

  /// When true, enables itemExtent optimization even when rowWrapper is used.
  ///
  /// By default, using [rowWrapper] disables ListView's itemExtent optimization
  /// to allow for variable row heights. However, if your rowWrapper only adds
  /// visual styling without affecting row height, setting this to true will
  /// restore O(1) scroll performance and allow accurate calculation of scroll
  /// position.
  ///
  /// Default is false for backward compatibility.
  final bool rowWrapperIsConstantHeight;

  const TrinaGridConfiguration({
    this.enableMoveDownAfterSelecting = false,
    this.enableMoveHorizontalInEditing = false,
    this.enableAutoSelectFirstRow = true,
    this.rowSelectionCheckBoxBehavior =
        TrinaGridRowSelectionCheckBoxBehavior.none,
    this.enterKeyAction = TrinaGridEnterKeyAction.editingAndMoveDown,
    this.tabKeyAction = TrinaGridTabKeyAction.normal,
    this.selectingMode = TrinaGridSelectingMode.cell,
    this.shortcut = const TrinaGridShortcut(),
    this.style = const TrinaGridStyleConfig(),
    this.scrollbar = const TrinaGridScrollbarConfig(),
    this.columnFilter = const TrinaGridColumnFilterConfig(),
    this.columnSize = const TrinaGridColumnSizeConfig(),
    this.localeText = const TrinaGridLocaleText(),
    this.paginationShowTotalRows = true,
    this.paginationEnableGotoPage = true,
    this.enableDragSelection = false,
    this.enableCtrlClickMultiSelect = false,
    this.dragSelectionDelayDuration = const Duration(milliseconds: 200),
    this.copyPasteCellSeparator,
    this.copyPasteLineSeparator,
    this.rowWrapperIsConstantHeight = false,
  });

  const TrinaGridConfiguration.dark({
    this.enableMoveDownAfterSelecting = false,
    this.enableMoveHorizontalInEditing = false,
    this.enableAutoSelectFirstRow = true,
    this.rowSelectionCheckBoxBehavior =
        TrinaGridRowSelectionCheckBoxBehavior.none,
    this.enterKeyAction = TrinaGridEnterKeyAction.editingAndMoveDown,
    this.tabKeyAction = TrinaGridTabKeyAction.normal,
    this.selectingMode = TrinaGridSelectingMode.cell,
    this.shortcut = const TrinaGridShortcut(),
    this.style = const TrinaGridStyleConfig.dark(),
    this.scrollbar = const TrinaGridScrollbarConfig(),
    this.columnFilter = const TrinaGridColumnFilterConfig(),
    this.columnSize = const TrinaGridColumnSizeConfig(),
    this.localeText = const TrinaGridLocaleText(),
    this.paginationShowTotalRows = true,
    this.paginationEnableGotoPage = true,
    this.enableDragSelection = false,
    this.enableCtrlClickMultiSelect = false,
    this.dragSelectionDelayDuration = const Duration(milliseconds: 200),
    this.copyPasteCellSeparator,
    this.copyPasteLineSeparator,
    this.rowWrapperIsConstantHeight = false,
  });

  void updateLocale() {
    TrinaFilterTypeContains.name = localeText.filterContains;
    TrinaFilterTypeEquals.name = localeText.filterEquals;
    TrinaFilterTypeStartsWith.name = localeText.filterStartsWith;
    TrinaFilterTypeEndsWith.name = localeText.filterEndsWith;
    TrinaFilterTypeGreaterThan.name = localeText.filterGreaterThan;
    TrinaFilterTypeGreaterThanOrEqualTo.name =
        localeText.filterGreaterThanOrEqualTo;
    TrinaFilterTypeLessThan.name = localeText.filterLessThan;
    TrinaFilterTypeLessThanOrEqualTo.name = localeText.filterLessThanOrEqualTo;
  }

  /// Fired when setConfiguration is called in [TrinaGridStateManager]'s constructor.
  void applyColumnFilter(List<TrinaColumn>? refColumns) {
    if (refColumns == null || refColumns.isEmpty) {
      return;
    }

    var len = refColumns.length;

    for (var i = 0; i < len; i += 1) {
      var column = refColumns[i];

      column.setDefaultFilter(columnFilter.getDefaultColumnFilter(column));
    }
  }

  TrinaGridConfiguration copyWith({
    bool? enableMoveDownAfterSelecting,
    bool? enableMoveHorizontalInEditing,
    bool? enableAutoSelectFirstRow,
    TrinaGridRowSelectionCheckBoxBehavior? rowSelectionCheckBoxBehavior,
    TrinaGridEnterKeyAction? enterKeyAction,
    TrinaGridTabKeyAction? tabKeyAction,
    TrinaGridSelectingMode? selectingMode,
    TrinaGridShortcut? shortcut,
    TrinaGridStyleConfig? style,
    TrinaGridScrollbarConfig? scrollbar,
    TrinaGridColumnFilterConfig? columnFilter,
    TrinaGridColumnSizeConfig? columnSize,
    TrinaGridLocaleText? localeText,
    bool? enableDragSelection,
    bool? enableCtrlClickMultiSelect,
    Duration? dragSelectionDelayDuration,
    String? copyPasteCellSeparator,
    String? copyPasteLineSeparator,
    bool? rowWrapperIsConstantHeight,
  }) {
    return TrinaGridConfiguration(
      enableMoveDownAfterSelecting:
          enableMoveDownAfterSelecting ?? this.enableMoveDownAfterSelecting,
      enableMoveHorizontalInEditing:
          enableMoveHorizontalInEditing ?? this.enableMoveHorizontalInEditing,
      enableAutoSelectFirstRow:
          enableAutoSelectFirstRow ?? this.enableAutoSelectFirstRow,
      rowSelectionCheckBoxBehavior:
          rowSelectionCheckBoxBehavior ?? this.rowSelectionCheckBoxBehavior,
      enterKeyAction: enterKeyAction ?? this.enterKeyAction,
      tabKeyAction: tabKeyAction ?? this.tabKeyAction,
      selectingMode: selectingMode ?? this.selectingMode,
      shortcut: shortcut ?? this.shortcut,
      style: style ?? this.style,
      scrollbar: scrollbar ?? this.scrollbar,
      columnFilter: columnFilter ?? this.columnFilter,
      columnSize: columnSize ?? this.columnSize,
      localeText: localeText ?? this.localeText,
      enableDragSelection: enableDragSelection ?? this.enableDragSelection,
      enableCtrlClickMultiSelect:
          enableCtrlClickMultiSelect ?? this.enableCtrlClickMultiSelect,
      dragSelectionDelayDuration:
          dragSelectionDelayDuration ?? this.dragSelectionDelayDuration,
      copyPasteCellSeparator:
          copyPasteCellSeparator ?? this.copyPasteCellSeparator,
      copyPasteLineSeparator:
          copyPasteLineSeparator ?? this.copyPasteLineSeparator,
      rowWrapperIsConstantHeight:
          rowWrapperIsConstantHeight ?? this.rowWrapperIsConstantHeight,
    );
  }

  @override
  bool operator ==(covariant Object other) {
    return identical(this, other) ||
        other is TrinaGridConfiguration &&
            runtimeType == other.runtimeType &&
            enableMoveDownAfterSelecting ==
                other.enableMoveDownAfterSelecting &&
            enableMoveHorizontalInEditing ==
                other.enableMoveHorizontalInEditing &&
            enableAutoSelectFirstRow == other.enableAutoSelectFirstRow &&
            rowSelectionCheckBoxBehavior ==
                other.rowSelectionCheckBoxBehavior &&
            enterKeyAction == other.enterKeyAction &&
            tabKeyAction == other.tabKeyAction &&
            selectingMode == other.selectingMode &&
            shortcut == other.shortcut &&
            style == other.style &&
            scrollbar == other.scrollbar &&
            columnFilter == other.columnFilter &&
            columnSize == other.columnSize &&
            localeText == other.localeText &&
            enableDragSelection == other.enableDragSelection &&
            enableCtrlClickMultiSelect == other.enableCtrlClickMultiSelect &&
            dragSelectionDelayDuration == other.dragSelectionDelayDuration &&
            copyPasteCellSeparator == other.copyPasteCellSeparator &&
            copyPasteLineSeparator == other.copyPasteLineSeparator &&
            rowWrapperIsConstantHeight == other.rowWrapperIsConstantHeight;
  }

  @override
  int get hashCode => Object.hash(
    enableMoveDownAfterSelecting,
    enableMoveHorizontalInEditing,
    enableAutoSelectFirstRow,
    rowSelectionCheckBoxBehavior,
    enterKeyAction,
    tabKeyAction,
    selectingMode,
    shortcut,
    style,
    scrollbar,
    columnFilter,
    columnSize,
    localeText,
    enableDragSelection,
    enableCtrlClickMultiSelect,
    Object.hash(
      dragSelectionDelayDuration,
      copyPasteCellSeparator,
      copyPasteLineSeparator,
      rowWrapperIsConstantHeight,
    ),
  );
}

class TrinaGridStyleConfig {
  static const TextStyle defaultLightCellTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.black,
  );

  static const TextStyle defaultDarkCellTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.white,
  );

  const TrinaGridStyleConfig({
    this.enableGridBorderShadow = false,
    this.enableColumnBorderVertical = true,
    this.enableColumnBorderHorizontal = true,
    this.enableCellBorderVertical = true,
    this.enableCellBorderHorizontal = true,
    this.enableRowColorAnimation = false,
    this.enableRowHoverColor = false,
    this.filterIcon = const Icon(Icons.filter_alt_outlined),
    this.gridBackgroundColor = Colors.white,
    this.rowColor = Colors.white,
    this.oddRowColor,
    this.evenRowColor,
    this.activatedColor = const Color(0xFFDCF5FF),
    Color? columnCheckedColor,
    this.columnCheckedSide,
    Color? cellCheckedColor,
    this.cellCheckedSide,
    this.rowCheckedColor = const Color(0x11757575),
    this.rowHoveredColor = const Color(0xFFB1B3B7),
    this.cellColorInEditState = Colors.white,
    this.cellColorInReadOnlyState = const Color(0xFFDBDBDC),
    this.cellReadonlyColor,
    this.cellDefaultColor,
    this.cellColorGroupedRow,
    this.cellDirtyColor = const Color(0xFFFFF9C4),
    this.frozenRowColor = const Color(0xFFF8F8F8),
    this.frozenRowBorderColor = const Color(0xFFE0E0E0),
    this.dragTargetColumnColor = const Color.fromARGB(129, 220, 245, 255),
    this.iconColor = Colors.black38,
    this.disabledIconColor = Colors.black12,
    this.menuBackgroundColor = Colors.white,
    this.gridBorderColor = const Color(0xFFA1A5AE),
    this.borderColor = const Color(0xFFDDE2EB),
    this.activatedBorderColor = Colors.lightBlue,
    this.inactivatedBorderColor = const Color(0xFFC4C7CC),
    this.iconSize = 18,
    this.rowHeight = TrinaGridSettings.rowHeight,
    this.columnHeight = TrinaGridSettings.rowHeight,
    this.columnFilterHeight = TrinaGridSettings.rowHeight,
    this.defaultColumnTitlePadding = TrinaGridSettings.columnTitlePadding,
    this.defaultColumnFilterPadding = TrinaGridSettings.columnFilterPadding,
    this.defaultCellPadding = TrinaGridSettings.cellPadding,
    this.columnTextStyle = const TextStyle(
      color: Colors.black,
      decoration: TextDecoration.none,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    Color? columnUnselectedColor,
    Color? columnActiveColor,
    Color? cellUnselectedColor,
    Color? cellActiveColor,
    this.cellTextStyle = defaultLightCellTextStyle,
    this.columnContextIcon = Icons.dehaze,
    this.columnResizeIcon = Icons.code_sharp,
    this.columnAscendingIcon,
    this.columnDescendingIcon,
    this.rowGroupExpandedIcon = Icons.keyboard_arrow_down,
    this.rowGroupCollapsedIcon = const IconData(
      0xe355,
      matchTextDirection: true,
      fontFamily: 'MaterialIcons',
    ),
    this.rowGroupEmptyIcon = Icons.noise_control_off,
    this.gridBorderRadius = BorderRadius.zero,
    this.gridPopupBorderRadius = BorderRadius.zero,
    this.gridPadding = TrinaGridSettings.gridPadding,
    this.gridBorderWidth = TrinaGridSettings.gridBorderWidth,
    this.cellVerticalBorderWidth = TrinaGridSettings.cellVerticalBorderWidth,
    this.cellHorizontalBorderWidth =
        TrinaGridSettings.cellHorizontalBorderWidth,
    this.filterHeaderColor,
    this.filterPopupHeaderColor,
    this.filterHeaderIconColor,
  }) : columnCheckedColor = (columnCheckedColor ?? activatedColor),
       cellCheckedColor = (cellCheckedColor ?? activatedColor),
       columnUnselectedColor = (columnUnselectedColor ?? iconColor),
       columnActiveColor = (columnActiveColor ?? activatedBorderColor),
       cellUnselectedColor = (cellUnselectedColor ?? iconColor),
       cellActiveColor = (cellActiveColor ?? activatedBorderColor),
       isDarkStyle = false;

  const TrinaGridStyleConfig.dark({
    this.enableGridBorderShadow = false,
    this.enableColumnBorderVertical = true,
    this.enableColumnBorderHorizontal = true,
    this.enableCellBorderVertical = true,
    this.enableCellBorderHorizontal = true,
    this.enableRowColorAnimation = false,
    this.enableRowHoverColor = false,
    this.filterIcon = const Icon(Icons.filter_alt_outlined),
    this.gridBackgroundColor = const Color(0xFF111111),
    this.rowColor = const Color(0xFF111111),
    this.oddRowColor,
    this.evenRowColor,
    this.activatedColor = const Color(0xFF313131),
    Color? columnCheckedColor,
    this.columnCheckedSide,
    Color? cellCheckedColor,
    this.cellCheckedSide,
    this.rowCheckedColor = const Color(0x11202020),
    this.rowHoveredColor = const Color(0xFF3D3D3D),
    this.cellColorInEditState = const Color(0xFF666666),
    this.cellColorInReadOnlyState = const Color(0xFF222222),
    this.cellReadonlyColor,
    this.cellDefaultColor,
    this.cellColorGroupedRow,
    this.cellDirtyColor = const Color(0xFF5D4037),
    this.frozenRowColor = const Color(0xFF222222),
    this.frozenRowBorderColor = const Color(0xFF666666),
    this.dragTargetColumnColor = const Color(0xFF313131),
    this.iconColor = Colors.white38,
    this.disabledIconColor = Colors.white12,
    this.menuBackgroundColor = const Color(0xFF414141),
    this.gridBorderColor = const Color(0xFF666666),
    this.borderColor = const Color(0xFF222222),
    this.activatedBorderColor = const Color(0xFFFFFFFF),
    this.inactivatedBorderColor = const Color(0xFF666666),
    this.iconSize = 18,
    this.rowHeight = TrinaGridSettings.rowHeight,
    this.columnHeight = TrinaGridSettings.rowHeight,
    this.columnFilterHeight = TrinaGridSettings.rowHeight,
    this.defaultColumnTitlePadding = TrinaGridSettings.columnTitlePadding,
    this.defaultColumnFilterPadding = TrinaGridSettings.columnFilterPadding,
    this.defaultCellPadding = TrinaGridSettings.cellPadding,
    this.columnTextStyle = const TextStyle(
      color: Colors.white,
      decoration: TextDecoration.none,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    Color? columnUnselectedColor,
    Color? columnActiveColor,
    Color? cellUnselectedColor,
    Color? cellActiveColor,
    this.cellTextStyle = defaultDarkCellTextStyle,
    this.columnContextIcon = Icons.dehaze,
    this.columnResizeIcon = Icons.code_sharp,
    this.columnAscendingIcon,
    this.columnDescendingIcon,
    this.rowGroupExpandedIcon = Icons.keyboard_arrow_down,
    this.rowGroupCollapsedIcon = const IconData(
      0xe355,
      matchTextDirection: true,
      fontFamily: 'MaterialIcons',
    ),
    this.rowGroupEmptyIcon = Icons.noise_control_off,
    this.gridBorderRadius = BorderRadius.zero,
    this.gridPopupBorderRadius = BorderRadius.zero,
    this.gridPadding = TrinaGridSettings.gridPadding,
    this.gridBorderWidth = TrinaGridSettings.gridBorderWidth,
    this.cellVerticalBorderWidth = TrinaGridSettings.cellVerticalBorderWidth,
    this.cellHorizontalBorderWidth =
        TrinaGridSettings.cellHorizontalBorderWidth,
    this.filterHeaderColor,
    this.filterPopupHeaderColor,
    this.filterHeaderIconColor,
  }) : columnCheckedColor = (columnCheckedColor ?? activatedColor),
       cellCheckedColor = (cellCheckedColor ?? activatedColor),
       columnUnselectedColor = (columnUnselectedColor ?? iconColor),
       columnActiveColor = (columnActiveColor ?? activatedBorderColor),
       cellUnselectedColor = (cellUnselectedColor ?? iconColor),
       cellActiveColor = (cellActiveColor ?? activatedBorderColor),
       isDarkStyle = true;

  /// Enable borderShadow in [TrinaGrid].
  final bool enableGridBorderShadow;

  /// Enable the vertical border of [TrinaColumn] and [TrinaColumnGroup].
  final bool enableColumnBorderVertical;

  /// Enable the horizontal border of [TrinaColumn] and [TrinaColumnGroup].
  final bool enableColumnBorderHorizontal;

  /// Enable the vertical border of [TrinaCell].
  final bool enableCellBorderVertical;

  /// Enable the horizontal border of [TrinaCell].
  final bool enableCellBorderHorizontal;

  /// Animation of background color transition of rows,
  /// such as when the current row or rows are dragged.
  final bool enableRowColorAnimation;

  /// Hover effect on rows.
  /// If true, the background color of the row changes to [rowHoveredColor]
  /// when the mouse hovers over it.
  /// If false, the background color of the row does not change and
  /// the background color of the row is the same as [rowColor].
  /// [rowHoveredColor] is therefore not used.
  final bool enableRowHoverColor;

  /// Filter icon shown in column titles when columns are filtered.
  /// Set to null to hide filter icons. Customize by providing a different icon.
  final Icon? filterIcon;

  final Color gridBackgroundColor;

  /// Default row background color
  ///
  /// If [TrinaGrid.rowColorCallback] is set, rowColorCallback takes precedence.
  final Color rowColor;

  /// Background color for odd rows
  ///
  /// The first row, which is number 0, is treated as an odd row.
  /// If [TrinaGrid.rowColorCallback] is set, rowColorCallback takes precedence.
  final Color? oddRowColor;

  /// Background color for even rows
  ///
  /// The row with number 1 is treated as an even row.
  /// If [TrinaGrid.rowColorCallback] is set, rowColorCallback takes precedence.
  final Color? evenRowColor;

  /// Activated Color. (Current or Selected row, cell)
  final Color activatedColor;

  /// Checked Color for the column title. (Checked rows)
  final Color columnCheckedColor;

  /// Checked side for the column title.
  final BorderSide? columnCheckedSide;

  /// Checked Color for the cell. (Checked rows)
  final Color cellCheckedColor;

  /// Checked side for the cell.
  final BorderSide? cellCheckedSide;

  /// Checked Color for the row. (Checked rows)
  final Color rowCheckedColor;

  /// Hovered Color. (Currently hovered row)
  final Color rowHoveredColor;

  /// Cell color in edit state. (only current cell)
  final Color cellColorInEditState;

  /// Cell color in read-only state (only current cell)
  final Color cellColorInReadOnlyState;

  /// Background color of cells grouped by column.
  final Color? cellColorGroupedRow;

  /// Background color of cells with uncommitted changes (dirty cells)
  final Color cellDirtyColor;

  /// Background color of readonly cells
  final Color? cellReadonlyColor;

  /// Default background color of cells
  final Color? cellDefaultColor;

  /// Background color for frozen rows
  final Color frozenRowColor;

  /// Border color for frozen rows
  final Color frozenRowBorderColor;

  /// The background color of the column to be dragged.
  /// When moving a column by dragging it.
  final Color dragTargetColumnColor;

  /// Icon color. (column menu, cell of popup type, pagination plugin)
  final Color iconColor;

  /// Disabled icon color. (pagination plugin)
  final Color disabledIconColor;

  /// BackgroundColor of Popup menu. (column menu)
  final Color menuBackgroundColor;

  /// Set the border color of [TrinaGrid].
  final Color gridBorderColor;

  /// Set the border color of the widgets inside [TrinaGrid].
  ///
  /// Border color is set
  /// for [TrinaColumn], [TrinaColumnGroup], [TrinaCell], [TrinaRow], etc.
  final Color borderColor;

  /// Border color set when widgets such as [TrinaRow] and [TrinaCell]
  /// receive focus or are currently selected.
  final Color activatedBorderColor;

  /// Border color set when widgets such as [TrinaRow] and [TrinaCell] lose focus.
  final Color inactivatedBorderColor;

  /// Icon size. (column menu, cell of popup type)
  final double iconSize;

  /// Height of a row.
  final double rowHeight;

  /// Height of column.
  final double columnHeight;

  /// Height of column filter.
  final double columnFilterHeight;

  /// Customise column title padding
  /// If there is no titlePadding of TrinaColumn,
  /// it is the title padding of the default column.
  final EdgeInsets defaultColumnTitlePadding;

  final EdgeInsets defaultColumnFilterPadding;

  /// Customise cell padding
  /// If there is no cellPadding of TrinaColumn,
  /// it is the padding value of cell.
  final EdgeInsets defaultCellPadding;

  /// Column - text style
  final TextStyle columnTextStyle;

  /// Unselected color of the column.
  final Color columnUnselectedColor;

  /// Active color of the column.
  final Color columnActiveColor;

  /// Unselected color of the default cell.
  final Color cellUnselectedColor;

  /// Active color of the default cell.
  final Color cellActiveColor;

  /// Cell - text style
  final TextStyle cellTextStyle;

  /// Icon that can open a pop-up menu next to the column title
  /// when [enableContextMenu] of [TrinaColumn] is true.
  final IconData columnContextIcon;

  /// If enableContextMenu of TrinaColumn is false and enableDropToResize is true,
  /// only the width of the column can be adjusted.
  final IconData columnResizeIcon;

  /// Ascending icon when sorting a column.
  ///
  /// If no value is specified, the default icon is set.
  final Icon? columnAscendingIcon;

  /// Descending icon when sorting a column.
  ///
  /// If no value is specified, the default icon is set.
  final Icon? columnDescendingIcon;

  /// Icon when RowGroup is expanded.
  final IconData rowGroupExpandedIcon;

  /// Icon when RowGroup is collapsed.
  final IconData rowGroupCollapsedIcon;

  /// Icon when RowGroup is empty.
  final IconData rowGroupEmptyIcon;

  /// Apply the border radius of [TrinaGrid].
  final BorderRadiusGeometry gridBorderRadius;

  /// Apply border radius to popup opened inside [TrinaGrid].
  final BorderRadiusGeometry gridPopupBorderRadius;

  /// Defaults to [TrinaGridSettings.gridPadding]
  final double gridPadding;

  /// Defaults to [TrinaGridSettings.gridBorderWidth]
  final double gridBorderWidth;

  /// Set color of filter popup header
  final Color? filterPopupHeaderColor;

  /// Set color of main grid filter header
  final Color? filterHeaderColor;

  /// Set color of filter popup header icon
  final Color? filterHeaderIconColor;

  /// A flag indicating whether the style is dark or not
  final bool isDarkStyle;

  /// Cell vertical border width
  final double cellVerticalBorderWidth;

  /// Cell horizontal border width
  final double cellHorizontalBorderWidth;

  TrinaGridStyleConfig copyWith({
    bool? enableGridBorderShadow,
    bool? enableColumnBorderVertical,
    bool? enableColumnBorderHorizontal,
    bool? enableCellBorderVertical,
    bool? enableCellBorderHorizontal,
    bool? enableRowColorAnimation,
    Icon? filterIcon,
    Color? gridBackgroundColor,
    Color? rowColor,
    TrinaOptional<Color?>? oddRowColor,
    TrinaOptional<Color?>? evenRowColor,
    Color? activatedColor,
    Color? columnCheckedColor,
    BorderSide? columnCheckedSide,
    Color? cellCheckedColor,
    BorderSide? cellCheckedSide,
    Color? cellColorInEditState,
    Color? cellColorInReadOnlyState,
    Color? cellReadonlyColor,
    TrinaOptional<Color?>? cellColorGroupedRow,
    Color? dragTargetColumnColor,
    Color? iconColor,
    Color? disabledIconColor,
    Color? menuBackgroundColor,
    Color? gridBorderColor,
    Color? borderColor,
    Color? activatedBorderColor,
    Color? inactivatedBorderColor,
    double? iconSize,
    double? rowHeight,
    double? columnHeight,
    double? columnFilterHeight,
    EdgeInsets? defaultColumnTitlePadding,
    EdgeInsets? defaultColumnFilterPadding,
    EdgeInsets? defaultCellPadding,
    TextStyle? columnTextStyle,
    Color? columnUnselectedColor,
    Color? columnActiveColor,
    Color? cellUnselectedColor,
    Color? cellActiveColor,
    TextStyle? cellTextStyle,
    IconData? columnContextIcon,
    IconData? columnResizeIcon,
    TrinaOptional<Icon?>? columnAscendingIcon,
    TrinaOptional<Icon?>? columnDescendingIcon,
    IconData? rowGroupExpandedIcon,
    IconData? rowGroupCollapsedIcon,
    IconData? rowGroupEmptyIcon,
    BorderRadiusGeometry? gridBorderRadius,
    BorderRadiusGeometry? gridPopupBorderRadius,
    double? gridPadding,
    double? gridBorderWidth,
    double? cellVerticalBorderWidth,
    double? cellHorizontalBorderWidth,
    Color? filterPopupHeaderColor,
    Color? filterHeaderColor,
    Color? filterHeaderIconColor,
  }) {
    // Preserve the dark style flag by using the appropriate constructor
    if (isDarkStyle) {
      return TrinaGridStyleConfig.dark(
        cellVerticalBorderWidth:
            cellVerticalBorderWidth ?? this.cellVerticalBorderWidth,
        cellHorizontalBorderWidth:
            cellHorizontalBorderWidth ?? this.cellHorizontalBorderWidth,
        enableGridBorderShadow:
            enableGridBorderShadow ?? this.enableGridBorderShadow,
        enableColumnBorderVertical:
            enableColumnBorderVertical ?? this.enableColumnBorderVertical,
        enableColumnBorderHorizontal:
            enableColumnBorderHorizontal ?? this.enableColumnBorderHorizontal,
        enableCellBorderVertical:
            enableCellBorderVertical ?? this.enableCellBorderVertical,
        enableCellBorderHorizontal:
            enableCellBorderHorizontal ?? this.enableCellBorderHorizontal,
        enableRowColorAnimation:
            enableRowColorAnimation ?? this.enableRowColorAnimation,
        filterIcon: filterIcon ?? this.filterIcon,
        gridBackgroundColor: gridBackgroundColor ?? this.gridBackgroundColor,
        rowColor: rowColor ?? this.rowColor,
        oddRowColor: oddRowColor == null ? this.oddRowColor : oddRowColor.value,
        evenRowColor: evenRowColor == null
            ? this.evenRowColor
            : evenRowColor.value,
        activatedColor: activatedColor ?? this.activatedColor,
        columnCheckedColor: columnCheckedColor ?? this.columnCheckedColor,
        columnCheckedSide: columnCheckedSide ?? this.columnCheckedSide,
        cellCheckedColor: cellCheckedColor ?? this.cellCheckedColor,
        cellCheckedSide: cellCheckedSide ?? this.cellCheckedSide,
        cellColorInEditState: cellColorInEditState ?? this.cellColorInEditState,
        cellColorInReadOnlyState:
            cellColorInReadOnlyState ?? this.cellColorInReadOnlyState,
        cellReadonlyColor: cellReadonlyColor ?? this.cellReadonlyColor,
        cellColorGroupedRow: cellColorGroupedRow == null
            ? this.cellColorGroupedRow
            : cellColorGroupedRow.value,
        dragTargetColumnColor:
            dragTargetColumnColor ?? this.dragTargetColumnColor,
        iconColor: iconColor ?? this.iconColor,
        disabledIconColor: disabledIconColor ?? this.disabledIconColor,
        menuBackgroundColor: menuBackgroundColor ?? this.menuBackgroundColor,
        gridBorderColor: gridBorderColor ?? this.gridBorderColor,
        borderColor: borderColor ?? this.borderColor,
        activatedBorderColor: activatedBorderColor ?? this.activatedBorderColor,
        inactivatedBorderColor:
            inactivatedBorderColor ?? this.inactivatedBorderColor,
        iconSize: iconSize ?? this.iconSize,
        rowHeight: rowHeight ?? this.rowHeight,
        columnHeight: columnHeight ?? this.columnHeight,
        columnFilterHeight: columnFilterHeight ?? this.columnFilterHeight,
        defaultColumnTitlePadding:
            defaultColumnTitlePadding ?? this.defaultColumnTitlePadding,
        defaultColumnFilterPadding:
            defaultColumnFilterPadding ?? this.defaultColumnFilterPadding,
        defaultCellPadding: defaultCellPadding ?? this.defaultCellPadding,
        columnTextStyle: columnTextStyle ?? this.columnTextStyle,
        columnUnselectedColor:
            columnUnselectedColor ?? this.columnUnselectedColor,
        columnActiveColor: columnActiveColor ?? this.columnActiveColor,
        cellUnselectedColor: cellUnselectedColor ?? this.cellUnselectedColor,
        cellActiveColor: cellActiveColor ?? this.cellActiveColor,
        cellTextStyle: cellTextStyle ?? this.cellTextStyle,
        columnContextIcon: columnContextIcon ?? this.columnContextIcon,
        columnResizeIcon: columnResizeIcon ?? this.columnResizeIcon,
        columnAscendingIcon: columnAscendingIcon == null
            ? this.columnAscendingIcon
            : columnAscendingIcon.value,
        columnDescendingIcon: columnDescendingIcon == null
            ? this.columnDescendingIcon
            : columnDescendingIcon.value,
        rowGroupExpandedIcon: rowGroupExpandedIcon ?? this.rowGroupExpandedIcon,
        rowGroupCollapsedIcon:
            rowGroupCollapsedIcon ?? this.rowGroupCollapsedIcon,
        rowGroupEmptyIcon: rowGroupEmptyIcon ?? this.rowGroupEmptyIcon,
        gridBorderRadius: gridBorderRadius ?? this.gridBorderRadius,
        gridPopupBorderRadius:
            gridPopupBorderRadius ?? this.gridPopupBorderRadius,
        gridPadding: gridPadding ?? this.gridPadding,
        gridBorderWidth: gridBorderWidth ?? this.gridBorderWidth,
        filterHeaderColor: filterHeaderColor ?? this.filterHeaderColor,
        filterPopupHeaderColor:
            filterPopupHeaderColor ?? this.filterPopupHeaderColor,
        filterHeaderIconColor:
            filterHeaderIconColor ?? this.filterHeaderIconColor,
      );
    } else {
      return TrinaGridStyleConfig(
        cellVerticalBorderWidth:
            cellVerticalBorderWidth ?? this.cellVerticalBorderWidth,
        cellHorizontalBorderWidth:
            cellHorizontalBorderWidth ?? this.cellHorizontalBorderWidth,
        enableGridBorderShadow:
            enableGridBorderShadow ?? this.enableGridBorderShadow,
        enableColumnBorderVertical:
            enableColumnBorderVertical ?? this.enableColumnBorderVertical,
        enableColumnBorderHorizontal:
            enableColumnBorderHorizontal ?? this.enableColumnBorderHorizontal,
        enableCellBorderVertical:
            enableCellBorderVertical ?? this.enableCellBorderVertical,
        enableCellBorderHorizontal:
            enableCellBorderHorizontal ?? this.enableCellBorderHorizontal,
        enableRowColorAnimation:
            enableRowColorAnimation ?? this.enableRowColorAnimation,
        filterIcon: filterIcon ?? this.filterIcon,
        gridBackgroundColor: gridBackgroundColor ?? this.gridBackgroundColor,
        rowColor: rowColor ?? this.rowColor,
        oddRowColor: oddRowColor == null ? this.oddRowColor : oddRowColor.value,
        evenRowColor: evenRowColor == null
            ? this.evenRowColor
            : evenRowColor.value,
        activatedColor: activatedColor ?? this.activatedColor,
        columnCheckedColor: columnCheckedColor ?? this.columnCheckedColor,
        columnCheckedSide: columnCheckedSide ?? this.columnCheckedSide,
        cellCheckedColor: cellCheckedColor ?? this.cellCheckedColor,
        cellCheckedSide: cellCheckedSide ?? this.cellCheckedSide,
        cellColorInEditState: cellColorInEditState ?? this.cellColorInEditState,
        cellColorInReadOnlyState:
            cellColorInReadOnlyState ?? this.cellColorInReadOnlyState,
        cellReadonlyColor: cellReadonlyColor ?? this.cellReadonlyColor,
        cellColorGroupedRow: cellColorGroupedRow == null
            ? this.cellColorGroupedRow
            : cellColorGroupedRow.value,
        dragTargetColumnColor:
            dragTargetColumnColor ?? this.dragTargetColumnColor,
        iconColor: iconColor ?? this.iconColor,
        disabledIconColor: disabledIconColor ?? this.disabledIconColor,
        menuBackgroundColor: menuBackgroundColor ?? this.menuBackgroundColor,
        gridBorderColor: gridBorderColor ?? this.gridBorderColor,
        borderColor: borderColor ?? this.borderColor,
        activatedBorderColor: activatedBorderColor ?? this.activatedBorderColor,
        inactivatedBorderColor:
            inactivatedBorderColor ?? this.inactivatedBorderColor,
        iconSize: iconSize ?? this.iconSize,
        rowHeight: rowHeight ?? this.rowHeight,
        columnHeight: columnHeight ?? this.columnHeight,
        columnFilterHeight: columnFilterHeight ?? this.columnFilterHeight,
        defaultColumnTitlePadding:
            defaultColumnTitlePadding ?? this.defaultColumnTitlePadding,
        defaultColumnFilterPadding:
            defaultColumnFilterPadding ?? this.defaultColumnFilterPadding,
        defaultCellPadding: defaultCellPadding ?? this.defaultCellPadding,
        columnTextStyle: columnTextStyle ?? this.columnTextStyle,
        columnUnselectedColor:
            columnUnselectedColor ?? this.columnUnselectedColor,
        columnActiveColor: columnActiveColor ?? this.columnActiveColor,
        cellUnselectedColor: cellUnselectedColor ?? this.cellUnselectedColor,
        cellActiveColor: cellActiveColor ?? this.cellActiveColor,
        cellTextStyle: cellTextStyle ?? this.cellTextStyle,
        columnContextIcon: columnContextIcon ?? this.columnContextIcon,
        columnResizeIcon: columnResizeIcon ?? this.columnResizeIcon,
        columnAscendingIcon: columnAscendingIcon == null
            ? this.columnAscendingIcon
            : columnAscendingIcon.value,
        columnDescendingIcon: columnDescendingIcon == null
            ? this.columnDescendingIcon
            : columnDescendingIcon.value,
        rowGroupExpandedIcon: rowGroupExpandedIcon ?? this.rowGroupExpandedIcon,
        rowGroupCollapsedIcon:
            rowGroupCollapsedIcon ?? this.rowGroupCollapsedIcon,
        rowGroupEmptyIcon: rowGroupEmptyIcon ?? this.rowGroupEmptyIcon,
        gridBorderRadius: gridBorderRadius ?? this.gridBorderRadius,
        gridPopupBorderRadius:
            gridPopupBorderRadius ?? this.gridPopupBorderRadius,
        gridPadding: gridPadding ?? this.gridPadding,
        gridBorderWidth: gridBorderWidth ?? this.gridBorderWidth,
        filterHeaderColor: filterHeaderColor ?? this.filterHeaderColor,
        filterPopupHeaderColor:
            filterPopupHeaderColor ?? this.filterPopupHeaderColor,
        filterHeaderIconColor:
            filterHeaderIconColor ?? this.filterHeaderIconColor,
      );
    }
  }

  @override
  bool operator ==(covariant Object other) {
    return identical(this, other) ||
        other is TrinaGridStyleConfig &&
            runtimeType == other.runtimeType &&
            enableGridBorderShadow == other.enableGridBorderShadow &&
            enableColumnBorderVertical == other.enableColumnBorderVertical &&
            enableColumnBorderHorizontal ==
                other.enableColumnBorderHorizontal &&
            enableCellBorderVertical == other.enableCellBorderVertical &&
            enableCellBorderHorizontal == other.enableCellBorderHorizontal &&
            enableRowColorAnimation == other.enableRowColorAnimation &&
            filterIcon == other.filterIcon &&
            gridBackgroundColor == other.gridBackgroundColor &&
            rowColor == other.rowColor &&
            oddRowColor == other.oddRowColor &&
            evenRowColor == other.evenRowColor &&
            activatedColor == other.activatedColor &&
            columnCheckedColor == other.columnCheckedColor &&
            columnCheckedSide == other.columnCheckedSide &&
            cellCheckedColor == other.cellCheckedColor &&
            cellCheckedSide == other.cellCheckedSide &&
            cellColorInEditState == other.cellColorInEditState &&
            cellColorInReadOnlyState == other.cellColorInReadOnlyState &&
            cellReadonlyColor == other.cellReadonlyColor &&
            cellColorGroupedRow == other.cellColorGroupedRow &&
            dragTargetColumnColor == other.dragTargetColumnColor &&
            iconColor == other.iconColor &&
            disabledIconColor == other.disabledIconColor &&
            menuBackgroundColor == other.menuBackgroundColor &&
            gridBorderColor == other.gridBorderColor &&
            borderColor == other.borderColor &&
            activatedBorderColor == other.activatedBorderColor &&
            inactivatedBorderColor == other.inactivatedBorderColor &&
            iconSize == other.iconSize &&
            rowHeight == other.rowHeight &&
            columnHeight == other.columnHeight &&
            columnFilterHeight == other.columnFilterHeight &&
            defaultColumnTitlePadding == other.defaultColumnTitlePadding &&
            defaultColumnFilterPadding == other.defaultColumnFilterPadding &&
            defaultCellPadding == other.defaultCellPadding &&
            columnTextStyle == other.columnTextStyle &&
            columnUnselectedColor == other.columnUnselectedColor &&
            columnActiveColor == other.columnActiveColor &&
            cellUnselectedColor == other.cellUnselectedColor &&
            cellActiveColor == other.cellActiveColor &&
            cellTextStyle == other.cellTextStyle &&
            columnContextIcon == other.columnContextIcon &&
            columnResizeIcon == other.columnResizeIcon &&
            columnAscendingIcon == other.columnAscendingIcon &&
            columnDescendingIcon == other.columnDescendingIcon &&
            rowGroupExpandedIcon == other.rowGroupExpandedIcon &&
            rowGroupCollapsedIcon == other.rowGroupCollapsedIcon &&
            rowGroupEmptyIcon == other.rowGroupEmptyIcon &&
            gridBorderRadius == other.gridBorderRadius &&
            gridPopupBorderRadius == other.gridPopupBorderRadius &&
            gridPadding == other.gridPadding &&
            gridBorderWidth == other.gridBorderWidth &&
            cellVerticalBorderWidth == other.cellVerticalBorderWidth &&
            cellHorizontalBorderWidth == other.cellHorizontalBorderWidth &&
            filterHeaderColor == other.filterHeaderColor &&
            filterPopupHeaderColor == other.filterPopupHeaderColor &&
            filterHeaderIconColor == other.filterHeaderIconColor &&
            isDarkStyle == other.isDarkStyle;
  }

  @override
  int get hashCode => Object.hashAll([
    enableGridBorderShadow,
    enableColumnBorderVertical,
    enableColumnBorderHorizontal,
    enableCellBorderVertical,
    enableCellBorderHorizontal,
    enableRowColorAnimation,
    filterIcon,
    gridBackgroundColor,
    rowColor,
    oddRowColor,
    evenRowColor,
    activatedColor,
    columnCheckedColor,
    columnCheckedSide,
    cellCheckedColor,
    cellCheckedSide,
    cellColorInEditState,
    cellColorInReadOnlyState,
    cellReadonlyColor,
    cellColorGroupedRow,
    dragTargetColumnColor,
    iconColor,
    disabledIconColor,
    menuBackgroundColor,
    gridBorderColor,
    borderColor,
    activatedBorderColor,
    inactivatedBorderColor,
    iconSize,
    rowHeight,
    columnHeight,
    columnFilterHeight,
    defaultColumnTitlePadding,
    defaultColumnFilterPadding,
    defaultCellPadding,
    columnTextStyle,
    columnUnselectedColor,
    columnActiveColor,
    cellUnselectedColor,
    cellActiveColor,
    cellTextStyle,
    columnContextIcon,
    columnResizeIcon,
    columnAscendingIcon,
    columnDescendingIcon,
    rowGroupExpandedIcon,
    rowGroupCollapsedIcon,
    rowGroupEmptyIcon,
    gridBorderRadius,
    gridPopupBorderRadius,
    gridPadding,
    gridBorderWidth,
    cellVerticalBorderWidth,
    cellHorizontalBorderWidth,
    filterPopupHeaderColor,
    filterHeaderColor,
    filterHeaderIconColor,
    isDarkStyle,
  ]);
}

/// Allows to customise scrollbars "look and feel"
/// The general feature is making vertical scrollbar draggable and therefore more useful
/// for desktop systems. Set [isDraggable] to true to achieve this behavior. Also
/// changing [isAlwaysShown] to true is recommended for more usability at desktops.
///
/// The appearance can be customized with:
/// - [thickness] - The width of the scrollbar
/// - [minThumbLength] - The minimum size of the thumb
/// - [radius] - The corner radius of the scrollbar thumb and track
/// - [thumbColor] and [trackColor] - Colors for normal state
/// - [thumbHoverColor] and [trackHoverColor] - Colors for hover state
class TrinaGridScrollbarConfig {
  const TrinaGridScrollbarConfig({
    // Basic scrollbar behavior settings
    this.isAlwaysShown = false,
    this.dragDevices = const <PointerDeviceKind>{
      PointerDeviceKind.mouse,
      PointerDeviceKind.touch,
      PointerDeviceKind.stylus,
      PointerDeviceKind.invertedStylus,
      PointerDeviceKind.trackpad,
      PointerDeviceKind.unknown,
    },
    this.isDraggable = true,
    this.smoothScrolling = true,

    // Advanced scrollbar appearance settings
    this.thumbVisible = true,
    this.showTrack = true,
    this.showHorizontal = true,
    this.showVertical = true,
    this.thickness = 8.0,
    this.minThumbLength = 40.0,
    this.radius,
    this.thumbColor,
    this.trackColor,
    this.thumbHoverColor,
    this.trackHoverColor,
    this.columnShowScrollWidth = true,
  });

  /// Whether the scrollbar is always visible
  final bool isAlwaysShown;

  /// Set of devices that can interact with the scrollbar
  ///
  /// By default [PointerDeviceKind.mouse], [PointerDeviceKind.touch],
  /// [PointerDeviceKind.stylus], [PointerDeviceKind.invertedStylus],
  /// and [PointerDeviceKind.trackpad] are configured to create drag gestures.
  ///
  /// See [ScrollBehavior.dragDevices] for more information.
  final Set<PointerDeviceKind> dragDevices;

  /// Whether scrollbar thumbs can be dragged with pointer devices
  final bool isDraggable;

  /// Whether to use smooth scrolling animation for mouse wheel input
  ///
  /// When enabled, mouse wheel scrolling will animate smoothly to the target
  /// position instead of jumping instantly. This provides a more polished
  /// user experience similar to macOS/iOS scrolling behavior.
  ///
  /// Defaults to true.
  final bool smoothScrolling;

  /// Whether the scrollbar thumb is visible
  final bool thumbVisible;

  /// Whether to show the scrollbar track
  final bool showTrack;

  /// Whether to show the horizontal scrollbar
  final bool showHorizontal;

  /// Whether to show the vertical scrollbar
  final bool showVertical;

  /// Thickness of the scrollbar
  final double thickness;

  /// Minimum length of the scrollbar thumb
  final double minThumbLength;

  /// Radius of the scrollbar thumb and track (defaults to thickness/2 if not specified)
  final double? radius;

  /// Color of the scrollbar thumb
  final Color? thumbColor;

  /// Color of the scrollbar track
  final Color? trackColor;

  /// Color of the scrollbar thumb when hovered
  final Color? thumbHoverColor;

  /// Color of the scrollbar track when hovered
  final Color? trackHoverColor;

  /// Whether to show the scrollbar width in the column header
  final bool columnShowScrollWidth;

  /// Get effective thumb color
  Color get effectiveThumbColor =>
      thumbColor ?? Colors.grey.withAlpha((153).toInt());

  /// Get effective thumb hover color
  Color get effectiveThumbHoverColor =>
      thumbHoverColor ?? effectiveThumbColor.withAlpha(200);

  /// Get effective track color
  Color get effectiveTrackColor => trackColor ?? Colors.grey.withAlpha(51);

  /// Get effective track hover color
  Color get effectiveTrackHoverColor =>
      trackHoverColor ?? effectiveTrackColor.withAlpha(80);

  /// Get effective radius for the scrollbar
  double get effectiveRadius => radius ?? thickness / 2;

  @override
  bool operator ==(covariant Object other) {
    return identical(this, other) ||
        other is TrinaGridScrollbarConfig &&
            runtimeType == other.runtimeType &&
            isAlwaysShown == other.isAlwaysShown &&
            dragDevices == other.dragDevices &&
            isDraggable == other.isDraggable &&
            smoothScrolling == other.smoothScrolling &&
            thumbVisible == other.thumbVisible &&
            showTrack == other.showTrack &&
            showHorizontal == other.showHorizontal &&
            showVertical == other.showVertical &&
            thickness == other.thickness &&
            minThumbLength == other.minThumbLength &&
            radius == other.radius &&
            thumbColor == other.thumbColor &&
            trackColor == other.trackColor &&
            thumbHoverColor == other.thumbHoverColor &&
            trackHoverColor == other.trackHoverColor &&
            columnShowScrollWidth == other.columnShowScrollWidth;
  }

  @override
  int get hashCode => Object.hashAll([
    isAlwaysShown,
    dragDevices,
    isDraggable,
    smoothScrolling,
    thumbVisible,
    showTrack,
    showHorizontal,
    showVertical,
    thickness,
    minThumbLength,
    radius,
    thumbColor,
    trackColor,
    thumbHoverColor,
    trackHoverColor,
    columnShowScrollWidth,
  ]);
}

extension TrinaGridConfigurationScrollbarExtension on TrinaGridConfiguration {
  /// Get the scrollbar configuration
  /// @deprecated Use the configuration.scrollbar property directly instead
  TrinaGridScrollbarConfig get scrollbarConfig => scrollbar;
}

typedef TrinaGridColumnFilterResolver = Function<T>();

typedef TrinaGridResolveDefaultColumnFilter =
    TrinaFilterType Function(
      TrinaColumn column,
      TrinaGridColumnFilterResolver resolver,
    );

class TrinaGridColumnFilterConfig {
  /// # Set the filter information of the column.
  ///
  /// **Return the value returned by [resolveDefaultColumnFilter] through the resolver function.**
  /// **Prevents errors returning filter that are not in the [filters] list.**
  ///
  /// The value of returning from resolveDefaultColumnFilter
  /// becomes the condition of TextField below the column or
  /// is set as the default filter when calling the column popup.
  ///
  /// ```dart
  ///
  /// var filterConfig = TrinaColumnFilterConfig(
  ///   filters: const [
  ///     ...FilterHelper.defaultFilters,
  ///     // custom filter
  ///     ClassYouImplemented(),
  ///   ],
  ///   resolveDefaultColumnFilter: (column, resolver) {
  ///     if (column.field == 'text') {
  ///       return resolver<TrinaFilterTypeContains>();
  ///     } else if (column.field == 'number') {
  ///       return resolver<TrinaFilterTypeGreaterThan>();
  ///     } else if (column.field == 'date') {
  ///       return resolver<TrinaFilterTypeLessThan>();
  ///     } else if (column.field == 'select') {
  ///       return resolver<ClassYouImplemented>();
  ///     }
  ///
  ///     return resolver<TrinaFilterTypeContains>();
  ///   },
  /// );
  ///
  /// class ClassYouImplemented implements TrinaFilterType {
  ///   String get title => 'Custom contains';
  ///
  ///   get compare => ({
  ///         String base,
  ///         String search,
  ///         TrinaColumn column,
  ///       }) {
  ///         var keys = search.split(',').map((e) => e.toUpperCase()).toList();
  ///
  ///         return keys.contains(base.toUpperCase());
  ///       };
  ///
  ///   const ClassYouImplemented();
  /// }
  /// ```
  const TrinaGridColumnFilterConfig({
    List<TrinaFilterType>? filters,
    TrinaGridResolveDefaultColumnFilter? resolveDefaultColumnFilter,
    int? debounceMilliseconds,
  }) : _userFilters = filters,
       _userResolveDefaultColumnFilter = resolveDefaultColumnFilter,
       _debounceMilliseconds = debounceMilliseconds == null
           ? TrinaGridSettings.debounceMillisecondsForColumnFilter
           : debounceMilliseconds < 0
           ? 0
           : debounceMilliseconds;

  final List<TrinaFilterType>? _userFilters;

  final TrinaGridResolveDefaultColumnFilter? _userResolveDefaultColumnFilter;

  final int _debounceMilliseconds;

  bool get hasUserFilter => _userFilters != null && _userFilters.isNotEmpty;

  List<TrinaFilterType> get filters =>
      hasUserFilter ? _userFilters! : FilterHelper.defaultFilters;

  int get debounceMilliseconds => _debounceMilliseconds;

  TrinaFilterType resolver<T>() {
    return filters.firstWhereOrNull((element) => element.runtimeType == T) ??
        filters.first;
  }

  TrinaFilterType getDefaultColumnFilter(TrinaColumn column) {
    if (_userResolveDefaultColumnFilter == null) {
      return filters.first;
    }

    var resolvedFilter = _userResolveDefaultColumnFilter(column, resolver);

    assert(filters.contains(resolvedFilter));

    return resolvedFilter;
  }

  @override
  bool operator ==(covariant Object other) {
    return identical(this, other) ||
        other is TrinaGridColumnFilterConfig &&
            runtimeType == other.runtimeType &&
            listEquals(_userFilters, other._userFilters) &&
            _userResolveDefaultColumnFilter ==
                other._userResolveDefaultColumnFilter &&
            _debounceMilliseconds == other._debounceMilliseconds;
  }

  @override
  int get hashCode => Object.hash(
    _userFilters,
    _userResolveDefaultColumnFilter,
    _debounceMilliseconds,
  );
}

/// Automatically change the column width or set the mode when changing the width.
class TrinaGridColumnSizeConfig {
  const TrinaGridColumnSizeConfig({
    this.autoSizeMode = TrinaAutoSizeMode.none,
    this.resizeMode = TrinaResizeMode.normal,
    this.restoreAutoSizeAfterHideColumn = true,
    this.restoreAutoSizeAfterFrozenColumn = true,
    this.restoreAutoSizeAfterMoveColumn = true,
    this.restoreAutoSizeAfterInsertColumn = true,
    this.restoreAutoSizeAfterRemoveColumn = true,
  });

  /// Automatically change the column width.
  final TrinaAutoSizeMode autoSizeMode;

  /// This is the condition for changing the width of the column.
  final TrinaResizeMode resizeMode;

  /// [TrinaColumn.hide] Whether to apply autoSizeMode after state change.
  /// If false, autoSizeMode is not applied after the state change
  /// and the state after the change is maintained.
  final bool restoreAutoSizeAfterHideColumn;

  /// [TrinaColumn.frozen] Whether to apply autoSizeMode after state change.
  /// If false, autoSizeMode is not applied after the state change
  /// and the state after the change is maintained.
  final bool restoreAutoSizeAfterFrozenColumn;

  /// Whether to apply autoSizeMode after [TrinaColumn] is moved.
  /// If false, do not apply autoSizeMode after moving
  /// and keep the state after change.
  final bool restoreAutoSizeAfterMoveColumn;

  /// Whether to apply autoSizeMode after adding [TrinaColumn].
  /// If false, autoSizeMode is not applied after column addition
  /// and the state after change is maintained.
  final bool restoreAutoSizeAfterInsertColumn;

  /// [TrinaColumn] Whether to apply autoSizeMode after deletion.
  /// If false, autoSizeMode is not applied after deletion
  /// and the state after change is maintained.
  final bool restoreAutoSizeAfterRemoveColumn;

  TrinaGridColumnSizeConfig copyWith({
    TrinaAutoSizeMode? autoSizeMode,
    TrinaResizeMode? resizeMode,
    bool? restoreAutoSizeAfterHideColumn,
    bool? restoreAutoSizeAfterFrozenColumn,
    bool? restoreAutoSizeAfterMoveColumn,
    bool? restoreAutoSizeAfterInsertColumn,
    bool? restoreAutoSizeAfterRemoveColumn,
  }) {
    return TrinaGridColumnSizeConfig(
      autoSizeMode: autoSizeMode ?? this.autoSizeMode,
      resizeMode: resizeMode ?? this.resizeMode,
      restoreAutoSizeAfterHideColumn:
          restoreAutoSizeAfterHideColumn ?? this.restoreAutoSizeAfterHideColumn,
      restoreAutoSizeAfterFrozenColumn:
          restoreAutoSizeAfterFrozenColumn ??
          this.restoreAutoSizeAfterFrozenColumn,
      restoreAutoSizeAfterMoveColumn:
          restoreAutoSizeAfterMoveColumn ?? this.restoreAutoSizeAfterMoveColumn,
      restoreAutoSizeAfterInsertColumn:
          restoreAutoSizeAfterInsertColumn ??
          this.restoreAutoSizeAfterInsertColumn,
      restoreAutoSizeAfterRemoveColumn:
          restoreAutoSizeAfterRemoveColumn ??
          this.restoreAutoSizeAfterRemoveColumn,
    );
  }

  @override
  bool operator ==(covariant Object other) {
    return identical(this, other) ||
        other is TrinaGridColumnSizeConfig &&
            runtimeType == other.runtimeType &&
            autoSizeMode == other.autoSizeMode &&
            resizeMode == other.resizeMode &&
            restoreAutoSizeAfterHideColumn ==
                other.restoreAutoSizeAfterHideColumn &&
            restoreAutoSizeAfterFrozenColumn ==
                other.restoreAutoSizeAfterFrozenColumn &&
            restoreAutoSizeAfterMoveColumn ==
                other.restoreAutoSizeAfterMoveColumn &&
            restoreAutoSizeAfterInsertColumn ==
                other.restoreAutoSizeAfterInsertColumn &&
            restoreAutoSizeAfterRemoveColumn ==
                other.restoreAutoSizeAfterRemoveColumn;
  }

  @override
  int get hashCode => Object.hash(
    autoSizeMode,
    resizeMode,
    restoreAutoSizeAfterHideColumn,
    restoreAutoSizeAfterFrozenColumn,
    restoreAutoSizeAfterMoveColumn,
    restoreAutoSizeAfterInsertColumn,
    restoreAutoSizeAfterRemoveColumn,
  );
}

class TrinaGridLocaleText {
  // Column menu
  final String unfreezeColumn;
  final String freezeColumnToStart;
  final String freezeColumnToEnd;
  final String autoFitColumn;
  final String hideColumn;
  final String setColumns;
  final String setFilter;
  final String resetFilter;

  // SetColumns popup
  final String setColumnsTitle;

  // Filter popup
  final String filterColumn;
  final String filterType;
  final String filterValue;
  final String filterAllColumns;
  final String filterContains;
  final String filterEquals;
  final String filterStartsWith;
  final String filterEndsWith;
  final String filterGreaterThan;
  final String filterGreaterThanOrEqualTo;
  final String filterLessThan;
  final String filterLessThanOrEqualTo;

  // Date column popup
  final String sunday;
  final String monday;
  final String tuesday;
  final String wednesday;
  final String thursday;
  final String friday;
  final String saturday;

  // Time column popup
  final String hour;
  final String minute;

  // Common
  final String loadingText;

  final String multiLineFilterHint;
  final String multiLineFilterEditTitle;
  final String multiLineFilterOkButton;

  // Pagination
  final String paginationGoToPageTitle;
  final String paginationGoToPageLabel;
  final String paginationCancelButton;
  final String paginationGoButton;
  final String paginationInvalidPageNumberMessage;
  final String paginationGoToPageTooltip;

  // Time picker
  final String timePickerHourLabel;
  final String timePickerMinuteLabel;
  final String timePickerInvalidHourMessage;
  final String timePickerInvalidMinuteMessage;
  final String timePickerMinTimeMessage;
  final String timePickerMaxTimeMessage;
  final String timePickerInvalidValueMessage;

  const TrinaGridLocaleText({
    // Column menu
    this.unfreezeColumn = 'Unfreeze',
    this.freezeColumnToStart = 'Freeze to start',
    this.freezeColumnToEnd = 'Freeze to end',
    this.autoFitColumn = 'Auto fit',
    this.hideColumn = 'Hide column',
    this.setColumns = 'Set columns',
    this.setFilter = 'Set filter',
    this.resetFilter = 'Reset filter',
    // SetColumns popup
    this.setColumnsTitle = 'Column title',
    // Filter popup
    this.filterColumn = 'Column',
    this.filterType = 'Type',
    this.filterValue = 'Value',
    this.filterAllColumns = 'All columns',
    this.filterContains = 'Contains',
    this.filterEquals = 'Equals',
    this.filterStartsWith = 'Starts with',
    this.filterEndsWith = 'Ends with',
    this.filterGreaterThan = 'Greater than',
    this.filterGreaterThanOrEqualTo = 'Greater than or equal to',
    this.filterLessThan = 'Less than',
    this.filterLessThanOrEqualTo = 'Less than or equal to',
    // Date popup
    this.sunday = 'Su',
    this.monday = 'Mo',
    this.tuesday = 'Tu',
    this.wednesday = 'We',
    this.thursday = 'Th',
    this.friday = 'Fr',
    this.saturday = 'Sa',
    // Time column popup
    this.hour = 'Hour',
    this.minute = 'Minute',
    // Common
    this.loadingText = 'Loading',
    this.multiLineFilterHint = 'Filter',
    this.multiLineFilterEditTitle = 'Edit Filter',
    this.multiLineFilterOkButton = 'Ok',
    // Pagination
    this.paginationGoToPageTitle = 'Go to Page',
    this.paginationGoToPageLabel = 'Page number',
    this.paginationCancelButton = 'Cancel',
    this.paginationGoButton = 'Go',
    this.paginationInvalidPageNumberMessage =
        'Please enter a valid page number',
    this.paginationGoToPageTooltip = 'Go to page',
    // Time picker
    this.timePickerHourLabel = 'Hour',
    this.timePickerMinuteLabel = 'Minute',
    this.timePickerInvalidHourMessage = 'Hour must be between 0 and 23',
    this.timePickerInvalidMinuteMessage = 'Minute must be between 0 and 59',
    this.timePickerMinTimeMessage = 'Min time is',
    this.timePickerMaxTimeMessage = 'Max time is',
    this.timePickerInvalidValueMessage = 'Invalid value',
  });

  const TrinaGridLocaleText.french({
    // Column menu
    this.unfreezeColumn = 'Libérer',
    this.freezeColumnToStart = 'Figer au début',
    this.freezeColumnToEnd = 'Figer à la fin',
    this.autoFitColumn = 'Ajuster automatiquement',
    this.hideColumn = 'Cacher colonne',
    this.setColumns = 'Définir les colonnes',
    this.setFilter = 'Filtrer',
    this.resetFilter = 'Défiltrer',
    // SetColumns popup
    this.setColumnsTitle = 'Titre de colonne',
    // Filter popup
    this.filterColumn = 'Colonne',
    this.filterType = 'Type',
    this.filterValue = 'Valeur',
    this.filterAllColumns = 'Toutes colonnes',
    this.filterContains = 'Contient',
    this.filterEquals = 'Egal',
    this.filterStartsWith = 'Commence par',
    this.filterEndsWith = 'Termine par',
    this.filterGreaterThan = 'Supérieur à',
    this.filterGreaterThanOrEqualTo = 'Supérieur ou égal à',
    this.filterLessThan = 'Inférieur à',
    this.filterLessThanOrEqualTo = 'Inférieur ou égal à',
    // Date popup
    this.sunday = 'Di',
    this.monday = 'Lu',
    this.tuesday = 'Ma',
    this.wednesday = 'Me',
    this.thursday = 'Je',
    this.friday = 'Ve',
    this.saturday = 'Sa',
    // Time column popup
    this.hour = 'Heure',
    this.minute = 'Minute',
    // Common
    this.loadingText = 'Chargement',
    this.multiLineFilterHint = 'Filtrer',
    this.multiLineFilterEditTitle = 'Modifier le filtre',
    this.multiLineFilterOkButton = 'Ok',
    // Pagination
    this.paginationGoToPageTitle = 'Aller à la page',
    this.paginationGoToPageLabel = 'Numéro de page',
    this.paginationCancelButton = 'Annuler',
    this.paginationGoButton = 'Aller',
    this.paginationInvalidPageNumberMessage =
        'Veuillez entrer un numéro de page valide',
    this.paginationGoToPageTooltip = 'Aller à la page',
    // Time picker
    this.timePickerHourLabel = 'Heure',
    this.timePickerMinuteLabel = 'Minute',
    this.timePickerInvalidHourMessage = 'L\'heure doit être entre 0 et 23',
    this.timePickerInvalidMinuteMessage =
        'Les minutes doivent être entre 0 et 59',
    this.timePickerMinTimeMessage = 'L\'heure minimale est',
    this.timePickerMaxTimeMessage = 'L\'heure maximale est',
    this.timePickerInvalidValueMessage = 'Valeur invalide',
  });

  const TrinaGridLocaleText.china({
    // Column menu
    this.unfreezeColumn = '解冻列',
    this.freezeColumnToStart = '冻结列至起点',
    this.freezeColumnToEnd = '冻结列至终点',
    this.autoFitColumn = '自动列宽',
    this.hideColumn = '隐藏列',
    this.setColumns = '设置列',
    this.setFilter = '设置过滤器',
    this.resetFilter = '重置过滤器',
    // SetColumns popup
    this.setColumnsTitle = '列标题',
    // Filter popup
    this.filterColumn = '列',
    this.filterType = '类型',
    this.filterValue = '值',
    this.filterAllColumns = '全部列',
    this.filterContains = '包含',
    this.filterEquals = '等于',
    this.filterStartsWith = '开始于',
    this.filterEndsWith = '结束于',
    this.filterGreaterThan = '大于',
    this.filterGreaterThanOrEqualTo = '大于等于',
    this.filterLessThan = '小于',
    this.filterLessThanOrEqualTo = '小于等于',
    // Date popup
    this.sunday = '日',
    this.monday = '一',
    this.tuesday = '二',
    this.wednesday = '三',
    this.thursday = '四',
    this.friday = '五',
    this.saturday = '六',
    // Time column popup
    this.hour = '时',
    this.minute = '分',
    // Common
    this.loadingText = '加载中',
    this.multiLineFilterHint = '筛选',
    this.multiLineFilterEditTitle = '编辑筛选',
    this.multiLineFilterOkButton = '确定',
    // Pagination
    this.paginationGoToPageTitle = '转到页面',
    this.paginationGoToPageLabel = '页码',
    this.paginationCancelButton = '取消',
    this.paginationGoButton = '转到',
    this.paginationInvalidPageNumberMessage = '请输入有效的页码',
    this.paginationGoToPageTooltip = '转到页面',
    // Time picker
    this.timePickerHourLabel = '时',
    this.timePickerMinuteLabel = '分',
    this.timePickerInvalidHourMessage = '小时必须在0到23之间',
    this.timePickerInvalidMinuteMessage = '分钟必须在0到59之间',
    this.timePickerMinTimeMessage = '最小时间为',
    this.timePickerMaxTimeMessage = '最大时间为',
    this.timePickerInvalidValueMessage = '无效值',
  });

  const TrinaGridLocaleText.korean({
    // Column menu
    this.unfreezeColumn = '고정 해제',
    this.freezeColumnToStart = '시작에 고정',
    this.freezeColumnToEnd = '끝에 고정',
    this.autoFitColumn = '넓이 자동 조정',
    this.hideColumn = '컬럼 숨기기',
    this.setColumns = '컬럼 설정',
    this.setFilter = '필터 설정',
    this.resetFilter = '필터 초기화',
    // SetColumns popup
    this.setColumnsTitle = '컬럼명',
    // Filter popup
    this.filterColumn = '컬럼',
    this.filterType = '종류',
    this.filterValue = '값',
    this.filterAllColumns = '전체 컬럼',
    this.filterContains = '포함',
    this.filterEquals = '일치',
    this.filterStartsWith = '~로 시작',
    this.filterEndsWith = '~로 끝',
    this.filterGreaterThan = '~보다 큰',
    this.filterGreaterThanOrEqualTo = '~보다 크거나 같은',
    this.filterLessThan = '~보다 작은',
    this.filterLessThanOrEqualTo = '~보다 작거나 같은',
    // Date popup
    this.sunday = '일',
    this.monday = '월',
    this.tuesday = '화',
    this.wednesday = '수',
    this.thursday = '목',
    this.friday = '금',
    this.saturday = '토',
    // Time column popup
    this.hour = '시',
    this.minute = '분',
    // Common
    this.loadingText = '로딩중',
    this.multiLineFilterHint = '필터',
    this.multiLineFilterEditTitle = '필터 편집',
    this.multiLineFilterOkButton = '확인',
    // Pagination
    this.paginationGoToPageTitle = '페이지로 이동',
    this.paginationGoToPageLabel = '페이지 번호',
    this.paginationCancelButton = '취소',
    this.paginationGoButton = '이동',
    this.paginationInvalidPageNumberMessage = '유효한 페이지 번호를 입력하세요',
    this.paginationGoToPageTooltip = '페이지로 이동',
    // Time picker
    this.timePickerHourLabel = '시',
    this.timePickerMinuteLabel = '분',
    this.timePickerInvalidHourMessage = '시는 0에서 23 사이여야 합니다',
    this.timePickerInvalidMinuteMessage = '분은 0에서 59 사이여야 합니다',
    this.timePickerMinTimeMessage = '최소 시간은',
    this.timePickerMaxTimeMessage = '최대 시간은',
    this.timePickerInvalidValueMessage = '잘못된 값',
  });

  const TrinaGridLocaleText.russian({
    // Column menu
    this.unfreezeColumn = 'Открепить',
    this.freezeColumnToStart = 'Закрепить в начале',
    this.freezeColumnToEnd = 'Закрепить в конце',
    this.autoFitColumn = 'Автоматический размер',
    this.hideColumn = 'Скрыть колонку',
    this.setColumns = 'Выбрать колонки',
    this.setFilter = 'Установить фильтр',
    this.resetFilter = 'Сбросить фильтр',
    // SetColumns popup
    this.setColumnsTitle = 'Column title',
    // Filter popup
    this.filterColumn = 'Колонка',
    this.filterType = 'Тип',
    this.filterValue = 'Значение',
    this.filterAllColumns = 'Все колонки',
    this.filterContains = 'Содержит',
    this.filterEquals = 'Равно',
    this.filterStartsWith = 'Начинается с',
    this.filterEndsWith = 'Заканчивается на',
    this.filterGreaterThan = 'Больше чем',
    this.filterGreaterThanOrEqualTo = 'Больше или равно',
    this.filterLessThan = 'Меньше чем',
    this.filterLessThanOrEqualTo = 'Меньше или равно',
    // Date popup
    this.sunday = 'Вск',
    this.monday = 'Пн',
    this.tuesday = 'Вт',
    this.wednesday = 'Ср',
    this.thursday = 'Чт',
    this.friday = 'Пт',
    this.saturday = 'Сб',
    // Time column popup
    this.hour = 'Часы',
    this.minute = 'Минуты',
    // Common
    this.loadingText = 'Загрузка',
    this.multiLineFilterHint = 'Фильтр',
    this.multiLineFilterEditTitle = 'Редактировать фильтр',
    this.multiLineFilterOkButton = 'Ок',
    // Pagination
    this.paginationGoToPageTitle = 'Перейти к странице',
    this.paginationGoToPageLabel = 'Номер страницы',
    this.paginationCancelButton = 'Отмена',
    this.paginationGoButton = 'Перейти',
    this.paginationInvalidPageNumberMessage =
        'Пожалуйста, введите действительный номер страницы',
    this.paginationGoToPageTooltip = 'Перейти к странице',
    // Time picker
    this.timePickerHourLabel = 'Час',
    this.timePickerMinuteLabel = 'Минута',
    this.timePickerInvalidHourMessage = 'Час должен быть от 0 до 23',
    this.timePickerInvalidMinuteMessage = 'Минута должна быть от 0 до 59',
    this.timePickerMinTimeMessage = 'Минимальное время',
    this.timePickerMaxTimeMessage = 'Максимальное время',
    this.timePickerInvalidValueMessage = 'Неверное значение',
  });

  const TrinaGridLocaleText.czech({
    // Column menu
    this.unfreezeColumn = 'Uvolnit',
    this.freezeColumnToStart = 'Ukotvit na začátek',
    this.freezeColumnToEnd = 'Ukotvit na konec',
    this.autoFitColumn = 'Autom. přizpůsobit',
    this.hideColumn = 'Skrýt sloupec',
    this.setColumns = 'Upravit sloupce',
    this.setFilter = 'Nastavit filtr',
    this.resetFilter = 'Resetovat filtr',
    // SetColumns popup
    this.setColumnsTitle = 'Název sloupce',
    // Filter popup
    this.filterColumn = 'Sloupec',
    this.filterType = 'Typ',
    this.filterValue = 'Hodnota',
    this.filterAllColumns = 'Všechny sloupce',
    this.filterContains = 'Obsahuje',
    this.filterEquals = 'Rovná se',
    this.filterStartsWith = 'Začíná na',
    this.filterEndsWith = 'Končí na',
    this.filterGreaterThan = 'Větší než',
    this.filterGreaterThanOrEqualTo = 'Větší než nebo rovno',
    this.filterLessThan = 'Menší než',
    this.filterLessThanOrEqualTo = 'Menší než nebo rovno',
    // Date popup
    this.sunday = 'Ne',
    this.monday = 'Po',
    this.tuesday = 'Út',
    this.wednesday = 'St',
    this.thursday = 'Čt',
    this.friday = 'Pá',
    this.saturday = 'So',
    // Time column popup
    this.hour = 'Hodina',
    this.minute = 'Minuta',
    // Common
    this.loadingText = 'Načítání',
    this.multiLineFilterHint = 'Filtr',
    this.multiLineFilterEditTitle = 'Upravit filtr',
    this.multiLineFilterOkButton = 'Ok',
    // Pagination
    this.paginationGoToPageTitle = 'Přejít na stránku',
    this.paginationGoToPageLabel = 'Číslo stránky',
    this.paginationCancelButton = 'Zrušit',
    this.paginationGoButton = 'Přejít',
    this.paginationInvalidPageNumberMessage =
        'Zadejte prosím platné číslo stránky',
    this.paginationGoToPageTooltip = 'Přejít na stránku',
    // Time picker
    this.timePickerHourLabel = 'Hodina',
    this.timePickerMinuteLabel = 'Minuta',
    this.timePickerInvalidHourMessage = 'Hodina musí být mezi 0 a 23',
    this.timePickerInvalidMinuteMessage = 'Minuta musí být mezi 0 a 59',
    this.timePickerMinTimeMessage = 'Minimální čas je',
    this.timePickerMaxTimeMessage = 'Maximální čas je',
    this.timePickerInvalidValueMessage = 'Neplatná hodnota',
  });

  const TrinaGridLocaleText.brazilianPortuguese({
    // Column menu
    this.unfreezeColumn = 'Descongelar',
    this.freezeColumnToStart = 'Congelar ao início',
    this.freezeColumnToEnd = 'Congelar ao final',
    this.autoFitColumn = 'Auto Ajustar',
    this.hideColumn = 'Esconder coluna',
    this.setColumns = 'Definir colunas',
    this.setFilter = 'Definir fitros',
    this.resetFilter = 'Limpar filtros',
    // SetColumns popup
    this.setColumnsTitle = 'Título da coluna',
    // Filter popup
    this.filterColumn = 'Coluna',
    this.filterType = 'Tipo',
    this.filterValue = 'Valor',
    this.filterAllColumns = 'Todas as colunas',
    this.filterContains = 'Contenha',
    this.filterEquals = 'Igual',
    this.filterStartsWith = 'Inicia com',
    this.filterEndsWith = 'Termina com',
    this.filterGreaterThan = 'Maior que',
    this.filterGreaterThanOrEqualTo = 'Maior ou igual que',
    this.filterLessThan = 'Menor que',
    this.filterLessThanOrEqualTo = 'Menor ou igual que',
    // Date popup
    this.sunday = 'Dom',
    this.monday = 'Seg',
    this.tuesday = 'Ter',
    this.wednesday = 'Qua',
    this.thursday = 'Qui',
    this.friday = 'Sex',
    this.saturday = 'Sab',
    // Time column popup
    this.hour = 'Hora',
    this.minute = 'Minuto',
    // Common
    this.loadingText = 'Carregando',
    this.multiLineFilterHint = 'Filtro',
    this.multiLineFilterEditTitle = 'Editar filtro',
    this.multiLineFilterOkButton = 'Ok',
    // Pagination
    this.paginationGoToPageTitle = 'Ir para página',
    this.paginationGoToPageLabel = 'Número da página',
    this.paginationCancelButton = 'Cancelar',
    this.paginationGoButton = 'Ir',
    this.paginationInvalidPageNumberMessage =
        'Por favor, insira um número de página válido',
    this.paginationGoToPageTooltip = 'Ir para página',
    // Time picker
    this.timePickerHourLabel = 'Hora',
    this.timePickerMinuteLabel = 'Minuto',
    this.timePickerInvalidHourMessage = 'A hora deve estar entre 0 e 23',
    this.timePickerInvalidMinuteMessage = 'O minuto deve estar entre 0 e 59',
    this.timePickerMinTimeMessage = 'O horário mínimo é',
    this.timePickerMaxTimeMessage = 'O horário máximo é',
    this.timePickerInvalidValueMessage = 'Valor inválido',
  });

  const TrinaGridLocaleText.spanish({
    // Column menu
    this.unfreezeColumn = 'Descongelar',
    this.freezeColumnToStart = 'Inmovilizar al principio',
    this.freezeColumnToEnd = 'Inmovilizar al final',
    this.autoFitColumn = 'Autoajuste',
    this.hideColumn = 'Ocultar columna',
    this.setColumns = 'Eligir columnas',
    this.setFilter = 'Definir fitros',
    this.resetFilter = 'Limpiar filtros',
    // SetColumns popup
    this.setColumnsTitle = 'Título de la columna',
    // Filter popup
    this.filterColumn = 'Columna',
    this.filterType = 'Tipo',
    this.filterValue = 'Valor',
    this.filterAllColumns = 'Todas las columnas',
    this.filterContains = 'Contenga',
    this.filterEquals = 'Igual',
    this.filterStartsWith = 'Empieza con',
    this.filterEndsWith = 'Termina con',
    this.filterGreaterThan = 'Más grande que',
    this.filterGreaterThanOrEqualTo = 'Más grande o igual que',
    this.filterLessThan = 'Más pequeño que',
    this.filterLessThanOrEqualTo = 'Más pequeño o igual que',
    // Date popup
    this.sunday = 'Dom',
    this.monday = 'Lu',
    this.tuesday = 'Ma',
    this.wednesday = 'Mi',
    this.thursday = 'Ju',
    this.friday = 'Vi',
    this.saturday = 'Sa',
    // Time column popup
    this.hour = 'Hora',
    this.minute = 'Minuto',
    // Common
    this.loadingText = 'Cargando',
    this.multiLineFilterHint = 'Filtro',
    this.multiLineFilterEditTitle = 'Editar filtro',
    this.multiLineFilterOkButton = 'Ok',
    // Pagination
    this.paginationGoToPageTitle = 'Ir a página',
    this.paginationGoToPageLabel = 'Número de página',
    this.paginationCancelButton = 'Cancelar',
    this.paginationGoButton = 'Ir',
    this.paginationInvalidPageNumberMessage =
        'Por favor, ingrese un número de página válido',
    this.paginationGoToPageTooltip = 'Ir a página',
    // Time picker
    this.timePickerHourLabel = 'Hora',
    this.timePickerMinuteLabel = 'Minuto',
    this.timePickerInvalidHourMessage = 'La hora debe estar entre 0 y 23',
    this.timePickerInvalidMinuteMessage = 'El minuto debe estar entre 0 y 59',
    this.timePickerMinTimeMessage = 'El horario mínimo es',
    this.timePickerMaxTimeMessage = 'El horario máximo es',
    this.timePickerInvalidValueMessage = 'Valor inválido',
  });

  const TrinaGridLocaleText.persian({
    // Column menu
    this.unfreezeColumn = 'جدا کردن',
    this.freezeColumnToStart = 'چسباندن به ابتدا',
    this.freezeColumnToEnd = 'چسباندن به انتها',
    this.autoFitColumn = 'عرض خودکار',
    this.hideColumn = 'مخفی کردن ستون',
    this.setColumns = 'تنظیم ستون ها',
    this.setFilter = 'اعمال فیلتر',
    this.resetFilter = 'ریست فیلتر',
    // SetColumns popup
    this.setColumnsTitle = 'عنوان ستون',
    // Filter popup
    this.filterColumn = 'ستون',
    this.filterType = 'نوع',
    this.filterValue = 'مقدار',
    this.filterAllColumns = 'تمام ستون ها',
    this.filterContains = 'شامل',
    this.filterEquals = 'برابر',
    this.filterStartsWith = 'شروع با',
    this.filterEndsWith = 'خاتمه با',
    this.filterGreaterThan = 'بزرگتر از',
    this.filterGreaterThanOrEqualTo = 'بزرگتر مساوی از',
    this.filterLessThan = 'کمتر از',
    this.filterLessThanOrEqualTo = 'کمتر مساوی از',
    // Date popup
    this.sunday = 'ی',
    this.monday = 'د',
    this.tuesday = 'س',
    this.wednesday = 'چ',
    this.thursday = 'پ',
    this.friday = 'ج',
    this.saturday = 'ش',
    // Time column popup
    this.hour = 'ساعت',
    this.minute = 'دقیقه',
    // Common
    this.loadingText = 'در حال بارگیری',
    this.multiLineFilterHint = 'فیلتر',
    this.multiLineFilterEditTitle = 'ویرایش فیلتر',
    this.multiLineFilterOkButton = 'تأیید',
    // Pagination
    this.paginationGoToPageTitle = 'رفتن به صفحه',
    this.paginationGoToPageLabel = 'شماره صفحه',
    this.paginationCancelButton = 'لغو',
    this.paginationGoButton = 'برو',
    this.paginationInvalidPageNumberMessage =
        'لطفاً یک شماره صفحه معتبر وارد کنید',
    this.paginationGoToPageTooltip = 'رفتن به صفحه',
    // Time picker
    this.timePickerHourLabel = 'ساعت',
    this.timePickerMinuteLabel = 'دقیقه',
    this.timePickerInvalidHourMessage = 'ساعت باید بین 0 تا 23 باشد',
    this.timePickerInvalidMinuteMessage = 'دقیقه باید بین 0 تا 59 باشد',
    this.timePickerMinTimeMessage = 'حداقل زمان',
    this.timePickerMaxTimeMessage = 'حداکثر زمان',
    this.timePickerInvalidValueMessage = 'مقدار نامعتبر',
  });

  const TrinaGridLocaleText.arabic({
    // Column menu
    this.unfreezeColumn = 'إلغاء التجميد',
    this.freezeColumnToStart = 'تجميد إلى البداية',
    this.freezeColumnToEnd = 'تجميد إلى النهاية',
    this.autoFitColumn = 'تعبئة تلقائية',
    this.hideColumn = 'إخفاء العمود',
    this.setColumns = 'إدراج أعمدة',
    this.setFilter = 'فلترة',
    this.resetFilter = 'تهيئة الفلترة',
    // SetColumns popup
    this.setColumnsTitle = 'اسم العمود',
    // Filter popup
    this.filterColumn = 'العمود',
    this.filterType = 'النوع',
    this.filterValue = 'القيمة',
    this.filterAllColumns = 'كل الأعمدة',
    this.filterContains = 'يحتوي',
    this.filterEquals = 'يساوي',
    this.filterStartsWith = 'يبدأ بـ',
    this.filterEndsWith = 'ينتهي بـ',
    this.filterGreaterThan = 'أكبر من',
    this.filterGreaterThanOrEqualTo = 'أكبر من أو يساوي',
    this.filterLessThan = 'اصغر من',
    this.filterLessThanOrEqualTo = 'أصغر من أو يساوي',
    // Date popup
    this.sunday = 'أح',
    this.monday = 'إث',
    this.tuesday = 'ثل',
    this.wednesday = 'أر',
    this.thursday = 'خم',
    this.friday = 'جم',
    this.saturday = 'ش',
    // Time column popup
    this.hour = 'ساعة',
    this.minute = 'دقيقي',
    // Common
    this.loadingText = 'جاري التحميل',
    this.multiLineFilterHint = 'تصفية',
    this.multiLineFilterEditTitle = 'تعديل التصفية',
    this.multiLineFilterOkButton = 'موافق',
    // Pagination
    this.paginationGoToPageTitle = 'الانتقال إلى الصفحة',
    this.paginationGoToPageLabel = 'رقم الصفحة',
    this.paginationCancelButton = 'إلغاء',
    this.paginationGoButton = 'انتقل',
    this.paginationInvalidPageNumberMessage = 'الرجاء إدخال رقم صفحة صالح',
    this.paginationGoToPageTooltip = 'الانتقال إلى الصفحة',
    // Time picker
    this.timePickerHourLabel = 'ساعة',
    this.timePickerMinuteLabel = 'دقيقة',
    this.timePickerInvalidHourMessage = 'يجب أن تكون الساعة بين 0 و 23',
    this.timePickerInvalidMinuteMessage = 'يجب أن تكون الدقيقة بين 0 و 59',
    this.timePickerMinTimeMessage = 'الحد الأدنى للوقت هو',
    this.timePickerMaxTimeMessage = 'الحد الأقصى للوقت هو',
    this.timePickerInvalidValueMessage = 'قيمة غير صالحة',
  });

  const TrinaGridLocaleText.norway({
    // Column menu
    this.unfreezeColumn = 'Løsne',
    this.freezeColumnToStart = 'Fest til start',
    this.freezeColumnToEnd = 'Fest til slutt',
    this.autoFitColumn = 'Auto-juster',
    this.hideColumn = 'Gjem kolonne',
    this.setColumns = 'Sett kolonner',
    this.setFilter = 'Sett filter',
    this.resetFilter = 'Tilbakestill filter',
    // SetColumns popup
    this.setColumnsTitle = 'Kolonnetittel',
    // Filter popup
    this.filterColumn = 'Kolonne',
    this.filterType = 'Type',
    this.filterValue = 'Verdi',
    this.filterAllColumns = 'Alle kolonner',
    this.filterContains = 'Inneholder',
    this.filterEquals = 'Er lik',
    this.filterStartsWith = 'Starter men',
    this.filterEndsWith = 'Ender med',
    this.filterGreaterThan = 'Større enn',
    this.filterGreaterThanOrEqualTo = 'Større enn eller lik',
    this.filterLessThan = 'Mindre enn',
    this.filterLessThanOrEqualTo = 'Mindre enn eller lik',
    // Date popup
    this.sunday = 'Søn',
    this.monday = 'Man',
    this.tuesday = 'Tir',
    this.wednesday = 'Ons',
    this.thursday = 'Tor',
    this.friday = 'Frr',
    this.saturday = 'Lør',
    // Time column popup
    this.hour = 'Time',
    this.minute = 'Minutt',
    // Common
    this.loadingText = 'Laster',
    this.multiLineFilterHint = 'Filter',
    this.multiLineFilterEditTitle = 'Rediger filter',
    this.multiLineFilterOkButton = 'Ok',
    // Pagination
    this.paginationGoToPageTitle = 'Gå til side',
    this.paginationGoToPageLabel = 'Sidenummer',
    this.paginationCancelButton = 'Avbryt',
    this.paginationGoButton = 'Gå',
    this.paginationInvalidPageNumberMessage =
        'Vennligst oppgi et gyldig sidenummer',
    this.paginationGoToPageTooltip = 'Gå til side',
    // Time picker
    this.timePickerHourLabel = 'Time',
    this.timePickerMinuteLabel = 'Minutt',
    this.timePickerInvalidHourMessage = 'Time må være mellom 0 og 23',
    this.timePickerInvalidMinuteMessage = 'Minutt må være mellom 0 og 59',
    this.timePickerMinTimeMessage = 'Min tid er',
    this.timePickerMaxTimeMessage = 'Maks tid er',
    this.timePickerInvalidValueMessage = 'Ugyldig verdi',
  });

  const TrinaGridLocaleText.german({
    // Column menu
    this.unfreezeColumn = 'Spalte lösen',
    this.freezeColumnToStart = 'An den Anfang pinnen',
    this.freezeColumnToEnd = 'Ans Ende pinnen',
    this.autoFitColumn = 'Auto fit',
    this.hideColumn = 'Spalte verstecken',
    this.setColumns = 'Spalten auswählen',
    this.setFilter = 'Filter anwenden',
    this.resetFilter = 'Filter zurücksetzen',
    // SetColumns popup
    this.setColumnsTitle = 'Spaltentitel',
    // Filter popup
    this.filterColumn = 'Spalte',
    this.filterType = 'Typ',
    this.filterValue = 'Wert',
    this.filterAllColumns = 'Alle Spalten',
    this.filterContains = 'Beinhaltet',
    this.filterEquals = 'Ist gleich',
    this.filterStartsWith = 'Started mit',
    this.filterEndsWith = 'Endet mit',
    this.filterGreaterThan = 'Größer als',
    this.filterGreaterThanOrEqualTo = 'Größer als oder gleich',
    this.filterLessThan = 'Kleiner als',
    this.filterLessThanOrEqualTo = 'Kleiner als oder gleich',
    // Date popup
    this.sunday = 'So',
    this.monday = 'Mo',
    this.tuesday = 'Di',
    this.wednesday = 'Mi',
    this.thursday = 'Do',
    this.friday = 'Fr',
    this.saturday = 'Sa',
    // Time column popup
    this.hour = 'Stunde',
    this.minute = 'Minute',
    // Common
    this.loadingText = 'Lädt',
    this.multiLineFilterHint = 'Filter',
    this.multiLineFilterEditTitle = 'Filter bearbeiten',
    this.multiLineFilterOkButton = 'Ok',
    // Pagination
    this.paginationGoToPageTitle = 'Gehe zu Seite',
    this.paginationGoToPageLabel = 'Seitennummer',
    this.paginationCancelButton = 'Abbrechen',
    this.paginationGoButton = 'Gehen',
    this.paginationInvalidPageNumberMessage =
        'Bitte geben Sie eine gültige Seitennummer ein',
    this.paginationGoToPageTooltip = 'Gehe zu Seite',
    // Time picker
    this.timePickerHourLabel = 'Stunde',
    this.timePickerMinuteLabel = 'Minute',
    this.timePickerInvalidHourMessage =
        'Die Stunde muss zwischen 0 und 23 liegen',
    this.timePickerInvalidMinuteMessage =
        'Die Minute muss zwischen 0 und 59 liegen',
    this.timePickerMinTimeMessage = 'Die Mindestzeit ist',
    this.timePickerMaxTimeMessage = 'Die Höchstzeit ist',
    this.timePickerInvalidValueMessage = 'Ungültiger Wert',
  });

  const TrinaGridLocaleText.turkish({
    // Column menu
    this.unfreezeColumn = 'Sütunu serbest bırak',
    this.freezeColumnToStart = 'Başa sabitle',
    this.freezeColumnToEnd = 'Sona sabitle',
    this.autoFitColumn = 'Otomatik genişlik',
    this.hideColumn = 'Sütunu gizle',
    this.setColumns = 'Sütunları seç',
    this.setFilter = 'Filtre uygula',
    this.resetFilter = 'Filtreyi sıfırla',
    // SetColumns popup
    this.setColumnsTitle = 'Sütun başlıkları',
    // Filter popup
    this.filterColumn = 'Sütun',
    this.filterType = 'Tip',
    this.filterValue = 'Değer',
    this.filterAllColumns = 'Tüm sütunlar',
    this.filterContains = 'İçerir',
    this.filterEquals = 'Eşittir',
    this.filterStartsWith = 'Başlar',
    this.filterEndsWith = 'Biter',
    this.filterGreaterThan = 'Büyüktür',
    this.filterGreaterThanOrEqualTo = 'Büyük veya eşittir',
    this.filterLessThan = 'Küçüktür',
    this.filterLessThanOrEqualTo = 'Küçük veya eşittir',
    // Date popup
    this.sunday = 'Paz',
    this.monday = 'Pzt',
    this.tuesday = 'Sal',
    this.wednesday = 'Çar',
    this.thursday = 'Per',
    this.friday = 'Cum',
    this.saturday = 'Cmt',
    // Time column popup
    this.hour = 'Saat',
    this.minute = 'Dakika',
    // Common
    this.loadingText = 'Yükleniyor',
    this.multiLineFilterHint = 'Filtre',
    this.multiLineFilterEditTitle = 'Filtreyi Düzenle',
    this.multiLineFilterOkButton = 'Tamam',
    // Pagination
    this.paginationGoToPageTitle = 'Sayfaya Git',
    this.paginationGoToPageLabel = 'Sayfa numarası',
    this.paginationCancelButton = 'İptal',
    this.paginationGoButton = 'Git',
    this.paginationInvalidPageNumberMessage =
        'Lütfen geçerli bir sayfa numarası girin',
    this.paginationGoToPageTooltip = 'Sayfaya git',
    // Time picker
    this.timePickerHourLabel = 'Saat',
    this.timePickerMinuteLabel = 'Dakika',
    this.timePickerInvalidHourMessage = 'Saat 0 ile 23 arasında olmalıdır',
    this.timePickerInvalidMinuteMessage = 'Dakika 0 ile 59 arasında olmalıdır',
    this.timePickerMinTimeMessage = 'Minimum zaman',
    this.timePickerMaxTimeMessage = 'Maksimum zaman',
    this.timePickerInvalidValueMessage = 'Geçersiz değer',
  });

  const TrinaGridLocaleText.japanese({
    // Column menu
    this.unfreezeColumn = '列の固定を解除する',
    this.freezeColumnToStart = '列を最初に固定する',
    this.freezeColumnToEnd = '列を最後に固定する',
    this.autoFitColumn = '列幅の自動修正',
    this.hideColumn = '列を非表示にする',
    this.setColumns = '列の表示設定',
    this.setFilter = 'フィルタの作成',
    this.resetFilter = 'フィルタの削除',
    // SetColumns popup
    this.setColumnsTitle = '列のタイトル',
    // Filter popup
    this.filterColumn = '列',
    this.filterType = '種類',
    this.filterValue = '値',
    this.filterAllColumns = '全列',
    this.filterContains = '含む',
    this.filterEquals = '等しい',
    this.filterStartsWith = '指定の値で始まる',
    this.filterEndsWith = '指定の値で終わる',
    this.filterGreaterThan = 'より大きい',
    this.filterGreaterThanOrEqualTo = '以上',
    this.filterLessThan = '未満',
    this.filterLessThanOrEqualTo = '以下',
    // Date popup
    this.sunday = '日',
    this.monday = '月',
    this.tuesday = '火',
    this.wednesday = '水',
    this.thursday = '木',
    this.friday = '金',
    this.saturday = '土',
    // Time column popup
    this.hour = '時間',
    this.minute = '分',
    // Common
    this.loadingText = 'にゃ〜',
    this.multiLineFilterHint = 'フィルター',
    this.multiLineFilterEditTitle = 'フィルターを編集',
    this.multiLineFilterOkButton = 'OK',
    // Pagination
    this.paginationGoToPageTitle = 'ページに移動',
    this.paginationGoToPageLabel = 'ページ番号',
    this.paginationCancelButton = 'キャンセル',
    this.paginationGoButton = '移動',
    this.paginationInvalidPageNumberMessage = '有効なページ番号を入力してください',
    this.paginationGoToPageTooltip = 'ページに移動',
    // Time picker
    this.timePickerHourLabel = '時間',
    this.timePickerMinuteLabel = '分',
    this.timePickerInvalidHourMessage = '時間は0から23の間でなければなりません',
    this.timePickerInvalidMinuteMessage = '分は0から59の間でなければなりません',
    this.timePickerMinTimeMessage = '最小時刻は',
    this.timePickerMaxTimeMessage = '最大時刻は',
    this.timePickerInvalidValueMessage = '無効な値',
  });

  @override
  bool operator ==(covariant Object other) {
    return identical(this, other) ||
        other is TrinaGridLocaleText &&
            runtimeType == other.runtimeType &&
            unfreezeColumn == other.unfreezeColumn &&
            freezeColumnToStart == other.freezeColumnToStart &&
            freezeColumnToEnd == other.freezeColumnToEnd &&
            autoFitColumn == other.autoFitColumn &&
            hideColumn == other.hideColumn &&
            setColumns == other.setColumns &&
            setFilter == other.setFilter &&
            resetFilter == other.resetFilter &&
            setColumnsTitle == other.setColumnsTitle &&
            filterColumn == other.filterColumn &&
            filterType == other.filterType &&
            filterValue == other.filterValue &&
            filterAllColumns == other.filterAllColumns &&
            filterContains == other.filterContains &&
            filterEquals == other.filterEquals &&
            filterStartsWith == other.filterStartsWith &&
            filterEndsWith == other.filterEndsWith &&
            filterGreaterThan == other.filterGreaterThan &&
            filterGreaterThanOrEqualTo == other.filterGreaterThanOrEqualTo &&
            filterLessThan == other.filterLessThan &&
            filterLessThanOrEqualTo == other.filterLessThanOrEqualTo &&
            sunday == other.sunday &&
            monday == other.monday &&
            tuesday == other.tuesday &&
            wednesday == other.wednesday &&
            thursday == other.thursday &&
            friday == other.friday &&
            saturday == other.saturday &&
            hour == other.hour &&
            minute == other.minute &&
            loadingText == other.loadingText &&
            multiLineFilterHint == other.multiLineFilterHint &&
            multiLineFilterEditTitle == other.multiLineFilterEditTitle &&
            multiLineFilterOkButton == other.multiLineFilterOkButton;
  }

  @override
  int get hashCode => Object.hashAll([
    unfreezeColumn,
    freezeColumnToStart,
    freezeColumnToEnd,
    autoFitColumn,
    hideColumn,
    setColumns,
    setFilter,
    resetFilter,
    setColumnsTitle,
    filterColumn,
    filterType,
    filterValue,
    filterAllColumns,
    filterContains,
    filterEquals,
    filterStartsWith,
    filterEndsWith,
    filterGreaterThan,
    filterGreaterThanOrEqualTo,
    filterLessThan,
    filterLessThanOrEqualTo,
    sunday,
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    hour,
    minute,
    loadingText,
    multiLineFilterHint,
    multiLineFilterEditTitle,
    multiLineFilterOkButton,
  ]);
}

enum TrinaGridRowSelectionCheckBoxBehavior {
  /// Selecting a row does nothing to its checkbox
  none,

  /// Automatically enables the checkbox of the selected rows
  checkRow,

  /// Automatically toggles the checkbox of the selected rows
  toggleCheckRow,

  /// Automatically enabels the checkbox of a selected row (if another row is checked via select, the previous one is unchecked)
  singleRowCheck,

  /// Automatically toggles the checkbox of a selected row (if another row is checked via select, the previous one is unchecked)
  toggleSingleRowCheck,
}

/// Behavior of the Enter key when a cell is selected.
enum TrinaGridEnterKeyAction {
  /// When the Enter key is pressed, the cell is changed to the edit state,
  /// or if it is already in the edit state, it moves to the cell below.
  editingAndMoveDown,

  /// When the Enter key is pressed, the cell is changed to the edit state,
  /// or if it is already in the edit state, it moves to the right cell.
  editingAndMoveRight,

  /// Pressing the Enter key toggles the editing status.
  toggleEditing,

  /// Pressing the Enter key does nothing.
  none;

  bool get isEditingAndMoveDown =>
      this == TrinaGridEnterKeyAction.editingAndMoveDown;

  bool get isEditingAndMoveRight =>
      this == TrinaGridEnterKeyAction.editingAndMoveRight;

  bool get isToggleEditing => this == TrinaGridEnterKeyAction.toggleEditing;

  bool get isNone => this == TrinaGridEnterKeyAction.none;
}

/// Tab key action type.
enum TrinaGridTabKeyAction {
  /// {@template trina_grid_tab_key_action_normal}
  /// Tab or Shift Tab key moves when reaching the edge no longer moves.
  /// {@endtemplate}
  normal,

  /// {@template trina_grid_tab_key_action_moveToNextOnEdge}
  /// Tab or Shift Tab key to continue moving to the next or previous row
  /// of cells when the edge is reached.
  /// {@endtemplate}
  moveToNextOnEdge;

  bool get isNormal => this == TrinaGridTabKeyAction.normal;

  bool get isMoveToNextOnEdge => this == TrinaGridTabKeyAction.moveToNextOnEdge;
}
