import 'dart:math';

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

  late TrinaGridStateManager stateManager;

  TrinaGridSelectingMode currentSelectingMode =
      TrinaGridSelectingMode.cellWithSingleTap;

  String selectedValues = '';

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 100);

    columns.addAll(dummyData.columns);

    rows.addAll(dummyData.rows);
  }

  void handleSelected() async {
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
                        Text(selectedValues),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
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

  void changeSelectingMode(TrinaGridSelectingMode? mode) {
    if (mode == null) {
      return;
    }
    stateManager.setSelectingMode(mode);
    setState(() {
      currentSelectingMode = mode;
      selectedValues = _getSelected(stateManager.selectedCells);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Cell selection',
      topTitle: 'Cell selection',
      topContents: [
        OverflowBar(
          alignment: MainAxisAlignment.start,
          // overflowSpacing: 10,
          children: [
            Text(
              '''Range Selection:
          - Shift + Click: Select a range of cells from the currently selected cell to the clicked cell.
          - Long Press and Drag: Press and hold on a cell, then drag to select multiple consecutive cells.
          ''',
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .2,
            ),
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'onSelected output (Scroll if needed):\n',
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
          alignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 200, child: Text('Choose selecting mode:')),
            SizedBox(
              width: 200,
              child: RadioListTile(
                value: TrinaGridSelectingMode.cellWithSingleTap,
                groupValue: currentSelectingMode,
                onChanged: changeSelectingMode,
                title: const Text('Single tap'),
              ),
            ),
            SizedBox(
              width: 200,
              child: RadioListTile(
                value: TrinaGridSelectingMode.cellWithCtrl,
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
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/cell_selection_screen.dart',
        ),
      ],
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: handleSelected,
                  child: const Text('Show selected cells.'),
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
              onSelected: (event) => setState(() {
                selectedValues = _getSelected(event.selectedCells);
              }),
              configuration:
                  TrinaGridConfiguration(autoSetFirstCellAsCurrent: true),
              onLoaded: (TrinaGridOnLoadedEvent event) {
                event.stateManager
                    .setSelectingMode(TrinaGridSelectingMode.cellWithSingleTap);

                stateManager = event.stateManager;
                setState(() {
                  currentSelectingMode = stateManager.selectingMode;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
