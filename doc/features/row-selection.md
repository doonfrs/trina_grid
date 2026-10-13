# Row Selection

Row selection is a feature in TrinaGrid that allows users to select one or multiple rows for various operations such as copying, exporting, or performing batch actions.

## Overview

The row selection feature enables users to interact with rows as complete units rather than individual cells. This is particularly useful for operations that apply to entire records, such as deleting, duplicating, or exporting data.

## Enabling Row Selection

To enable row selection in TrinaGrid, you need to set the selecting mode to `TrinaGridSelectingMode.row` using the state manager:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onLoaded: (TrinaGridOnLoadedEvent event) {
    // Enable row selection mode
    event.stateManager.setSelectingMode(TrinaGridSelectingMode.row);
  },
)
```

## Selection Modes

TrinaGrid supports three selection modes:

1. **Row Selection Mode** (`TrinaGridSelectingMode.row`): Allows users to select entire rows.
2. **Cell Selection Mode** (`TrinaGridSelectingMode.cell`): Allows users to select individual cells or ranges of cells.
3. **No Selection Mode** (`TrinaGridSelectingMode.none`): Disables selection functionality.

## User Interactions for Row Selection

When row selection mode is enabled, users can select rows using the following interactions:

### Single Row Selection

- **Click**: Click on any cell in a row to select it.
- **Keyboard Navigation**: Use arrow keys to navigate to a row and press Space or Enter to select it.

### Multiple Row Selection

- **Shift + Click**: Select a range of rows from the currently selected row to the clicked row.
- **Ctrl/Cmd + Click**: Add or remove individual rows from the selection without affecting other selected rows.
- **Long Press and Drag**: Press and hold on a row, then drag to select multiple consecutive rows.

## Programmatic Row Selection

You can programmatically select rows using the TrinaGrid state manager:

### Selecting Rows by Range

```dart
// Select rows from index 2 to index 5
stateManager.setCurrentSelectingRowsByRange(2, 5);
```

### Toggling Row Selection

```dart
// Toggle selection state of the row at index 3
stateManager.toggleSelectingRow(3);
```

### Clearing Selection

```dart
// Clear all selected rows
stateManager.clearCurrentSelecting();
```

## Accessing Selected Rows

You can access the currently selected rows through the state manager:

```dart
// Get all currently selected rows
List<TrinaRow> selectedRows = stateManager.currentSelectingRows;

// Process selected rows
for (var row in selectedRows) {
  // Access row data
  var cellValue = row.cells['fieldName'].value;
  // Perform operations with the selected row
}
```

## Selection Events

`onSelected` is called when the selection changes. With row selection mode in the normal grid mode, it fires when a row is clicked, and when rows are selected with Shift or Ctrl/Cmd click or a long press:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onLoaded: (TrinaGridOnLoadedEvent event) {
    event.stateManager.setSelectingMode(TrinaGridSelectingMode.row);
  },
  onSelected: (TrinaGridOnSelectedEvent event) {
    // The current row, the one that was clicked.
    print('Current row: ${event.rowIdx}');

    // Every selected row.
    print('Selected rows: ${event.selectedRows?.length}');
  },
)
```

`onSelected` also fires in the `TrinaGridMode.select`, `selectWithOneTap` and `multiSelect` grid modes. `event.selectedRows` is filled in `multiSelect` and in row selection mode; in the other cases use `event.row`.

## Visual Feedback

When a row is selected, TrinaGrid provides visual feedback by highlighting the entire row. The default styling can be customized through the TrinaGrid configuration.

## Best Practices

1. **Clear Communication**: Provide visual cues and instructions to users about how to select rows, especially for multiple selection.

2. **Batch Operations**: When implementing actions that operate on selected rows, ensure they handle both single and multiple selections appropriately.

3. **Selection Persistence**: Consider whether selection should persist across pagination or filtering operations based on your application's needs.

4. **Keyboard Accessibility**: Ensure that row selection can be performed using keyboard navigation for accessibility.

5. **Selection Feedback**: Provide clear visual feedback when rows are selected, and consider adding a count of selected rows when multiple rows are selected.

6. **Performance Considerations**: Be mindful of performance when handling large numbers of selected rows, especially when performing operations on the selection.

## Example

Here's a complete example demonstrating row selection:

```dart
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

class RowSelectionExample extends StatefulWidget {
  @override
  _RowSelectionExampleState createState() => _RowSelectionExampleState();
}

class _RowSelectionExampleState extends State<RowSelectionExample> {
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

  void showSelectedRows() {
    if (stateManager.currentSelectingRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No rows selected')),
      );
      return;
    }

    // Build a string with information about selected rows
    String message = 'Selected rows:\n';
    for (var row in stateManager.currentSelectingRows) {
      message += 'ID: ${row.cells['id'].value}, Name: ${row.cells['name'].value}\n';
    }

    // Show the selected rows in a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Selected Rows'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Row Selection Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: showSelectedRows,
              child: Text('Show Selected Rows'),
            ),
          ),
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                // Enable row selection mode
                stateManager.setSelectingMode(TrinaGridSelectingMode.row);
              },
              onSelected: (TrinaGridOnSelectedEvent event) {
                // Optional: Handle selection changes
                print('Selection changed');
              },
            ),
          ),
        ],
      ),
    );
  }
}

## Related Features

- [Cell Selection](cell-selection.md)
- [Row Checking](row-checking.md)
- [Clipboard Operations](clipboard-operations.md)
- [Row Editing](row-editing.md)
