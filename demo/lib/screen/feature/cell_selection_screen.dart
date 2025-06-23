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
          .rows[element.rowIdx!].cells[element.field!]!.value
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
    stateManager.setSelectingMode(mode);
    setState(() {
      currentSelectingMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Cell selection',
      topTitle: 'Cell selection',
      topContents: [
        Text(
          '''Available cell selection modes:
          Single tap: Select a cell or multiple cells with a single tap.
          Ctrl + Click: Select a cell or multiple cells with Ctrl + Click.
          Disabled: Disable cell selection.
          ''',
        ),
        Text(
          '''Range Selection:
          - Shift + Click: Select a range of cells from the currently selected cell to the clicked cell.
          - Long Press and Drag: Press and hold on a cell, then drag to select multiple consecutive cells.
          ''',
        ),
        SizedBox(
          width: double.infinity,
          child: OverflowBar(
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
