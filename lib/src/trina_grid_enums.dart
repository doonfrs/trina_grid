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
