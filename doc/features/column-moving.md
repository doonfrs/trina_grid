# Column Moving

Column moving is a feature that allows users to change the order of columns in TrinaGrid by dragging and dropping column headers. This feature enhances the user experience by enabling customization of the grid layout according to user preferences.

## Overview

TrinaGrid provides a flexible column moving system that allows users to rearrange columns through a simple drag-and-drop interface. Developers can also programmatically move columns using the state manager API.

## How to Move Columns

### Using Drag and Drop (UI)

The most intuitive way to move columns is through the user interface:

1. Hover over the column header you want to move
2. Click and hold the column header
3. Drag the column to the desired position
4. Release the mouse button to drop the column in its new position

As you drag a column, a visual indicator will show where the column will be placed when you release the mouse button.

### Using the State Manager (Programmatic)

You can also move columns programmatically using the state manager:

```dart
// Move 'columnA' to the position of 'columnB'
stateManager.moveColumn(
  column: columnA,
  targetColumn: columnB,
);
```

This will move `columnA` to the position where `columnB` is currently located.

## Behavior with Frozen Columns

Column moving has special behavior when working with frozen columns:

1. When moving a non-frozen column to a frozen area, the column will adopt the frozen state of the target column
2. There are width limitations when moving columns to frozen areas to ensure the frozen area doesn't exceed the available space
3. The system handles the transition between different frozen states (start, end, none) automatically

## Limitations

### Width Limitations

When moving columns to frozen areas, there are width limitations to consider:

- The total width of frozen columns cannot exceed a certain percentage of the grid width
- If moving a column would cause the frozen area to exceed this limit, the move operation will be prevented
- These limitations ensure that non-frozen columns always have sufficient space to be displayed

### Frozen Column Limitations

There are specific limitations when moving frozen columns:

1. Moving a frozen column to a non-frozen area will change its frozen state
2. Moving a non-frozen column to a frozen area will change its frozen state to match the target area
3. The system prevents moves that would violate the frozen column width limitations

## Events

When columns are moved, TrinaGrid fires events that you can listen to:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onLoaded: (TrinaGridOnLoadedEvent event) {
    stateManager = event.stateManager;
  },
  onColumnsMoved: (TrinaGridOnColumnsMovedEvent event) {
    // Handle column moved event
    print('Column moved to index: ${event.idx}');
    print('Column moved to visual index: ${event.visualIdx}');
    print('Moved columns: ${event.columns}');
  },
)
```

## Auto-Size Restoration

By default, TrinaGrid will restore auto-sizing after moving columns. You can control this behavior through the configuration:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: const TrinaGridConfiguration(
    columnSize: TrinaGridColumnSizeConfig(
      // Set to false to prevent auto-size restoration after moving columns
      restoreAutoSizeAfterMoveColumn: false,
    ),
  ),
)
```

## Example

Here's a complete example demonstrating column moving:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

class ColumnMovingExample extends StatefulWidget {
  @override
  _ColumnMovingExampleState createState() => _ColumnMovingExampleState();
}

class _ColumnMovingExampleState extends State<ColumnMovingExample> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];
  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'Column A',
        field: 'column_a',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Column B',
        field: 'column_b',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Column C',
        field: 'column_c',
        type: TrinaColumnType.text(),
      ),
    ]);

    rows.addAll([
      TrinaRow(
        cells: {
          'column_a': TrinaCell(value: 'a1'),
          'column_b': TrinaCell(value: 'b1'),
          'column_c': TrinaCell(value: 'c1'),
        },
      ),
      TrinaRow(
        cells: {
          'column_a': TrinaCell(value: 'a2'),
          'column_b': TrinaCell(value: 'b2'),
          'column_c': TrinaCell(value: 'c2'),
        },
      ),
      TrinaRow(
        cells: {
          'column_a': TrinaCell(value: 'a3'),
          'column_b': TrinaCell(value: 'b3'),
          'column_c': TrinaCell(value: 'c3'),
        },
      ),
    ]);
  }

  void _moveColumnProgrammatically() {
    // Move Column A to the position of Column C
    final columnA = columns.firstWhere((col) => col.field == 'column_a');
    final columnC = columns.firstWhere((col) => col.field == 'column_c');
    
    stateManager.moveColumn(
      column: columnA,
      targetColumn: columnC,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Column Moving Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _moveColumnProgrammatically,
                  child: Text('Move Column A to Column C Position'),
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
              onColumnsMoved: (TrinaGridOnColumnsMovedEvent event) {
                print('Column moved to index: ${event.idx}');
                print('Column moved to visual index: ${event.visualIdx}');
                print('Moved columns: ${event.columns}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## Best Practices

1. **Provide Visual Feedback**: Ensure that your grid provides clear visual feedback during drag operations to help users understand where columns will be placed.

2. **Consider Frozen Columns**: Be mindful of the interaction between column moving and frozen columns. Moving columns between frozen and non-frozen areas changes their frozen state.

3. **Handle Events**: Listen to column moved events to update any dependent UI or data structures when columns are rearranged.

4. **Auto-Size Configuration**: Decide whether to restore auto-sizing after column moves based on your application's needs. For data-dense grids, you might want to maintain user-defined column sizes.

5. **Combine with Column Resizing**: Column moving works well in combination with column resizing, giving users complete control over the grid layout.

## Related Features

- [Column Types](column-types.md)
- [Column Freezing](column-freezing.md)
- [Column Resizing](column-resizing.md)
