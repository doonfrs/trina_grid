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
  bool enterKeyTogglesEditing = false;
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

  void toggleEnterKeyActionToEditing(bool flag) {
    setState(() {
      enterKeyTogglesEditing = flag;
      stateManager.setConfiguration(stateManager.configuration.copyWith(
        enterKeyAction: flag
            ? TrinaGridEnterKeyAction.toggleEditing
            : TrinaGridEnterKeyAction.editingAndMoveDown,
      ));
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
          Expanded(
            flex: 0,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 10),
              scrollDirection: Axis.horizontal,
              child: OverflowBar(
                spacing: 10,
                children: [
                  LabeledSwitch(
                    width: 220,
                    label: 'Auto Editing on tap',
                    value: autoEditing,
                    onChanged: toggleAutoEditing,
                  ),
                  LabeledSwitch(
                    width: 280,
                    label: 'Press Enter to Toggle Editing',
                    value: enterKeyTogglesEditing,
                    onChanged: toggleEnterKeyActionToEditing,
                  ),
                ],
              ),
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
                stateManager = event.stateManager;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LabeledSwitch extends StatelessWidget {
  const LabeledSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.padding,
    this.width = 200,
  });

  final String label;
  final EdgeInsets? padding;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        width: width,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.blueGrey[50],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label)),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
