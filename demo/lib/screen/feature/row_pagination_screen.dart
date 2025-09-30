import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class RowPaginationScreen extends StatefulWidget {
  static const routeName = 'feature/row-pagination';

  const RowPaginationScreen({super.key});

  @override
  _RowPaginationScreenState createState() => _RowPaginationScreenState();
}

class _RowPaginationScreenState extends State<RowPaginationScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  bool showTotalRows = true;
  bool enableGotoPage = true;

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 5000);

    columns.addAll(dummyData.columns);

    rows.addAll(dummyData.rows);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Row pagination',
      topTitle: 'Row pagination',
      topContents: [
        const Text(
          'If you pass the built-in TrinaPagination widget as the return value of the createFooter callback when creating a grid, pagination is processed.',
        ),
        const Text(
          'Also, referring to TrinaPagination, you can create a UI in the desired shape and set it as the response value of the createFooter callback.',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: showTotalRows,
              onChanged: (value) {
                setState(() {
                  showTotalRows = value ?? true;
                });
              },
            ),
            const Text('Show Total Rows'),
            const SizedBox(width: 24),
            Checkbox(
              value: enableGotoPage,
              onChanged: (value) {
                setState(() {
                  enableGotoPage = value ?? true;
                });
              },
            ),
            const Text('Enable Go to Page'),
          ],
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/row_pagination_screen.dart',
        ),
      ],
      body: TrinaGrid(
        key: ValueKey('$showTotalRows-$enableGotoPage'),
        columns: columns,
        rows: rows,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          event.stateManager.setShowColumnFilter(true);
        },
        onChanged: (TrinaGridOnChangedEvent event) {
          print(event);
        },
        configuration: const TrinaGridConfiguration(),
        createFooter: (stateManager) {
          stateManager.setPageSize(100, notify: false); // default 40
          return TrinaPagination(
            stateManager,
            showTotalRows: showTotalRows,
            enableGotoPage: enableGotoPage,
          );
        },
      ),
    );
  }
}
