# Column Resizing

Column resizing is a feature that allows users to adjust the width of columns in TrinaGrid. This feature provides flexibility in displaying data and helps users optimize their view based on the content in each column.

## Overview

TrinaGrid provides a comprehensive column resizing system with different modes and behaviors. Users can resize columns by dragging the right edge of a column header, and developers can configure how the resizing behaves through various configuration options.

## Resize Modes

TrinaGrid supports three resize modes, defined by the `TrinaResizeMode` enum:

### 1. None (`TrinaResizeMode.none`)

In this mode, column resizing is disabled. Users cannot resize columns by dragging the column edges.

### 2. Normal (`TrinaResizeMode.normal`)

This is the default mode. When a column is resized, only that specific column's width changes. Other columns maintain their original widths, which may change the overall width of the grid.

### 3. Push and Pull (`TrinaResizeMode.pushAndPull`)

In this mode, when a column is resized, neighboring columns adjust their widths to maintain the overall grid width. This creates a more fluid resizing experience where:

- When a column is expanded, other columns shrink to compensate
- When a column is shrunk, other columns expand to fill the available space

This mode is particularly useful when you want to maintain a fixed total width for your grid.

## Auto-Size Modes

In addition to resize modes, TrinaGrid also supports auto-sizing columns through the `TrinaAutoSizeMode` enum:

### 1. None (`TrinaAutoSizeMode.none`)

Columns are not automatically sized and maintain their explicitly set widths.

### 2. Equal (`TrinaAutoSizeMode.equal`)

All columns are sized equally, regardless of their content.

### 3. Scale (`TrinaAutoSizeMode.scale`)

Columns are sized proportionally based on their current widths.

## How to Configure Column Resizing

### Basic Configuration

You can configure column resizing when creating your TrinaGrid:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: const TrinaGridConfiguration(
    columnSize: TrinaGridColumnSizeConfig(
      autoSizeMode: TrinaAutoSizeMode.none,
      resizeMode: TrinaResizeMode.normal,
    ),
  ),
)
```

### Configuring Individual Columns

You can also control whether specific columns can be resized:

```dart
final List<TrinaColumn> columns = [
  TrinaColumn(
    title: 'ID',
    field: 'id',
    type: TrinaColumnType.number(),
    enableDropToResize: false, // Disable resizing for this column
  ),
  TrinaColumn(
    title: 'Name',
    field: 'name',
    type: TrinaColumnType.text(),
    // This column can be resized (default)
  ),
];
```

### Using the State Manager

You can dynamically change column resizing configuration using the state manager:

```dart
// Change the column size configuration
stateManager.setColumnSizeConfig(
  TrinaGridColumnSizeConfig(
    autoSizeMode: TrinaAutoSizeMode.equal,
    resizeMode: TrinaResizeMode.pushAndPull,
  ),
);

// Resize a specific column programmatically
stateManager.resizeColumn(column, 50); // Increase width by 50 pixels
```

### Restore Options

TrinaGrid provides options to control when auto-sizing should be restored after certain actions:

```dart
TrinaGridColumnSizeConfig(
  autoSizeMode: TrinaAutoSizeMode.equal,
  resizeMode: TrinaResizeMode.normal,
  // Restore auto-sizing after these actions
  restoreAutoSizeAfterHideColumn: true,
  restoreAutoSizeAfterFrozenColumn: true,
  restoreAutoSizeAfterMoveColumn: true,
  restoreAutoSizeAfterInsertColumn: true,
  restoreAutoSizeAfterRemoveColumn: true,
)
```

## How Column Resizing Works

### User Interaction

1. The user hovers over the right edge of a column header, and the cursor changes to a resize cursor
2. The user clicks and drags to resize the column
3. Depending on the resize mode, other columns may adjust their widths

### Implementation Details

When a column is resized:

1. The `resizeColumn` method is called with the column and the offset (change in width)
2. If the resize mode is `normal`, only the target column's width is updated
3. If the resize mode is `pushAndPull`, the `TrinaResizePushAndPull` class handles distributing the width changes across multiple columns
4. The grid layout is updated to reflect the new column widths

## Minimum Column Width

Each column has a minimum width to ensure that content remains visible. When resizing a column, it cannot be made smaller than its minimum width.

```dart
TrinaColumn(
  title: 'Name',
  field: 'name',
  type: TrinaColumnType.text(),
  minWidth: 100, // Set minimum width to 100 pixels
)
```

## Auto-Fitting Columns

TrinaGrid also provides the ability to automatically fit a column's width to its content:

```dart
// Auto-fit a column to its content
stateManager.autoFitColumn(context, column);
// Auto-fit all columns, with optional ignore list
stateManager.autoFitColumns(context, columns, [ignoreIndexes]);

```

This calculates the optimal width based on the column's content and header text.

## Example

Here's a complete example demonstrating column resizing:

```dart
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

class ColumnResizingExample extends StatefulWidget {
  @override
  _ColumnResizingExampleState createState() => _ColumnResizingExampleState();
}

class _ColumnResizingExampleState extends State<ColumnResizingExample> {
  final List<TrinaColumn> columns = [
    TrinaColumn(
      title: 'ID',
      field: 'id',
      type: TrinaColumnType.number(),
      width: 80,
      minWidth: 60,
    ),
    TrinaColumn(
      title: 'Name',
      field: 'name',
      type: TrinaColumnType.text(),
      width: 150,
      minWidth: 100,
    ),
    TrinaColumn(
      title: 'Email',
      field: 'email',
      type: TrinaColumnType.text(),
      width: 200,
      minWidth: 120,
    ),
    TrinaColumn(
      title: 'Role',
      field: 'role',
      type: TrinaColumnType.text(),
      width: 120,
      minWidth: 80,
    ),
  ];

  final List<TrinaRow> rows = [];
  late TrinaGridStateManager stateManager;

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
          },
        ),
      );
    }
  }

  void _setResizeMode(TrinaResizeMode mode) {
    stateManager.setColumnSizeConfig(
      TrinaGridColumnSizeConfig(
        autoSizeMode: TrinaAutoSizeMode.none,
        resizeMode: mode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Column Resizing Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => _setResizeMode(TrinaResizeMode.normal),
                  child: Text('Normal Resize'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _setResizeMode(TrinaResizeMode.pushAndPull),
                  child: Text('Push and Pull Resize'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _setResizeMode(TrinaResizeMode.none),
                  child: Text('Disable Resize'),
                ),
              ],
            ),
          ),
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
              configuration: const TrinaGridConfiguration(
                columnSize: TrinaGridColumnSizeConfig(
                  autoSizeMode: TrinaAutoSizeMode.none,
                  resizeMode: TrinaResizeMode.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Best Practices

1. **Choose the Right Resize Mode**: Use `normal` for independent column resizing or `pushAndPull` when you want to maintain a fixed grid width.

2. **Set Appropriate Minimum Widths**: Define minimum widths for columns to ensure content remains readable after resizing.

3. **Consider Auto-Size Options**: Use auto-sizing for initial column widths, but allow users to manually resize columns for their specific needs.

4. **Restore Auto-Size Selectively**: Configure restore options based on your application's needs. For example, you might want to restore auto-sizing after hiding a column but not after freezing a column.

5. **Combine with Column Freezing**: When using column resizing with column freezing, be aware that frozen columns will maintain their position while non-frozen columns can be resized.

## Related Features

- [Column Types](column-types.md)
- [Column Freezing](column-freezing.md)
- [Column Moving](column-moving.md)
