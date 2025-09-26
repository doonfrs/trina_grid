import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class RowSelectionScreen extends StatefulWidget {
  static const routeName = 'feature/row-selection';

  const RowSelectionScreen({super.key});

  @override
  _RowSelectionScreenState createState() => _RowSelectionScreenState();
}

class _RowSelectionScreenState extends State<RowSelectionScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  TrinaGridStateManager? stateManager;

  // Debug info for onSelected callback
  String _selectedInfo = 'No selection event fired yet';
  int _selectionEventCount = 0;

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 100);

    columns.addAll(dummyData.columns);

    rows.addAll(dummyData.rows);
  }

  void handleSelected() async {
    String value = '';

    for (var element in stateManager!.currentSelectingRows) {
      final cellValue = element.cells.entries.first.value.value.toString();

      value += 'first cell value of row: $cellValue\n';
    }

    if (value.isEmpty) {
      value = 'No rows are selected.';
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
                    children: [Text(value)],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _onRowSelected(TrinaGridOnSelectedEvent event) {
    setState(() {
      _selectionEventCount++;
      String info = 'onSelected Event #$_selectionEventCount fired!\n';
      info += 'Row: ${event.row?.key}\n';
      info += 'Row Index: ${event.rowIdx}\n';
      info += 'Cell: ${event.cell?.key}\n';
      info += 'Selected Rows Count: ${event.selectedRows?.length ?? 0}\n';
      info +=
          'Current Selecting Rows: ${stateManager?.currentSelectingRows.length ?? 0}\n';
      if (event.selectedRows != null && event.selectedRows!.isNotEmpty) {
        info +=
            'Selected Row Keys: ${event.selectedRows!.map((r) => r.key).toList()}\n';
      }
      if (stateManager != null &&
          stateManager!.currentSelectingRows.isNotEmpty) {
        info +=
            'Currently Selecting Row Keys: ${stateManager!.currentSelectingRows.map((r) => r.key).toList()}\n';
      }
      _selectedInfo = info;
    });

    print(
      'onSelected callback fired: rowIdx=${event.rowIdx}, selectedRowsCount=${event.selectedRows?.length}, currentSelectingCount=${stateManager?.currentSelectingRows.length}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Row selection',
      topTitle: 'Row selection',
      topContents: [
        const Text(
          'In Row selection mode, Shift + tap or long tap and then move or Control + tap to select a row.',
        ),
        const Text(
          'onSelected callback now fires in Normal mode too! Try tapping rows, Ctrl+click, Shift+click, long press, or pressing Enter.',
        ),
        const SizedBox(height: 8),
        Text(
          'onSelected Event Status: $_selectedInfo',
          style: const TextStyle(fontSize: 12, color: Colors.blue),
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/row_selection_screen.dart',
        ),
      ],
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                TextButton(
                  onPressed: handleSelected,
                  child: const Text('Show selected rows.'),
                ),
              ],
            ),
          ),
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              // Now onSelected works in normal mode too!
              onChanged: (TrinaGridOnChangedEvent event) {
                print(event);
              },
              onSelected: _onRowSelected, // Add the onSelected callback
              onLoaded: (TrinaGridOnLoadedEvent event) {
                event.stateManager.setSelectingMode(TrinaGridSelectingMode.row);

                stateManager = event.stateManager;
              },
            ),
          ),
        ],
      ),
    );
  }
}
