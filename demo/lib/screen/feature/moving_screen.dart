import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class MovingScreen extends StatefulWidget {
  static const routeName = 'feature/moving';

  const MovingScreen({super.key});

  @override
  _MovingScreenState createState() => _MovingScreenState();
}

class _MovingScreenState extends State<MovingScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 100);

    columns.addAll(dummyData.columns);

    rows.addAll(dummyData.rows);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Moving',
      topTitle: 'Moving',
      topContents: const [
        Text(
          'Change the current cell position with the arrow keys, enter key, and tab key.',
        ),
        Text(
          'When creating a Grid, you can control "Enter key action" and "After pop-up action" with enableMoveDownAfterSelecting and enterKeyAction properties in the configuration.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/moving_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onChanged: (TrinaGridOnChangedEvent event) {
          print(event);
        },
        configuration: const TrinaGridConfiguration(
          enableMoveDownAfterSelecting: true,
          enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveRight,
        ),
      ),
    );
  }
}
