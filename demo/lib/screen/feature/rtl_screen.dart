import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class RTLScreen extends StatefulWidget {
  static const routeName = 'feature/rtl';

  const RTLScreen({super.key});

  @override
  _RTLScreenState createState() => _RTLScreenState();
}

class _RTLScreenState extends State<RTLScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 200);

    columns.addAll(dummyData.columns);

    rows.addAll(dummyData.rows);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Right To Left.',
      topTitle: 'Text direction.',
      topContents: const [
        Text(
          'Wrap the TrinaGrid with a Directionality widget and pass rtl to textDirection to enable RTL.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/rtl_screen.dart',
        ),
      ],
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: TrinaGrid(
          columns: columns,
          rows: rows,
          onLoaded: (event) {
            event.stateManager.setShowColumnFilter(true);
          },
          // configuration: const TrinaGridConfiguration(
          //   localeText: TrinaGridLocaleText.arabic(),
          // ),
          createFooter: (stateManager) {
            stateManager.setPageSize(20);
            return TrinaPagination(stateManager);
          },
        ),
      ),
    );
  }
}
