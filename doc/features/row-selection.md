# Row Selection

Row selection is a feature in TrinaGrid that allows users to select one or multiple rows for various operations such as copying, exporting, or performing batch actions.

## Overview

The row selection feature enables users to interact with rows as complete units rather than individual cells. This is particularly useful for operations that apply to entire records, such as deleting, duplicating, or exporting data.

## Enabling Row Selection

To enable row selection in TrinaGrid, you can set the selecting mode in two ways:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  // 1- Using the configuration
  configuration: TrinaGridConfiguration(
    selectingMode: TrinaGridSelectingMode.rowWithSingleTap,
  ),
  // 2- Using the state manager
  onLoaded: (TrinaGridOnLoadedEvent event) {
    event.stateManager.setSelectingMode(TrinaGridSelectingMode.rowWithSingleTap);
  },
)
```

## Row Selection Modes


### TrinaGridSelectingMode.rowWithSingleTap

Allows users to select single or multiple rows with a single tap.

### TrinaGridSelectingMode.rowWithCtrl

Allows users to select single or multiple rows using Click + Ctrl key(cmd on Mac).

- **Keyboard Navigation**: Use arrow keys to navigate to a row and press Space or Enter to select it.

## Range Row Selection

- **Shift + Click**: Select a range of rows from the currently selected row to the clicked row.
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

TrinaGrid provides events to respond to selection changes:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onSelected: (TrinaGridOnSelectedEvent event) {
    // Handle selection change
    print('Selected rows: ${event.row}');
    print('Selected cell: ${event.cell}');
    print('Selected column: ${event.column}');
  },
)
```

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
                stateManager.setSelectingMode(TrinaGridSelectingMode.rowWithSingleTap);
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
