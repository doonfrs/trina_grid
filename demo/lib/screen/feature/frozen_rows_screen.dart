import 'package:demo/dummy_data/development.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class FrozenRowsScreen extends StatefulWidget {
  static const routeName = 'feature/frozen-rows';

  const FrozenRowsScreen({super.key});

  @override
  _FrozenRowsScreenState createState() => _FrozenRowsScreenState();
}

class _FrozenRowsScreenState extends State<FrozenRowsScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  late final TrinaGridStateManager stateManager;

  void setColumnSizeConfig(TrinaGridColumnSizeConfig config) {
    stateManager.setColumnSizeConfig(config);
  }

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 1000);

    columns.addAll(dummyData.columns);

    rows.addAll(dummyData.rows);

    rows.insert(
      0,
      TrinaRow(
        cells: Map.fromIterables(
          columns.map((e) => e.field),
          columns.map((e) => TrinaCell(value: 'frozen')),
        ),
        frozen: TrinaRowFrozen.start,
      ),
    );

    rows.insert(
      rows.length - 1,
      TrinaRow(
        cells: Map.fromIterables(
          columns.map((e) => e.field),
          columns.map((e) => TrinaCell(value: 'frozen')),
        ),
        frozen: TrinaRowFrozen.end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Frozen Rows',
      topTitle: 'Frozen Rows',
      topContents: const [
        Text(
          'You can freeze the row by setting the frozen property to TrinaRowFrozen.start or TrinaRowFrozen.end.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/frozen_rows_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
        },
        createHeader: (stateManager) => _Header(setConfig: setColumnSizeConfig),
        configuration: const TrinaGridConfiguration(
          columnSize: TrinaGridColumnSizeConfig(
            autoSizeMode: TrinaAutoSizeMode.none,
            resizeMode: TrinaResizeMode.normal,
          ),
        ),
        createFooter: (stateManager) {
          stateManager.setPageSize(100, notify: false); // default 40
          return TrinaPagination(stateManager);
        },
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({required this.setConfig});

  final void Function(TrinaGridColumnSizeConfig) setConfig;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  TrinaGridColumnSizeConfig columnSizeConfig =
      const TrinaGridColumnSizeConfig();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [],
        ),
      ),
    );
  }
}
