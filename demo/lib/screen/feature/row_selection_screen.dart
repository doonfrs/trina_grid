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

  String selectedValues = '';

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 100);

    columns.addAll(dummyData.columns);

    rows.addAll(dummyData.rows);
  }

  String _getSelectedValues(List<TrinaRow>? selectedRows) {
    if (selectedRows == null || selectedRows.isEmpty) {
      return 'No rows are selected.';
    }

    String value = '';
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
              '• CTRL + Click to select multiple rows.\n'
              '• Shift + Click to select a range of rows from the currently selected row to the clicked row.\n'
              '• Long Press and Drag to select multiple consecutive rows.',
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .2,
            ),
            SizedBox(
              height: 120,
              width: 300,
              child: Column(
                children: [
                  if (stateManager != null)
                    ListenableBuilder(
                      listenable: stateManager!,
                      builder: (context, asyncSnapshot) {
                        return Text(
                          'onSelected event - '
                          'Total selected rows: ${stateManager!.selectedRows.length} \n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  Flexible(
                    child: SizedBox(
                      width: 300,
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          primary: true,
                          reverse: true,
                          child: Text(selectedValues),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (stateManager != null)
          OverflowBar(
            alignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 180, child: Text('Programmatic control:')),
              ListenableBuilder(
                listenable: stateManager!,
                builder: (context, _) {
                  return Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 20,
                    children: [
                      SizedBox(
                        width: 250,
                        child: SwitchListTile(
                          title: Text('Enable selection'),
                          value: stateManager!.selectingMode.isRow,
                          onChanged: (flag) {
                            stateManager!.setSelectingMode(flag == true
                                ? TrinaGridSelectingMode.row
                                : TrinaGridSelectingMode.disabled);
                          },
                        ),
                      ),
                      FilledButton(
                        onPressed: stateManager!.selectedRows.isEmpty
                            ? null
                            : () {
                                stateManager!
                                  ..clearCurrentSelecting()
                                  ..handleOnSelected();
                              },
                        child: Text('Clear selection'),
                      ),
                    ],
                  );
                },
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
              configuration:
                  TrinaGridConfiguration(autoSetFirstCellAsCurrent: true),
              onLoaded: (TrinaGridOnLoadedEvent event) {
                event.stateManager.setSelectingMode(TrinaGridSelectingMode.row);
                setState(() {
                  stateManager = event.stateManager;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
