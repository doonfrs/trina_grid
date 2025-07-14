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

  String selectedValues = '';

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 100);

    columns.addAll(dummyData.columns);

    rows.addAll(dummyData.rows);
  }

  void changeSelectingMode(TrinaGridSelectingMode? mode) {
    if (mode == null) {
      return;
    }
    stateManager!.setSelectingMode(mode);
    setState(() {
      currentSelectingMode = mode;
      selectedValues = _getSelectedValues(stateManager!.selectedRows);
    });
  }

  String _getSelectedValues(List<TrinaRow>? selectedRows) {
    if (selectedRows == null || selectedRows.isEmpty) {
      return 'No rows are selected.';
    }

    String value = 'Total selected rows: ${selectedRows.length} \n';
    for (var row in selectedRows) {
      value += 'rowIdx: ${row.sortIdx}\n';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Row selection',
      topTitle: 'Row selection',
      topContents: [
        OverflowBar(
          overflowSpacing: 10,
          alignment: MainAxisAlignment.start,
          children: [
            Text(
              'In Row selection mode:\n'
              '• CTRL + Click to select a single row or multiple rows.\n'
              '• Single tap to select a single row or multiple rows.\n'
              '• Shift + tap or long press & drag to select a range.',
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .3,
            ),
            SizedBox(
              child: Column(
                children: [
                  Text(
                    'onSelected output (Scroll if you need):\n',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 100,
                    width: 300,
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        primary: true,
                        child: Text(selectedValues),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            SizedBox(
              width: 200,
              child: RadioListTile(
                value: TrinaGridSelectingMode.disabled,
                groupValue: currentSelectingMode,
                onChanged: changeSelectingMode,
                title: const Text('Disabled'),
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
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onChanged: (TrinaGridOnChangedEvent event) {
                print(event);
              },
              onSelected: (event) => setState(() {
                selectedValues = _getSelectedValues(event.selectedRows);
              }),
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
