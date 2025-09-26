import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_screen.dart';

class CheckViewPortVisibleColumnsScreen extends StatefulWidget {
  static const routeName = 'check-view-port-visible-columns';

  const CheckViewPortVisibleColumnsScreen({super.key});

  @override
  _CheckViewPortVisibleColumnsScreenState createState() =>
      _CheckViewPortVisibleColumnsScreenState();
}

class _CheckViewPortVisibleColumnsScreenState
    extends State<CheckViewPortVisibleColumnsScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      for (var i = 1; i < 50; i++)
        TrinaColumn(
          title: 'Column $i',
          field: 'column$i',
          type: TrinaColumnType.text(),
        ),
    ]);

    rows.addAll([
      for (var i = 1; i < 50; i++)
        TrinaRow(
          cells: {
            for (var column in columns)
              column.field: TrinaCell(value: faker.lorem.sentence()),
          },
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Check view port visible columns',
      topTitle: 'Check view port visible columns',
      topContents: const [Text('You can check view port visible columns.')],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
        },
        createHeader: (stateManager) => _Header(stateManager: stateManager),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({required this.stateManager});

  final TrinaGridStateManager stateManager;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  TrinaGridSelectingMode gridSelectingMode = TrinaGridSelectingMode.row;

  @override
  void initState() {
    super.initState();
  }

  void _showViewPortVisibleColumns() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('View port visible columns'),
        children: [
          for (var element in widget.stateManager.getViewPortVisibleColumns())
            SimpleDialogOption(onPressed: () {}, child: Text(element.title)),
        ],
      ),
    );
  }

  void _isColumnVisibleInViewport() {
    int? columnIndex;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Is column visible?'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                        onChanged: (value) {
                          columnIndex = int.tryParse(value);
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Column index',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: const Text('Check'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (columnIndex != null)
                  Text(
                    widget.stateManager.isColumnVisibleInViewport(
                          widget.stateManager.refColumns[columnIndex!],
                        )
                        ? 'Visible'
                        : 'Hidden',
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _showViewPortVisibleColumns,
              child: const Text('Show view port visible columns'),
            ),
            ElevatedButton(
              onPressed: _isColumnVisibleInViewport,
              child: const Text('Is column visible?'),
            ),
          ],
        ),
      ),
    );
  }
}
