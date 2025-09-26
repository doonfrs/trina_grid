import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ChangeTrackingScreen extends StatefulWidget {
  static const routeName = 'feature/change-tracking';

  const ChangeTrackingScreen({super.key});

  @override
  _ChangeTrackingScreenState createState() => _ChangeTrackingScreenState();
}

class _ChangeTrackingScreenState extends State<ChangeTrackingScreen> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];
  late TrinaGridStateManager stateManager;

  final ValueNotifier<bool> changeTrackingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<TrinaCell?> selectedCellNotifier =
      ValueNotifier<TrinaCell?>(null);
  final ValueNotifier<int> dirtyCountNotifier = ValueNotifier<int>(0);

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    changeTrackingNotifier.dispose();
    selectedCellNotifier.dispose();
    dirtyCountNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Create columns
    columns.addAll([
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.text(),
        width: 100,
        readOnly: true,
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        width: 150,
      ),
      TrinaColumn(
        title: 'Age',
        field: 'age',
        type: TrinaColumnType.number(),
        width: 80,
      ),
      TrinaColumn(
        title: 'Job',
        field: 'job',
        type: TrinaColumnType.text(),
        width: 200,
      ),
      TrinaColumn(
        title: 'Salary',
        field: 'salary',
        type: TrinaColumnType.currency(format: '#,###.##'),
        width: 150,
      ),
      TrinaColumn(
        title: 'Join Date',
        field: 'joinDate',
        type: TrinaColumnType.date(),
        width: 150,
      ),
    ]);

    // Create rows
    for (int i = 1; i <= 20; i++) {
      rows.add(
        TrinaRow(
          cells: {
            'id': TrinaCell(value: 'EMP-$i'),
            'name': TrinaCell(value: 'Employee $i'),
            'age': TrinaCell(value: 25 + (i % 20)),
            'job': TrinaCell(
              value: i % 3 == 0
                  ? 'Developer'
                  : (i % 3 == 1 ? 'Designer' : 'Manager'),
            ),
            'salary': TrinaCell(value: 50000 + (i * 1000)),
            'joinDate': TrinaCell(
              value: DateTime(2020, (i % 12) + 1, (i % 28) + 1),
            ),
          },
        ),
      );
    }
  }

  void toggleChangeTracking(bool flag) {
    if (_disposed) return;
    changeTrackingNotifier.value = flag;
    stateManager.setChangeTracking(flag);
    updateDirtyCount();
  }

  void commitChanges() {
    if (_disposed) return;
    stateManager.commitChanges();
    updateDirtyCount();
  }

  void revertChanges() {
    if (_disposed) return;
    stateManager.revertChanges();
    updateDirtyCount();
  }

  void commitSelectedCell() {
    if (_disposed) return;
    if (selectedCellNotifier.value != null) {
      stateManager.commitChanges(cell: selectedCellNotifier.value);
      updateDirtyCount();
    }
  }

  void revertSelectedCell() {
    if (_disposed) return;
    if (selectedCellNotifier.value != null) {
      stateManager.revertChanges(cell: selectedCellNotifier.value);
      updateDirtyCount();
    }
  }

  void updateDirtyCount() {
    if (_disposed) return;

    // Use Future.microtask to ensure we're not updating during build or dispose
    Future.microtask(() {
      if (_disposed) return;

      int count = 0;
      for (var row in rows) {
        for (var cell in row.cells.values) {
          if (cell.isDirty) {
            count++;
          }
        }
      }
      if (!_disposed) {
        dirtyCountNotifier.value = count;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Change Tracking',
      topTitle: 'Change Tracking',
      topContents: const [
        Text(
          'Track changes in cells and highlight dirty cells. You can commit or revert changes for all cells or just the selected cell.',
        ),
        SizedBox(height: 10),
        Text('1. Enable change tracking with the switch'),
        Text(
          '2. Edit some cells - they will be highlighted with a yellow background',
        ),
        Text('3. Use the buttons to commit or revert changes'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/change_tracking_screen.dart',
        ),
      ],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: changeTrackingNotifier,
                      builder: (context, isEnabled, _) {
                        return Switch(
                          value: isEnabled,
                          onChanged: toggleChangeTracking,
                        );
                      },
                    ),
                    const Text('Enable Change Tracking'),
                    const SizedBox(width: 20),
                    ValueListenableBuilder<int>(
                      valueListenable: dirtyCountNotifier,
                      builder: (context, count, _) {
                        return Text(
                          'Dirty Cells: $count',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: count > 0 ? Colors.orange : Colors.black,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<TrinaCell?>(
                  valueListenable: selectedCellNotifier,
                  builder: (context, selectedCell, _) {
                    return Row(
                      children: [
                        ElevatedButton(
                          onPressed: commitChanges,
                          child: const Text('Commit All Changes'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: revertChanges,
                          child: const Text('Revert All Changes'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: selectedCell != null
                              ? commitSelectedCell
                              : null,
                          child: const Text('Commit Selected Cell'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: selectedCell != null
                              ? revertSelectedCell
                              : null,
                          child: const Text('Revert Selected Cell'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onChanged: (TrinaGridOnChangedEvent event) {
                if (changeTrackingNotifier.value) {
                  updateDirtyCount();
                }
              },
              onLoaded: (TrinaGridOnLoadedEvent event) {
                event.stateManager.setSelectingMode(
                  TrinaGridSelectingMode.cell,
                );
                stateManager = event.stateManager;
              },
              onActiveCellChanged: (TrinaGridOnActiveCellChangedEvent event) {
                selectedCellNotifier.value = event.cell;
              },
              configuration: TrinaGridConfiguration(
                style: TrinaGridStyleConfig(cellDirtyColor: Colors.amber[100]!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
