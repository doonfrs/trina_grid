import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trina_grid/trina_grid.dart';

import 'state/cell_state.dart';
import 'state/column_group_state.dart';
import 'state/column_sizing_state.dart';
import 'state/column_state.dart';
import 'state/dragging_row_state.dart';
import 'state/editing_state.dart';
import 'state/filtering_row_state.dart';
import 'state/focus_state.dart';
import 'state/grid_state.dart';
import 'state/keyboard_state.dart';
import 'state/layout_state.dart';
import 'state/pagination_row_state.dart';
import 'state/row_group_state.dart';
import 'state/row_state.dart';
import 'state/scroll_state.dart';
import 'state/selecting_state.dart';
import 'state/visibility_layout_state.dart';
import 'state/hovering_state.dart';

abstract class ITrinaGridState
    implements
        TrinaChangeNotifier,
        ICellState,
        IColumnGroupState,
        IColumnSizingState,
        IColumnState,
        IDraggingRowState,
        IEditingState,
        IFilteringRowState,
        IFocusState,
        IGridState,
        IKeyboardState,
        ILayoutState,
        IPaginationRowState,
        IRowGroupState,
        IRowState,
        IScrollState,
        ISelectingState,
        IVisibilityLayoutState,
        IHoveringState {}

class TrinaGridStateChangeNotifier extends TrinaChangeNotifier
    with
        CellState,
        ColumnGroupState,
        ColumnSizingState,
        ColumnState,
        DraggingRowState,
        EditingState,
        FilteringRowState,
        FocusState,
        GridState,
        KeyboardState,
        LayoutState,
        PaginationRowState,
        RowGroupState,
        RowState,
        ScrollState,
        SelectingState,
        VisibilityLayoutState,
        HoveringState {
  TrinaGridStateChangeNotifier({
    required List<TrinaColumn> columns,
    required List<TrinaRow> rows,
    required this.gridFocusNode,
    required this.scroll,
    List<TrinaColumnGroup>? columnGroups,
    this.rowsCacheExtent,
    this.rowWrapper,
    this.editCellRenderer,
    this.onChanged,
    this.onSelected,
    this.onSorted,
    this.onRowChecked,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.onRowEnter,
    this.onRowExit,
    this.onRowsMoved,
    this.onBeforeActiveCellChange,
    this.onActiveCellChanged,
    this.onColumnsMoved,
    this.rowColorCallback,
    this.cellColorCallback,
    this.selectDateCallback,
    this.createHeader,
    this.createFooter,
    this.onValidationFailed,
    this.onLazyFetchCompleted,
    TrinaColumnMenuDelegate? columnMenuDelegate,
    TrinaChangeNotifierFilterResolver? notifierFilterResolver,
    TrinaGridConfiguration configuration = const TrinaGridConfiguration(),
    TrinaGridMode? mode,
    metadata,
  }) : refColumns = FilteredList(initialList: columns),
       refRows = FilteredList(initialList: rows),
       refColumnGroups = FilteredList<TrinaColumnGroup>(
         initialList: columnGroups,
       ),
       columnMenuDelegate =
           columnMenuDelegate ?? const TrinaColumnMenuDelegateDefault(),
       notifierFilterResolver =
           notifierFilterResolver ?? const TrinaNotifierFilterResolverDefault(),
       gridKey = GlobalKey(),
       _enableChangeTracking = false {
    setConfiguration(configuration);
    setGridMode(mode ?? TrinaGridMode.normal);
    _initialize();
  }

  final double? rowsCacheExtent;

  /// {@macro trina_grid_row_wrapper}
  @override
  final RowWrapper? rowWrapper;

  @override
  final Widget Function(
    Widget defaultEditCellWidget,
    TrinaCell cell,
    TextEditingController controller,
    FocusNode focusNode,
    Function(dynamic value)? handleSelected,
  )?
  editCellRenderer;

  @override
  final FilteredList<TrinaColumn> refColumns;

  @override
  final FilteredList<TrinaColumnGroup> refColumnGroups;

  @override
  final FilteredList<TrinaRow> refRows;

  @override
  final FocusNode gridFocusNode;

  @override
  final TrinaGridScrollController scroll;

  @override
  final TrinaOnChangedEventCallback? onChanged;

  @override
  final TrinaOnSelectedEventCallback? onSelected;

  @override
  final TrinaOnSortedEventCallback? onSorted;

  @override
  final TrinaOnRowCheckedEventCallback? onRowChecked;

  @override
  final TrinaOnRowDoubleTapEventCallback? onRowDoubleTap;

  @override
  final TrinaOnRowSecondaryTapEventCallback? onRowSecondaryTap;

  @override
  final TrinaOnRowEnterEventCallback? onRowEnter;

  @override
  final TrinaOnRowExitEventCallback? onRowExit;

  @override
  final TrinaOnRowsMovedEventCallback? onRowsMoved;

  @override
  final TrinaOnBeforeActiveCellChangeEventCallback? onBeforeActiveCellChange;

  @override
  final TrinaOnActiveCellChangedEventCallback? onActiveCellChanged;

  @override
  final TrinaOnColumnsMovedEventCallback? onColumnsMoved;

  @override
  final TrinaRowColorCallback? rowColorCallback;

  @override
  final TrinaCellColorCallback? cellColorCallback;

  @override
  final CreateHeaderCallBack? createHeader;

  @override
  final CreateFooterCallBack? createFooter;

  @override
  final TrinaSelectDateCallBack? selectDateCallback;

  @override
  final TrinaColumnMenuDelegate columnMenuDelegate;

  final TrinaChangeNotifierFilterResolver notifierFilterResolver;

  @override
  final GlobalKey gridKey;

  /// Callback triggered when cell validation fails
  @override
  final TrinaOnValidationFailedCallback? onValidationFailed;

  /// Callback triggered when lazy fetch is completed
  final TrinaOnLazyFetchCompletedEventCallback? onLazyFetchCompleted;

  /// Flag to enable/disable change tracking
  bool _enableChangeTracking = false;

  /// Get the current state of change tracking
  bool get enableChangeTracking => _enableChangeTracking;

  // Optional metadata to attach additional data to the state manager
  Map<String, dynamic>? metadata = {};

  /// Enable or disable change tracking
  void setChangeTracking(bool enable, {bool notify = true}) {
    if (_enableChangeTracking == enable) return;

    _enableChangeTracking = enable;

    notifyListeners(notify, setChangeTracking.hashCode);
  }

  /// Commit changes for all cells or a specific cell
  void commitChanges({TrinaCell? cell, bool notify = true}) {
    if (cell != null) {
      // Commit changes for a specific cell
      cell.commitChanges();
    } else {
      // Commit changes for all cells
      for (final row in refRows) {
        for (final cell in row.cells.values) {
          cell.commitChanges();
        }
      }
    }

    notifyListeners(notify, commitChanges.hashCode);
  }

  /// Revert changes for all cells or a specific cell
  void revertChanges({TrinaCell? cell, bool notify = true}) {
    if (cell != null) {
      // Revert changes for a specific cell
      cell.revertChanges();
    } else {
      // Revert changes for all cells
      for (final row in refRows) {
        for (final cell in row.cells.values) {
          cell.revertChanges();
        }
      }
    }

    notifyListeners(notify, revertChanges.hashCode);
  }

  void _initialize() {
    TrinaGridStateManager.initializeRows(
      refColumns.originalList,
      refRows.originalList,
    );

    refColumns.setFilter((element) => element.hide == false);

    setShowColumnGroups(columnGroups.isNotEmpty, notify: false);

    setShowColumnFooter(
      refColumns.originalList.any((e) => e.footerRenderer != null),
      notify: false,
    );

    setGroupToColumn();
  }
}

/// It manages the state of the [TrinaGrid] and contains methods used by the grid.
///
/// An instance of [TrinaGridStateManager] can be returned
/// through the [onLoaded] callback of the [TrinaGrid] constructor.
/// ```dart
/// TrinaGridStateManager stateManager;
///
/// TrinaGrid(
///   onLoaded: (TrinaGridOnLoadedEvent event) => stateManager = event.stateManager,
/// )
/// ```
/// {@template initialize_rows_sync_or_async}
/// It is created when [TrinaGrid] is first created,
/// and the state required for the grid is set for `List<TrinaRow> rows`.
/// [TrinaGridStateManager.initializeRows], which operates at this time, works synchronously,
/// and if there are many rows, the UI may freeze when starting the grid.
///
/// To prevent UI from freezing when passing many rows to [TrinaGrid],
/// you can set rows asynchronously as follows.
/// After passing an empty list when creating [TrinaGrid],
/// add rows initialized with [initializeRowsAsync] as shown below.
///
/// ```dart
/// TrinaGridStateManager.initializeRowsAsync(columns, fetchedRows).then((initializedRows) {
///   stateManager.refRows.addAll(initializedRows);
///   stateManager.notifyListeners();
/// });
/// ```
/// {@endtemplate}
class TrinaGridStateManager extends TrinaGridStateChangeNotifier {
  TrinaGridStateManager({
    required super.columns,
    required super.rows,
    required super.gridFocusNode,
    required super.scroll,
    super.rowsCacheExtent,
    super.rowWrapper,
    super.editCellRenderer,
    super.columnGroups,
    super.onChanged,
    super.onSelected,
    super.onSorted,
    super.onRowChecked,
    super.onRowDoubleTap,
    super.onRowSecondaryTap,
    super.onRowEnter,
    super.onRowExit,
    super.onRowsMoved,
    super.onBeforeActiveCellChange,
    super.onActiveCellChanged,
    super.onColumnsMoved,
    super.rowColorCallback,
    super.cellColorCallback,
    super.selectDateCallback,
    super.createHeader,
    super.createFooter,
    super.onValidationFailed,
    super.onLazyFetchCompleted,
    super.columnMenuDelegate,
    super.notifierFilterResolver,
    super.configuration,
    super.mode,
  });

  TrinaChangeNotifierFilter<T> resolveNotifierFilter<T>() {
    return TrinaChangeNotifierFilter<T>(
      notifierFilterResolver.resolve(this, T),
      TrinaChangeNotifierFilter.debug
          ? TrinaChangeNotifierFilterResolver.notifierNames(this)
          : null,
    );
  }

  void scrollToColumn(TrinaColumn column) {
    final index = refColumns.indexOf(column);

    if (index == -1) return;

    double jumpTo = column.startPosition;
    if (jumpTo > scroll.maxScrollHorizontal) {
      jumpTo = scroll.maxScrollHorizontal;
    }

    scroll.horizontal?.jumpTo(jumpTo);
  }

  /// Returns a list of columns that are currently visible in the viewport
  List<TrinaColumn> getViewPortVisibleColumns() {
    if (refColumns.isEmpty) return [];

    return refColumns
        .where((column) => isColumnVisibleInViewport(column))
        .toList();
  }

  /// Checks if a specific column is currently visible in the viewport
  bool isColumnVisibleInViewport(TrinaColumn column) {
    if (column.hide) return false;

    final RenderBox? gridRenderBox =
        gridKey.currentContext?.findRenderObject() as RenderBox?;

    if (gridRenderBox == null) {
      return false;
    }

    final scrollPosition = scroll.horizontal?.offset ?? 0;
    final viewportWidth = gridRenderBox.size.width;
    final viewportEnd = scrollPosition + viewportWidth;

    final columnStart = column.startPosition;
    final columnEnd = columnStart + column.width;

    // Column is visible if any part of it is in the viewport
    return (columnStart <= viewportEnd && columnEnd > scrollPosition);
  }

  /// It handles the necessary settings when [rows] are first set or added to the [TrinaGrid].
  ///
  /// {@template initialize_rows_params}
  /// [forceApplySortIdx] determines whether to force TrinaRow.sortIdx to be set.
  ///
  /// [increase] and [start] are valid only when [forceApplySortIdx] is true.
  ///
  /// [increase] determines whether to increment or decrement when initializing [sortIdx].
  /// For example, if a row is added before an existing row,
  /// the [sortIdx] value should be set to a negative number than the row being added.
  ///
  /// [start] sets the starting value when initializing [sortIdx].
  /// For example, if sortIdx is set from 0 to 9 in the previous 10 rows,
  /// [start] is set to 10, which sets the sortIdx of the row added at the end.
  /// {@endtemplate}
  ///
  /// {@macro initialize_rows_sync_or_async}
  static List<TrinaRow> initializeRows(
    List<TrinaColumn> refColumns,
    List<TrinaRow> refRows, {
    bool forceApplySortIdx = true,
    bool increase = true,
    int start = 0,
  }) {
    if (refColumns.isEmpty || refRows.isEmpty) {
      return refRows;
    }

    _ApplyList applyList = _ApplyList([
      _ApplyCellForSetColumnRow(refColumns),
      _ApplyRowForSortIdx(
        forceApply: forceApplySortIdx,
        increase: increase,
        start: start,
        firstRow: refRows.first,
      ),
      _ApplyRowGroup(refColumns),
    ]);

    if (!applyList.apply) {
      return refRows;
    }

    var rowLength = refRows.length;

    for (var rowIdx = 0; rowIdx < rowLength; rowIdx += 1) {
      applyList.execute(refRows[rowIdx]);
    }

    return refRows;
  }

  /// An asynchronous version of [TrinaGridStateManager.initializeRows].
  ///
  /// [TrinaGridStateManager.initializeRowsAsync] repeats [Timer] every [duration],
  /// Process the setting of [refRows] by the size of [chunkSize].
  /// [Isolate] is a good way to handle CPU heavy work, but
  /// The condition that List&lt;TrinaRow&gt; cannot be passed to Isolate
  /// solves the problem of UI freezing by dividing the work with Timer.
  ///
  /// {@macro initialize_rows_params}
  ///
  /// [chunkSize] determines the number of lists processed at one time when setting rows.
  ///
  /// [duration] determines the processing interval when setting rows.
  ///
  /// If pagination is set, [TrinaGridStateManager.setPage] must be called
  /// after Future is completed before Rows appear on the screen.
  ///
  /// ```dart
  /// TrinaGridStateManager.initializeRowsAsync(columns, fetchedRows).then((initializedRows) {
  ///   stateManager.refRows.addAll(initializedRows);
  ///   stateManager.setPage(1, notify: false);
  ///   stateManager.notifyListeners();
  /// });
  /// ```
  ///
  /// {@macro initialize_rows_sync_or_async}
  static Future<List<TrinaRow>> initializeRowsAsync(
    List<TrinaColumn> refColumns,
    List<TrinaRow> refRows, {
    bool forceApplySortIdx = true,
    bool increase = true,
    int start = 0,
    int chunkSize = 100,
    Duration duration = const Duration(milliseconds: 1),
  }) {
    if (refColumns.isEmpty || refRows.isEmpty) {
      return Future.value(refRows);
    }

    assert(chunkSize > 0);

    final Completer<List<TrinaRow>> completer = Completer();

    SplayTreeMap<int, List<TrinaRow>> splayMapRows = SplayTreeMap();

    final Iterable<List<TrinaRow>> chunks = refRows.slices(chunkSize);

    final chunksLength = chunks.length;

    final List<int> chunksIndexes = List.generate(
      chunksLength,
      (index) => index,
    );

    Timer.periodic(duration, (timer) {
      if (chunksIndexes.isEmpty) {
        return;
      }

      final chunkIndex = chunksIndexes.removeLast();

      final chunk = chunks.elementAt(chunkIndex);

      Future(() {
        return TrinaGridStateManager.initializeRows(
          refColumns,
          chunk,
          forceApplySortIdx: forceApplySortIdx,
          increase: increase,
          start: start + (chunkIndex * chunkSize),
        );
      }).then((value) {
        splayMapRows[chunkIndex] = value;

        if (splayMapRows.length == chunksLength) {
          completer.complete(
            splayMapRows.values.expand((element) => element).toList(),
          );

          timer.cancel();
        }
      });
    });

    return completer.future;
  }
}

/// This is a class for handling horizontal and vertical scrolling of columns and rows of [TrinaGrid].
class TrinaGridScrollController {
  LinkedScrollControllerGroup? vertical;

  LinkedScrollControllerGroup? horizontal;

  TrinaGridScrollController({this.vertical, this.horizontal});

  ScrollController? get bodyRowsHorizontal => _bodyRowsHorizontal;

  ScrollController? _bodyRowsHorizontal;

  ScrollController? get bodyRowsVertical => _bodyRowsVertical;

  ScrollController? _bodyRowsVertical;

  double get maxScrollHorizontal {
    assert(_bodyRowsHorizontal != null);

    return _bodyRowsHorizontal!.position.maxScrollExtent;
  }

  double get maxScrollVertical {
    assert(_bodyRowsVertical != null);

    return _bodyRowsVertical!.position.maxScrollExtent;
  }

  double get verticalOffset => vertical!.offset;

  double get horizontalOffset => horizontal!.offset;

  void setBodyRowsHorizontal(ScrollController? scrollController) {
    _bodyRowsHorizontal = scrollController;
  }

  void setBodyRowsVertical(ScrollController? scrollController) {
    _bodyRowsVertical = scrollController;
  }
}

class TrinaGridCellPosition {
  final int? columnIdx;
  final int? rowIdx;

  const TrinaGridCellPosition({this.columnIdx, this.rowIdx});

  bool get hasPosition => columnIdx != null && rowIdx != null;

  @override
  bool operator ==(covariant Object other) {
    return identical(this, other) ||
        other is TrinaGridCellPosition &&
            runtimeType == other.runtimeType &&
            columnIdx == other.columnIdx &&
            rowIdx == other.rowIdx;
  }

  @override
  int get hashCode => Object.hash(columnIdx, rowIdx);
}

class TrinaGridSelectingCellPosition {
  final String? field;
  final int? rowIdx;

  const TrinaGridSelectingCellPosition({this.field, this.rowIdx});

  @override
  bool operator ==(covariant Object other) {
    return identical(this, other) ||
        other is TrinaGridSelectingCellPosition &&
            runtimeType == other.runtimeType &&
            field == other.field &&
            rowIdx == other.rowIdx;
  }

  @override
  int get hashCode => Object.hash(field, rowIdx);
}

class TrinaGridKeyPressed {
  bool get shift {
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;

    return !(!keysPressed.contains(LogicalKeyboardKey.shiftLeft) &&
        !keysPressed.contains(LogicalKeyboardKey.shiftRight));
  }

  bool get ctrl {
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;

    // Support both Ctrl (Windows/Linux) and Cmd (Mac) for cross-platform compatibility
    return !(!keysPressed.contains(LogicalKeyboardKey.controlLeft) &&
        !keysPressed.contains(LogicalKeyboardKey.controlRight) &&
        !keysPressed.contains(LogicalKeyboardKey.metaLeft) &&
        !keysPressed.contains(LogicalKeyboardKey.metaRight));
  }
}

/// A type of selection mode when you select a row or cell in a grid
/// by tapping and holding, then moving the pointer
/// or selecting a row or cell in the grid with controls or shift and tap.
///
/// [TrinaGridSelectingMode.cell] selects each cell.
///
/// [TrinaGridSelectingMode.row] selects row by row.
///
/// [TrinaGridSelectingMode.none] does nothing.
enum TrinaGridSelectingMode {
  cell,
  row,
  none,

  /// using only internal
  horizontal;

  bool get isCell => this == TrinaGridSelectingMode.cell;

  bool get isRow => this == TrinaGridSelectingMode.row;

  bool get isNone => this == TrinaGridSelectingMode.none;

  /// using only internal
  bool get isHorizontal => this == TrinaGridSelectingMode.horizontal;
}

abstract class _Apply {
  bool get apply;

  void execute(TrinaRow row);
}

class _ApplyList implements _Apply {
  final List<_Apply> list;

  _ApplyList(this.list) {
    list.removeWhere((element) => !element.apply);
  }

  @override
  bool get apply => list.isNotEmpty;

  @override
  void execute(TrinaRow row) {
    var len = list.length;

    for (var i = 0; i < len; i += 1) {
      list[i].execute(row);
    }
  }
}

class _ApplyCellForSetColumnRow implements _Apply {
  final List<TrinaColumn> refColumns;

  _ApplyCellForSetColumnRow(this.refColumns);

  @override
  bool get apply => true;

  @override
  void execute(TrinaRow row) {
    if (row.initialized) {
      return;
    }

    for (var element in refColumns) {
      row.cells[element.field]!
        ..setColumn(element)
        ..setRow(row);
    }
  }
}

class _ApplyRowForSortIdx implements _Apply {
  final bool forceApply;

  final bool increase;

  final int start;

  final TrinaRow? firstRow;

  _ApplyRowForSortIdx({
    required this.forceApply,
    required this.increase,
    required this.start,
    required this.firstRow,
  }) {
    assert(firstRow != null);

    _sortIdx = start;
  }

  late int _sortIdx;

  @override
  bool get apply => forceApply == true;

  @override
  void execute(TrinaRow row) {
    row.sortIdx = _sortIdx;

    _sortIdx = increase ? ++_sortIdx : --_sortIdx;
  }
}

class _ApplyRowGroup implements _Apply {
  final List<TrinaColumn> refColumns;

  _ApplyRowGroup(this.refColumns);

  @override
  bool get apply => true;

  @override
  void execute(TrinaRow row) {
    if (_hasChildren(row)) {
      _initializeChildren(
        columns: refColumns,
        rows: row.type.group.children.originalList,
        parent: row,
      );
    }
  }

  void _initializeChildren({
    required List<TrinaColumn> columns,
    required List<TrinaRow> rows,
    required TrinaRow parent,
  }) {
    for (final row in rows) {
      row.setParent(parent);
    }

    TrinaGridStateManager.initializeRows(columns, rows);
  }

  bool _hasChildren(TrinaRow row) {
    return row.type.isGroup && row.type.group.children.originalList.isNotEmpty;
  }
}
