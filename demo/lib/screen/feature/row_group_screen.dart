import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_screen.dart';

class RowGroupScreen extends StatefulWidget {
  static const routeName = 'feature/row-group';

  const RowGroupScreen({super.key});

  @override
  _RowGroupScreenState createState() => _RowGroupScreenState();
}

class _RowGroupScreenState extends State<RowGroupScreen> {
  final List<TrinaColumn> columnsA = [];

  final List<TrinaRow> rowsA = [];

  final List<TrinaColumn> columnsB = [];

  final List<TrinaRow> rowsB = [];

  late TrinaGridStateManager stateManagerA;
  late TrinaGridStateManager stateManagerB;

  @override
  void initState() {
    super.initState();

    columnsA.addAll([
      TrinaColumn(
        title: 'Planets',
        field: 'planets',
        type: TrinaColumnType.select([
          'Mercury',
          'Venus',
          'Earth',
          'Mars',
          'Jupiter',
          'Saturn',
          'Uranus',
          'Neptune',
          'Trina',
        ]),
      ),
      TrinaColumn(title: 'Users', field: 'users', type: TrinaColumnType.text()),
      TrinaColumn(title: 'Date', field: 'date', type: TrinaColumnType.date()),
      TrinaColumn(title: 'Time', field: 'time', type: TrinaColumnType.time()),
    ]);

    rowsA.addAll(DummyData.rowsByColumns(length: 100, columns: columnsA));

    columnsB.addAll([
      TrinaColumn(
        title: 'Files',
        field: 'files',
        type: TrinaColumnType.text(),
        renderer: (c) {
          IconData icon = c.row.type.isGroup
              ? Icons.folder
              : Icons.file_present;
          return Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 10),
              Text(c.cell.value),
            ],
          );
        },
      ),
    ]);

    rowsB.addAll([
      TrinaRow(
        cells: {'files': TrinaCell(value: 'TrinaGrid')},
        type: TrinaRowType.group(
          children: FilteredList<TrinaRow>(
            initialList: [
              TrinaRow(
                cells: {'files': TrinaCell(value: 'lib')},
                type: TrinaRowType.group(
                  children: FilteredList<TrinaRow>(
                    initialList: [
                      TrinaRow(
                        cells: {'files': TrinaCell(value: 'src')},
                        type: TrinaRowType.group(
                          children: FilteredList<TrinaRow>(
                            initialList: [
                              TrinaRow(
                                cells: {
                                  'files': TrinaCell(value: 'trina_grid.dart'),
                                },
                              ),
                              TrinaRow(
                                cells: {
                                  'files': TrinaCell(
                                    value: 'trina_dual_grid.dart',
                                  ),
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TrinaRow(
                cells: {'files': TrinaCell(value: 'test')},
                type: TrinaRowType.group(
                  children: FilteredList<TrinaRow>(
                    initialList: [
                      TrinaRow(
                        cells: {
                          'files': TrinaCell(value: 'trina_grid_test.dart'),
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Row group',
      topTitle: 'Row group',
      topContents: const [Text('Grouping rows in a column or tree structure.')],
      topButtons: [
        ElevatedButton.icon(
          onPressed: () {
            if (mounted) {
              stateManagerA.expandAllRowGroups();
              stateManagerB.expandAllRowGroups();
            }
          },
          icon: Icon(Icons.unfold_more),
          label: const Text('Expand All'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () {
            if (mounted) {
              stateManagerA.collapseAllRowGroups();
              stateManagerB.collapseAllRowGroups();
            }
          },
          icon: Icon(Icons.unfold_less),
          label: const Text('Collapse All'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () {
            if (mounted) {
              if (stateManagerA.currentRow != null) {
                stateManagerA.toggleExpandedRowGroup(
                  rowGroup: stateManagerA.currentRow!,
                );
              }
              if (stateManagerB.currentRow != null) {
                stateManagerB.toggleExpandedRowGroup(
                  rowGroup: stateManagerB.currentRow!,
                );
              }
            }
          },
          icon: Icon(Icons.unfold_less),
          label: const Text('Toggle Selected'),
        ),
      ],
      body: TrinaDualGrid(
        gridPropsA: TrinaDualGridProps(
          columns: columnsA,
          rows: rowsA,
          configuration: const TrinaGridConfiguration(
            style: TrinaGridStyleConfig(cellColorGroupedRow: Color(0x80F6F6F6)),
          ),
          onLoaded: (e) {
            stateManagerA = e.stateManager;
            e.stateManager.setRowGroup(
              TrinaRowGroupByColumnDelegate(
                columns: [columnsA[0], columnsA[1]],
                showFirstExpandableIcon: false,
              ),
            );
          },
        ),
        gridPropsB: TrinaDualGridProps(
          columns: columnsB,
          rows: rowsB,
          configuration: const TrinaGridConfiguration(
            style: TrinaGridStyleConfig(cellColorGroupedRow: Color(0x80F6F6F6)),
            columnSize: TrinaGridColumnSizeConfig(
              autoSizeMode: TrinaAutoSizeMode.equal,
            ),
          ),
          onLoaded: (e) {
            stateManagerB = e.stateManager;
            e.stateManager.setRowGroup(
              TrinaRowGroupTreeDelegate(
                resolveColumnDepth: (column) =>
                    e.stateManager.columnIndex(column),
                showText: (cell) => true,
                showFirstExpandableIcon: true,
              ),
            );
          },
        ),
      ),
    );
  }
}
