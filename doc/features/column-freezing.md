# Column Freezing

Column freezing is a feature that allows you to lock columns in place while scrolling horizontally through a data grid. This is particularly useful when working with wide tables that have identifying columns (like ID, name, etc.) that you want to keep visible at all times.

## Overview

TrinaGrid supports freezing columns on both the left and right sides of the grid. When columns are frozen, they remain visible even when scrolling horizontally through the grid content.

## Types of Column Freezing

TrinaGrid supports three states for column freezing:

- **None**: The default state where columns scroll normally with the grid.
- **Start (Left)**: Freezes the column to the left side of the grid.
- **End (Right)**: Freezes the column to the right side of the grid.

## How to Freeze Columns

### Programmatically

You can set the frozen state of a column when defining your columns:

```dart
final List<TrinaColumn> columns = [
  TrinaColumn(
    title: 'ID',
    field: 'id',
    type: TrinaColumnType.number(),
    frozen: TrinaColumnFrozen.start, // Freeze this column to the left
  ),
  TrinaColumn(
    title: 'Name',
    field: 'name',
    type: TrinaColumnType.text(),
  ),
  TrinaColumn(
    title: 'Actions',
    field: 'actions',
    type: TrinaColumnType.text(),
    frozen: TrinaColumnFrozen.end, // Freeze this column to the right
  ),
];
```

### Using the Column Menu

Users can freeze columns through the column menu that appears when clicking on the menu icon in the column header:

1. Click on the menu icon in the column header
2. Select "Freeze to start" to freeze the column to the left side
3. Select "Freeze to end" to freeze the column to the right side
4. Select "Unfreeze" to return the column to normal scrolling behavior

### Using the State Manager

You can also toggle column freezing using the state manager:

```dart
// Freeze a column to the left
stateManager.toggleFrozenColumn(column, TrinaColumnFrozen.start);

// Freeze a column to the right
stateManager.toggleFrozenColumn(column, TrinaColumnFrozen.end);

// Unfreeze a column
stateManager.toggleFrozenColumn(column, TrinaColumnFrozen.none);
```

## Limitations

TrinaGrid has built-in safeguards to prevent freezing too many columns:

1. The grid ensures there's always enough space for non-frozen columns to be visible.
2. If the width of the middle (non-frozen) columns becomes too narrow, frozen columns will be automatically released.
3. The `limitToggleFrozenColumn` method checks if there's enough space before allowing a column to be frozen.

## Example

Here's a complete example demonstrating column freezing:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

class ColumnFreezingExample extends StatefulWidget {
  @override
  _ColumnFreezingExampleState createState() => _ColumnFreezingExampleState();
}

class _ColumnFreezingExampleState extends State<ColumnFreezingExample> {
  final List<TrinaColumn> columns = [
    TrinaColumn(
      title: 'ID',
      field: 'id',
      type: TrinaColumnType.number(),
      frozen: TrinaColumnFrozen.start, // Frozen to left by default
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
    TrinaColumn(
      title: 'Actions',
      field: 'actions',
      type: TrinaColumnType.text(),
      frozen: TrinaColumnFrozen.end, // Frozen to right by default
    ),
  ];

  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();
    
    // Generate sample data
    for (int i = 0; i < 100; i++) {
      rows.add(
        TrinaRow(
          cells: {
            'id': TrinaCell(value: i),
            'name': TrinaCell(value: 'User $i'),
            'email': TrinaCell(value: 'user$i@example.com'),
            'role': TrinaCell(value: i % 2 == 0 ? 'Admin' : 'User'),
            'actions': TrinaCell(value: 'Edit | Delete'),
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Column Freezing Example')),
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          // You can also freeze columns after the grid is loaded
          // event.stateManager.toggleFrozenColumn(columns[1], TrinaColumnFrozen.start);
        },
      ),
    );
  }
}
```

## Best Practices

1. **Freeze Important Columns**: Typically, you'll want to freeze columns containing identifying information (like IDs or names) on the left, and action columns on the right.

2. **Don't Freeze Too Many Columns**: Freezing too many columns can reduce the space available for scrollable content. Only freeze columns that are essential for context.

3. **Consider Column Width**: Frozen columns take up fixed space in the grid. Make sure your frozen columns aren't too wide to ensure enough space for the scrollable content.

4. **Responsive Design**: When implementing column freezing in a responsive layout, be aware that on smaller screens, having frozen columns might take up too much space. Consider making column freezing conditional based on screen width.

## Related Features

- [Column Types](column-types.md)
- [Column Resizing](column-resizing.md)
- [Column Moving](column-moving.md)
