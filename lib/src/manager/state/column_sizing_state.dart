import 'package:trina_grid/trina_grid.dart';

/// Automatically adjust column width or manage width adjustment mode.
abstract class IColumnSizingState {
  /// Refers to the value set in [TrinaGridConfiguration].
  TrinaGridColumnSizeConfig get columnSizeConfig;

  /// Automatically adjust the column width at the start of the grid
  /// or when the grid width is changed.
  TrinaAutoSizeMode get columnsAutoSizeMode;

  /// Condition for changing column width.
  TrinaResizeMode get columnsResizeMode;

  /// Whether [columnsAutoSizeMode] is enabled.
  bool get enableColumnsAutoSize;

  /// Whether [columnsAutoSizeMode] should be applied while [columnsAutoSizeMode] is enabled.
  ///
  /// After changing the state of the column,
  /// set whether to apply [columnsAutoSizeMode] again according to the value below.
  /// [TrinaGridColumnSizeConfig.restoreAutoSizeAfterHideColumn]
  /// [TrinaGridColumnSizeConfig.restoreAutoSizeAfterFrozenColumn]
  /// [TrinaGridColumnSizeConfig.restoreAutoSizeAfterMoveColumn]
  /// [TrinaGridColumnSizeConfig.restoreAutoSizeAfterInsertColumn]
  /// [TrinaGridColumnSizeConfig.restoreAutoSizeAfterRemoveColumn]
  ///
  /// If the above values are set to false,
  /// [columnsAutoSizeMode] is not applied after changing the column state.
  ///
  /// In this case, if the width of the grid is changed again or there is a layout change,
  /// it will be activated again.
  bool get activatedColumnsAutoSize;

  void activateColumnsAutoSize();

  void deactivateColumnsAutoSize();

  TrinaAutoSize getColumnsAutoSizeHelper({
    required Iterable<TrinaColumn> columns,
    required double maxWidth,
  });

  TrinaResize getColumnsResizeHelper({
    required List<TrinaColumn> columns,
    required TrinaColumn column,
    required double offset,
  });

  void setColumnSizeConfig(TrinaGridColumnSizeConfig config);
}

class _State {
  bool? _activatedColumnsAutoSize;
}

mixin ColumnSizingState implements ITrinaGridState {
  final _State _state = _State();

  @override
  TrinaGridColumnSizeConfig get columnSizeConfig => configuration.columnSize;

  @override
  TrinaAutoSizeMode get columnsAutoSizeMode => columnSizeConfig.autoSizeMode;

  @override
  TrinaResizeMode get columnsResizeMode => columnSizeConfig.resizeMode;

  @override
  bool get enableColumnsAutoSize => !columnsAutoSizeMode.isNone;

  @override
  bool get activatedColumnsAutoSize =>
      enableColumnsAutoSize && _state._activatedColumnsAutoSize != false;

  @override
  void activateColumnsAutoSize() {
    _state._activatedColumnsAutoSize = true;
  }

  @override
  void deactivateColumnsAutoSize() {
    _state._activatedColumnsAutoSize = false;
  }

  @override
  TrinaAutoSize getColumnsAutoSizeHelper({
    required Iterable<TrinaColumn> columns,
    required double maxWidth,
  }) {
    assert(columnsAutoSizeMode.isNone == false);
    assert(columns.isNotEmpty);

    return TrinaAutoSizeHelper.items<TrinaColumn>(
      maxSize: maxWidth,
      items: columns,
      isSuppressed: (e) =>
          e.suppressedAutoSize ||
          (columnSizeConfig.scaleOnlyFlexibleColumns &&
              columnsAutoSizeMode.isScale &&
              e.hasExplicitWidth),
      getItemSize: (e) => e.width,
      getItemMinSize: (e) => e.minWidth,
      setItemSize: (e, size) => e.width = size,
      mode: columnsAutoSizeMode,
    );
  }

  @override
  TrinaResize getColumnsResizeHelper({
    required List<TrinaColumn> columns,
    required TrinaColumn column,
    required double offset,
  }) {
    assert(!columnsResizeMode.isNone && !columnsResizeMode.isNormal);
    assert(columns.isNotEmpty);

    return TrinaResizeHelper.items<TrinaColumn>(
      offset: offset,
      items: columns,
      isMainItem: (e) => e.key == column.key,
      getItemSize: (e) => e.width,
      getItemMinSize: (e) => e.minWidth,
      setItemSize: (e, size) => e.width = size,
      mode: columnsResizeMode,
    );
  }

  @override
  void setColumnSizeConfig(TrinaGridColumnSizeConfig config) {
    setConfiguration(
      configuration.copyWith(columnSize: config),
      updateLocale: false,
      applyColumnFilter: false,
    );

    if (enableColumnsAutoSize) {
      activateColumnsAutoSize();

      notifyResizingListeners();
    }
  }
}
