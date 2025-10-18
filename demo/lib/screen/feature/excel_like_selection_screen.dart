import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ExcelLikeSelectionScreen extends StatefulWidget {
  static const routeName = 'feature/excel-like-selection';

  const ExcelLikeSelectionScreen({super.key});

  @override
  _ExcelLikeSelectionScreenState createState() =>
      _ExcelLikeSelectionScreenState();
}

class _ExcelLikeSelectionScreenState extends State<ExcelLikeSelectionScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  late TrinaGridStateManager stateManager;

  // Configuration state
  bool enableDragSelection = true;
  bool enableCtrlClickMultiSelect = true;
  int delayDurationMs = 100;

  // Available delay options
  final List<int> delayOptions = [50, 100, 150, 200, 250, 300, 400, 500];

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 100);

    columns.addAll(dummyData.columns);

    rows.addAll(dummyData.rows);
  }

  void handleSelected() async {
    String value = '';

    for (var element in stateManager.currentSelectingPositionList) {
      final cellValue = stateManager
          .rows[element.rowIdx!]
          .cells[element.field!]!
          .value
          .toString();

      value +=
          'rowIdx: ${element.rowIdx}, field: ${element.field}, value: $cellValue\n';
    }

    if (value.isEmpty) {
      value = 'No cells are selected.';
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          child: LayoutBuilder(
            builder: (ctx, size) {
              return Container(
                padding: const EdgeInsets.all(15),
                width: 400,
                height: 500,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Cells',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(value),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Excel-like Selection',
      topTitle: 'Excel-like Selection',
      topContents: const [
        Text(
          'Experience Excel-like cell selection with two powerful modes:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text('• Click and drag to select range (no long press needed)'),
        Text('• Ctrl+Click to select/deselect individual cells'),
        Text('• Shift+Click for range selection (also works)'),
        Text('• Click without modifiers to clear individual selections'),
        SizedBox(height: 8),
        Text(
          'Try it: Click and drag, then Ctrl+Click different cells to build a multi-selection!',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/excel_like_selection_screen.dart',
        ),
      ],
      body: Column(
        children: [
          // Configuration Controls
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configuration Controls:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Enable Drag Selection
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: enableDragSelection,
                          onChanged: (value) {
                            setState(() {
                              enableDragSelection = value;
                            });
                          },
                        ),
                        const SizedBox(width: 4),
                        const Text('Enable Drag Selection'),
                      ],
                    ),
                    // Enable Ctrl+Click
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: enableCtrlClickMultiSelect,
                          onChanged: (value) {
                            setState(() {
                              enableCtrlClickMultiSelect = value;
                            });
                          },
                        ),
                        const SizedBox(width: 4),
                        const Text('Enable Ctrl+Click Multi-Select'),
                      ],
                    ),
                    // Delay Duration Dropdown
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Delay: '),
                        DropdownButton<int>(
                          value: delayDurationMs,
                          items: delayOptions.map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text('${value}ms'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                delayDurationMs = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: handleSelected,
                    child: const Text('Show selected cells'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => stateManager.clearCurrentSelecting(),
                    child: const Text('Clear selection'),
                  ),
                ],
              ),
            ),
          ),
          // Grid
          Expanded(
            child: TrinaGrid(
              // Key forces grid rebuild when config changes
              key: ValueKey(
                'grid_${enableDragSelection}_${enableCtrlClickMultiSelect}_$delayDurationMs',
              ),
              columns: columns,
              rows: rows,
              onChanged: (TrinaGridOnChangedEvent event) {
                debugPrint('[Grid] Cell changed: ${event.value}');
              },
              onLoaded: (TrinaGridOnLoadedEvent event) {
                event.stateManager.setSelectingMode(
                  TrinaGridSelectingMode.cell,
                );

                stateManager = event.stateManager;
              },
              configuration: TrinaGridConfiguration(
                selectingMode: TrinaGridSelectingMode.cell,
                enableDragSelection: enableDragSelection,
                enableCtrlClickMultiSelect: enableCtrlClickMultiSelect,
                dragSelectionDelayDuration: Duration(
                  milliseconds: delayDurationMs,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
