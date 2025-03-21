import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class AddRowsAsynchronouslyScreen extends StatefulWidget {
  static const routeName = 'feature/add-rows-asynchronously';

  const AddRowsAsynchronouslyScreen({super.key});

  @override
  _AddRowsAsynchronouslyScreenState createState() =>
      _AddRowsAsynchronouslyScreenState();
}

class _AddRowsAsynchronouslyScreenState
    extends State<AddRowsAsynchronouslyScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    /// Columns must be provided at the beginning of a row synchronously.
    columns.addAll(DummyData(30, 0).columns);

    fetchRows().then((fetchedRows) {
      /// When there are many rows and the UI freezes when the grid is loaded
      /// Initialize the rows asynchronously through the initializeRowsAsync method
      /// Add rows to stateManager.refRows.
      /// And disable the loading screen.
      TrinaGridStateManager.initializeRowsAsync(
        columns,
        fetchedRows,
      ).then((value) {
        stateManager.refRows.addAll(value);

        /// In this example,
        /// the loading screen is activated in the onLoaded callback when the grid is created.
        /// If the loading screen is not activated
        /// You must update the grid state by calling the stateManager.notifyListeners() method.
        /// Because calling setShowLoading updates the grid state
        /// No need to call stateManager.notifyListeners.
        stateManager.setShowLoading(false);
      });
    });
  }

  /// This method creates rows asynchronously for the sake of example.
  /// In actual use, you are requesting server-side data with Http and
  /// You will need to create and return TrinaRow and TrinaCell.
  /// It's up to you.
  /// This is just an example.
  Future<List<TrinaRow>> fetchRows() {
    final Completer<List<TrinaRow>> completer = Completer();

    final List<TrinaRow> _rows = [];

    int count = 0;

    const max = 100;

    const chunkSize = 100;

    const totalRows = chunkSize * max;

    Timer.periodic(const Duration(milliseconds: 1), (timer) {
      if (count == max) {
        return;
      }

      ++count;

      Future(() {
        return DummyData.rowsByColumns(length: chunkSize, columns: columns);
      }).then((value) {
        _rows.addAll(value);

        if (_rows.length == totalRows) {
          completer.complete(_rows);

          timer.cancel();
        }
      });
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Add rows asynchronously',
      topTitle: 'Add rows asynchronously',
      topContents: const [
        Text(
            'The grid can freeze if there are many rows at the start of the grid.'),
        Text(
            'When a row is first set up or a new row is added, the TrinaGridStateManager.initializeRows method is executed and the necessary settings are made for the grid.'),
        Text(
            'In the example, an empty row is provided at the start of the grid, and the row is set asynchronously and reflected in the grid.'),
        Text('See the example code for details.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/add_rows_asynchronously.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onChanged: (TrinaGridOnChangedEvent event) {
          print(event);
        },
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;

          /// When the grid is finished loading, enable loading.
          stateManager.setShowLoading(true);
        },
        configuration: const TrinaGridConfiguration(),
      ),
    );
  }
}
