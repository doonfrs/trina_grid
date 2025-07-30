enum TrinaGridMode {
  /// {@template trina_grid_mode_normal}
  /// Basic mode with most functions not limited, such as editing and selection.
  /// {@endtemplate}
  normal,

  /// {@template trina_grid_mode_readOnly}
  /// Cell cannot be edited.
  /// To try to edit by force, it is possible as follows.
  ///
  /// ```dart
  /// stateManager.changeCellValue(
  ///   stateManager.currentCell!,
  ///   'test',
  ///   force: true,
  /// );
  /// ```
  /// {@endtemplate}
  readOnly,

  /// {@template trina_grid_mode_select}
  /// Mode for selecting one list from a specific list.
  /// Tap a row or press Enter to select the current row.
  ///
  /// [select]
  /// Call the [TrinaGrid.onSelected] callback when the selected row is tapped.
  /// To select an unselected row, select the row and then tap once more.
  /// [selectWithOneTap]
  /// Same as [select], but calls [TrinaGrid.onSelected] with one tap.
  ///
  /// This mode is non-editable, but programmatically possible.
  /// ```dart
  /// stateManager.changeCellValue(
  ///   stateManager.currentRow!.cells['column_1']!,
  ///   value,
  ///   force: true,
  /// );
  /// ```
  /// {@endtemplate}
  select,

  /// {@macro trina_grid_mode_select}
  selectWithOneTap,

  /// {@template trina_grid_mode_multiSelect}
  /// Mode to select multiple rows.
  /// When a row is tapped, it is selected or deselected and the [TrinaGrid.onSelected] callback is called.
  /// [TrinaGridOnSelectedEvent.selectedRows] contains the selected rows.
  /// When a row is selected with keyboard shift + arrowDown/Up keys,
  /// the [TrinaGrid.onSelected] callback is called only when the Enter key is pressed.
  /// When the Escape key is pressed,
  /// the selected row is canceled and the [TrinaGrid.onSelected] callback is called
  /// with a [TrinaGridOnSelectedEvent.selectedRows] value of null.
  /// {@endtemplate}
  multiSelect,

  /// {@template trina_grid_mode_popup}
  /// This is a mode for popup type.
  /// It is used when calling a popup for filtering or column setting
  /// inside [TrinaGrid], and it is not a mode for users.
  ///
  /// If the user wants to run [TrinaGrid] as a popup,
  /// use [TrinaGridPopup] or [TrinaGridDualGridPopup].
  /// {@endtemplate}
  popup;

  bool get isNormal => this == TrinaGridMode.normal;

  bool get isReadOnly => this == TrinaGridMode.readOnly;

  bool get isEditableMode => isNormal || isPopup;

  bool get isSelectMode => isSingleSelectMode || isMultiSelectMode;

  bool get isSingleSelectMode => isSelect || isSelectWithOneTap;

  bool get isMultiSelectMode => isMultiSelect;

  bool get isSelect => this == TrinaGridMode.select;

  bool get isSelectWithOneTap => this == TrinaGridMode.selectWithOneTap;

  bool get isMultiSelect => this == TrinaGridMode.multiSelect;

  bool get isPopup => this == TrinaGridMode.popup;
}

/// When calling loading screen with [TrinaGridStateManager.setShowLoading] method
/// Determines the level of loading.
///
/// {@template trina_grid_loading_level_grid}
/// [grid] makes the entire grid opaque and puts the loading indicator in the center.
/// The user is in a state where no interaction is possible.
/// {@endtemplate}
///
/// {@template trina_grid_loading_level_rows}
/// [rows] represents the [LinearProgressIndicator] at the top of the widget area
/// that displays the rows.
/// User can interact.
/// {@endtemplate}
///
/// {@template trina_grid_loading_level_rowsBottomCircular}
/// [rowsBottomCircular] represents the [CircularProgressIndicator] at the bottom of the widget
/// that displays the rows.
/// User can interact.
/// {@endtemplate}
enum TrinaGridLoadingLevel {
  /// {@macro trina_grid_loading_level_grid}
  grid,

  /// {@macro trina_grid_loading_level_rows}
  rows,

  /// {@macro trina_grid_loading_level_rowsBottomCircular}
  rowsBottomCircular;

  bool get isGrid => this == TrinaGridLoadingLevel.grid;

  bool get isRows => this == TrinaGridLoadingLevel.rows;

  bool get isRowsBottomCircular =>
      this == TrinaGridLoadingLevel.rowsBottomCircular;
}

/// Controls which field is auto-focused in the time picker.
enum TrinaTimePickerAutoFocusMode {
  /// Auto-focus the hour field.
  hourField,

  /// Auto-focus the minute field.
  minuteField,

  /// No auto-focus.
  none;

  /// Returns true if the hour field should be focused.
  bool get isHour => this == TrinaTimePickerAutoFocusMode.hourField;

  /// Returns true if the minute field should be focused.
  bool get isMinute => this == TrinaTimePickerAutoFocusMode.minuteField;

  /// Returns true if any field should be focused.
  bool get isEnabled => this != TrinaTimePickerAutoFocusMode.none;
}
