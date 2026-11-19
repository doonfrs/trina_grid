# Row Groups

Row grouping is a powerful feature in TrinaGrid that allows you to organize and categorize your data in a hierarchical structure. This feature enhances data visualization and analysis by providing a structured view of your data.

## Overview

The row grouping feature enables you to:

- Group rows based on common values in specified columns
- Create hierarchical tree structures for nested data
- Collapse and expand groups to focus on relevant data
- Apply custom styling to group headers
- Show count indicators for the number of items in each group
- Improve data organization and readability

Row grouping is particularly useful when working with large datasets that can be naturally categorized into logical groups or when displaying hierarchical data structures.

## Enabling Row Groups

To enable row grouping in TrinaGrid, you need to set a row group delegate using the `setRowGroup` method on the state manager:

```dart
// After loading the grid
TrinaGrid(
  columns: columns,
  rows: rows,
  onLoaded: (e) {
    // Set up row grouping
    e.stateManager.setRowGroup(
      TrinaRowGroupByColumnDelegate(
        columns: [
          columns[0], // First column to group by
          columns[1], // Second column to group by (for nested groups)
        ],
        showFirstExpandableIcon: false,
      ),
    );
  },
)
```

## Row Group Delegates

TrinaGrid provides two types of row group delegates:

### 1. TrinaRowGroupByColumnDelegate

This delegate groups rows based on common values in specified columns, creating a hierarchical structure based on column values.

```dart
TrinaRowGroupByColumnDelegate(
  columns: [
    columns[0], // Primary grouping column
    columns[1], // Secondary grouping column (for nested groups)
  ],
  showFirstExpandableIcon: false, // Whether to show expand/collapse icon for first level
  showCount: true,                // Whether to show count of items in each group
  enableCompactCount: true,       // Whether to use compact number format for count
  onToggled: ({required row, required expanded}) {
    // Optional callback when a group is expanded or collapsed
    print('Group ${row.cells.values.first.value} is now ${expanded ? 'expanded' : 'collapsed'}');
  },
)
```

### 2. TrinaRowGroupTreeDelegate

This delegate is used for pre-defined tree structures where the hierarchy is already defined in the data model.

```dart
TrinaRowGroupTreeDelegate(
  resolveColumnDepth: (column) => stateManager.columnIndex(column),
  showText: (cell) => true,
  showFirstExpandableIcon: true,
  showCount: true,
  enableCompactCount: true,
  onToggled: ({required row, required expanded}) {
    // Optional callback when a group is expanded or collapsed
  },
)
```

## Configuration Options

Both row group delegates can be configured with the following parameters:

- `showFirstExpandableIcon`: Whether to show expand/collapse icon for the first level of groups
- `showCount`: Whether to show the count of items in each group
- `enableCompactCount`: Whether to use compact number format for the count display
- `onToggled`: Callback function that is triggered when a group is expanded or collapsed

Additionally, each delegate has its own specific parameters:

### TrinaRowGroupByColumnDelegate Parameters

- `columns`: List of columns to group by, in order of grouping hierarchy

### TrinaRowGroupTreeDelegate Parameters

- `resolveColumnDepth`: Function that determines the depth of a column in the tree structure
- `showText`: Function that determines whether to show text for a given cell

## Creating Row Groups

### Column-Based Grouping

To create column-based grouping, provide a list of columns to group by:

```dart
// Create columns
final List<TrinaColumn> columns = [
  TrinaColumn(
    title: 'Category',
    field: 'category',
    type: TrinaColumnType.text(),
  ),
  TrinaColumn(
    title: 'Subcategory',
    field: 'subcategory',
    type: TrinaColumnType.text(),
  ),
  TrinaColumn(
    title: 'Product',
    field: 'product',
    type: TrinaColumnType.text(),
  ),
];

// Create rows with data
final List<TrinaRow> rows = [
  TrinaRow(cells: {
    'category': TrinaCell(value: 'Electronics'),
    'subcategory': TrinaCell(value: 'Phones'),
    'product': TrinaCell(value: 'Smartphone X'),
  }),
  TrinaRow(cells: {
    'category': TrinaCell(value: 'Electronics'),
    'subcategory': TrinaCell(value: 'Phones'),
    'product': TrinaCell(value: 'Smartphone Y'),
  }),
  TrinaRow(cells: {
    'category': TrinaCell(value: 'Electronics'),
    'subcategory': TrinaCell(value: 'Laptops'),
    'product': TrinaCell(value: 'Laptop Z'),
  }),
];

// Enable grouping in the grid
TrinaGrid(
  columns: columns,
  rows: rows,
  onLoaded: (e) {
    e.stateManager.setRowGroup(
      TrinaRowGroupByColumnDelegate(
        columns: [
          columns[0], // Group by Category
          columns[1], // Then by Subcategory
        ],
      ),
    );
  },
)
```

### Tree-Based Grouping

For tree-based grouping, you need to create a hierarchical structure in your rows:

```dart
// Create columns
final List<TrinaColumn> columns = [
  TrinaColumn(
    title: 'Files',
    field: 'files',
    type: TrinaColumnType.text(),
    renderer: (c) {
      IconData icon = c.row.type.isGroup ? Icons.folder : Icons.file_present;
      return Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text(c.cell.value),
        ],
      );
    },
  ),
];

// Create hierarchical rows
final List<TrinaRow> rows = [
  TrinaRow(
    cells: {'files': TrinaCell(value: 'Project')},
    type: TrinaRowType.group(
      children: FilteredList<TrinaRow>(
        initialList: [
          TrinaRow(
            cells: {'files': TrinaCell(value: 'src')},
            type: TrinaRowType.group(
              children: FilteredList<TrinaRow>(
                initialList: [
                  TrinaRow(cells: {'files': TrinaCell(value: 'main.dart')}),
                  TrinaRow(cells: {'files': TrinaCell(value: 'utils.dart')}),
                ],
              ),
            ),
          ),
          TrinaRow(
            cells: {'files': TrinaCell(value: 'test')},
            type: TrinaRowType.group(
              children: FilteredList<TrinaRow>(
                initialList: [
                  TrinaRow(cells: {'files': TrinaCell(value: 'test_app.dart')}),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
];

// Enable tree-based grouping
TrinaGrid(
  columns: columns,
  rows: rows,
  onLoaded: (e) {
    e.stateManager.setRowGroup(
      TrinaRowGroupTreeDelegate(
        resolveColumnDepth: (column) => e.stateManager.columnIndex(column),
        showText: (cell) => true,
        showFirstExpandableIcon: true,
      ),
    );
  },
)
```

## Styling Group Rows

You can apply custom styling to group rows using the configuration options:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: const TrinaGridConfiguration(
    style: TrinaGridStyleConfig(
      cellColorGroupedRow: Color(0x80F6F6F6), // Background color for group rows
      groupRowBorderColor: Colors.grey,        // Border color for group rows
      groupRowBorderWidth: 1.0,                // Border width for group rows
      groupRowTextStyle: TextStyle(           // Text style for group rows
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    ),
  ),
  onLoaded: (e) {
    e.stateManager.setRowGroup(
      TrinaRowGroupByColumnDelegate(
        columns: [columns[0]],
      ),
    );
  },
)
```

## Programmatic Control

You can programmatically control row groups through the state manager:

```dart
// Toggle a specific group row (expand if collapsed, collapse if expanded)
void toggleGroupExpansion(TrinaRow groupRow) {
  if (groupRow.type.isGroup) {
    stateManager.toggleExpandedRowGroup(rowGroup: groupRow);
  }
}

// Explicitly expand a specific group row
void expandGroup(TrinaRow groupRow) {
  if (groupRow.type.isGroup) {
    stateManager.toggleExpandedRowGroup(rowGroup: groupRow, expanded: true);
  }
}

// Explicitly collapse a specific group row
void collapseGroup(TrinaRow groupRow) {
  if (groupRow.type.isGroup) {
    stateManager.toggleExpandedRowGroup(rowGroup: groupRow, expanded: false);
  }
}

// Expand all group rows
void expandAllGroups() {
  stateManager.expandAllRowGroups();
}

// Collapse all group rows
void collapseAllGroups() {
  stateManager.collapseAllRowGroups();
}

// Check if a row is a group row
bool isGroupRow(TrinaRow row) {
  return row.type.isGroup;
}

// Get all group rows
List<TrinaRow> getAllGroupRows() {
  return stateManager.rows.where((row) => row.type.isGroup).toList();
}
```

## Complete Example

Here's a complete example demonstrating both types of row grouping:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

class RowGroupExample extends StatefulWidget {
  @override
  _RowGroupExampleState createState() => _RowGroupExampleState();
}

class _RowGroupExampleState extends State<RowGroupExample> {
  final List<TrinaColumn> columnsA = [];
  final List<TrinaRow> rowsA = [];
  
  final List<TrinaColumn> columnsB = [];
  final List<TrinaRow> rowsB = [];
  
  late TrinaGridStateManager stateManagerA;
  late TrinaGridStateManager stateManagerB;

  @override
  void initState() {
    super.initState();

    // Set up columns for column-based grouping
    columnsA.addAll([
      TrinaColumn(
        title: 'Category',
        field: 'category',
        type: TrinaColumnType.select([
          'Electronics',
          'Clothing',
          'Food',
        ]),
      ),
      TrinaColumn(
        title: 'Subcategory',
        field: 'subcategory',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Product',
        field: 'product',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Price',
        field: 'price',
        type: TrinaColumnType.number(format: '\$#,###.00'),
      ),
    ]);

    // Add rows for column-based grouping
    rowsA.addAll([
      TrinaRow(cells: {
        'category': TrinaCell(value: 'Electronics'),
        'subcategory': TrinaCell(value: 'Phones'),
        'product': TrinaCell(value: 'Smartphone X'),
        'price': TrinaCell(value: 999.99),
      }),
      TrinaRow(cells: {
        'category': TrinaCell(value: 'Electronics'),
        'subcategory': TrinaCell(value: 'Phones'),
        'product': TrinaCell(value: 'Smartphone Y'),
        'price': TrinaCell(value: 799.99),
      }),
      TrinaRow(cells: {
        'category': TrinaCell(value: 'Electronics'),
        'subcategory': TrinaCell(value: 'Laptops'),
        'product': TrinaCell(value: 'Laptop Z'),
        'price': TrinaCell(value: 1299.99),
      }),
      TrinaRow(cells: {
        'category': TrinaCell(value: 'Clothing'),
        'subcategory': TrinaCell(value: 'Shirts'),
        'product': TrinaCell(value: 'T-Shirt'),
        'price': TrinaCell(value: 29.99),
      }),
      TrinaRow(cells: {
        'category': TrinaCell(value: 'Clothing'),
        'subcategory': TrinaCell(value: 'Pants'),
        'product': TrinaCell(value: 'Jeans'),
        'price': TrinaCell(value: 49.99),
      }),
    ]);

    // Set up columns for tree-based grouping
    columnsB.addAll([
      TrinaColumn(
        title: 'Files',
        field: 'files',
        type: TrinaColumnType.text(),
        renderer: (c) {
          IconData icon = c.row.type.isGroup ? Icons.folder : Icons.file_present;
          return Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 10),
              Text(c.cell.value),
            ],
          );
        },
      ),
    ]);

    // Add rows for tree-based grouping
    rowsB.addAll([
      TrinaRow(
        cells: {'files': TrinaCell(value: 'Project')},
        type: TrinaRowType.group(
          children: FilteredList<TrinaRow>(
            initialList: [
              TrinaRow(
                cells: {'files': TrinaCell(value: 'src')},
                type: TrinaRowType.group(
                  children: FilteredList<TrinaRow>(
                    initialList: [
                      TrinaRow(cells: {'files': TrinaCell(value: 'main.dart')}),
                      TrinaRow(cells: {'files': TrinaCell(value: 'utils.dart')}),
                    ],
                  ),
                ),
              ),
              TrinaRow(
                cells: {'files': TrinaCell(value: 'test')},
                type: TrinaRowType.group(
                  children: FilteredList<TrinaRow>(
                    initialList: [
                      TrinaRow(cells: {'files': TrinaCell(value: 'test_app.dart')}),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Row Group Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.unfold_more),
            onPressed: () {
              stateManagerA.expandAllRowGroups();
              stateManagerB.expandAllRowGroups();
            },
            tooltip: 'Expand All Groups',
          ),
          IconButton(
            icon: Icon(Icons.unfold_less),
            onPressed: () {
              stateManagerA.collapseAllRowGroups();
              stateManagerB.collapseAllRowGroups();
            },
            tooltip: 'Collapse All Groups',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Column-Based Grouping',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: TrinaGrid(
                    columns: columnsA,
                    rows: rowsA,
                    configuration: const TrinaGridConfiguration(
                      style: TrinaGridStyleConfig(
                        cellColorGroupedRow: Color(0x80F6F6F6),
                      ),
                    ),
                    onLoaded: (e) {
                      stateManagerA = e.stateManager;
                      e.stateManager.setRowGroup(
                        TrinaRowGroupByColumnDelegate(
                          columns: [
                            columnsA[0], // Group by Category
                            columnsA[1], // Then by Subcategory
                          ],
                          showFirstExpandableIcon: false,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Tree-Based Grouping',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: TrinaGrid(
                    columns: columnsB,
                    rows: rowsB,
                    configuration: const TrinaGridConfiguration(
                      style: TrinaGridStyleConfig(
                        cellColorGroupedRow: Color(0x80F6F6F6),
                      ),
                      columnSize: TrinaGridColumnSizeConfig(
                        autoSizeMode: TrinaAutoSizeMode.equal,
                      ),
                    ),
                    onLoaded: (e) {
                      stateManagerB = e.stateManager;
                      e.stateManager.setRowGroup(
                        TrinaRowGroupTreeDelegate(
                          resolveColumnDepth: (column) => e.stateManager.columnIndex(column),
                          showText: (cell) => true,
                          showFirstExpandableIcon: true,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## Best Practices

1. **Choose the Right Delegate**: Use `TrinaRowGroupByColumnDelegate` for data that naturally groups by column values, and `TrinaRowGroupTreeDelegate` for pre-defined hierarchical structures.

2. **Limit Group Depth**: While nesting is powerful, limit the depth to 2-3 levels to maintain usability and prevent excessive indentation.

3. **Provide Visual Cues**: Use icons and styling to clearly distinguish between group rows and regular data rows.

4. **Include Expand/Collapse Controls**: Add UI controls to expand or collapse all groups for better user experience.

5. **Show Group Counts**: Enable the `showCount` option to give users a quick overview of how many items are in each group.

6. **Optimize Performance**: For large datasets, consider loading data on-demand when groups are expanded to improve performance.

## Related Features

- [Frozen Rows](frozen-rows.md): Keep important rows visible while scrolling
- [Row Selection](row-selection.md): Select rows for operations
- [Row Coloring](row-color.md): Apply custom colors to rows
- [Column Groups](column-groups.md): Group columns into categories
