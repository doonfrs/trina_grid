import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class CellSelectionScreen extends StatefulWidget {
  static const routeName = 'feature/cell-selection';

  const CellSelectionScreen({super.key});

  @override
  _CellSelectionScreenState createState() => _CellSelectionScreenState();
}

class _CellSelectionScreenState extends State<CellSelectionScreen> {
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

  String _getSelected(List<TrinaCell>? selectedCells) {
    if (selectedCells == null || selectedCells.isEmpty) {
      return 'No cells are selected.';
    }

    String value = '';
    for (var cell in selectedCells) {
      value +=
          'value: ${cell.value}, row: ${cell.row.sortIdx}, column: ${cell.column.field}\n';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Cell selection',
      topTitle: 'Cell selection',
      topContents: [
        OverflowBar(
          alignment: MainAxisAlignment.start,
          children: [
            Text(
              '''- Ctrl + Click: select multiple cells.
- Shift + Click: select a range of cells from the currently selected cell to the clicked cell.
- Long Press and Drag: press and hold on a cell, then drag to select multiple consecutive cells
           ''',
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
                          'Total selected cells: ${stateManager!.selectedCells.length} \n',
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
        OverflowBar(
          alignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 180, child: Text('Programmatic control:')),
            if (stateManager != null)
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
                          value: stateManager!.selectingMode.isCell,
                          onChanged: (flag) {
                            stateManager!.setSelectingMode(flag == true
                                ? TrinaGridSelectingMode.cell
                                : TrinaGridSelectingMode.disabled);
                          },
                        ),
                      ),
                      FilledButton(
                        onPressed: stateManager!.selectedCells.isEmpty
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
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/cell_selection_screen.dart',
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
                selectedValues = _getSelected(event.selectedCells);
              }),
              configuration: TrinaGridConfiguration(
                autoSetFirstCellAsCurrent: true,
                selectingMode: TrinaGridSelectingMode.cell,
              ),
              onLoaded: (TrinaGridOnLoadedEvent event) {
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
