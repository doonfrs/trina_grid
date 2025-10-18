import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class RowWrapperFrozenScreen extends StatefulWidget {
  static const routeName = 'feature/row-wrapper-frozen';

  const RowWrapperFrozenScreen({super.key});

  @override
  State<RowWrapperFrozenScreen> createState() => _RowWrapperFrozenScreenState();
}

class _RowWrapperFrozenScreenState extends State<RowWrapperFrozenScreen> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();
    final dummyData = DummyData(10, 30);

    // Create columns with some frozen left and right
    for (int i = 0; i < dummyData.columns.length; i++) {
      final column = dummyData.columns[i];
      if (i < 2) {
        // First 2 columns frozen left
        column.frozen = TrinaColumnFrozen.start;
      } else if (i >= dummyData.columns.length - 2) {
        // Last 2 columns frozen right
        column.frozen = TrinaColumnFrozen.end;
      }
      columns.add(column);
    }

    rows.addAll(dummyData.rows);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Row Wrapper with Frozen Columns',
      topTitle: 'Row Wrapper with Frozen Columns',
      topContents: const [
        Text('Demonstrates rowWrapper working with frozen columns.'),
        Text(
          'Notice how the wrapper styling is applied to ALL rows, including those in frozen columns.',
        ),
        Text(
          'The first 2 columns are frozen left, and the last 2 columns are frozen right.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/doc/features/row-wrapper.md',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        createFooter: (stateManager) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              border: Border(
                top: BorderSide(color: Colors.deepPurple.shade200, width: 2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.deepPurple.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'The purple borders and shadows are applied via rowWrapper to all rows, including frozen columns',
                    style: TextStyle(
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        rowWrapper: (context, rowWidget, rowData, stateManager) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepPurple, width: 2),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withAlpha(8),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
              color: Colors.white,
            ),
            child: rowWidget,
          );
        },
      ),
    );
  }
}
