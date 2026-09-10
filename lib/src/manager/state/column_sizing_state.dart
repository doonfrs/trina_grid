import 'dart:math' as math;

import 'package:flutter/material.dart';
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

    final isFitContent = columnsAutoSizeMode.isFitContent;
    // Only fitContent overrides the floor, and only when the config supplies
    // one: minWidth doubles as the drag limit and is often set far above the
    // width the content needs. equal and scale keep using minWidth untouched.
    final minFitContentWidth = isFitContent
        ? columnSizeConfig.minFitContentWidth
        : null;
    final maxFitContentWidth = isFitContent
        ? columnSizeConfig.maxFitContentWidth
        : null;

    return TrinaAutoSizeHelper.items<TrinaColumn>(
      maxSize: maxWidth,
      items: columns,
      isSuppressed: (e) => e.suppressedAutoSize,
      getItemSize: (e) => e.width,
      // A column with a renderer draws something the measuring cannot see, so
      // it keeps its own minWidth as the floor: that is the width its author
      // declared it needs. Only measurable columns get the override.
      getItemMinSize: (e) =>
          e.renderer == null ? (minFitContentWidth ?? e.minWidth) : e.minWidth,
      setItemSize: (e, size) => e.width = size,
      mode: columnsAutoSizeMode,
      getItemPreferredSize: isFitContent ? _measureContentWidth : null,
      getItemMaxSize: maxFitContentWidth == null
          ? null
          : (_) => maxFitContentWidth,
    );
  }

  /// The width [TrinaAutoSizeMode.fitContent] wants for [column]: the widest of
  /// its title, the values on screen and its filter field, plus the padding and
  /// icons drawn around each of them.
  ///
  /// Only the loaded rows are measured, so on a paginated grid this is the
  /// current page. Widths from a [TrinaColumn.renderer] are not measured, the
  /// same limitation [autoFitColumn] has, which is why such a column keeps its
  /// own [TrinaColumn.minWidth] as its floor rather than the configured one.
  double _measureContentWidth(TrinaColumn column) {
    final titleWidth = _textWidth(column.title, style.columnTextStyle);
    final valueWidth = _widestValueWidth(column);

    // Mirrors autoFitColumn, minus the checkbox: that needs a BuildContext for
    // the tap target size, which the sizing pass does not have, so assume the
    // default rather than skip the allowance.
    final titlePadding =
        (column.titlePadding ?? style.defaultColumnTitlePadding).horizontal;
    final cellPadding =
        (column.cellPadding ?? style.defaultCellPadding).horizontal;
    final iconWidth = column.isShowRightIcon ? style.iconSize : 0.0;
    final checkboxWidth = column.enableRowChecked
        ? kMinInteractiveDimension
        : 0.0;

    return math.max(
      math.max(
        titleWidth + titlePadding + iconWidth + checkboxWidth + 8,
        valueWidth + cellPadding + iconWidth + checkboxWidth + 2,
      ),
      _measureFilterWidth(column),
    );
  }

  /// The width [column]'s filter field needs for its placeholder and buttons to
  /// stay usable, or 0 when no filter row is shown.
  ///
  /// Without this a column of short values fits to those values and leaves the
  /// filter below it too narrow to read or type in.
  double _measureFilterWidth(TrinaColumn column) {
    if (!showColumnFilter) return 0;

    final delegate = column.filterWidgetDelegate;
    final isMultiItems = delegate?.isMultiItems == true;

    if (!isMultiItems && !column.enableFilterMenuItem) return 0;

    final hint = isMultiItems
        ? configuration.localeText.multiLineFilterHint
        : (delegate?.filterHintText ?? column.defaultFilter.title);

    final double buttonsWidth;
    if (isMultiItems) {
      // Two 30px slots. The edit button is always there, and the clear button
      // appears as soon as the field has text, which is exactly when the field
      // would otherwise run out of room.
      buttonsWidth = 60;
    } else {
      // An arbitrary widget either way, so allow an icon's worth per button.
      final iconSlot = style.iconSize + 8;
      buttonsWidth =
          (delegate?.filterSuffixIcon == null ? 0 : iconSlot) +
          (delegate?.onClear == null ? 0 : iconSlot);
    }

    // The field's own InputDecoration.contentPadding, EdgeInsets.all(5).
    const contentPadding = 10.0;
    final filterPadding =
        (column.filterPadding ?? style.defaultColumnFilterPadding).horizontal;

    return _textWidth(hint, style.cellTextStyle) +
        contentPadding +
        filterPadding +
        buttonsWidth;
  }

  /// Measures the widest displayed value in [column].
  ///
  /// Character count is only a rough proxy for rendered width in a proportional
  /// font, so rather than trusting the longest string this lays out the few
  /// longest candidates and takes the widest of those.
  double _widestValueWidth(TrinaColumn column) {
    const candidateCount = 5;
    const maxRowsToScan = 500;

    final candidates = <String>[];
    var shortestCandidate = 0;

    final rowCount = math.min(refRows.length, maxRowsToScan);
    for (int i = 0; i < rowCount; i += 1) {
      // A map lookup, not entries.firstWhere: that is O(columns) per cell, and
      // it throws when a row is missing the field.
      final cell = refRows[i].cells[column.field];
      if (cell == null) continue;

      final value = column.formattedValueForDisplay(cell.value);
      if (value.isEmpty) continue;
      if (candidates.length == candidateCount &&
          value.length <= shortestCandidate) {
        continue;
      }

      candidates.add(value);
      candidates.sort((a, b) => b.length.compareTo(a.length));
      if (candidates.length > candidateCount) candidates.removeLast();
      shortestCandidate = candidates.last.length;
    }

    double widest = 0;
    for (final candidate in candidates) {
      widest = math.max(widest, _textWidth(candidate, style.cellTextStyle));
    }
    return widest;
  }

  double _textWidth(String text, TextStyle textStyle) {
    if (text.isEmpty) return 0;
    final painter = TextPainter(
      text: TextSpan(style: textStyle, text: text),
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
    )..layout();
    return painter.width;
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
