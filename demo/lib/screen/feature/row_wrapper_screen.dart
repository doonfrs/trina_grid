import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class RowWrapperScreen extends StatefulWidget {
  static const routeName = 'feature/row-wrapper';

  const RowWrapperScreen({super.key});

  @override
  State<RowWrapperScreen> createState() => _RowWrapperScreenState();
}

class _RowWrapperScreenState extends State<RowWrapperScreen> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();
    final dummyData = DummyData(6, 30);
    columns.addAll(dummyData.columns);
    rows.addAll(dummyData.rows);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Row Wrapper',
      topTitle: 'Row Wrapper',
      topContents: const [
        Text(
          'The rowWrapper property lets you wrap each row with your own widget.',
        ),
        Text(
          'This is useful for adding custom styling, interactivity, or extra UI elements.',
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
