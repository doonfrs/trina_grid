import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ColumnRendererScreen extends StatefulWidget {
  static const routeName = 'feature/column-renderer';

  const ColumnRendererScreen({super.key});

  @override
  _ColumnRendererScreenState createState() => _ColumnRendererScreenState();
}

class _ColumnRendererScreenState extends State<ColumnRendererScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'column1',
        field: 'column1',
        type: TrinaColumnType.text(),
        enableRowDrag: true,
        enableRowChecked: true,
        width: 250,
        minWidth: 175,
        renderer: (rendererContext) {
          return Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () {
                  rendererContext.stateManager.insertRows(
                    rendererContext.rowIdx,
                    [rendererContext.stateManager.getNewRow()],
                  );
                },
                iconSize: 18,
                color: Colors.green,
                padding: const EdgeInsets.all(0),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outlined),
                onPressed: () {
                  rendererContext.stateManager.removeRows([
                    rendererContext.row,
                  ]);
                },
                iconSize: 18,
                color: Colors.red,
                padding: const EdgeInsets.all(0),
              ),
              Expanded(
                child: Text(
                  rendererContext.row.cells[rendererContext.column.field]!.value
                      .toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
      TrinaColumn(
        title: 'column2',
        field: 'column2',
        type: TrinaColumnType.select(<String>['red', 'blue', 'green']),
        renderer: (rendererContext) {
          Color textColor = Colors.black;

          if (rendererContext.cell.value == 'red') {
            textColor = Colors.red;
          } else if (rendererContext.cell.value == 'blue') {
            textColor = Colors.blue;
          } else if (rendererContext.cell.value == 'green') {
            textColor = Colors.green;
          }

          return Text(
            rendererContext.cell.value.toString(),
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          );
        },
      ),
      TrinaColumn(
        title: 'column3',
        field: 'column3',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'column4',
        field: 'column4',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'column5',
        field: 'column5',
        type: TrinaColumnType.text(),
        enableEditingMode: false,
        renderer: (rendererContext) {
          return Image.asset('assets/images/cat.jpg');
        },
      ),
    ]);

    rows.addAll(DummyData.rowsByColumns(length: 15, columns: columns));
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Cell renderer',
      topTitle: 'Cell renderer',
      topContents: const [
        Text('You can change the widget of the cell through the renderer.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/cell_renderer_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onChanged: (TrinaGridOnChangedEvent event) {
          print(event);
        },
        onLoaded: (TrinaGridOnLoadedEvent event) {
          event.stateManager.setSelectingMode(TrinaGridSelectingMode.cell);

          stateManager = event.stateManager;
        },
        // configuration: TrinaConfiguration.dark(),
      ),
    );
  }
}
