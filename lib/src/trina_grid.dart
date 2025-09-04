import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show Intl;
import 'package:trina_grid/trina_grid.dart';

import 'helper/platform_helper.dart';
import 'ui/trina_frozen_rows_before_header.dart';
import 'ui/ui.dart';

typedef TrinaOnLoadedEventCallback = void Function(
    TrinaGridOnLoadedEvent event);

typedef TrinaOnChangedEventCallback = void Function(
    TrinaGridOnChangedEvent event);

typedef TrinaOnKeyPressedEventCallback = void Function(
    TrinaGridOnKeyEvent event);

typedef TrinaOnSelectedEventCallback = void Function(
    TrinaGridOnSelectedEvent event);

typedef TrinaOnSortedEventCallback = void Function(
    TrinaGridOnSortedEvent event);

typedef TrinaOnRowCheckedEventCallback = void Function(
    TrinaGridOnRowCheckedEvent event);

typedef TrinaOnRowDoubleTapEventCallback = void Function(
    TrinaGridOnRowDoubleTapEvent event);

typedef TrinaOnRowSecondaryTapEventCallback = void Function(
    TrinaGridOnRowSecondaryTapEvent event);

typedef TrinaOnRowEnterEventCallback = void Function(
    TrinaGridOnRowEnterEvent event);

typedef TrinaOnRowExitEventCallback = void Function(
    TrinaGridOnRowExitEvent event);

typedef TrinaOnRowsMovedEventCallback = void Function(
    TrinaGridOnRowsMovedEvent event);

typedef TrinaOnColumnsMovedEventCallback = void Function(
    TrinaGridOnColumnsMovedEvent event);

typedef CreateHeaderCallBack = Widget Function(
    TrinaGridStateManager stateManager);

typedef CreateFooterCallBack = Widget Function(
    TrinaGridStateManager stateManager);

typedef TrinaRowColorCallback = Color Function(
    TrinaRowColorContext rowColorContext);

typedef TrinaCellColorCallback = Color? Function(
    TrinaCellColorContext cellColorContext);

typedef TrinaSelectDateCallBack = Future<DateTime?> Function(
    TrinaCell dateCell, TrinaColumn column);

typedef TrinaOnActiveCellChangedEventCallback = void Function(
    TrinaGridOnActiveCellChangedEvent event);

typedef TrinaOnValidationFailedCallback = void Function(
    TrinaGridValidationEvent event);

typedef TrinaOnLazyFetchCompletedEventCallback = void Function(
    TrinaGridOnLazyFetchCompletedEvent event);

typedef RowWrapper = Widget Function(
  BuildContext context,
  Widget rowWidget,
  TrinaRow rowData,
  TrinaGridStateManager stateManager,
);

/// [TrinaGrid] is a widget that receives columns and rows and is expressed as a grid-type UI.
///
/// [TrinaGrid] supports movement and editing with the keyboard,
/// Through various settings, it can be transformed and used in various UIs.
///
/// Pop-ups such as date selection, time selection,
/// and option selection used inside [TrinaGrid] are created with the API provided outside of [TrinaGrid].
/// Also, the popup to set the filter or column inside the grid is implemented through the setting of [TrinaGrid].
class TrinaGrid extends TrinaStatefulWidget {
  const TrinaGrid({
    super.key,
    required this.columns,
    required this.rows,
    this.rowsCacheExtent,
    this.rowWrapper,
    this.editCellRenderer,
    this.columnGroups,
    this.onLoaded,
    this.onChanged,
    this.onSelected,
    this.onSorted,
    this.onRowChecked,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.onRowEnter,
    this.onRowExit,
    this.onRowsMoved,
    this.onActiveCellChanged,
    this.onColumnsMoved,
    this.createHeader,
    this.createFooter,
    this.noRowsWidget,
    this.rowColorCallback,
    this.cellColorCallback,
    this.selectDateCallback,
    this.columnMenuDelegate,
    this.configuration = const TrinaGridConfiguration(),
    this.notifierFilterResolver,
    this.mode = TrinaGridMode.normal,
    this.onValidationFailed,
    this.onLazyFetchCompleted,
  });

  final double? rowsCacheExtent;

  /// {@macro trina_grid_row_wrapper}
  final RowWrapper? rowWrapper;

  /// Grid-level edit cell renderer.
  /// This allows customizing the edit cell UI for all columns.
  /// Column-level editCellRenderer takes precedence if provided.
  final Widget Function(
    Widget defaultEditCellWidget,
    TrinaCell cell,
    TextEditingController controller,
    FocusNode focusNode,
    Function(dynamic value)? handleSelected,
  )? editCellRenderer;

  /// {@template trina_grid_property_columns}
  /// The [TrinaColumn] column is delivered as a list and can be added or deleted after grid creation.
  ///
  /// Columns can be added or deleted
  /// with [TrinaGridStateManager.insertColumns] and [TrinaGridStateManager.removeColumns].
  ///
  /// Each [TrinaColumn.field] value in [List] must be unique.
  /// [TrinaColumn.field] must be provided to match the map key in [TrinaRow.cells].
  /// should also be provided to match in [TrinaColumnGroup.fields] as well.
  /// {@endtemplate}
  final List<TrinaColumn> columns;

  /// {@template trina_grid_property_rows}
  /// [rows] contains a call to the [TrinaGridStateManager.initializeRows] method
  /// that handles necessary settings when creating a grid or when a new row is added.
  ///
  /// CPU operation is required as much as [rows.length] multiplied by the number of [TrinaRow.cells].
  /// No problem under normal circumstances, but if there are many rows and columns,
  /// the UI may freeze at the start of the grid.
  /// In this case, the grid is started by passing an empty list to rows
  /// and after the [TrinaGrid.onLoaded] callback is called
  /// Rows initialization can be done asynchronously with [TrinaGridStateManager.initializeRowsAsync] .
  ///
  /// ```dart
  /// stateManager.setShowLoading(true);
  ///
  /// TrinaGridStateManager.initializeRowsAsync(
  ///   columns,
  ///   fetchedRows,
  /// ).then((value) {
  ///   stateManager.refRows.addAll(value);
  ///
  ///   /// In this example,
  ///   /// the loading screen is activated in the onLoaded callback when the grid is created.
  ///   /// If the loading screen is not activated
  ///   /// You must update the grid state by calling the stateManager.notifyListeners() method.
  ///   /// Because calling setShowLoading updates the grid state
  ///   /// No need to call stateManager.notifyListeners.
  ///   stateManager.setShowLoading(false);
  /// });
  /// ```
  /// {@endtemplate}
  final List<TrinaRow> rows;

  /// {@template trina_grid_property_columnGroups}
  /// [columnGroups] can be expressed in UI by grouping columns.
  /// {@endtemplate}
  final List<TrinaColumnGroup>? columnGroups;

  /// {@template trina_grid_property_onLoaded}
  /// [TrinaGrid] completes setting and passes [TrinaGridStateManager] to [event].
  ///
  /// When the [TrinaGrid] starts,
  /// the desired setting can be made through [TrinaGridStateManager].
  ///
  /// ex) Change the selection mode to cell selection.
  /// ```dart
  /// onLoaded: (TrinaGridOnLoadedEvent event) {
  ///   event.stateManager.setSelectingMode(TrinaGridSelectingMode.cell);
  /// },
  /// ```
  /// {@endtemplate}
  final TrinaOnLoadedEventCallback? onLoaded;

  /// {@template trina_grid_property_onChanged}
  /// [onChanged] is called when the cell value changes.
  ///
  /// When changing the cell value directly programmatically
  /// with the [TrinaGridStateManager.changeCellValue] method
  /// When changing the value by calling [callOnChangedEvent]
  /// as false as the parameter of [TrinaGridStateManager.changeCellValue]
  /// The [onChanged] callback is not called.
  /// {@endtemplate}
  final TrinaOnChangedEventCallback? onChanged;

  /// {@template trina_grid_property_onSelected}
  /// [onSelected] can receive a response only if [TrinaGrid.mode] is set to [TrinaGridMode.select] .
  ///
  /// When a row is tapped or the Enter key is pressed, the row information can be returned.
  /// When [TrinaGrid] is used for row selection, you can use [TrinaGridMode.select] .
  /// Basically, in [TrinaGridMode.select], the [onLoaded] callback works
  /// when the current selected row is tapped or the Enter key is pressed.
  /// This will require a double tap if no row is selected.
  /// In [TrinaGridMode.selectWithOneTap], the [onLoaded] callback works when the unselected row is tapped once.
  /// {@endtemplate}
  final TrinaOnSelectedEventCallback? onSelected;

  /// {@template trina_grid_property_onSorted}
  /// [onSorted] is a callback that is called when column sorting is changed.
  /// {@endtemplate}
  final TrinaOnSortedEventCallback? onSorted;

  /// {@template trina_grid_property_onRowChecked}
  /// [onRowChecked] can receive the check status change of the checkbox
  /// when [TrinaColumn.enableRowChecked] is enabled.
  /// {@endtemplate}
  final TrinaOnRowCheckedEventCallback? onRowChecked;

  /// {@template trina_grid_property_onRowDoubleTap}
  /// [onRowDoubleTap] is called when a row is tapped twice in a row.
  /// {@endtemplate}
  final TrinaOnRowDoubleTapEventCallback? onRowDoubleTap;

  /// {@template trina_grid_property_onRowSecondaryTap}
  /// [onRowSecondaryTap] is called when a mouse right-click event occurs.
  /// {@endtemplate}
  final TrinaOnRowSecondaryTapEventCallback? onRowSecondaryTap;

  /// {@template trina_grid_property_onRowEnter}
  /// [onRowEnter] is called when the mouse enters the row.
  /// {@endtemplate}
  final TrinaOnRowEnterEventCallback? onRowEnter;

  /// {@template trina_grid_property_onRowExit}
  /// [onRowExit] is called when the mouse exits the row.
  /// {@endtemplate}
  final TrinaOnRowExitEventCallback? onRowExit;

  /// {@template trina_grid_property_onRowsMoved}
  /// [onRowsMoved] is called after the row is dragged and moved
  /// if [TrinaColumn.enableRowDrag] is enabled.
  /// {@endtemplate}
  final TrinaOnRowsMovedEventCallback? onRowsMoved;

  /// {@template trina_grid_property_onActiveCellChanged}
  /// Callback for receiving events
  /// when the active cell is changed
  /// {@endtemplate}
  final TrinaOnActiveCellChangedEventCallback? onActiveCellChanged;

  /// {@template trina_grid_property_onColumnsMoved}
  /// Callback for receiving events
  /// when the column is moved by dragging the column
  /// or frozen it to the left or right.
  /// {@endtemplate}
  final TrinaOnColumnsMovedEventCallback? onColumnsMoved;

  /// {@template trina_grid_property_createHeader}
  /// [createHeader] is a user-definable area located above the upper column area of [TrinaGrid].
  ///
  /// Just pass a callback that returns [Widget] .
  /// Assuming you created a widget called Header.
  /// ```dart
  /// createHeader: (stateManager) {
  ///   stateManager.headerHeight = 45;
  ///   return Header(
  ///     stateManager: stateManager,
  ///   );
  /// },
  /// ```
  ///
  /// If the widget returned to the callback detects the state and updates the UI,
  /// register the callback in [TrinaGridStateManager.addListener]
  /// and update the UI with [StatefulWidget.setState], etc.
  /// The listener callback registered with [TrinaGridStateManager.addListener]
  /// must remove the listener callback with [TrinaGridStateManager.removeListener]
  /// when the widget returned by the callback is dispose.
  /// {@endtemplate}
  final CreateHeaderCallBack? createHeader;

  /// {@template trina_grid_property_createFooter}
  /// [createFooter] is equivalent to [createHeader].
  /// However, it is located at the bottom of the grid.
  ///
  /// [CreateFooter] can also be passed an already provided widget for Pagination.
  /// Of course you can pass it to [createHeader] , but it's not a typical UI.
  /// ```dart
  /// createFooter: (stateManager) {
  ///   stateManager.setPageSize(100, notify: false); // default 40
  ///   return TrinaPagination(stateManager);
  /// },
  /// ```
  /// {@endtemplate}
  final CreateFooterCallBack? createFooter;

  /// {@template trina_grid_property_noRowsWidget}
  /// Widget to be shown if there are no rows.
  ///
  /// Create a widget like the one below and pass it to [TrinaGrid.noRowsWidget].
  /// ```dart
  /// class _NoRows extends StatelessWidget {
  ///   const _NoRows({Key? key}) : super(key: key);
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return IgnorePointer(
  ///       child: Center(
  ///         child: DecoratedBox(
  ///           decoration: BoxDecoration(
  ///             color: Colors.white,
  ///             border: Border.all(),
  ///             borderRadius: const BorderRadius.all(Radius.circular(5)),
  ///           ),
  ///           child: Padding(
  ///             padding: const EdgeInsets.all(10),
  ///             child: Column(
  ///               mainAxisSize: MainAxisSize.min,
  ///               mainAxisAlignment: MainAxisAlignment.center,
  ///               children: const [
  ///                 Icon(Icons.info_outline),
  ///                 SizedBox(height: 5),
  ///                 Text('There are no records'),
  ///               ],
  ///             ),
  ///           ),
  ///         ),
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  /// {@endtemplate}
  final Widget? noRowsWidget;

  /// {@template trina_grid_property_rowColorCallback}
  /// [rowColorCallback] can change the row background color dynamically according to the state.
  ///
  /// Implement a callback that returns a [Color] by referring to the value passed as a callback argument.
  /// An exception should be handled when a column is deleted.
  /// ```dart
  /// rowColorCallback = (TrinaRowColorContext rowColorContext) {
  ///   return rowColorContext.row.cells['column2']?.value == 'green'
  ///       ? const Color(0xFFE2F6DF)
  ///       : Colors.white;
  /// }
  /// ```
  /// {@endtemplate}
  final TrinaRowColorCallback? rowColorCallback;

  /// {@template trina_grid_property_cellColorCallback}
  /// [cellColorCallback] can change the cell background color dynamically according to the state.
  ///
  /// Implement a callback that returns a [Color] by referring to the value passed as a callback argument.
  /// An exception should be handled when a column is deleted.
  /// ```dart
  /// cellColorCallback = (TrinaCellColorContext cellColorContext) {
  ///   return cellColorContext.cell.value == 'highlight'
  ///       ? const Color(0xFFE2F6DF)
  ///       : Colors.white;
  /// }
  /// ```
  /// {@endtemplate}
  final TrinaCellColorCallback? cellColorCallback;

  final TrinaSelectDateCallBack? selectDateCallback;

  /// {@template trina_grid_property_columnMenuDelegate}
  /// Column menu can be customized.
  ///
  /// See the demo example link below.
  /// https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/column_menu_screen.dart
  /// {@endtemplate}
  final TrinaColumnMenuDelegate? columnMenuDelegate;

  /// {@template trina_grid_property_configuration}
  /// In [configuration], you can change the style and settings or text used in [TrinaGrid].
  /// {@endtemplate}
  final TrinaGridConfiguration configuration;

  final TrinaChangeNotifierFilterResolver? notifierFilterResolver;

  /// Execution mode of [TrinaGrid].
  ///
  /// [TrinaGridMode.normal]
  /// {@macro trina_grid_mode_normal}
  ///
  /// [TrinaGridMode.readOnly]
  /// {@macro trina_grid_mode_readOnly}
  ///
  /// [TrinaGridMode.select], [TrinaGridMode.selectWithOneTap]
  /// {@macro trina_grid_mode_select}
  ///
  /// [TrinaGridMode.multiSelect]
  /// {@macro trina_grid_mode_multiSelect}
  ///
  /// [TrinaGridMode.popup]
  /// {@macro trina_grid_mode_popup}
  final TrinaGridMode mode;

  /// Callback triggered when cell validation fails
  final TrinaOnValidationFailedCallback? onValidationFailed;

  /// Callback triggered when a lazy pagination fetch operation completes
  final TrinaOnLazyFetchCompletedEventCallback? onLazyFetchCompleted;

  /// [setDefaultLocale] sets locale when [Intl] package is used in [TrinaGrid].
  ///
  /// {@template intl_default_locale}
  /// ```dart
  /// TrinaGrid.setDefaultLocale('es_ES');
  /// TrinaGrid.initializeDateFormat();
  ///
  /// // or if you already use Intl in your app.
  ///
  /// Intl.defaultLocale = 'es_ES';
  /// initializeDateFormatting();
  /// ```
  /// {@endtemplate}
  static void setDefaultLocale(String locale) {
    Intl.defaultLocale = locale;
  }

  /// [initializeDateFormat] should be called
  /// when you need to set date format when changing locale.
  ///
  /// {@macro intl_default_locale}
  static void initializeDateFormat() {
    initializeDateFormatting();
  }

  @override
  TrinaGridState createState() => TrinaGridState();
}

class TrinaGridState extends TrinaStateWithChange<TrinaGrid> {
  bool _showColumnTitle = false;

  bool _showColumnFilter = false;

  bool _showColumnFooter = false;

  bool _showColumnGroups = false;

  bool _showFrozenColumn = false;

  bool _showLoading = false;

  bool _hasLeftFrozenColumns = false;

  bool _hasRightFrozenColumns = false;

  double _bodyLeftOffset = 0.0;

  double _bodyRightOffset = 0.0;

  double _rightFrozenLeftOffset = 0.0;

  Widget? _header;

  Widget? _footer;

  final FocusNode _gridFocusNode = FocusNode();

  final LinkedScrollControllerGroup _verticalScroll =
      LinkedScrollControllerGroup();

  final LinkedScrollControllerGroup _horizontalScroll =
      LinkedScrollControllerGroup();

  final List<Function()> _disposeList = [];

  late final TrinaGridStateManager _stateManager;

  late final TrinaGridKeyManager _keyManager;

  late final TrinaGridEventManager _eventManager;

  @override
  TrinaGridStateManager get stateManager => _stateManager;

  @override
  void initState() {
    _initStateManager();

    _initKeyManager();

    _initEventManager();

    _initOnLoadedEvent();

    _initSelectMode();

    _initHeaderFooter();

    _disposeList.add(() {
      _gridFocusNode.dispose();
    });

    super.initState();
  }

  @override
  void dispose() {
    for (var dispose in _disposeList) {
      dispose();
    }

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TrinaGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool configChanged = widget.configuration != oldWidget.configuration;
    final bool modeChanged = widget.mode != oldWidget.mode;

    if (configChanged || modeChanged) {
      stateManager
        ..setConfiguration(widget.configuration)
        ..setGridMode(widget.mode);

      // Recreate footer when configuration changes
      if (configChanged && stateManager.showFooter) {
        setState(() {
          _footer = stateManager.createFooter!(stateManager);
        });
      }
    }
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _showColumnTitle = update<bool>(
      _showColumnTitle,
      stateManager.showColumnTitle,
    );

    _showColumnFilter = update<bool>(
      _showColumnFilter,
      stateManager.showColumnFilter,
    );

    _showColumnFooter = update<bool>(
      _showColumnFooter,
      stateManager.showColumnFooter,
    );

    _showColumnGroups = update<bool>(
      _showColumnGroups,
      stateManager.showColumnGroups,
    );

    _showFrozenColumn = update<bool>(
      _showFrozenColumn,
      stateManager.showFrozenColumn,
    );

    _showLoading = update<bool>(_showLoading, stateManager.showLoading);

    _hasLeftFrozenColumns = update<bool>(
      _hasLeftFrozenColumns,
      stateManager.hasLeftFrozenColumns,
    );

    _hasRightFrozenColumns = update<bool>(
      _hasRightFrozenColumns,
      stateManager.hasRightFrozenColumns,
    );

    _bodyLeftOffset = update<double>(
      _bodyLeftOffset,
      stateManager.bodyLeftOffset,
    );

    _bodyRightOffset = update<double>(
      _bodyRightOffset,
      stateManager.bodyRightOffset,
    );

    _rightFrozenLeftOffset = update<double>(
      _rightFrozenLeftOffset,
      stateManager.rightFrozenLeftOffset,
    );
  }

  void _initStateManager() {
    _stateManager = TrinaGridStateManager(
      columns: widget.columns,
      rows: widget.rows,
      gridFocusNode: _gridFocusNode,
      scroll: TrinaGridScrollController(
        vertical: _verticalScroll,
        horizontal: _horizontalScroll,
      ),
      rowsCacheExtent: widget.rowsCacheExtent,
      rowWrapper: widget.rowWrapper,
      editCellRenderer: widget.editCellRenderer,
      columnGroups: widget.columnGroups,
      onChanged: widget.onChanged,
      onSelected: widget.onSelected,
      onSorted: widget.onSorted,
      onRowChecked: widget.onRowChecked,
      onRowDoubleTap: widget.onRowDoubleTap,
      onRowSecondaryTap: widget.onRowSecondaryTap,
      onRowEnter: widget.onRowEnter,
      onRowExit: widget.onRowExit,
      onRowsMoved: widget.onRowsMoved,
      onActiveCellChanged: widget.onActiveCellChanged,
      onColumnsMoved: widget.onColumnsMoved,
      rowColorCallback: widget.rowColorCallback,
      cellColorCallback: widget.cellColorCallback,
      selectDateCallback: widget.selectDateCallback,
      createHeader: widget.createHeader,
      createFooter: widget.createFooter,
      onValidationFailed: widget.onValidationFailed,
      onLazyFetchCompleted: widget.onLazyFetchCompleted,
      columnMenuDelegate: widget.columnMenuDelegate,
      notifierFilterResolver: widget.notifierFilterResolver,
      configuration: widget.configuration,
      mode: widget.mode,
    );

    // Dispose
    _disposeList.add(() {
      _stateManager.dispose();
    });
  }

  void _initKeyManager() {
    _keyManager = TrinaGridKeyManager(stateManager: _stateManager);

    _keyManager.init();

    _stateManager.setKeyManager(_keyManager);

    // Dispose
    _disposeList.add(() {
      _keyManager.dispose();
    });
  }

  void _initEventManager() {
    _eventManager = TrinaGridEventManager(stateManager: _stateManager);

    _eventManager.init();

    _stateManager.setEventManager(_eventManager);

    // Dispose
    _disposeList.add(() {
      _eventManager.dispose();
    });
  }

  void _initOnLoadedEvent() {
    if (widget.onLoaded == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onLoaded!(TrinaGridOnLoadedEvent(stateManager: _stateManager));
    });
  }

  void _initSelectMode() {
    if (!widget.mode.isSelectMode) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stateManager.configuration.enableAutoSelectFirstRow &&
          _stateManager.currentCell == null) {
        _stateManager.setCurrentCell(_stateManager.firstCell, 0);
      }

      _stateManager.gridFocusNode.requestFocus();
    });
  }

  void _initHeaderFooter() {
    if (_stateManager.showHeader) {
      _header = _stateManager.createHeader!(_stateManager);
    }

    if (_stateManager.showFooter) {
      _footer = _stateManager.createFooter!(_stateManager);
    }

    if (_header is TrinaPagination || _footer is TrinaPagination) {
      _stateManager.setPage(1, notify: false);
    }
  }

  KeyEventResult _handleGridFocusOnKey(FocusNode focusNode, KeyEvent event) {
    // Get the current primary focus
    final FocusNode? primaryFocus = FocusManager.instance.primaryFocus;

    // If the primary focus is not the grid's focus node, don't handle the event
    // This allows TextFields and other input widgets (for example, in the header or footer)
    // to receive keyboard events
    if (primaryFocus != null && primaryFocus != _stateManager.gridFocusNode) {
      return KeyEventResult.ignored;
    }

    final trinaEvent = TrinaKeyManagerEvent(focusNode: focusNode, event: event);

    if (_isRegisteredShortcut(event)) {
      _keyManager.subject.add(trinaEvent);
      return KeyEventResult.handled;
    }

    // check if it's a character for editing
    if (_isCharInput(trinaEvent)) {
      _keyManager.subject.add(trinaEvent);
      return KeyEventResult.handled;
    }

    // 4. If it's not a shortcut and not a character for editing, ignore it.
    return KeyEventResult.ignored;
  }

  bool _isRegisteredShortcut(KeyEvent keyEvent) {
    return stateManager.configuration.shortcut.actions.entries.any(
      (element) => element.key.accepts(keyEvent, HardwareKeyboard.instance),
    );
  }

  bool _isCharInput(TrinaKeyManagerEvent trinaEvent) {
    final hasAllowedModifier =
        !trinaEvent.isModifierPressed || trinaEvent.isShiftPressed;
    return trinaEvent.isCharacter && hasAllowedModifier;
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      onFocusChange: _stateManager.setKeepFocus,
      onKeyEvent: _handleGridFocusOnKey,
      child: _GridContainer(
        stateManager: _stateManager,
        child: LayoutBuilder(
          builder: (c, size) {
            _stateManager.setLayout(size);

            final style = _stateManager.style;

            final bool showLeftFrozen = _stateManager.showFrozenColumn &&
                _stateManager.hasLeftFrozenColumns;

            final bool showRightFrozen = _stateManager.showFrozenColumn &&
                _stateManager.hasRightFrozenColumns;

            final bool showColumnRowDivider =
                _stateManager.showColumnTitle || _stateManager.showColumnFilter;

            final bool showColumnFooter = _stateManager.showColumnFooter;

            return CustomMultiChildLayout(
              key: _stateManager.gridKey,
              delegate: TrinaGridLayoutDelegate(
                _stateManager,
                Directionality.of(context),
              ),
              children: [
                /// Frozen rows before title
                LayoutId(
                  id: _StackName.frozenBeforeTitleRows,
                  child: TrinaFrozenRowsBeforeHeader(
                    stateManager: _stateManager,
                    frozenType: TrinaRowFrozen.beforeTitle,
                  ),
                ),
                
                /// Divider after frozen rows before title
                if (_stateManager.refRows.originalList
                    .any((row) => row.frozen == TrinaRowFrozen.beforeTitle))
                  LayoutId(
                    id: _StackName.frozenBeforeTitleDivider,
                    child: TrinaShadowLine(
                      axis: Axis.horizontal,
                      color: style.gridBorderColor,
                      shadow: style.enableGridBorderShadow,
                    ),
                  ),
                
                /// Body rows
                LayoutId(
                  id: _StackName.bodyRows,
                  child: TrinaBodyRows(_stateManager),
                ),
                
                /// Body column titles only
                LayoutId(
                  id: _StackName.bodyColumnTitles,
                  child: TrinaBodyColumns(
                    _stateManager,
                    renderMode: TrinaColumnRenderMode.titleOnly,
                  ),
                ),
                
                /// Frozen rows before filter (positioned between titles and filters)
                LayoutId(
                  id: _StackName.frozenBeforeFilterRows,
                  child: TrinaFrozenRowsBeforeHeader(
                    stateManager: _stateManager,
                    frozenType: TrinaRowFrozen.beforeFilter,
                  ),
                ),
                
                /// Divider after frozen rows before filter
                if (_stateManager.refRows.originalList
                    .any((row) => row.frozen == TrinaRowFrozen.beforeFilter))
                  LayoutId(
                    id: _StackName.frozenBeforeFilterDivider,
                    child: TrinaShadowLine(
                      axis: Axis.horizontal,
                      color: style.gridBorderColor,
                      shadow: style.enableGridBorderShadow,
                    ),
                  ),
                
                /// Body column filters only
                LayoutId(
                  id: _StackName.bodyColumnFilters,
                  child: TrinaBodyColumns(
                    _stateManager,
                    renderMode: TrinaColumnRenderMode.filterOnly,
                  ),
                ),

                /// Body columns footer.
                if (showColumnFooter)
                  LayoutId(
                    id: _StackName.bodyColumnFooters,
                    child: TrinaBodyColumnsFooter(stateManager),
                  ),

                /// Left columns and rows.
                if (showLeftFrozen) ...[
                  LayoutId(
                    id: _StackName.leftFrozenColumns,
                    child: TrinaLeftFrozenColumns(_stateManager),
                  ),
                  LayoutId(
                    id: _StackName.leftFrozenRows,
                    child: TrinaLeftFrozenRows(_stateManager),
                  ),
                  LayoutId(
                    id: _StackName.leftFrozenDivider,
                    child: TrinaShadowLine(
                      axis: Axis.vertical,
                      color: style.gridBorderColor,
                      shadow: style.enableGridBorderShadow,
                    ),
                  ),
                  if (showColumnFooter)
                    LayoutId(
                      id: _StackName.leftFrozenColumnFooters,
                      child: TrinaLeftFrozenColumnsFooter(stateManager),
                    ),
                ],

                /// Right columns and rows.
                if (showRightFrozen) ...[
                  LayoutId(
                    id: _StackName.rightFrozenColumns,
                    child: TrinaRightFrozenColumns(_stateManager),
                  ),
                  LayoutId(
                    id: _StackName.rightFrozenRows,
                    child: TrinaRightFrozenRows(_stateManager),
                  ),
                  LayoutId(
                    id: _StackName.rightFrozenDivider,
                    child: TrinaShadowLine(
                      axis: Axis.vertical,
                      color: style.gridBorderColor,
                      shadow: style.enableGridBorderShadow,
                      reverse: true,
                    ),
                  ),
                  if (showColumnFooter)
                    LayoutId(
                      id: _StackName.rightFrozenColumnFooters,
                      child: TrinaRightFrozenColumnsFooter(stateManager),
                    ),
                ],

                /// Column and row divider.
                if (showColumnRowDivider)
                  LayoutId(
                    id: _StackName.columnRowDivider,
                    child: TrinaShadowLine(
                      axis: Axis.horizontal,
                      color: style.gridBorderColor,
                      shadow: style.enableGridBorderShadow,
                    ),
                  ),

                /// Header and divider.
                if (_stateManager.showHeader) ...[
                  LayoutId(
                    id: _StackName.headerDivider,
                    child: TrinaShadowLine(
                      axis: Axis.horizontal,
                      color: style.gridBorderColor,
                      shadow: style.enableGridBorderShadow,
                    ),
                  ),
                  LayoutId(id: _StackName.header, child: _header!),
                ],

                /// Column footer divider.
                if (showColumnFooter)
                  LayoutId(
                    id: _StackName.columnFooterDivider,
                    child: TrinaShadowLine(
                      axis: Axis.horizontal,
                      color: style.gridBorderColor,
                      shadow: style.enableGridBorderShadow,
                    ),
                  ),

                /// Footer and divider.
                if (_stateManager.showFooter) ...[
                  LayoutId(
                    id: _StackName.footerDivider,
                    child: TrinaShadowLine(
                      axis: Axis.horizontal,
                      color: style.gridBorderColor,
                      shadow: style.enableGridBorderShadow,
                      reverse: true,
                    ),
                  ),
                  LayoutId(id: _StackName.footer, child: _footer!),
                ],

                /// Loading screen.
                if (_stateManager.showLoading)
                  LayoutId(
                    id: _StackName.loading,
                    child: _stateManager.customLoadingWidget ??
                        TrinaLoading(
                          level: _stateManager.loadingLevel,
                          backgroundColor: style.gridBackgroundColor,
                          indicatorColor: style.activatedBorderColor,
                          text: _stateManager.localeText.loadingText,
                          textStyle: style.cellTextStyle,
                        ),
                  ),

                /// NoRows
                if (widget.noRowsWidget != null)
                  LayoutId(
                    id: _StackName.noRows,
                    child: TrinaNoRowsWidget(
                      stateManager: _stateManager,
                      child: widget.noRowsWidget!,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TrinaGridLayoutDelegate extends MultiChildLayoutDelegate {
  final TrinaGridStateManager _stateManager;

  final TextDirection _textDirection;

  TrinaGridLayoutDelegate(this._stateManager, this._textDirection)
      : super(relayout: _stateManager.resizingChangeNotifier) {
    // set textDirection before the first frame is laid-out
    _stateManager.setTextDirection(_textDirection);
  }

  @override
  void performLayout(Size size) {
    bool isLTR = _stateManager.isLTR;
    double bodyRowsTopOffset = 0;
    double bodyRowsBottomOffset = 0;
    double columnsTopOffset = 0;
    double bodyLeftOffset = 0;
    double bodyRightOffset = 0;

    final gridBorderWidth = _stateManager.configuration.style.gridBorderWidth;

    // Layout frozen rows before title (these appear above everything including column titles)
    if (hasChild(_StackName.frozenBeforeTitleRows)) {
      var s = layoutChild(
        _StackName.frozenBeforeTitleRows,
        BoxConstraints.loose(Size(size.width, size.height)),
      );

      positionChild(_StackName.frozenBeforeTitleRows, Offset(0, bodyRowsTopOffset));
      
      bodyRowsTopOffset += s.height;
      columnsTopOffset += s.height;
    }
    
    if (hasChild(_StackName.frozenBeforeTitleDivider)) {
      layoutChild(
        _StackName.frozenBeforeTitleDivider,
        BoxConstraints.tight(Size(size.width, gridBorderWidth)),
      );
      
      positionChild(_StackName.frozenBeforeTitleDivider, Offset(0, bodyRowsTopOffset));
      bodyRowsTopOffset += gridBorderWidth;
      columnsTopOffset += gridBorderWidth;
    }
    
    // first layout header and footer and see what remains for the scrolling part
    if (hasChild(_StackName.header)) {
      // maximum 40% of the height
      var s = layoutChild(
        _StackName.header,
        BoxConstraints.loose(Size(size.width, _safe(size.height / 100 * 40))),
      );

      _stateManager.headerHeight = s.height;

      bodyRowsTopOffset += s.height;

      columnsTopOffset += s.height;
    }

    if (hasChild(_StackName.headerDivider)) {
      layoutChild(
        _StackName.headerDivider,
        BoxConstraints.tight(Size(size.width, gridBorderWidth)),
      );

      positionChild(_StackName.headerDivider, Offset(0, columnsTopOffset));
    }

    if (hasChild(_StackName.footer)) {
      // maximum 40% of the height
      var s = layoutChild(
        _StackName.footer,
        BoxConstraints.loose(Size(size.width, _safe(size.height / 100 * 40))),
      );

      _stateManager.footerHeight = s.height;

      bodyRowsBottomOffset += s.height;

      positionChild(
        _StackName.footer,
        Offset(0, size.height - bodyRowsBottomOffset),
      );
    }

    if (hasChild(_StackName.footerDivider)) {
      layoutChild(
        _StackName.footerDivider,
        BoxConstraints.tight(Size(size.width, gridBorderWidth)),
      );

      positionChild(
        _StackName.footerDivider,
        Offset(0, size.height - bodyRowsBottomOffset),
      );
    }

    // now layout columns of frozen sides and see what remains for the body width
    if (hasChild(_StackName.leftFrozenColumns)) {
      var s = layoutChild(
        _StackName.leftFrozenColumns,
        BoxConstraints.loose(size),
      );

      final double posX = isLTR ? 0 : size.width - s.width;

      positionChild(
        _StackName.leftFrozenColumns,
        Offset(posX, columnsTopOffset),
      );

      if (isLTR) {
        bodyLeftOffset = s.width;
      } else {
        bodyRightOffset = s.width;
      }
    }

    if (hasChild(_StackName.leftFrozenDivider)) {
      var s = layoutChild(
        _StackName.leftFrozenDivider,
        BoxConstraints.tight(
          Size(
            gridBorderWidth,
            _safe(size.height - columnsTopOffset - bodyRowsBottomOffset),
          ),
        ),
      );

      final double posX = isLTR
          ? bodyLeftOffset
          : size.width - bodyRightOffset - gridBorderWidth;

      positionChild(
        _StackName.leftFrozenDivider,
        Offset(posX, columnsTopOffset),
      );

      if (isLTR) {
        bodyLeftOffset += s.width;
      } else {
        bodyRightOffset += s.width;
      }
    }

    if (hasChild(_StackName.rightFrozenColumns)) {
      var s = layoutChild(
        _StackName.rightFrozenColumns,
        BoxConstraints.loose(size),
      );

      final double posX = isLTR ? size.width - s.width + gridBorderWidth : 0;

      positionChild(
        _StackName.rightFrozenColumns,
        Offset(posX, columnsTopOffset),
      );

      if (isLTR) {
        bodyRightOffset = s.width;
      } else {
        bodyLeftOffset = s.width;
      }
    }

    if (hasChild(_StackName.rightFrozenDivider)) {
      var s = layoutChild(
        _StackName.rightFrozenDivider,
        BoxConstraints.tight(
          Size(
            gridBorderWidth,
            _safe(size.height - columnsTopOffset - bodyRowsBottomOffset),
          ),
        ),
      );

      final double posX = isLTR
          ? size.width - bodyRightOffset - gridBorderWidth
          : bodyLeftOffset;

      positionChild(
        _StackName.rightFrozenDivider,
        Offset(posX, columnsTopOffset),
      );

      if (isLTR) {
        bodyRightOffset += s.width;
      } else {
        bodyLeftOffset += s.width;
      }
    }

    if (hasChild(_StackName.bodyColumnTitles)) {
      var s = layoutChild(
        _StackName.bodyColumnTitles,
        BoxConstraints.loose(
          Size(
            _safe(size.width - bodyLeftOffset - bodyRightOffset),
            size.height,
          ),
        ),
      );

      final double posX =
          isLTR ? bodyLeftOffset : size.width - s.width - bodyRightOffset;

      positionChild(_StackName.bodyColumnTitles, Offset(posX, columnsTopOffset));

      bodyRowsTopOffset += s.height;
    }
    
    // Layout frozen rows before filter (these appear between column titles and filters)
    if (hasChild(_StackName.frozenBeforeFilterRows)) {
      var s = layoutChild(
        _StackName.frozenBeforeFilterRows,
        BoxConstraints.loose(Size(size.width, size.height)),
      );

      positionChild(_StackName.frozenBeforeFilterRows, Offset(0, bodyRowsTopOffset));
      
      bodyRowsTopOffset += s.height;
    }
    
    if (hasChild(_StackName.frozenBeforeFilterDivider)) {
      layoutChild(
        _StackName.frozenBeforeFilterDivider,
        BoxConstraints.tight(Size(size.width, gridBorderWidth)),
      );
      
      positionChild(_StackName.frozenBeforeFilterDivider, Offset(0, bodyRowsTopOffset));
      bodyRowsTopOffset += gridBorderWidth;
    }
    
    if (hasChild(_StackName.bodyColumnFilters)) {
      var s = layoutChild(
        _StackName.bodyColumnFilters,
        BoxConstraints.loose(
          Size(
            _safe(size.width - bodyLeftOffset - bodyRightOffset),
            size.height,
          ),
        ),
      );

      final double posX =
          isLTR ? bodyLeftOffset : size.width - s.width - bodyRightOffset;

      positionChild(_StackName.bodyColumnFilters, Offset(posX, bodyRowsTopOffset));

      bodyRowsTopOffset += s.height;
    }

    if (hasChild(_StackName.bodyColumnFooters)) {
      var s = layoutChild(
        _StackName.bodyColumnFooters,
        BoxConstraints.loose(
          Size(
            _safe(size.width - bodyLeftOffset - bodyRightOffset),
            size.height,
          ),
        ),
      );

      _stateManager.columnFooterHeight = s.height;

      final double posX =
          isLTR ? bodyLeftOffset : size.width - s.width - bodyRightOffset;

      positionChild(
        _StackName.bodyColumnFooters,
        Offset(posX, size.height - bodyRowsBottomOffset - s.height),
      );

      bodyRowsBottomOffset += s.height;
    }

    if (hasChild(_StackName.columnFooterDivider)) {
      var s = layoutChild(
        _StackName.columnFooterDivider,
        BoxConstraints.tight(Size(size.width, gridBorderWidth)),
      );

      positionChild(
        _StackName.columnFooterDivider,
        Offset(0, size.height - bodyRowsBottomOffset - s.height),
      );
    }

    // layout rows
    if (hasChild(_StackName.columnRowDivider)) {
      var s = layoutChild(
        _StackName.columnRowDivider,
        BoxConstraints.tight(Size(size.width, gridBorderWidth)),
      );

      positionChild(_StackName.columnRowDivider, Offset(0, bodyRowsTopOffset));

      bodyRowsTopOffset += s.height;
    } else {
      bodyRowsTopOffset += gridBorderWidth;
    }

    if (hasChild(_StackName.leftFrozenRows)) {
      final double offset = isLTR ? bodyLeftOffset : bodyRightOffset;
      final double posX =
          isLTR ? 0 : size.width - bodyRightOffset + gridBorderWidth;

      layoutChild(
        _StackName.leftFrozenRows,
        BoxConstraints.loose(
          Size(
            offset,
            _safe(size.height - bodyRowsTopOffset - bodyRowsBottomOffset),
          ),
        ),
      );

      positionChild(_StackName.leftFrozenRows, Offset(posX, bodyRowsTopOffset));
    }

    if (hasChild(_StackName.leftFrozenColumnFooters)) {
      final double offset = isLTR ? bodyLeftOffset : bodyRightOffset;
      final double posX =
          isLTR ? 0 : size.width - bodyRightOffset + gridBorderWidth;

      layoutChild(
        _StackName.leftFrozenColumnFooters,
        BoxConstraints.loose(
          Size(offset, _safe(size.height - bodyRowsBottomOffset)),
        ),
      );

      positionChild(
        _StackName.leftFrozenColumnFooters,
        Offset(posX, size.height - bodyRowsBottomOffset),
      );
    }

    if (hasChild(_StackName.rightFrozenRows)) {
      final double offset = isLTR ? bodyRightOffset : bodyLeftOffset;
      final double posX =
          isLTR ? size.width - bodyRightOffset + gridBorderWidth : 0;

      layoutChild(
        _StackName.rightFrozenRows,
        BoxConstraints.loose(
          Size(
            offset,
            _safe(size.height - bodyRowsTopOffset - bodyRowsBottomOffset),
          ),
        ),
      );

      positionChild(
        _StackName.rightFrozenRows,
        Offset(posX, bodyRowsTopOffset),
      );
    }

    if (hasChild(_StackName.rightFrozenColumnFooters)) {
      final double offset = isLTR ? bodyRightOffset : bodyLeftOffset;
      var s = layoutChild(
        _StackName.rightFrozenColumnFooters,
        BoxConstraints.loose(Size(offset, size.height)),
      );

      final double posX = isLTR ? size.width - s.width + gridBorderWidth : 0;

      positionChild(
        _StackName.rightFrozenColumnFooters,
        Offset(posX, size.height - bodyRowsBottomOffset),
      );
    }

    if (hasChild(_StackName.bodyRows)) {
      layoutChild(
        _StackName.bodyRows,
        BoxConstraints.tight(
          Size(
            _safe(size.width - bodyLeftOffset - bodyRightOffset),
            _safe(size.height - bodyRowsTopOffset - bodyRowsBottomOffset),
          ),
        ),
      );

      positionChild(
        _StackName.bodyRows,
        Offset(bodyLeftOffset, bodyRowsTopOffset),
      );
    }

    if (hasChild(_StackName.loading)) {
      Size loadingSize;

      switch (_stateManager.loadingLevel) {
        case TrinaGridLoadingLevel.grid:
          loadingSize = size;
          break;
        case TrinaGridLoadingLevel.rows:
          loadingSize = Size(size.width, 3);
          positionChild(_StackName.loading, Offset(0, bodyRowsTopOffset));
          break;
        case TrinaGridLoadingLevel.rowsBottomCircular:
          loadingSize = const Size(30, 30);
          positionChild(
            _StackName.loading,
            Offset(
              (size.width / 2) + 15,
              size.height - bodyRowsBottomOffset - 45,
            ),
          );
          break;
      }

      layoutChild(_StackName.loading, BoxConstraints.tight(loadingSize));
    }

    if (hasChild(_StackName.noRows)) {
      layoutChild(
        _StackName.noRows,
        BoxConstraints.loose(
          Size(
            size.width,
            _safe(size.height - bodyRowsTopOffset - bodyRowsBottomOffset),
          ),
        ),
      );

      positionChild(_StackName.noRows, Offset(0, bodyRowsTopOffset));
    }
  }

  @override
  bool shouldRelayout(covariant TrinaGridLayoutDelegate oldDelegate) {
    return true;
  }

  double _safe(double value) => max(0, value);
}

class _GridContainer extends StatelessWidget {
  final TrinaGridStateManager stateManager;

  final Widget child;

  const _GridContainer({required this.stateManager, required this.child});

  @override
  Widget build(BuildContext context) {
    final style = stateManager.style;

    final borderRadius = style.gridBorderRadius.resolve(TextDirection.ltr);

    return Focus(
      focusNode: stateManager.gridFocusNode,
      child: ScrollConfiguration(
        behavior: TrinaScrollBehavior(
          isMobile: PlatformHelper.isMobile,
          userDragDevices: stateManager.configuration.scrollbar.dragDevices,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: style.gridBackgroundColor,
            borderRadius: style.gridBorderRadius,
            border: Border.all(
              color: style.gridBorderColor,
              width: style.gridBorderWidth,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(style.gridPadding),
            child: borderRadius == BorderRadius.zero
                ? child
                : ClipRRect(borderRadius: borderRadius, child: child),
          ),
        ),
      ),
    );
  }
}

/// Argument of [TrinaGrid.rowColumnCallback] callback
/// to dynamically change the background color of a row.
class TrinaRowColorContext {
  final TrinaRow row;

  final int rowIdx;

  final TrinaGridStateManager stateManager;

  const TrinaRowColorContext({
    required this.row,
    required this.rowIdx,
    required this.stateManager,
  });
}

/// Argument of [TrinaGrid.cellColorCallback] callback
/// to dynamically change the background color of a cell.
class TrinaCellColorContext {
  final TrinaCell cell;

  final TrinaColumn column;

  final TrinaRow row;

  final int rowIdx;

  final TrinaGridStateManager stateManager;

  const TrinaCellColorContext({
    required this.cell,
    required this.column,
    required this.row,
    required this.rowIdx,
    required this.stateManager,
  });
}

/// Extension class for [ScrollConfiguration.behavior] of [TrinaGrid].
class TrinaScrollBehavior extends MaterialScrollBehavior {
  const TrinaScrollBehavior({
    required this.isMobile,
    Set<PointerDeviceKind>? userDragDevices,
  })  : _dragDevices = userDragDevices ??
            (isMobile ? _mobileDragDevices : _desktopDragDevices),
        super();

  final bool isMobile;

  @override
  Set<PointerDeviceKind> get dragDevices => _dragDevices;

  final Set<PointerDeviceKind> _dragDevices;

  static const Set<PointerDeviceKind> _mobileDragDevices = {
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.unknown,
  };

  static const Set<PointerDeviceKind> _desktopDragDevices = {
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.unknown,
  };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

/// A class for changing the value of a nullable property in a method such as [copyWith].
class TrinaOptional<T> {
  const TrinaOptional(this.value);

  final T? value;
}

enum _StackName {
  header,
  headerDivider,
  frozenBeforeTitleRows,
  frozenBeforeTitleDivider,
  leftFrozenColumns,
  leftFrozenColumnFooters,
  leftFrozenRows,
  leftFrozenDivider,
  bodyColumnTitles,
  frozenBeforeFilterRows,
  frozenBeforeFilterDivider,
  bodyColumnFilters,
  bodyColumnFooters,
  bodyRows,
  rightFrozenColumns,
  rightFrozenColumnFooters,
  rightFrozenRows,
  rightFrozenDivider,
  columnRowDivider,
  columnFooterDivider,
  footer,
  footerDivider,
  loading,
  noRows,
}
