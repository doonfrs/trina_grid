import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

/// [TrinaGridPopup] calls [TrinaGrid] in the form of a popup.
class TrinaGridPopup {
  final BuildContext context;

  /// {@macro trina_grid_property_columns}
  final List<TrinaColumn> columns;

  /// {@macro trina_grid_property_rows}
  final List<TrinaRow> rows;

  /// {@macro trina_grid_property_columnGroups}
  final List<TrinaColumnGroup>? columnGroups;

  /// {@macro trina_grid_property_onLoaded}
  final TrinaOnLoadedEventCallback? onLoaded;

  /// {@macro trina_grid_property_onChanged}
  final TrinaOnChangedEventCallback? onChanged;

  /// {@macro trina_grid_property_onSelected}
  final TrinaOnSelectedEventCallback? onSelected;

  /// {@macro trina_grid_property_onSorted}
  final TrinaOnSortedEventCallback? onSorted;

  /// {@macro trina_grid_property_onRowChecked}
  final TrinaOnRowCheckedEventCallback? onRowChecked;

  /// {@macro trina_grid_property_onRowDoubleTap}
  final TrinaOnRowDoubleTapEventCallback? onRowDoubleTap;

  /// {@macro trina_grid_property_onRowSecondaryTap}
  final TrinaOnRowSecondaryTapEventCallback? onRowSecondaryTap;

  /// {@macro trina_grid_property_onRowsMoved}
  final TrinaOnRowsMovedEventCallback? onRowsMoved;

  /// {@macro trina_grid_property_onActiveCellChanged}
  final TrinaOnActiveCellChangedEventCallback? onActiveCellChanged;

  /// {@macro trina_grid_property_onColumnsMoved}
  final TrinaOnColumnsMovedEventCallback? onColumnsMoved;

  /// {@macro trina_grid_property_createHeader}
  final CreateHeaderCallBack? createHeader;

  /// {@macro trina_grid_property_createFooter}
  final CreateFooterCallBack? createFooter;

  /// {@macro trina_grid_property_noRowsWidget}
  final Widget? noRowsWidget;

  /// {@macro trina_grid_property_rowColorCallback}
  final TrinaRowColorCallback? rowColorCallback;

  /// {@macro trina_grid_property_columnMenuDelegate}
  final TrinaColumnMenuDelegate? columnMenuDelegate;

  /// {@macro trina_grid_property_configuration}
  final TrinaGridConfiguration configuration;

  /// Execution mode of [TrinaGrid].
  ///
  /// [TrinaGridMode.normal]
  /// {@macro trina_grid_mode_normal}

  /// [TrinaGridMode.popup]
  /// {@macro trina_grid_mode_popup}
  final TrinaGridMode mode;

  final double? width;

  final double? height;

  final bool? barrierDismissible;

  TrinaGridPopup({
    required this.context,
    required this.columns,
    required this.rows,
    this.columnGroups,
    this.onLoaded,
    this.onChanged,
    this.onSelected,
    this.onSorted,
    this.onRowChecked,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.onRowsMoved,
    this.onActiveCellChanged,
    this.onColumnsMoved,
    this.createHeader,
    this.createFooter,
    this.noRowsWidget,
    this.rowColorCallback,
    this.columnMenuDelegate,
    this.configuration = const TrinaGridConfiguration(),
    this.mode = TrinaGridMode.normal,
    this.width,
    this.height,
    this.barrierDismissible,
  }) {
    open();
  }

  setColumnConfig() {
    columns.map((element) {
      if (configuration.style.filterHeaderColor != null) {
        element.backgroundColor = configuration.style.filterHeaderColor!;
      }
    }).toList();
    return columns;
  }

  Future<void> open() async {
    final textDirection = Directionality.of(context);

    final borderRadius = configuration.style.gridBorderRadius.resolve(
      textDirection,
    );

    TrinaGridOnSelectedEvent? selected =
        await showDialog<TrinaGridOnSelectedEvent>(
            context: context,
            barrierDismissible: barrierDismissible ?? true,
            builder: (BuildContext ctx) {
              return Dialog(
                shape: borderRadius == BorderRadius.zero
                    ? null
                    : RoundedRectangleBorder(borderRadius: borderRadius),
                child: LayoutBuilder(
                  builder: (ctx, size) {
                    return SizedBox(
                      width: (width ?? size.maxWidth) +
                          TrinaGridSettings.gridInnerSpacing,
                      height: height ?? size.maxHeight,
                      child: Directionality(
                        textDirection: textDirection,
                        child: TrinaGrid(
                          columns: setColumnConfig(),
                          rows: rows,
                          columnGroups: columnGroups,
                          onLoaded: onLoaded,
                          onChanged: onChanged,
                          onSelected: (TrinaGridOnSelectedEvent event) {
                            Navigator.pop(ctx, event);
                          },
                          onSorted: onSorted,
                          onRowChecked: onRowChecked,
                          onRowDoubleTap: onRowDoubleTap,
                          onRowSecondaryTap: onRowSecondaryTap,
                          onRowsMoved: onRowsMoved,
                          onActiveCellChanged: onActiveCellChanged,
                          onColumnsMoved: onColumnsMoved,
                          createHeader: createHeader,
                          createFooter: createFooter,
                          noRowsWidget: noRowsWidget,
                          rowColorCallback: rowColorCallback,
                          columnMenuDelegate: columnMenuDelegate,
                          configuration: configuration,
                          mode: mode,
                        ),
                      ),
                    );
                  },
                ),
              );
            });
    if (onSelected != null && selected != null) {
      onSelected!(selected);
    }
  }
}
