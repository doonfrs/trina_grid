import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

import '../dummy_data/development.dart';

class EmptyScreen extends StatefulWidget {
  static const routeName = 'empty';

  const EmptyScreen({super.key});

  @override
  _EmptyScreenState createState() => _EmptyScreenState();
}

class _EmptyScreenState extends State<EmptyScreen> {
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
      ),
      TrinaColumn(
        title: 'column2',
        field: 'column2',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'column3',
        field: 'column3',
        type: TrinaColumnType.text(),
      ),
    ];

    rows = DummyData.rowsByColumns(length: 10, columns: columns);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(15),
          child: TrinaGrid(
            columns: columns,
            rows: rows,
            onChanged: (TrinaGridOnChangedEvent event) {
              print(event);
            },
            onLoaded: (TrinaGridOnLoadedEvent event) {
              stateManager = event.stateManager;
            },
            configuration: const TrinaGridConfiguration(),
          ),
        ),
      ),
    );
  }
}
