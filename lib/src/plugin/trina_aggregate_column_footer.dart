import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trina_grid/trina_grid.dart';

import '../ui/ui.dart';

/// {@template trina_aggregate_filter}
/// Returns whether to be filtered according to the value of [TrinaCell.value].
/// {@endtemplate}
typedef TrinaAggregateFilter = bool Function(TrinaCell);

/// {@template trina_aggregate_column_type}
/// Determine the aggregate type.
/// {@endtemplate}
enum TrinaAggregateColumnType {
  /// Returns the sum of all values.
  sum,

  /// Returns the result of adding up all values and dividing by the number of elements.
  average,

  /// Returns the smallest value among all values.
  min,

  /// Returns the largest value out of all values.
  max,

  /// Returns the total count.
  count,
}

/// {@template trina_aggregate_column_iterate_row_type}
/// Determine the condition of the rows to be included in the aggregation.
/// {@endtemplate}
enum TrinaAggregateColumnIterateRowType {
  /// Include all rows in the aggregation.
  all,

  /// Include the rows of the filtered result in the aggregation.
  filtered,

  /// Include rows from filtered and paginated results in aggregates.
  filteredAndPaginated;

  bool get isAll => this == TrinaAggregateColumnIterateRowType.all;

  bool get isFiltered => this == TrinaAggregateColumnIterateRowType.filtered;

  bool get isFilteredAndPaginated =>
      this == TrinaAggregateColumnIterateRowType.filteredAndPaginated;
}

/// {@template trina_aggregate_column_grouped_row_type}
/// When grouping row is applied, set the condition of row to be aggregated.
/// {@endtemplate}
enum TrinaAggregateColumnGroupedRowType {
  /// processes both groups and rows.
  all,

  /// processes only the group and the children of the expanded group.
  expandedAll,

  /// processes non-group rows.
  rows,

  /// processes only expanded rows, not groups.
  expandedRows;

  bool get isAll => this == TrinaAggregateColumnGroupedRowType.all;

  bool get isExpandedAll =>
      this == TrinaAggregateColumnGroupedRowType.expandedAll;

  bool get isRows => this == TrinaAggregateColumnGroupedRowType.rows;

  bool get isExpandedRows =>
      this == TrinaAggregateColumnGroupedRowType.expandedRows;

  bool get isExpanded => isExpandedAll || isExpandedRows;

  bool get isRowsOnly => isRows || isExpandedRows;
}

/// Widget for outputting the sum, average, minimum,
/// and maximum values of all values in a column.
///
/// Example) [TrinaColumn.footerRenderer] Implement column footer as return value of callback
/// ```dart
/// TrinaColumn(
///   title: 'column',
///   field: 'column',
///   type: TrinaColumnType.number(format: '#,###.###'),
///   textAlign: TrinaColumnTextAlign.right,
///   footerRenderer: (rendererContext) {
///     return TrinaAggregateColumnFooter(
///       rendererContext: rendererContext,
///       type: TrinaAggregateColumnType.sum,
///       numberFormat: NumberFormat('Sum: #,###.###'),
///       alignment: Alignment.center,
///     );
///   },
/// ),
/// ```
///
/// [TrinaAggregateColumnFooter]
/// You can also return a [Widget] you wrote yourself instead of a widget.
/// However, you must implement the process
/// of updating according to the value change yourself.
class TrinaAggregateColumnFooter extends TrinaStatefulWidget {
  /// Contains information needed to implement the widget.
  final TrinaColumnFooterRendererContext rendererContext;

  /// {@macro trina_aggregate_column_type}
  final TrinaAggregateColumnType type;

  /// {@macro trina_aggregate_column_iterate_row_type}
  final TrinaAggregateColumnIterateRowType iterateRowType;

  /// {@macro trina_aggregate_column_grouped_row_type}
  final TrinaAggregateColumnGroupedRowType groupedRowType;

  /// {@macro trina_aggregate_filter}
  ///
  /// Example) Only when the value of [TrinaCell.value] is Android,
  /// it is included in the aggregate list.
  /// ```dart
  /// filter: (cell) => cell.value == 'Android',
  /// ```
  final TrinaAggregateFilter? filter;

  /// Set the format of aggregated result values.
  ///
  /// Example)
  /// ```dart
  /// format: 'Android: #,###', // Android: 100 (if the result is 100)
  /// format: '#,###.###', // 1,000,000.123 (expressed to 3 decimal places)
  /// ```
  @Deprecated('Use numberFormat instead.')
  final String format;

  /// Setting the locale of the resulting value.
  ///
  /// Example)
  /// ```dart
  /// locale: 'da_DK',
  /// ```
  @Deprecated('Use numberFormat and set the locale there instead.')
  final String? locale;

  /// You can customize the resulting values.
  ///
  /// Example)
  /// ```dart
  /// titleSpanBuilder: (text) {
  ///   return [
  ///     const TextSpan(
  ///       text: 'Sum',
  ///       style: TextStyle(color: Colors.red),
  ///     ),
  ///     const TextSpan(text: ' : '),
  ///     TextSpan(text: text),
  ///   ];
  /// },
  /// ```
  final List<InlineSpan> Function(String)? titleSpanBuilder;

  final AlignmentGeometry? alignment;

  final EdgeInsets? padding;

  /// The number format to use for the aggregated value.
  /// If not provided, it uses the default format: NumberFormat("#,###").
  ///
  /// Examples,
  ///
  /// ```dart
  /// numberFormat: NumberFormat('Total: #,###.###'),
  /// numberFormat: NumberFormat.simpleCurrency(),
  /// ```
  final NumberFormat? numberFormat;

  final bool formatAsCurrency;

  const TrinaAggregateColumnFooter({
    required this.rendererContext,
    required this.type,
    this.iterateRowType =
        TrinaAggregateColumnIterateRowType.filteredAndPaginated,
    this.groupedRowType = TrinaAggregateColumnGroupedRowType.all,
    this.filter,
    @Deprecated('Use numberFormat instead.') this.format = "#,###",
    @Deprecated('Use numberFormat and set the locale in there instead.')
    this.locale,
    this.titleSpanBuilder,
    this.alignment,
    this.padding,
    this.numberFormat,
    @Deprecated('Use numberFormat instead.') this.formatAsCurrency = false,
    super.key,
  });

  @override
  TrinaAggregateColumnFooterState createState() =>
      TrinaAggregateColumnFooterState();
}

class TrinaAggregateColumnFooterState
    extends TrinaStateWithChange<TrinaAggregateColumnFooter> {
  num? _aggregatedValue;
  late final NumberFormat _numberFormat;

  late final num? Function({
    required Iterable<TrinaRow> rows,
    required TrinaColumn column,
    TrinaAggregateFilter? filter,
  })
  _aggregator;

  @override
  TrinaGridStateManager get stateManager => widget.rendererContext.stateManager;

  TrinaColumn get column => widget.rendererContext.column;

  Iterable<TrinaRow> get rows =>
      stateManager.enabledRowGroups ? _groupedRows : _normalRows;

  Iterable<TrinaRow> get _normalRows {
    switch (widget.iterateRowType) {
      case TrinaAggregateColumnIterateRowType.all:
        return stateManager.refRows.originalList;
      case TrinaAggregateColumnIterateRowType.filtered:
        return stateManager.refRows.filterOrOriginalList;
      case TrinaAggregateColumnIterateRowType.filteredAndPaginated:
        return stateManager.refRows;
    }
  }

  Iterable<TrinaRow> get _groupedRows {
    Iterable<TrinaRow> iterableRows;

    switch (widget.iterateRowType) {
      case TrinaAggregateColumnIterateRowType.all:
        iterableRows = stateManager.iterateAllMainRowGroup;
        break;
      case TrinaAggregateColumnIterateRowType.filtered:
        iterableRows = stateManager.iterateFilteredMainRowGroup;
        break;
      case TrinaAggregateColumnIterateRowType.filteredAndPaginated:
        iterableRows = stateManager.iterateMainRowGroup;
        break;
    }

    return TrinaRowGroupHelper.iterateWithFilter(
      iterableRows,
      filter: widget.groupedRowType.isRowsOnly ? (r) => !r.type.isGroup : null,
      childrenFilter: (r) {
        if (!r.type.isGroup ||
            (widget.groupedRowType.isExpanded && !r.type.group.expanded)) {
          return null;
        }

        switch (widget.iterateRowType) {
          case TrinaAggregateColumnIterateRowType.all:
            return r.type.group.children.originalList.iterator;
          case TrinaAggregateColumnIterateRowType.filtered:
          case TrinaAggregateColumnIterateRowType.filteredAndPaginated:
            return r.type.group.children.iterator;
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _numberFormat =
        widget.numberFormat ??
        (widget.formatAsCurrency
            ? NumberFormat.simpleCurrency()
            : NumberFormat("#,###"));

    _setAggregator();

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _aggregatedValue = update<num?>(
      _aggregatedValue,
      _aggregator(rows: rows, column: column, filter: widget.filter),
    );
  }

  void _setAggregator() {
    switch (widget.type) {
      case TrinaAggregateColumnType.sum:
        _aggregator = TrinaAggregateHelper.sum;
        break;
      case TrinaAggregateColumnType.average:
        _aggregator = TrinaAggregateHelper.average;
        break;
      case TrinaAggregateColumnType.min:
        _aggregator = TrinaAggregateHelper.min;
        break;
      case TrinaAggregateColumnType.max:
        _aggregator = TrinaAggregateHelper.max;
        break;
      case TrinaAggregateColumnType.count:
        _aggregator = TrinaAggregateHelper.count;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTitleSpan = widget.titleSpanBuilder != null;

    final formattedValue = _aggregatedValue == null
        ? ''
        : _numberFormat.format(_aggregatedValue);

    final text = hasTitleSpan ? null : formattedValue;

    final children = hasTitleSpan
        ? widget.titleSpanBuilder!(formattedValue)
        : null;

    return Padding(
      padding: widget.padding ?? TrinaGridSettings.columnTitlePadding,
      child: Align(
        alignment: widget.alignment ?? AlignmentDirectional.centerStart,
        child: Text.rich(
          TextSpan(text: text, children: children),
          style: stateManager.configuration.style.cellTextStyle.copyWith(
            decoration: TextDecoration.none,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
