import 'dart:async';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class DualModeScreen extends StatefulWidget {
  static const routeName = 'feature/dual-mode';

  const DualModeScreen({super.key});

  @override
  _DualModeScreenState createState() => _DualModeScreenState();
}

class _DualModeScreenState extends State<DualModeScreen> {
  final List<TrinaColumn> gridAColumns = [];

  final List<TrinaRow> gridARows = [];

  final List<TrinaColumn> gridBColumns = [];

  final List<TrinaRow> gridBRows = [];

  late TrinaGridStateManager gridAStateManager;

  late TrinaGridStateManager gridBStateManager;

  bool isVertical = false;

  Key? currentRowKey;

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    gridAColumns.addAll([
      TrinaColumn(
        title: 'Username',
        field: 'username',
        type: TrinaColumnType.text(),
        enableRowChecked: true,
      ),
      TrinaColumn(
        title: 'Point',
        field: 'point',
        type: TrinaColumnType.number(),
      ),
      TrinaColumn(
        title: 'grade',
        field: 'grade',
        type: TrinaColumnType.select(<String>['A', 'B', 'C']),
      ),
    ]);

    gridARows.addAll(
      DummyData.rowsByColumns(length: 30, columns: gridAColumns),
    );

    gridBColumns.addAll([
      TrinaColumn(
        title: 'Activity',
        field: 'activity',
        type: TrinaColumnType.text(),
        enableRowChecked: true,
      ),
      TrinaColumn(title: 'Date', field: 'date', type: TrinaColumnType.date()),
      TrinaColumn(title: 'Time', field: 'time', type: TrinaColumnType.time()),
    ]);
  }

  void gridAHandler() {
    if (gridAStateManager.currentRow == null) {
      return;
    }

    if (gridAStateManager.currentRow!.key != currentRowKey) {
      currentRowKey = gridAStateManager.currentRow!.key;

      gridBStateManager.setShowLoading(true);

      fetchUserActivity();
    }
  }

  void fetchUserActivity() {
    // This is just an example to reproduce the server load time.
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          final rows = DummyData.rowsByColumns(
            length: faker.randomGenerator.integer(10, min: 1),
            columns: gridBColumns,
          );

          gridBStateManager.removeRows(gridBStateManager.rows);
          gridBStateManager.resetCurrentState();
          gridBStateManager.appendRows(rows);
        });

        gridBStateManager.setShowLoading(false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Dual mode',
      topTitle: 'Dual mode',
      topContents: [
        Text(
          'Place the grid on the left and right and move or edit with the keyboard.',
        ),
        Text('Refer to the display property for the width of the grid.'),
        Text(
          'This is an example in which the right list is randomly generated whenever the current row of the left grid changes.',
        ),
        Row(
          children: [
            Switch(
              value: isVertical,
              onChanged: (bool value) {
                setState(() {
                  isVertical = value;
                });
              },
            ),
            Text('Toggle to switch between vertical and horizontal mode'),
          ],
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/dual_mode_screen.dart',
        ),
      ],
      body: TrinaDualGrid(
        isVertical: isVertical,
        gridPropsA: TrinaDualGridProps(
          columns: gridAColumns,
          rows: gridARows,
          onChanged: (TrinaGridOnChangedEvent event) {
            print(event);
          },
          onLoaded: (TrinaGridOnLoadedEvent event) {
            gridAStateManager = event.stateManager;
            event.stateManager.addListener(gridAHandler);
          },
          onSorted: (TrinaGridOnSortedEvent event) {
            print('Grid A : $event');
          },
          onRowChecked: (TrinaGridOnRowCheckedEvent event) {
            print('Grid A : $event');
          },
          configuration: const TrinaGridConfiguration(
            style: TrinaGridStyleConfig(
              enableColumnBorderVertical: false,
              enableCellBorderVertical: false,
            ),
            columnSize: TrinaGridColumnSizeConfig(
              autoSizeMode: TrinaAutoSizeMode.scale,
              resizeMode: TrinaResizeMode.pushAndPull,
            ),
          ),
        ),
        gridPropsB: TrinaDualGridProps(
          columns: gridBColumns,
          rows: gridBRows,
          onChanged: (TrinaGridOnChangedEvent event) {
            print(event);
          },
          onLoaded: (TrinaGridOnLoadedEvent event) {
            gridBStateManager = event.stateManager;
          },
          onSorted: (TrinaGridOnSortedEvent event) {
            print('Grid B : $event');
          },
          onRowChecked: (TrinaGridOnRowCheckedEvent event) {
            print('Grid B : $event');
          },
          configuration: const TrinaGridConfiguration(
            style: TrinaGridStyleConfig(
              enableColumnBorderVertical: false,
              enableCellBorderVertical: false,
            ),
            columnSize: TrinaGridColumnSizeConfig(
              autoSizeMode: TrinaAutoSizeMode.scale,
              resizeMode: TrinaResizeMode.pushAndPull,
            ),
          ),
        ),
        display: TrinaDualGridDisplayRatio(ratio: 0.5),
      ),
    );
  }
}
