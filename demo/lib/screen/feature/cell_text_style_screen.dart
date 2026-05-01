import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class CellTextStyleScreen extends StatefulWidget {
  static const routeName = 'feature/cell-text-style';

  const CellTextStyleScreen({super.key});

  @override
  State<CellTextStyleScreen> createState() => _CellTextStyleScreenState();
}

class _CellTextStyleScreenState extends State<CellTextStyleScreen> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];
  TrinaGridStateManager? stateManager;

  static const List<MapEntry<String, Color>> _colorOptions = [
    MapEntry('Red', Colors.red),
    MapEntry('Orange', Colors.orange),
    MapEntry('Green', Colors.green),
    MapEntry('Blue', Colors.blue),
    MapEntry('Purple', Colors.purple),
    MapEntry('Black', Colors.black),
  ];

  bool boldOverdueRows = true;
  int highPriorityColorIdx = 0; // Red
  int completedColorIdx = 2; // Green
  int negativeBudgetColorIdx = 0; // Red

  Color get _highPriorityColor => _colorOptions[highPriorityColorIdx].value;
  Color get _completedColor => _colorOptions[completedColorIdx].value;
  Color get _negativeBudgetColor => _colorOptions[negativeBudgetColorIdx].value;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.number(),
        width: 70,
      ),
      TrinaColumn(
        title: 'Task',
        field: 'task',
        type: TrinaColumnType.text(),
        width: 220,
      ),
      TrinaColumn(
        title: 'Priority',
        field: 'priority',
        type: TrinaColumnType.select(<String>['High', 'Medium', 'Low']),
        width: 110,
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
        title: 'Budget',
        field: 'budget',
        type: TrinaColumnType.currency(),
        width: 130,
      ),
      TrinaColumn(
        title: 'Due Date',
        field: 'due_date',
        type: TrinaColumnType.date(),
        width: 130,
      ),
    ]);

    final today = DateTime.now();
    rows.addAll([
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 1),
          'task': TrinaCell(value: 'Fix login bug'),
          'priority': TrinaCell(value: 'High'),
          'status': TrinaCell(value: 'Pending'),
          'budget': TrinaCell(value: 1500),
          'due_date': TrinaCell(value: today.subtract(const Duration(days: 3))),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 2),
          'task': TrinaCell(value: 'Update documentation'),
          'priority': TrinaCell(value: 'Low'),
          'status': TrinaCell(value: 'Completed'),
          'budget': TrinaCell(value: 600),
          'due_date': TrinaCell(value: today.subtract(const Duration(days: 8))),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 3),
          'task': TrinaCell(value: 'Implement new feature'),
          'priority': TrinaCell(value: 'Medium'),
          'status': TrinaCell(value: 'Pending'),
          'budget': TrinaCell(value: 4200),
          'due_date': TrinaCell(value: today.add(const Duration(days: 5))),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 4),
          'task': TrinaCell(value: 'Refund processing'),
          'priority': TrinaCell(value: 'High'),
          'status': TrinaCell(value: 'Pending'),
          'budget': TrinaCell(value: -250),
          'due_date': TrinaCell(value: today.subtract(const Duration(days: 1))),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 5),
          'task': TrinaCell(value: 'Code review'),
          'priority': TrinaCell(value: 'Medium'),
          'status': TrinaCell(value: 'Completed'),
          'budget': TrinaCell(value: 0),
          'due_date': TrinaCell(value: today.subtract(const Duration(days: 2))),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 6),
          'task': TrinaCell(value: 'Database migration'),
          'priority': TrinaCell(value: 'Low'),
          'status': TrinaCell(value: 'Cancelled'),
          'budget': TrinaCell(value: 800),
          'due_date': TrinaCell(value: today.add(const Duration(days: 10))),
        },
      ),
    ]);
  }

  bool _isOverdue(TrinaRow row) {
    final raw = row.cells['due_date']?.value;
    final status = row.cells['status']?.value;
    if (status == 'Completed' || status == 'Cancelled') return false;
    // TrinaColumnType.date() stores the cell value as the formatted string
    // ("yyyy-MM-dd" by default), so parse it back before comparing.
    final due = raw is DateTime
        ? raw
        : DateTime.tryParse(raw?.toString() ?? '');
    if (due == null) return false;
    return due.isBefore(DateTime.now());
  }

  Widget _colorDropdown(int selectedIdx, ValueChanged<int> onChanged) {
    return DropdownButton<int>(
      value: selectedIdx,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      items: _colorOptions.asMap().entries.map((entry) {
        return DropdownMenuItem<int>(
          value: entry.key,
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: entry.value.value,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(entry.value.key),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _controlRow(String label, Widget control) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 220, child: Text(label)),
          control,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Cell text style',
      topTitle: 'Cell text style',
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/cell_text_style_screen.dart',
        ),
      ],
      topContents: const [
        Text(
          'Customize the cell text style dynamically using rowTextStyleCallback and '
          'cellTextStyleCallback. Each callback returns a TextStyle (typically with '
          'just the fields you want to override) which is merged onto cellTextStyle.\n\n'
          'Merge order: cellTextStyle (base) → rowTextStyleCallback → cellTextStyleCallback.\n'
          'Cell-level styles win per-field. Returning null is a no-op.',
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Style settings',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _controlRow(
                      'Bold overdue rows (row-level):',
                      Switch(
                        value: boldOverdueRows,
                        onChanged: (v) {
                          setState(() => boldOverdueRows = v);
                          // Cells listen to the state manager, not to the
                          // parent's setState. Notify so they re-run the
                          // text-style callbacks immediately.
                          stateManager?.notifyListeners();
                        },
                      ),
                    ),
                    _controlRow(
                      'High priority text color (cell-level):',
                      _colorDropdown(highPriorityColorIdx, (i) {
                        setState(() => highPriorityColorIdx = i);
                        stateManager?.notifyListeners();
                      }),
                    ),
                    _controlRow(
                      'Completed status text color (cell-level):',
                      _colorDropdown(completedColorIdx, (i) {
                        setState(() => completedColorIdx = i);
                        stateManager?.notifyListeners();
                      }),
                    ),
                    _controlRow(
                      'Negative budget text color (cell-level):',
                      _colorDropdown(negativeBudgetColorIdx, (i) {
                        setState(() => negativeBudgetColorIdx = i);
                        stateManager?.notifyListeners();
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (event) =>
                  setState(() => stateManager = event.stateManager),
              rowTextStyleCallback: (context) {
                if (boldOverdueRows && _isOverdue(context.row)) {
                  return const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  );
                }
                return null;
              },
              cellTextStyleCallback: (context) {
                final field = context.column.field;
                final value = context.cell.value;

                if (field == 'priority' && value == 'High') {
                  return TextStyle(color: _highPriorityColor);
                }
                if (field == 'status' && value == 'Completed') {
                  return TextStyle(color: _completedColor);
                }
                if (field == 'status' && value == 'Cancelled') {
                  return const TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  );
                }
                if (field == 'budget' && value is num && value < 0) {
                  return TextStyle(color: _negativeBudgetColor);
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
