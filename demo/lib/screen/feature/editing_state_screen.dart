import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class EditingStateScreen extends StatefulWidget {
  static const routeName = 'feature/editing-state';

  const EditingStateScreen({super.key});

  @override
  _EditingStateScreenState createState() => _EditingStateScreenState();
}

class _EditingStateScreenState extends State<EditingStateScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  late TrinaGridStateManager stateManager;

  bool autoEditing = false;

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 100);

    columns.addAll(dummyData.columns);

    rows.addAll(dummyData.rows);
  }

  void toggleAutoEditing(bool flag) {
    setState(() {
      autoEditing = flag;
      stateManager.setAutoEditing(flag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Editing state',
      topTitle: 'Editing state',
      topContents: const [
        Text('Automatically change to editing state when a cell is selected.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/editing_state_screen.dart',
        ),
      ],
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Switch(
                  value: autoEditing,
                  onChanged: toggleAutoEditing,
                ),
                const Text('autoEditing'),
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
                    .setSelectingMode(TrinaGridSelectingMode.cellWithCtrl);

                stateManager = event.stateManager;
              },
            ),
          ),
        ],
      ),
    );
  }
}
