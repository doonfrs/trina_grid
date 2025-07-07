import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ColumnFooterScreen extends StatefulWidget {
  static const routeName = 'feature/column-footer';

  const ColumnFooterScreen({super.key});

  @override
  _ColumnFooterScreenState createState() => _ColumnFooterScreenState();
}

class _ColumnFooterScreenState extends State<ColumnFooterScreen> {
  late List<TrinaColumn> columns;

  late List<TrinaRow> rows;

  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns = [
      TrinaColumn(
        title: 'column1',
        field: 'column1',
        type: TrinaColumnType.text(),
        enableRowChecked: true,
        footerRenderer: (rendererContext) {
          return TrinaAggregateColumnFooter(
            rendererContext: rendererContext,
            type: TrinaAggregateColumnType.count,
            numberFormat: NumberFormat('Checked : #,###.###'),
            filter: (cell) => cell.row.checked == true,
            alignment: Alignment.center,
          );
        },
      ),
      TrinaColumn(
        title: 'column2',
        field: 'column2',
        type: TrinaColumnType.number(),
        textAlign: TrinaColumnTextAlign.end,
        footerRenderer: (rendererContext) {
          return TrinaAggregateColumnFooter(
            rendererContext: rendererContext,
            type: TrinaAggregateColumnType.sum,
            numberFormat: NumberFormat('#,###'),
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(
                  text: 'Sum',
                  style: TextStyle(color: Colors.red),
                ),
                const TextSpan(text: ' : '),
                TextSpan(text: text),
              ];
            },
          );
        },
      ),
      TrinaColumn(
        title: 'column3',
        field: 'column3',
        type: TrinaColumnType.number(format: '#,###.###'),
        textAlign: TrinaColumnTextAlign.right,
        footerRenderer: (rendererContext) {
          return TrinaAggregateColumnFooter(
            rendererContext: rendererContext,
            type: TrinaAggregateColumnType.average,
            numberFormat: NumberFormat('#,###.###'),
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(text: 'Average : '),
                TextSpan(text: text),
              ];
            },
          );
        },
      ),
      TrinaColumn(
        title: 'column4',
        field: 'column4',
        type: TrinaColumnType.number(),
        textAlign: TrinaColumnTextAlign.right,
        footerRenderer: (rendererContext) {
          return TrinaAggregateColumnFooter(
            rendererContext: rendererContext,
            type: TrinaAggregateColumnType.min,
            numberFormat: NumberFormat('#,###'),
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(text: 'Min : '),
                TextSpan(text: text),
              ];
            },
          );
        },
      ),
      TrinaColumn(
        title: 'column5',
        field: 'column5',
        type: TrinaColumnType.number(),
        textAlign: TrinaColumnTextAlign.right,
        footerRenderer: (rendererContext) {
          return TrinaAggregateColumnFooter(
            rendererContext: rendererContext,
            type: TrinaAggregateColumnType.max,
            numberFormat: NumberFormat('#,###'),
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(text: 'Max : '),
                TextSpan(text: text),
              ];
            },
          );
        },
      ),
      TrinaColumn(
        title: 'column6',
        field: 'column6',
        type: TrinaColumnType.select(['Android', 'iOS', 'Windows', 'Linux']),
        footerRenderer: (rendererContext) {
          return TrinaAggregateColumnFooter(
            rendererContext: rendererContext,
            type: TrinaAggregateColumnType.count,
            filter: (cell) => cell.value == 'Android',
            numberFormat: NumberFormat('Android : #,###'),
            alignment: Alignment.center,
          );
        },
      ),
    ];

    rows = DummyData.rowsByColumns(length: 100, columns: columns);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Column footer',
      topTitle: 'Column footer',
      topContents: const [
        Text(
            'Implement TrinaColumn \'s footerRenderer callback to display information such as sum, average, min, max, etc.'),
        Text(
            'You can easily implement it with the built-in TrinaAggregateColumnFooter plugin widget, or return the widget you want as a callback return value.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/column_footer_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onChanged: (TrinaGridOnChangedEvent event) {
          print(event);
        },
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setSelectingMode(TrinaGridSelectingMode.cellWithCtrl);
          stateManager.setShowColumnFilter(true);
        },
        configuration: const TrinaGridConfiguration(),
      ),
    );
  }
}
