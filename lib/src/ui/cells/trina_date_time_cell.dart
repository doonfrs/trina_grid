import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import 'popup_cell.dart';

class TrinaDateTimeCell extends StatefulWidget implements PopupCell {
  @override
  final TrinaGridStateManager stateManager;

  @override
  final TrinaCell cell;

  @override
  final TrinaColumn column;

  @override
  final TrinaRow row;

  const TrinaDateTimeCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  TrinaDateTimeCellState createState() => TrinaDateTimeCellState();
}

class TrinaDateTimeCellState extends State<TrinaDateTimeCell>
    with PopupCellState<TrinaDateTimeCell> {
  TrinaGridStateManager? popupStateManager;

  @override
  List<TrinaColumn> popupColumns = [];

  @override
  List<TrinaRow> popupRows = [];

  @override
  IconData? get icon =>
      (widget.column.type as TrinaColumnTypeDateTime).popupIcon;

  @override
  void openPopup() async {
    if (widget.column.checkReadOnly(widget.row, widget.cell)) {
      return;
    }
    isOpenedPopup = true;

    // First select date
    DateTime? selectedDate;
    final columnType = widget.column.type as TrinaColumnTypeDateTime;

    if (widget.stateManager.selectDateCallback != null) {
      final sm = widget.stateManager;
      selectedDate = await sm.selectDateCallback!(widget.cell, widget.column);
      if (selectedDate == null) {
        isOpenedPopup = false;
        return;
      }
    } else {
      // Create a completer to handle the date selection
      final completer = Completer<DateTime?>();

      TrinaGridDatePicker(
        context: context,
        initDate: TrinaDateTimeHelper.parseOrNullWithFormat(
          widget.cell.value,
          columnType.format,
        ),
        startDate: columnType.startDate,
        endDate: columnType.endDate,
        dateFormat: columnType.dateFormat,
        headerDateFormat: columnType.headerDateFormat,
        onSelected: (event) {
          if (event.cell != null) {
            final selectedDateStr = event.cell!.value.toString();
            try {
              final date = columnType.dateFormat.parse(selectedDateStr);
              completer.complete(date);
            } catch (e) {
              completer.complete(null);
            }
          } else {
            completer.complete(null);
          }
        },
        itemHeight: widget.stateManager.rowTotalHeight,
        configuration: widget.stateManager.configuration,
      );

      selectedDate = await completer.future;
      if (selectedDate == null) {
        isOpenedPopup = false;
        return;
      }
    }

    // Then select time
    // Create a completer to handle the time selection
    final timeCompleter = Completer<String?>();

    // Get current date and time parts
    final DateTime currentDateTime =
        widget.cell.value != null && widget.cell.value.toString().isNotEmpty
            ? columnType.dateFormat.parse(widget.cell.value.toString())
            : DateTime.now();

    // Open time picker dialog
    final localeText = widget.stateManager.configuration.localeText;
    final style = widget.stateManager.style;

    final configuration = widget.stateManager.configuration.copyWith(
      tabKeyAction: TrinaGridTabKeyAction.normal,
      style: style.copyWith(
        enableColumnBorderVertical: false,
        enableColumnBorderHorizontal: false,
        enableCellBorderVertical: false,
        enableCellBorderHorizontal: false,
        enableRowColorAnimation: false,
        oddRowColor: const TrinaOptional(null),
        evenRowColor: const TrinaOptional(null),
        activatedColor: style.gridBackgroundColor,
        gridBorderColor: style.gridBackgroundColor,
        borderColor: style.gridBackgroundColor,
        activatedBorderColor: style.gridBackgroundColor,
        inactivatedBorderColor: style.gridBackgroundColor,
        rowHeight: style.rowHeight,
        defaultColumnTitlePadding: TrinaGridSettings.columnTitlePadding,
        defaultCellPadding: const EdgeInsets.symmetric(horizontal: 3),
        gridBorderRadius: style.gridPopupBorderRadius,
      ),
      columnSize: const TrinaGridColumnSizeConfig(
        autoSizeMode: TrinaAutoSizeMode.none,
        resizeMode: TrinaResizeMode.none,
      ),
    );

    if (!mounted) {
      return;
    }

    TrinaDualGridPopup(
      context: context,
      onSelected: (TrinaDualOnSelectedEvent event) {
        if (event.gridA == null || event.gridB == null) {
          timeCompleter.complete(null);
        } else {
          timeCompleter.complete(
            '${event.gridA!.cell!.value}:${event.gridB!.cell!.value}',
          );
        }
      },
      gridPropsA: TrinaDualGridProps(
        columns: [
          TrinaColumn(
            title: localeText.hour,
            field: 'hour',
            readOnly: true,
            type: TrinaColumnType.text(),
            enableSorting: false,
            enableColumnDrag: false,
            enableContextMenu: false,
            enableDropToResize: false,
            textAlign: TrinaColumnTextAlign.center,
            titleTextAlign: TrinaColumnTextAlign.center,
            width: 134,
            renderer: _timePartCellRenderer,
          ),
        ],
        rows: Iterable<int>.generate(24)
            .map(
              (hour) => TrinaRow(
                cells: {
                  'hour': TrinaCell(value: hour.toString().padLeft(2, '0')),
                },
              ),
            )
            .toList(growable: false),
        onLoaded: (TrinaGridOnLoadedEvent event) {
          final stateManager = event.stateManager;
          final rows = stateManager.refRows;
          final length = rows.length;

          stateManager.setSelectingMode(TrinaGridSelectingMode.disabled);

          final currentHour = currentDateTime.hour.toString().padLeft(2, '0');

          for (var i = 0; i < length; i += 1) {
            if (rows[i].cells['hour']!.value == currentHour) {
              stateManager.setCurrentCell(rows[i].cells['hour'], i);

              stateManager.moveScrollByRow(
                TrinaMoveDirection.up,
                i + 1 + offsetOfScrollRowIdx,
              );

              return;
            }
          }
        },
        configuration: configuration,
      ),
      gridPropsB: TrinaDualGridProps(
        columns: [
          TrinaColumn(
            title: localeText.minute,
            field: 'minute',
            readOnly: true,
            type: TrinaColumnType.text(),
            enableSorting: false,
            enableColumnDrag: false,
            enableContextMenu: false,
            enableDropToResize: false,
            textAlign: TrinaColumnTextAlign.center,
            titleTextAlign: TrinaColumnTextAlign.center,
            width: 134,
            renderer: _timePartCellRenderer,
          ),
        ],
        rows: Iterable<int>.generate(60)
            .map(
              (minute) => TrinaRow(
                cells: {
                  'minute': TrinaCell(value: minute.toString().padLeft(2, '0')),
                },
              ),
            )
            .toList(growable: false),
        onLoaded: (TrinaGridOnLoadedEvent event) {
          final stateManager = event.stateManager;
          final rows = stateManager.refRows;
          final length = rows.length;

          stateManager.setSelectingMode(TrinaGridSelectingMode.disabled);

          final currentMinute =
              currentDateTime.minute.toString().padLeft(2, '0');

          for (var i = 0; i < length; i += 1) {
            if (rows[i].cells['minute']!.value == currentMinute) {
              stateManager.setCurrentCell(rows[i].cells['minute'], i);

              stateManager.moveScrollByRow(
                TrinaMoveDirection.up,
                i + 1 + offsetOfScrollRowIdx,
              );

              return;
            }
          }
        },
        configuration: configuration,
      ),
      mode: TrinaGridMode.select,
      width: 276,
      height: 300,
      divider: const TrinaDualGridDivider(show: false),
    );

    final timeString = await timeCompleter.future;

    isOpenedPopup = false;

    if (timeString != null) {
      final timeParts = timeString.split(':');
      final hours = int.parse(timeParts[0]);
      final minutes = int.parse(timeParts[1]);

      // Combine date and time
      final selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        hours,
        minutes,
      );

      handleSelected(
        columnType.dateFormat.format(selectedDateTime),
      );
    } else {
      widget.stateManager.setKeepFocus(true);
      textFocus.requestFocus();
    }
  }

  Widget _timePartCellRenderer(TrinaColumnRendererContext renderContext) {
    final cell = renderContext.cell;

    final isCurrentCell = renderContext.stateManager.isCurrentCell(cell);

    final cellColor = isCurrentCell && renderContext.stateManager.hasFocus
        ? widget.stateManager.style.activatedBorderColor
        : widget.stateManager.style.gridBackgroundColor;

    final textColor = isCurrentCell && renderContext.stateManager.hasFocus
        ? widget.stateManager.style.gridBackgroundColor
        : widget.stateManager.style.cellTextStyle.color;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cellColor,
        shape: BoxShape.circle,
        border: !isCurrentCell
            ? null
            : !renderContext.stateManager.hasFocus
                ? Border.all(
                    color: widget.stateManager.style.activatedBorderColor,
                    width: 1,
                  )
                : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Center(
          child: Text(cell.value, style: TextStyle(color: textColor)),
        ),
      ),
    );
  }
}
