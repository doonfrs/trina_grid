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

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Cell selection',
      topTitle: 'Cell selection',
      topContents: const [
        Text(
          'In cell selection mode, Shift + tap or long tap and then move to select cells.',
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
                event.stateManager.setSelectingMode(
                  TrinaGridSelectingMode.cell,
                );

                stateManager = event.stateManager;
              },
            ),
          ),
        ],
      ),
    );
  }
}
