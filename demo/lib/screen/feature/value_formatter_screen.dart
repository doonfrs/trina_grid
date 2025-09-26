import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ValueFormatterScreen extends StatefulWidget {
  static const routeName = 'feature/value-formatter';

  const ValueFormatterScreen({super.key});

  @override
  _ValueFormatterScreenState createState() => _ValueFormatterScreenState();
}

class _ValueFormatterScreenState extends State<ValueFormatterScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'Permission',
        field: 'permission',
        type: TrinaColumnType.number(),
        formatter: (dynamic value) {
          if (value.toString() == '1') {
            return '(1) Allowed';
          } else {
            return '(0) Disallowed';
          }
        },
      ),
      TrinaColumn(
        title: 'Permission readonly',
        field: 'permission_readonly',
        readOnly: true,
        type: TrinaColumnType.number(),
        applyFormatterInEditing: true,
        formatter: (dynamic value) {
          if (value.toString() == '1') {
            return '(1) Allowed';
          } else {
            return '(0) Disallowed';
          }
        },
      ),
      TrinaColumn(
        title: 'Group',
        field: 'group',
        type: TrinaColumnType.select(<String>['A', 'B', 'C', 'N']),
        applyFormatterInEditing: true,
        formatter: (dynamic value) {
          switch (value.toString()) {
            case 'A':
              return '(A) Admin';
            case 'B':
              return '(B) Manager';
            case 'C':
              return '(C) User';
          }

          return '(N) None';
        },
      ),
      TrinaColumn(
        title: 'Group original value',
        field: 'group_original_value',
        type: TrinaColumnType.select(<String>['A', 'B', 'C', 'N']),
        applyFormatterInEditing: false,
        formatter: (dynamic value) {
          switch (value.toString()) {
            case 'A':
              return '(A) Admin';
            case 'B':
              return '(B) Manager';
            case 'C':
              return '(C) User';
          }

          return '(N) None';
        },
      ),
    ]);

    rows.addAll([
      TrinaRow(
        cells: {
          'permission': TrinaCell(value: 0),
          'permission_readonly': TrinaCell(value: 0),
          'group': TrinaCell(value: 'A'),
          'group_original_value': TrinaCell(value: 'A'),
        },
      ),
      TrinaRow(
        cells: {
          'permission': TrinaCell(value: 1),
          'permission_readonly': TrinaCell(value: 1),
          'group': TrinaCell(value: 'B'),
          'group_original_value': TrinaCell(value: 'B'),
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Value formatter',
      topTitle: 'Value formatter',
      topContents: const [
        Text('Formatter for display of cell values.'),
        Text(
          'You can output the desired value, not the actual value, in the view state, not the edit state.',
        ),
        Text(
          'In the case of a readonly or popup type column where text cannot be directly edited, if applyFormatterInEditing is set to true, the formatter is applied even in the editing state.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/value_formatter_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onChanged: (TrinaGridOnChangedEvent event) {
          print(event);
        },
      ),
    );
  }
}
