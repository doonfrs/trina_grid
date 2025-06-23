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
  TrinaGridSelectingMode currentSelectingMode =
      TrinaGridSelectingMode.rowWithSingleTap;

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 100);

    columns.addAll(dummyData.columns);

    rows.addAll(dummyData.rows);
  }

  void handleSelected() async {
    String value = '';

    for (var element in stateManager!.selectedRows) {
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
                      children: [
                        Text(value),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  void changeSelectingMode(TrinaGridSelectingMode? mode) {
    if (mode == null) {
      return;
    }
    stateManager!.setSelectingMode(mode);
    setState(() {
      currentSelectingMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Row selection',
      topTitle: 'Row selection',
      topContents: [
        Text(
          'In Row selection mode:\n'
          '• CTRL + Click to select a single row or multiple rows.\n'
          '• Single tap to select a single row or multiple rows.\n'
          '• Shift + tap or long press & drag to select a range.',
        ),
        OverflowBar(
          children: [
            Text('Choose selecting mode:'),
            SizedBox(
              width: 200,
              child: RadioListTile(
                value: TrinaGridSelectingMode.rowWithSingleTap,
                groupValue: currentSelectingMode,
                onChanged: changeSelectingMode,
                title: const Text('Single tap'),
              ),
            ),
            SizedBox(
              width: 200,
              child: RadioListTile(
                value: TrinaGridSelectingMode.rowWithCtrl,
                groupValue: currentSelectingMode,
                onChanged: changeSelectingMode,
                title: const Text('Ctrl + Click'),
              ),
            ),
          ],
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
              onChanged: (TrinaGridOnChangedEvent event) {
                print(event);
              },
              onLoaded: (TrinaGridOnLoadedEvent event) {
                event.stateManager
                    .setSelectingMode(TrinaGridSelectingMode.rowWithSingleTap);

                stateManager = event.stateManager;
              },
            ),
          ),
        ],
      ),
    );
  }
}
