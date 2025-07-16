import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import 'popup_cell.dart';

class TrinaTimeCell extends StatefulWidget implements PopupCell {
  @override
  final TrinaGridStateManager stateManager;

  @override
  final TrinaCell cell;

  @override
  final TrinaColumn column;

  @override
  final TrinaRow row;

  const TrinaTimeCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  TrinaTimeCellState createState() => TrinaTimeCellState();
}

class TrinaTimeCellState extends State<TrinaTimeCell>
    with PopupCellState<TrinaTimeCell> {
  TrinaGridStateManager? popupStateManager;

  @override
  List<TrinaColumn> popupColumns = [];

  @override
  List<TrinaRow> popupRows = [];

  @override
  IconData? get icon => widget.column.type.time.popupIcon;

  String get cellValue =>
      widget.cell.value ?? widget.column.type.time.defaultValue;

  String get cellHour => cellValue.toString().substring(0, 2);

  String get cellMinute => cellValue.toString().substring(3, 5);

  @override
  void openPopup() {
    if (widget.column.readOnly) {
      return;
    }

    isOpenedPopup = true;

    final localeText = widget.stateManager.localeText;

    final style = widget.stateManager.style;

    final configuration = widget.stateManager.configuration.copyWith(
      tabKeyAction: TrinaGridTabKeyAction.normal,
      enterKeyAction: TrinaGridEnterKeyAction.select,
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

    TrinaDualGridPopup(
      context: context,
      onSelected: (TrinaDualOnSelectedEvent event) {
        isOpenedPopup = false;

        if (event.gridA.selectedCells.isEmpty &&
            event.gridB.selectedCells.isEmpty) {
          widget.stateManager.setKeepFocus(true);
          textFocus.requestFocus();
          return;
        }

        super.handleSelected(
          '${event.gridA.selectedCells.first.value}:'
          '${event.gridB.selectedCells.first.value}',
        );
      },
      gridPropsA: TrinaDualGridProps(
        columns: [
          TrinaColumn(
            title: localeText.hour,
            field: 'hour',
            readOnly: true,
            type: TrinaColumnType.text(),
            enableEditingMode: false,
            enableSorting: false,
            enableColumnDrag: false,
            enableContextMenu: false,
            enableDropToResize: false,
            textAlign: TrinaColumnTextAlign.center,
            titleTextAlign: TrinaColumnTextAlign.center,
            width: 134,
            renderer: _cellRenderer,
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

          for (var i = 0; i < length; i += 1) {
            if (rows[i].cells['hour']!.value == cellHour) {
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
            enableEditingMode: false,
            enableSorting: false,
            enableColumnDrag: false,
            enableContextMenu: false,
            enableDropToResize: false,
            textAlign: TrinaColumnTextAlign.center,
            titleTextAlign: TrinaColumnTextAlign.center,
            width: 134,
            renderer: _cellRenderer,
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

          for (var i = 0; i < length; i += 1) {
            if (rows[i].cells['minute']!.value == cellMinute) {
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
      mode: TrinaGridMode.popup,
      width: 276,
      height: 300,
      divider: const TrinaDualGridDivider(show: false),
    );
  }

  Widget _cellRenderer(TrinaColumnRendererContext renderContext) {
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
