# Column Sorting

Column sorting is a feature that allows users to order data in TrinaGrid based on the values in a specific column. This feature enhances data analysis by enabling users to quickly identify patterns, find specific values, and organize data in a meaningful way.

## Overview

TrinaGrid provides a comprehensive column sorting system that supports both ascending and descending order. Users can sort columns by clicking on column headers, and developers can also programmatically sort columns using the state manager API.

## Sorting Modes

TrinaGrid supports three sorting modes, defined by the `TrinaColumnSort` enum:

### 1. None (`TrinaColumnSort.none`)

This is the default state where no sorting is applied to the column.

### 2. Ascending (`TrinaColumnSort.ascending`)

In this mode, data is sorted from smallest to largest (A to Z, oldest to newest, etc.). For text, this means alphabetical order.

### 3. Descending (`TrinaColumnSort.descending`)

In this mode, data is sorted from largest to smallest (Z to A, newest to oldest, etc.). For text, this means reverse alphabetical order.

## How to Sort Columns

### Using Column Headers (UI)

The most intuitive way to sort columns is through the user interface:

1. Click once on a column header to sort in ascending order
2. Click again on the same column header to switch to descending order
3. Click a third time to remove sorting and return to the original order

As you click on a column header, a sort indicator (arrow) will appear to show the current sort direction.

### Using the State Manager (Programmatic)

You can also sort columns programmatically using the state manager:

```dart
// Sort a column in ascending order
stateManager.sortAscending(column);

// Sort a column in descending order
stateManager.sortDescending(column);

// Toggle sorting (cycles through none -> ascending -> descending -> none)
stateManager.toggleSortColumn(column);
```

## Sorting Behavior

### Type-Aware Sorting

TrinaGrid sorts data based on the column's data type. This ensures that numbers, dates, and text are all sorted appropriately:

- **Text columns**: Sorted alphabetically
- **Number columns**: Sorted numerically
- **Date columns**: Sorted chronologically
- **Custom type columns**: Sorted based on the custom comparison logic defined in the column type

### Row Groups

When row grouping is enabled, sorting respects the group structure:

1. Rows within each group are sorted according to the selected column
2. The groups themselves maintain their original order

## Events

When columns are sorted, TrinaGrid fires events that you can listen to:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onSorted: (TrinaGridOnSortedEvent event) {
    // Handle column sorted event
    print('Column sorted: ${event.column.title}');
    print('New sort order: ${event.column.sort}');
    print('Previous sort order: ${event.oldSort}');
  },
)
```

The `TrinaGridOnSortedEvent` provides:

- `column`: The column that was sorted
- `oldSort`: The previous sort state before the change

## Example

Here's a complete example demonstrating column sorting:

```dart
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

class ColumnSortingExample extends StatefulWidget {
  @override
  _ColumnSortingExampleState createState() => _ColumnSortingExampleState();
}

class _ColumnSortingExampleState extends State<ColumnSortingExample> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];
  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.number(),
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Date',
        field: 'date',
        type: TrinaColumnType.date(),
      ),
    ]);

    rows.addAll([
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 3),
          'name': TrinaCell(value: 'Charlie'),
          'date': TrinaCell(value: DateTime(2023, 3, 15)),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 1),
          'name': TrinaCell(value: 'Alice'),
          'date': TrinaCell(value: DateTime(2023, 1, 10)),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 2),
          'name': TrinaCell(value: 'Bob'),
          'date': TrinaCell(value: DateTime(2023, 2, 20)),
        },
      ),
    ]);
  }

  void _sortIdAscending() {
    final idColumn = columns.firstWhere((col) => col.field == 'id');
    stateManager.sortAscending(idColumn);
  }

  void _sortIdDescending() {
    final idColumn = columns.firstWhere((col) => col.field == 'id');
    stateManager.sortDescending(idColumn);
  }

  void _sortNameAscending() {
    final nameColumn = columns.firstWhere((col) => col.field == 'name');
    stateManager.sortAscending(nameColumn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Column Sorting Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _sortIdAscending,
                  child: Text('Sort ID Ascending'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sortIdDescending,
                  child: Text('Sort ID Descending'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sortNameAscending,
                  child: Text('Sort Name Ascending'),
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
              onSorted: (TrinaGridOnSortedEvent event) {
                print('Column sorted: ${event.column.title}');
                print('New sort order: ${event.column.sort}');
                print('Previous sort order: ${event.oldSort}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## Customizing Sort Behavior

### Disabling Sorting for Specific Columns

You can disable sorting for specific columns by setting the `enableSorting` property to `false`:

```dart
TrinaColumn(
  title: 'Actions',
  field: 'actions',
  type: TrinaColumnType.text(),
  enableSorting: false, // Disable sorting for this column
)
```

### Custom Sorting Logic

You can implement custom sorting logic by creating a custom column type with a custom `compare` method:

```dart
class CustomColumnType extends TrinaColumnType {
  const CustomColumnType();

  @override
  int compare(dynamic a, dynamic b) {
    // Implement your custom comparison logic here
    // Return negative if a < b, 0 if a == b, positive if a > b
    return customCompare(a, b);
  }
  
  // Other required overrides...
}
```

## Multi-Column Sorting

TrinaGrid supports multi-column sorting, allowing users and developers to sort rows across multiple columns in priority order (compound sorting).

### Enabling Multi-Column Sorting

Multi-column sorting via keyboard modifiers is enabled through `TrinaGridConfiguration`:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: const TrinaGridConfiguration(
    enableMultiColumnSort: true, // Enable Shift-click and Ctrl-click multi-sort
  ),
)
```

### User Interaction

When `enableMultiColumnSort` is enabled:
- **Click**: Performs a standard single-column sort, resetting any previous sorts.
- **Shift + Click** or **Ctrl + Click**: Appends the clicked column to the sort hierarchy without clearing existing sorts.
- **Priority Indicators**: When multiple columns are sorted, each header displays a priority badge number (1, 2, 3...) next to the sort direction icon indicating its sort precedence.
- Clicking an active column with Shift/Ctrl cycles its sort state (`ascending` -> `descending` -> `none`). When a column is un-sorted, the remaining sorted columns automatically re-rank their priority badges.

### Initial Multi-Column Sorting via Constructors

You can define initial sort states directly on column definitions:

```dart
final columns = [
  TrinaColumn(
    title: 'Department',
    field: 'dept',
    type: TrinaColumnType.text(),
    sort: TrinaColumnSort.ascending,
    sortPriority: 1,
  ),
  TrinaColumn(
    title: 'Score',
    field: 'score',
    type: TrinaColumnType.number(),
    sort: TrinaColumnSort.descending,
    sortPriority: 2,
  ),
];
```

If `sort` is set without specifying `sortPriority`, TrinaGrid automatically assigns sequential priorities to all initial sorted columns.

### Programmatic Multi-Column Sorting

Use the `append` parameter on sorting methods to build multi-column sorts programmatically:

```dart
// Primary sort by department ascending
stateManager.sortAscending(deptColumn);

// Secondary sort by score descending (appended)
stateManager.sortDescending(scoreColumn, append: true);

// Tertiary sort by name ascending (appended)
stateManager.sortAscending(nameColumn, append: true);

// Inspect currently sorted columns ordered by priority
final List<TrinaColumn> activeSorts = stateManager.sortedColumns;

// Clear all active sorting at once
stateManager.clearSorting();
```

### Server-Side Multi-Column Sorting

Both `TrinaLazyPagination` and `TrinaInfinityScrollRows` provide the full list of sorted columns via `request.sortedColumns`:

```dart
TrinaLazyPagination(
  stateManager: stateManager,
  fetch: (request) async {
    // Access all sorted columns in priority order:
    for (final column in request.sortedColumns) {
      print('Sort by ${column.field}: ${column.sort.name} (priority: ${column.sortPriority})');
    }

    // Single-column fallback (returns the first sorted column):
    final primaryColumn = request.sortColumn;

    return TrinaLazyPaginationResponse(
      totalPage: totalPages,
      totalRecords: totalCount,
      rows: fetchedRows,
    );
  },
)
```

## Best Practices

1. **Choose Appropriate Column Types**: Make sure to set the appropriate column type (text, number, date, etc.) to ensure proper sorting behavior.

2. **Provide Sort Indicators**: TrinaGrid automatically adds sort indicators to column headers, but make sure they are visible and clear to users.

3. **Handle Sort Events**: Listen to sort events to update any dependent UI or perform additional actions when sorting changes.

4. **Consider Performance**: For very large datasets, consider implementing server-side sorting to improve performance.

5. **Combine with Filtering**: Sorting works well in combination with filtering, allowing users to find and organize data more efficiently.

## Related Features

- [Column Types](column-types.md)
- [Column Filtering](column-filtering.md)
- [Column Resizing](column-resizing.md)
- [Column Moving](column-moving.md)
