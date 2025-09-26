import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class CellColorScreen extends StatefulWidget {
  static const routeName = 'feature/cell-color';

  const CellColorScreen({super.key});

  @override
  _CellColorScreenState createState() => _CellColorScreenState();
}

class _CellColorScreenState extends State<CellColorScreen> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];
  TrinaGridStateManager? stateManager;

  // Define color options with names for identification
  final List<Map<String, dynamic>> colorOptions = [
    {'name': 'Light Blue', 'color': Colors.lightBlue[100]!},
    {'name': 'Light Green', 'color': Colors.lightGreen[100]!},
    {'name': 'Light Orange', 'color': Colors.orange[100]!},
    {'name': 'Light Red', 'color': Colors.red[100]!},
    {'name': 'Light Purple', 'color': Colors.purple[100]!},
    {'name': 'Light Yellow', 'color': Colors.yellow[100]!},
    {'name': 'Light Pink', 'color': Colors.pink[100]!},
    {'name': 'Light Cyan', 'color': Colors.cyan[100]!},
    {'name': 'Transparent', 'color': Colors.transparent},
  ];

  // Color selections for different cell values
  int selectedHighPriorityColorIndex = 3; // Light Red
  int selectedMediumPriorityColorIndex = 1; // Light Green
  int selectedLowPriorityColorIndex = 0; // Light Blue
  int selectedCompletedColorIndex = 1; // Light Green
  int selectedPendingColorIndex = 5; // Light Yellow
  int selectedCancelledColorIndex = 7; // Light Cyan

  Color get highPriorityColor =>
      colorOptions[selectedHighPriorityColorIndex]['color'];
  Color get mediumPriorityColor =>
      colorOptions[selectedMediumPriorityColorIndex]['color'];
  Color get lowPriorityColor =>
      colorOptions[selectedLowPriorityColorIndex]['color'];
  Color get completedColor =>
      colorOptions[selectedCompletedColorIndex]['color'];
  Color get pendingColor => colorOptions[selectedPendingColorIndex]['color'];
  Color get cancelledColor =>
      colorOptions[selectedCancelledColorIndex]['color'];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.number(),
        width: 80,
      ),
      TrinaColumn(
        title: 'Task',
        field: 'task',
        type: TrinaColumnType.text(),
        width: 200,
      ),
      TrinaColumn(
        title: 'Priority',
        field: 'priority',
        type: TrinaColumnType.select(<String>['High', 'Medium', 'Low']),
        width: 120,
      ),
      TrinaColumn(
        title: 'Status',
        field: 'status',
        type: TrinaColumnType.select(<String>[
          'Completed',
          'Pending',
          'Cancelled',
        ]),
        width: 120,
      ),
      TrinaColumn(
        title: 'Assignee',
        field: 'assignee',
        type: TrinaColumnType.text(),
        width: 150,
      ),
      TrinaColumn(
        title: 'Due Date',
        field: 'due_date',
        type: TrinaColumnType.date(),
        width: 130,
      ),
    ]);

    rows.addAll([
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 1),
          'task': TrinaCell(value: 'Fix login bug'),
          'priority': TrinaCell(value: 'High'),
          'status': TrinaCell(value: 'Pending'),
          'assignee': TrinaCell(value: 'John Doe'),
          'due_date': TrinaCell(value: DateTime(2024, 3, 15)),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 2),
          'task': TrinaCell(value: 'Update documentation'),
          'priority': TrinaCell(value: 'Low'),
          'status': TrinaCell(value: 'Completed'),
          'assignee': TrinaCell(value: 'Jane Smith'),
          'due_date': TrinaCell(value: DateTime(2024, 3, 10)),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 3),
          'task': TrinaCell(value: 'Implement new feature'),
          'priority': TrinaCell(value: 'Medium'),
          'status': TrinaCell(value: 'Pending'),
          'assignee': TrinaCell(value: 'Bob Wilson'),
          'due_date': TrinaCell(value: DateTime(2024, 3, 20)),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 4),
          'task': TrinaCell(value: 'Code review'),
          'priority': TrinaCell(value: 'High'),
          'status': TrinaCell(value: 'Completed'),
          'assignee': TrinaCell(value: 'Alice Brown'),
          'due_date': TrinaCell(value: DateTime(2024, 3, 5)),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 5),
          'task': TrinaCell(value: 'Database migration'),
          'priority': TrinaCell(value: 'Medium'),
          'status': TrinaCell(value: 'Cancelled'),
          'assignee': TrinaCell(value: 'Charlie Davis'),
          'due_date': TrinaCell(value: DateTime(2024, 3, 25)),
        },
      ),
    ]);
  }

  Widget _buildColorSelector(
    String label,
    int selectedIndex,
    Function(int) onChanged,
  ) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label)),
        DropdownButton<int>(
          value: selectedIndex,
          onChanged: (int? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items: colorOptions.asMap().entries.map<DropdownMenuItem<int>>((
            entry,
          ) {
            int index = entry.key;
            Map<String, dynamic> colorOption = entry.value;
            return DropdownMenuItem<int>(
              value: index,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colorOption['color'],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(colorOption['name']),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Cell Color',
      topTitle: 'Cell Color',
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/cell_color_screen.dart',
        ),
      ],
      topContents: [
        const Text(
          'Cell color can be changed dynamically according to cell values using cellColorCallback.\n'
          'This example shows how to color cells based on Priority and Status values.',
        ),
      ],
      body: Column(
        children: [
          // Color controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Color Settings:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Priority Colors:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              _buildColorSelector(
                                'High Priority:',
                                selectedHighPriorityColorIndex,
                                (index) {
                                  setState(() {
                                    selectedHighPriorityColorIndex = index;
                                  });
                                },
                              ),
                              _buildColorSelector(
                                'Medium Priority:',
                                selectedMediumPriorityColorIndex,
                                (index) {
                                  setState(() {
                                    selectedMediumPriorityColorIndex = index;
                                  });
                                },
                              ),
                              _buildColorSelector(
                                'Low Priority:',
                                selectedLowPriorityColorIndex,
                                (index) {
                                  setState(() {
                                    selectedLowPriorityColorIndex = index;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status Colors:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              _buildColorSelector(
                                'Completed:',
                                selectedCompletedColorIndex,
                                (index) {
                                  setState(() {
                                    selectedCompletedColorIndex = index;
                                  });
                                },
                              ),
                              _buildColorSelector(
                                'Pending:',
                                selectedPendingColorIndex,
                                (index) {
                                  setState(() {
                                    selectedPendingColorIndex = index;
                                  });
                                },
                              ),
                              _buildColorSelector(
                                'Cancelled:',
                                selectedCancelledColorIndex,
                                (index) {
                                  setState(() {
                                    selectedCancelledColorIndex = index;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Grid
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              configuration: TrinaGridConfiguration(
                style: TrinaGridStyleConfig(
                  // Set a default activated color
                  activatedColor: Colors.blue[50]!,
                  activatedBorderColor: Colors.blue[300]!,
                ),
              ),
              onChanged: (TrinaGridOnChangedEvent event) {
                print('Cell changed: ${event.value}');
              },
              onLoaded: (TrinaGridOnLoadedEvent event) {
                setState(() {
                  stateManager = event.stateManager;
                });
              },
              mode: TrinaGridMode.selectWithOneTap,
              cellColorCallback: (TrinaCellColorContext context) {
                // Color cells based on their column and value
                if (context.column.field == 'priority') {
                  final priority = context.cell.value;
                  if (priority == 'High') {
                    return highPriorityColor;
                  } else if (priority == 'Medium') {
                    return mediumPriorityColor;
                  } else if (priority == 'Low') {
                    return lowPriorityColor;
                  }
                } else if (context.column.field == 'status') {
                  final status = context.cell.value;
                  if (status == 'Completed') {
                    return completedColor;
                  } else if (status == 'Pending') {
                    return pendingColor;
                  } else if (status == 'Cancelled') {
                    return cancelledColor;
                  }
                }

                // Return null for default color for other cells
                return null;
              },
              onSelected: (TrinaGridOnSelectedEvent event) {
                print('Cell selected: ${event.cell?.value}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
