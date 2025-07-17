# Row Checking

Row checking is a feature in TrinaGrid that allows users to select rows using checkboxes. This feature is particularly useful for operations that need to be performed on multiple rows, such as bulk actions, data export, or batch processing.

## Overview

The row checking feature adds checkboxes to rows in your grid, enabling users to:

- Select individual rows by checking their corresponding checkboxes
- Select or deselect all rows at once using a header checkbox
- Perform actions on the selected rows
- Track the checked state of rows programmatically

This feature is distinct from row selection (which highlights rows) and can be used independently or in conjunction with row selection.

## Enabling Row Checking

To enable row checking in TrinaGrid, you need to set the `enableRowChecked` property to `true` for at least one column:

```dart
TrinaColumn(
  title: 'Name',
  field: 'name',
  type: TrinaColumnType.text(),
  enableRowChecked: true,  // Enable checkbox for this column
)
```

When `enableRowChecked` is set to `true`, a checkbox appears in the cells of that column, allowing users to check or uncheck rows.

## User Interactions

### Checking Individual Rows

Users can check or uncheck individual rows by clicking on the checkbox in the row. When a row is checked:

- The checkbox appears checked
- The row is added to the `checkedRows` list in the state manager
- The `onRowChecked` callback is triggered (if provided)

### Checking All Rows

If a column has `enableRowChecked` set to `true`, a checkbox also appears in the column header. This checkbox allows users to:

- Check all visible rows when clicked if not all rows are currently checked
- Uncheck all rows when clicked if all rows are currently checked

## Handling Row Check Events

TrinaGrid provides an `onRowChecked` callback that is triggered when rows are checked or unchecked:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onRowChecked: (TrinaGridOnRowCheckedEvent event) {
    if (event.isRow) {
      // A single row was checked/unchecked
      print('Row checked: ${event.row?.cells['id']?.value}');
      print('Checked state: ${event.checked}');
    } else {
      // All rows were checked/unchecked
      print('All rows toggled');
      print('Checked state: ${event.checked}');
    }
  },
)
```

The `TrinaGridOnRowCheckedEvent` provides information about the check event:

- `isRow`: Indicates whether a single row was checked (`true`) or all rows were toggled (`false`)
- `isAll`: The opposite of `isRow`
- `row`: The row that was checked or unchecked (null if `isAll` is true)
- `checked`: The new checked state (true if checked, false if unchecked)

## Accessing Checked Rows

You can access the list of checked rows through the state manager:

```dart
// Get all checked rows
List<TrinaRow> checkedRows = stateManager.checkedRows;

// Perform operations on checked rows
for (var row in checkedRows) {
  // Process each checked row
  print(row.cells['name']?.value);
}
```

## Programmatic Control

You can programmatically check or uncheck rows using the row's `checked` property:

```dart
// Check a specific row
row.checked = true;

// Uncheck a specific row
row.checked = false;

// Notify the grid to update the UI
stateManager.notifyListeners();
```

## Example

Here's a complete example demonstrating row checking functionality:

```dart
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

class RowCheckingExample extends StatefulWidget {
  @override
  _RowCheckingExampleState createState() => _RowCheckingExampleState();
}

class _RowCheckingExampleState extends State<RowCheckingExample> {
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
        enableRowChecked: true,  // Enable checkbox for this column
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
        title: 'Status',
        field: 'status',
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
          'status': TrinaCell(value: 'Active'),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 2),
          'name': TrinaCell(value: 'Jane Doe'),
          'email': TrinaCell(value: 'jane.doe@example.com'),
          'status': TrinaCell(value: 'Inactive'),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 3),
          'name': TrinaCell(value: 'Bob Johnson'),
          'email': TrinaCell(value: 'bob.johnson@example.com'),
          'status': TrinaCell(value: 'Active'),
        },
      ),
      // Add more rows as needed
    ]);
  }

  void handleRowChecked(TrinaGridOnRowCheckedEvent event) {
    if (event.isRow) {
      // A single row was checked/unchecked
      print('Row checked: ${event.row?.cells['id']?.value}');
      print('Checked state: ${event.checked}');
    } else {
      // All rows were checked/unchecked
      print('All rows toggled');
      print('Checked state: ${event.checked}');
      print('Number of checked rows: ${stateManager.checkedRows.length}');
    }
  }

  void processCheckedRows() {
    final checkedRows = stateManager.checkedRows;
    
    if (checkedRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No rows selected')),
      );
      return;
    }
    
    // Example of processing checked rows
    final rowIds = checkedRows.map((row) => row.cells['id']?.value).join(', ');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Processing rows with IDs: $rowIds')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Row Checking Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Check rows using the checkboxes in the ID column',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: processCheckedRows,
              child: Text('Process Checked Rows'),
            ),
          ),
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
              onRowChecked: handleRowChecked,
            ),
          ),
        ],
      ),
    );
  }
}

## Combining with Row Selection

Row checking can be used alongside row selection to provide multiple ways for users to interact with rows:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onLoaded: (TrinaGridOnLoadedEvent event) {
    // Use a row selection mode
    event.stateManager.setSelectingMode(TrinaGridSelectingMode.row);
    stateManager = event.stateManager;
  },
  onRowChecked: handleRowChecked,
  onSelected: handleRowSelected,
)
```

When used together:

- Row selection highlights the selected rows
- Row checking maintains a separate list of checked rows
- Users can select rows for immediate operations and check rows for batch operations

## Best Practices

1. **Clear Purpose**: Use row checking when you need to perform operations on multiple rows that may not be adjacent.

2. **Visual Clarity**: Place the checkbox in a column that makes sense for your UI, typically the leftmost column or an ID column.

3. **Batch Actions**: Provide clear actions that can be performed on checked rows, such as buttons for "Delete Selected", "Export Selected", etc.

4. **Feedback**: Always provide feedback when users check/uncheck rows, especially when performing batch operations.

5. **State Persistence**: Consider whether checked state should persist across pagination, sorting, or filtering operations based on your application's needs.

6. **Accessibility**: Ensure that checkboxes are accessible to keyboard and screen reader users.

## Related Features

- [Row Selection](row-selection.md)
- [Row Moving](row-moving.md)
- [Row Coloring](row-color.md)
- [Row Groups](row-groups.md)
