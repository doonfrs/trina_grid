# Row Moving

Row moving is a feature in TrinaGrid that allows users to reorder rows by dragging them to a new position. This feature enhances the user experience by providing an intuitive way to reorganize data within the grid.

## Overview

The row moving feature enables users to change the order of rows in the grid through drag-and-drop interactions. This is particularly useful when users need to prioritize certain data or create a custom ordering that differs from the default.

## Enabling Row Moving

To enable row moving in TrinaGrid, you need to set the `enableRowDrag` property to `true` for at least one column:

```dart
TrinaColumn(
  title: 'Name',
  field: 'name',
  type: TrinaColumnType.text(),
  enableRowDrag: true,  // Enable row dragging for this column
)
```

When `enableRowDrag` is set to `true`, a drag handle icon appears in the cells of that column, allowing users to drag the row.

## User Interactions

### Dragging Rows

When row moving is enabled:

1. Users can click and hold on the drag handle icon in a cell.
2. While holding, they can drag the row up or down to the desired position.
3. Upon releasing, the row will be moved to the new position.

### Moving Multiple Rows

When using row selection modes (`TrinaGridSelectingMode.rowWithCtrl` or `TrinaGridSelectingMode.rowWithSingleTap`), users can:

1. Select multiple rows.
2. Drag any of the selected rows to move all selected rows together to a new position.

## Programmatic Row Moving

You can also move rows programmatically using the TrinaGrid state manager:

### Moving Rows by Index

```dart
// Move specified rows to index 5
stateManager.moveRowsByIndex(rowsToMove, 5);
```

### Moving Rows by Offset

```dart
// Move specified rows to the position at the given vertical offset
stateManager.moveRowsByOffset(rowsToMove, offsetValue);
```

## Handling Row Movement Events

TrinaGrid provides an `onRowsMoved` callback that is triggered when rows are moved:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onRowsMoved: (TrinaGridOnRowsMovedEvent event) {
    // Access the new index where rows were moved
    print('Rows moved to index: ${event.idx}');
    
    // Access the moved rows
    for (var row in event.rows) {
      print('Moved row: ${row.cells['id']?.value}');
    }
    
    // Perform any additional actions after rows are moved
    updateExternalDataSource(event.rows, event.idx);
  },
)
```

## Example

Here's a complete example demonstrating row moving functionality:

```dart
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

class RowMovingExample extends StatefulWidget {
  @override
  _RowMovingExampleState createState() => _RowMovingExampleState();
}

class _RowMovingExampleState extends State<RowMovingExample> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];
  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    // Define columns
    columns.addAll([
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.number(),
        width: 80,
        enableRowDrag: true,  // Enable row dragging
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Email',
        field: 'email',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Role',
        field: 'role',
        type: TrinaColumnType.text(),
      ),
    ]);

    // Define rows
    rows.addAll([
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 1),
          'name': TrinaCell(value: 'John Smith'),
          'email': TrinaCell(value: 'john.smith@example.com'),
          'role': TrinaCell(value: 'Developer'),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 2),
          'name': TrinaCell(value: 'Jane Doe'),
          'email': TrinaCell(value: 'jane.doe@example.com'),
          'role': TrinaCell(value: 'Designer'),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 3),
          'name': TrinaCell(value: 'Bob Johnson'),
          'email': TrinaCell(value: 'bob.johnson@example.com'),
          'role': TrinaCell(value: 'Manager'),
        },
      ),
      // Add more rows as needed
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Row Moving Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Drag rows using the handle in the ID column to reorder them',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                // Enable row selection mode to allow moving multiple rows
                stateManager.setSelectingMode(TrinaGridSelectingMode.row);
              },
              onRowsMoved: (TrinaGridOnRowsMovedEvent event) {
                // Handle row movement
                print('Rows moved to index: ${event.idx}');
                for (var row in event.rows) {
                  print('Moved row ID: ${row.cells['id']?.value}');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

## Best Practices

1. **Visual Feedback**: Ensure that the drag handle icon is clearly visible and distinguishable to provide users with a clear indication of where to click for dragging.

2. **Row Selection Integration**: When implementing row moving, consider enabling row selection mode to allow users to move multiple rows simultaneously.

3. **Data Synchronization**: If your grid data is connected to an external data source, make sure to update the source when rows are moved to maintain consistency.

4. **Accessibility**: Provide alternative methods for reordering rows for users who may have difficulty with drag-and-drop interactions, such as keyboard shortcuts or context menu options.

5. **Validation**: Consider implementing validation logic to restrict where certain rows can be moved if your application has specific business rules about row ordering.

6. **Performance**: Be mindful of performance when moving large numbers of rows, especially in grids with many columns or complex cell renderers.

## Related Features

- [Row Selection](row-selection.md)
- [Row Editing](row-editing.md)
- [Drag and Drop](drag-and-drop.md)
