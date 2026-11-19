# Frozen Rows

Frozen rows is a feature in TrinaGrid that allows you to keep specific rows visible at all times, even when scrolling through a large dataset. This feature is particularly useful for displaying header rows, summary rows, or any important information that needs to remain visible regardless of the user's scroll position.

## Overview

The frozen rows feature enables you to:

- Pin specific rows to the top or bottom of the grid
- Keep important information visible at all times
- Improve user experience when working with large datasets
- Apply different styling to frozen rows to distinguish them visually
- Maintain context while scrolling through data

Frozen rows remain fixed in position while the rest of the grid scrolls, providing users with constant access to critical information.

## Enabling Frozen Rows

To enable frozen rows in TrinaGrid, you can set the `frozen` property when creating your row:

```dart
TrinaRow(
  cells: {
    'id': TrinaCell(value: 'H1'),
    'name': TrinaCell(value: 'Header Row'),
    'status': TrinaCell(value: 'Always Visible'),
  },
  frozen: TrinaRowFrozen.start,  // Freeze this row at the top
)
```

### Configuration Options

The frozen rows feature can be configured with the following parameter:

- `frozen`: Determines if and where the row should be frozen
  - `TrinaRowFrozen.none`: The row is not frozen (default)
  - `TrinaRowFrozen.start`: Freezes the row at the top of the grid
  - `TrinaRowFrozen.end`: Freezes the row at the bottom of the grid

## Creating Frozen Rows

You can specify which rows should be frozen by setting the `frozen` property on individual rows:

```dart
// Create a frozen header row at the top
TrinaRow(
  cells: {
    'id': TrinaCell(value: 'H1'),
    'name': TrinaCell(value: 'Header Row'),
    'status': TrinaCell(value: 'Always Visible'),
  },
  frozen: TrinaRowFrozen.start,  // Freeze this row at the top
)

// Create a frozen footer row at the bottom
TrinaRow(
  cells: {
    'id': TrinaCell(value: 'F1'),
    'name': TrinaCell(value: 'Footer Row'),
    'status': TrinaCell(value: 'Always Visible'),
  },
  frozen: TrinaRowFrozen.end,  // Freeze this row at the bottom
)
```

## Styling Frozen Rows

You can apply custom styling to frozen rows to distinguish them visually from regular rows:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    style: TrinaGridStyleConfig(
      frozenRowColor: Colors.lightBlue[50],
      frozenRowBorderColor: Colors.blue,
      frozenRowBorderWidth: 2.0,
    ),
  ),
)
```

Available styling options include:

- `frozenRowColor`: Background color for frozen rows (default: Color(0xFFF8F8F8) in light mode, Color(0xFF222222) in dark mode)
- `frozenRowBorderColor`: Border color for frozen rows (default: Color(0xFFE0E0E0) in light mode, Color(0xFF666666) in dark mode)

## Combining with Other Features

Frozen rows can be combined with other TrinaGrid features for enhanced functionality:

### Frozen Rows with Frozen Columns

You can combine frozen rows with frozen columns to create a fixed section of the grid that always remains visible:

```dart
// Create a frozen column
TrinaColumn(
  title: 'ID',
  field: 'id',
  type: TrinaColumnType.text(),
  frozen: TrinaColumnFrozen.start,  // Freeze this column
)

// Create a frozen row
TrinaRow(
  cells: {
    'id': TrinaCell(value: 'H1'),
    'name': TrinaCell(value: 'Header Row'),
  },
  frozen: TrinaRowFrozen.start,  // Freeze this row at the top
)
```

This configuration creates a fixed corner section where the frozen row and frozen column intersect.

### Frozen Rows with Row Groups

When using row groups, you can freeze group header rows to keep them visible while scrolling through group contents:

```dart
// Create a group header row that is frozen
TrinaRow(
  cells: {
    'category': TrinaCell(value: 'Electronics'),
    'count': TrinaCell(value: '15 items'),
  },
  type: TrinaRowTypeGroup.instance,
  frozen: TrinaRowFrozen.start,  // Freeze this group header at the top
)
```

## Programmatic Control

You can programmatically control frozen rows through the state manager:

```dart
// Create a new row
final newRow = TrinaRow(
  cells: {
    'id': TrinaCell(value: 'H2'),
    'name': TrinaCell(value: 'New Header Row'),
  },
);

// Freeze a row at the top
newRow.frozen = TrinaRowFrozen.start;

// Add the row to the grid
stateManager.addRow(newRow);

// Get all rows with frozen status
List<TrinaRow> frozenTopRows = stateManager.refRows.originalList
    .where((row) => row.frozen == TrinaRowFrozen.start)
    .toList();

List<TrinaRow> frozenBottomRows = stateManager.refRows.originalList
    .where((row) => row.frozen == TrinaRowFrozen.end)
    .toList();
```

## Example

Here's a complete example demonstrating frozen rows functionality:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

class FrozenRowsExample extends StatefulWidget {
  @override
  _FrozenRowsExampleState createState() => _FrozenRowsExampleState();
}

class _FrozenRowsExampleState extends State<FrozenRowsExample> {
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
        frozen: TrinaColumnFrozen.start,  // Freeze this column
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Department',
        field: 'department',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Salary',
        field: 'salary',
        type: TrinaColumnType.number(format: '\$#,###.00'),
      ),
    ]);

    // Create a header row (will be frozen)
    rows.add(
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 'H1'),
          'name': TrinaCell(value: 'Employee Information'),
          'department': TrinaCell(value: ''),
          'salary': TrinaCell(value: ''),
        },
        height: 50,
        backgroundColor: Colors.lightBlue[50],
        frozen: TrinaRowFrozen.start,  // Freeze at the top
      ),
    );

    // Add regular data rows
    for (int i = 1; i <= 20; i++) {
      rows.add(
        TrinaRow(
          cells: {
            'id': TrinaCell(value: i),
            'name': TrinaCell(value: 'Employee $i'),
            'department': TrinaCell(value: i % 3 == 0 ? 'Engineering' : (i % 3 == 1 ? 'Marketing' : 'Sales')),
            'salary': TrinaCell(value: 50000 + (i * 1000)),
          },
        ),
      );
    }

    // Create a footer row (will be frozen)
    rows.add(
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 'F1'),
          'name': TrinaCell(value: 'Total'),
          'department': TrinaCell(value: ''),
          'salary': TrinaCell(value: '\$1,260,000.00'),
        },
        backgroundColor: Colors.amber[50],
        frozen: TrinaRowFrozen.end,  // Freeze at the bottom
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Frozen Rows Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Add a new frozen row at the top
              final newRow = TrinaRow(
                cells: {
                  'id': TrinaCell(value: 'H2'),
                  'name': TrinaCell(value: 'New Header Row'),
                  'department': TrinaCell(value: ''),
                  'salary': TrinaCell(value: ''),
                },
                backgroundColor: Colors.green[50],
                frozen: TrinaRowFrozen.start,  // Freeze at the top
              );
              stateManager.addRow(newRow);
            },
            tooltip: 'Add Frozen Row',
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: TrinaGrid(
          columns: columns,
          rows: rows,
          configuration: TrinaGridConfiguration(
            style: TrinaGridStyleConfig(
              frozenRowBorderColor: Colors.blue,
            ),
          ),
          onLoaded: (TrinaGridOnLoadedEvent event) {
            stateManager = event.stateManager;
          },
        ),
      ),
    );
  }
}

## Best Practices

1. **Use Sparingly**: Limit the number of frozen rows to avoid taking up too much screen space. Usually, 1-2 rows at the top and/or bottom is sufficient.

2. **Visual Distinction**: Apply distinct styling to frozen rows to help users understand which rows are fixed and which are scrollable.

3. **Appropriate Content**: Use frozen rows for content that provides context or summary information that's useful to see at all times.

4. **Row Height**: Consider adjusting the height of frozen rows to accommodate more content or to make them more prominent.

5. **Performance**: Be aware that having many frozen rows might impact performance, especially on devices with limited resources.

6. **Responsive Design**: Test how frozen rows behave on different screen sizes to ensure a good user experience across devices.

## Related Features

- [Column Freezing](column-freezing.md): Freeze columns to keep them visible while scrolling horizontally
- [Row Groups](row-groups.md): Group rows based on common values
- [Row Selection](row-selection.md): Select rows for operations
- [Row Coloring](row-color.md): Apply custom colors to rows
