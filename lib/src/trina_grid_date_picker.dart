import 'dart:async';
import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:trina_grid/trina_grid.dart';

import 'ui/ui.dart';

/// [TrinaGridDatePicker] Calls the popup for date selection.
/// Select the date by using the keyboard action of [TrinaGrid].
class TrinaGridDatePicker {
  final BuildContext context;

  final intl.DateFormat dateFormat;

  final intl.DateFormat headerDateFormat;

  final DateTime? initDate;

  final DateTime? startDate;

  final DateTime? endDate;

  final TrinaOnLoadedEventCallback? onLoaded;

  final TrinaOnSelectedEventCallback? onSelected;

  final double itemHeight;

  final TrinaGridConfiguration configuration;

  TrinaGridDatePicker({
    required this.context,
    required this.dateFormat,
    required this.headerDateFormat,
    this.initDate,
    this.startDate,
    this.endDate,
    this.onLoaded,
    this.onSelected,
    this.itemHeight = TrinaGridSettings.rowTotalHeight,
    this.configuration = const TrinaGridConfiguration(),
  }) {
    open();
  }

  static double dateCellWidth = 45.0;

  late final TrinaGridStateManager datePickerStateManager;

  late final StreamSubscription keyboardStream;

  late int currentYear;

  late int currentMonth;

  Future<void> open() async {
    double rowsHeight = 6 * itemHeight;

    // itemHeight * 2 = Header Height + Column Height
    double popupHeight = (itemHeight * 2) +
        rowsHeight +
        TrinaGridSettings.totalShadowLineWidth +
        TrinaGridSettings.gridInnerSpacing;

    final popupColumns = _buildColumns();

    final defaultDate = _getDefaultDate();

    currentYear = defaultDate.year;

    currentMonth = defaultDate.month;

    final List<DateTime> days = TrinaDateTimeHelper.getDaysInBetween(
      DateTime(defaultDate.year, defaultDate.month, 1),
      DateTime(defaultDate.year, defaultDate.month + 1, 0),
    );

    final popupRows = _buildRows(days);

    TrinaGridPopup(
      mode: TrinaGridMode.popup,
      context: context,
      onLoaded: _onLoaded,
      onSelected: _onSelected,
      columns: popupColumns,
      rows: popupRows,
      width: popupColumns.fold<double>(0, (previous, column) {
            return previous + column.width;
          }) +
          1,
      height: popupHeight,
      createHeader: _createHeader,
      onDoubleTap: (event) {
        Navigator.pop(
          context,
          TrinaGridOnSelectedEvent(
              selectedCells: [event.cell], selectedRows: [event.row]),
        );
      },
      configuration: configuration.copyWith(
        tabKeyAction: TrinaGridTabKeyAction.normal,
        style: configuration.style.copyWith(
          enableColumnBorderVertical: false,
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: false,
          enableRowColorAnimation: false,
          oddRowColor: const TrinaOptional(null),
          evenRowColor: const TrinaOptional(null),
          activatedColor: configuration.style.gridBackgroundColor,
          gridBorderColor: configuration.style.gridBackgroundColor,
          borderColor: configuration.style.gridBackgroundColor,
          activatedBorderColor: configuration.style.gridBackgroundColor,
          inactivatedBorderColor: configuration.style.gridBackgroundColor,
          rowHeight: configuration.style.rowHeight,
          defaultColumnTitlePadding: TrinaGridSettings.columnTitlePadding,
          defaultCellPadding: const EdgeInsets.symmetric(horizontal: 3),
          gridBorderRadius: configuration.style.gridPopupBorderRadius,
        ),
        columnSize: const TrinaGridColumnSizeConfig(
          autoSizeMode: TrinaAutoSizeMode.none,
          resizeMode: TrinaResizeMode.none,
        ),
      ),
    );
  }

  void keyboardListener(TrinaGridEvent event) {
    if (event is! TrinaGridCannotMoveCurrentCellEvent) {
      return;
    }

    switch (event.direction) {
      case TrinaMoveDirection.left:
        _updateRows(-12);
        break;
      case TrinaMoveDirection.right:
        _updateRows(12);
        break;
      case TrinaMoveDirection.up:
        _updateRows(-1);
        break;
      case TrinaMoveDirection.down:
        _updateRows(1);
        break;
    }
  }

  void _onLoaded(TrinaGridOnLoadedEvent event) {
    datePickerStateManager = event.stateManager;

    keyboardStream = datePickerStateManager.eventManager!.listener(
      keyboardListener,
    );

    if (initDate != null) {
      final rows = datePickerStateManager.rows;

      //only get date only from initDate
      final initDateString = dateFormat.format(
        DateTime(initDate!.year, initDate!.month, initDate!.day),
      );

      for (var i = 0; i < rows.length; i += 1) {
        for (var entry in rows[i].cells.entries) {
          if (rows[i].cells[entry.key]!.value == initDateString) {
            datePickerStateManager.setCurrentCell(
              datePickerStateManager.refRows[i].cells[entry.key],
              i,
            );
            break;
          }
        }
      }
    }

    if (onLoaded != null) {
      onLoaded!(event);
    }
  }

  void _onSelected(TrinaGridOnSelectedEvent event) {
    keyboardStream.cancel();

    if (onSelected != null) {
      onSelected!(event);
    }
  }

  DateTime _getDefaultDate() {
    DateTime defaultDate = DateTime.now();

    if (initDate != null && _isValidRange(initDate!)) {
      return initDate!;
    }

    if (startDate != null) {
      return startDate!;
    }

    if (endDate != null) {
      return endDate!;
    }

    return defaultDate;
  }

  void _updateRows(int offset) {
    final offsetDate = DateTime(currentYear, currentMonth + offset);

    if (false ==
        TrinaDateTimeHelper.isValidRangeInMonth(
          date: offsetDate,
          start: startDate,
          end: endDate,
        )) {
      return;
    }

    TrinaGridCellPosition? currentCellPosition =
        datePickerStateManager.currentCellPosition;

    TrinaGridCellPosition? cellPosition;

    currentYear = offsetDate.year;

    currentMonth = offsetDate.month;

    final List<DateTime> days = TrinaDateTimeHelper.getDaysInBetween(
      DateTime.utc(offsetDate.year, offsetDate.month, 1),
      DateTime.utc(offsetDate.year, offsetDate.month + 1, 0),
    );

    final popupRows = _buildRows(days);

    datePickerStateManager.removeAllRows(notify: false);

    datePickerStateManager.insertRows(0, popupRows, notify: false);

    switch (offset) {
      case -12:
        cellPosition = TrinaGridCellPosition(
          columnIdx: datePickerStateManager.refColumns.length - 1,
          rowIdx: min(currentCellPosition?.rowIdx ?? 0,
              datePickerStateManager.refRows.length - 1),
        );
        break;
      case 12:
        cellPosition = TrinaGridCellPosition(
          columnIdx: 0,
          rowIdx: min(currentCellPosition?.rowIdx ?? 0,
              datePickerStateManager.refRows.length - 1),
        );
        break;
      case -1:
        cellPosition = TrinaGridCellPosition(
          columnIdx: currentCellPosition?.columnIdx ?? 0,
          rowIdx: datePickerStateManager.refRows.length - 1,
        );
        break;
      case 1:
        cellPosition = TrinaGridCellPosition(
          columnIdx: currentCellPosition?.columnIdx ?? 0,
          rowIdx: 0,
        );
        break;
    }

    if (cellPosition != null) {
      final TrinaCell cell = datePickerStateManager
          .refRows[cellPosition.rowIdx!].cells.entries
          .elementAt(cellPosition.columnIdx!)
          .value;

      datePickerStateManager.setCurrentCell(
        cell,
        cellPosition.rowIdx,
        notify: false,
      );
    }

    datePickerStateManager.notifyListeners();
  }

  Widget _createHeader(TrinaGridStateManager? stateManager) {
    return _DateCellHeader(
      stateManager: stateManager!,
      dateFormat: dateFormat,
      headerDateFormat: headerDateFormat,
      changeMonth: (offset) => _updateRows(offset),
    );
  }

  String _dateFormatter(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return '';
    }

    var dateTime = dateFormat.parse(
      value.toString(),
    );

    return dateTime.day.toString();
  }

  bool _isValidRange(DateTime date) {
    return TrinaDateTimeHelper.isValidRange(
      date: date,
      start: startDate,
      end: endDate,
    );
  }

  Widget _cellRenderer(TrinaColumnRendererContext renderContext) {
    final cell = renderContext.cell;

    final isCurrentCell = renderContext.stateManager.isCurrentCell(cell);

    final isValidDate = cell.value.toString().isNotEmpty &&
        _isValidRange(dateFormat.parse(cell.value));

    final cellColor = isCurrentCell
        ? isValidDate
            ? configuration.style.activatedBorderColor
            : configuration.style.cellColorInReadOnlyState
        : configuration.style.gridBackgroundColor;

    final textColor = isCurrentCell
        ? configuration.style.gridBackgroundColor
        : isValidDate
            ? configuration.style.cellTextStyle.color
            : configuration.style.cellColorInReadOnlyState;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cellColor,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Center(
          child: Text(
            _dateFormatter(cell.value),
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }

  List<TrinaColumn> _buildColumns() {
    final localeText = configuration.localeText;

    return [
      [localeText.sunday, '7'],
      [localeText.monday, '1'],
      [localeText.tuesday, '2'],
      [localeText.wednesday, '3'],
      [localeText.thursday, '4'],
      [localeText.friday, '5'],
      [localeText.saturday, '6'],
    ].map((e) {
      return TrinaColumn(
        title: e[0],
        field: e[1],
        readOnly: true,
        type: TrinaColumnType.text(),
        width: dateCellWidth,
        enableColumnDrag: false,
        enableEditingMode: false,
        enableSorting: false,
        enableContextMenu: false,
        enableDropToResize: false,
        textAlign: TrinaColumnTextAlign.center,
        titleTextAlign: TrinaColumnTextAlign.center,
        renderer: _cellRenderer,
      );
    }).toList(growable: false);
  }

  List<TrinaRow> _buildRows(List<DateTime> days) {
    List<TrinaRow> rows = [];

    while (days.isNotEmpty) {
      final Map<String, TrinaCell> cells = Map.fromIterable(
        <String>['7', '1', '2', '3', '4', '5', '6'],
        key: (dynamic e) => e.toString(),
        value: (dynamic e) {
          if (days.isEmpty) {
            return TrinaCell(value: '');
          }

          if (days.first.weekday.toString() != e) {
            return TrinaCell(value: '');
          }

          final DateTime day = days.removeAt(0);

          return TrinaCell(
            value: dateFormat.format(day),
          );
        },
      );

      rows.add(TrinaRow(cells: cells));
    }

    return rows;
  }
}

class _DateCellHeader extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  final intl.DateFormat dateFormat;

  final intl.DateFormat headerDateFormat;

  final Function(int offset) changeMonth;

  const _DateCellHeader({
    required this.stateManager,
    required this.dateFormat,
    required this.headerDateFormat,
    required this.changeMonth,
  });

  @override
  _DateCellHeaderState createState() => _DateCellHeaderState();
}

abstract class _DateCellHeaderStateWithChange
    extends TrinaStateWithChange<_DateCellHeader> {
  TrinaCell? _currentCell;

  int _currentYear = 0;

  int _currentMonth = 0;

  late final ScrollController _scroll;

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    _scroll = stateManager.scroll.horizontal!.addAndGet();

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void dispose() {
    _scroll.dispose();

    super.dispose();
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _currentCell = update<TrinaCell?>(
      _currentCell,
      stateManager.currentCell,
      compare: identical,
    );

    final date = widget.dateFormat.parse(
      stateManager.rows[1].cells.entries.first.value.value,
    );

    _currentYear = update<int>(
      _currentYear,
      date.year,
    );

    _currentMonth = update<int>(
      _currentMonth,
      date.month,
    );
  }
}

class _DateCellHeaderState extends _DateCellHeaderStateWithChange {
  Color? get textColor =>
      stateManager.configuration.style.columnTextStyle.color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: stateManager.rowTotalHeight,
      child: Padding(
        padding: TrinaGridSettings.cellPadding,
        child: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  padding: const EdgeInsets.all(0),
                  iconSize: stateManager.configuration.style.iconSize,
                  onPressed: () => widget.changeMonth(-12),
                  icon: Icon(
                    Icons.navigate_before,
                    color: stateManager.configuration.style.iconColor,
                  ),
                ),
                IconButton(
                  padding: const EdgeInsets.all(0),
                  iconSize: stateManager.configuration.style.iconSize,
                  onPressed: () => widget.changeMonth(12),
                  icon: Icon(
                    Icons.navigate_next,
                    color: stateManager.configuration.style.iconColor,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.headerDateFormat.format(
                    DateTime(_currentYear, _currentMonth),
                  ),
                  style: TextStyle(
                    color: textColor,
                    fontSize: stateManager
                        .configuration.style.columnTextStyle.fontSize,
                    fontWeight: stateManager
                        .configuration.style.columnTextStyle.fontWeight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(width: 10),
                RotatedBox(
                  quarterTurns: 3,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    iconSize: stateManager.configuration.style.iconSize,
                    onPressed: () => widget.changeMonth(-1),
                    icon: Icon(
                      Icons.navigate_next,
                      color: stateManager.configuration.style.iconColor,
                    ),
                  ),
                ),
                RotatedBox(
                  quarterTurns: 3,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    iconSize: stateManager.configuration.style.iconSize,
                    onPressed: () => widget.changeMonth(1),
                    icon: Icon(
                      Icons.navigate_before,
                      color: stateManager.configuration.style.iconColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
