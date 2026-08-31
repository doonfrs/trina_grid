# Column Filtering

Column filtering is a powerful feature that allows users to display only the rows that match specific criteria. This feature enhances data analysis by enabling users to focus on relevant information and quickly find specific values within large datasets.

## Overview

TrinaGrid provides a comprehensive column filtering system that supports various filter types for different column data types. Users can filter data through a dedicated filter row that appears below the column headers, and developers can also programmatically apply filters using the state manager API.

## Enabling Column Filtering

To enable column filtering in your TrinaGrid, you need to set the `showColumnFilter` property to `true`:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onLoaded: (TrinaGridOnLoadedEvent event) {
    // Enable column filtering
    event.stateManager.setShowColumnFilter(true);
  },
)
```

When column filtering is enabled, a filter row appears below the column headers, allowing users to enter filter criteria for each column.

## Filter Types

TrinaGrid includes several built-in filter types that can be used to filter data in different ways:

### Text Filters

- **Contains** (`TrinaFilterTypeContains`): Matches rows where the cell value contains the search text
- **Equals** (`TrinaFilterTypeEquals`): Matches rows where the cell value exactly matches the search text
- **Starts With** (`TrinaFilterTypeStartsWith`): Matches rows where the cell value starts with the search text
- **Ends With** (`TrinaFilterTypeEndsWith`): Matches rows where the cell value ends with the search text
- **Regex** (`TrinaFilterTypeRegex`): Matches rows where the cell value matches the regular expression pattern

#### Regular Expression (Regex) Filter Example

The Regex filter allows more advanced pattern matching:

```dart
// Example: Filter for email addresses
// Pattern: .+@.+\..+
// Matches: user@example.com, info@domain.co.uk

// Example: Filter for numbers
// Pattern: ^\d+$
// Matches: 123, 456789

// Example: Filter for specific patterns like product codes
// Pattern: ^[A-Z]{3}\d{4}$
// Matches: ABC1234, XYZ5678
```

### Numeric Filters

- **Greater Than** (`TrinaFilterTypeGreaterThan`): Matches rows where the cell value is greater than the search value
- **Greater Than or Equal To** (`TrinaFilterTypeGreaterThanOrEqualTo`): Matches rows where the cell value is greater than or equal to the search value
- **Less Than** (`TrinaFilterTypeLessThan`): Matches rows where the cell value is less than the search value
- **Less Than or Equal To** (`TrinaFilterTypeLessThanOrEqualTo`): Matches rows where the cell value is less than or equal to the search value

## Filter UI

The filter UI consists of:

1. **Filter Row**: A row below the column headers where users can enter filter criteria
2. **Filter Type Selector**: A dropdown menu that allows users to select the type of filter to apply
3. **Filter Input Field**: A text field where users can enter the filter value

Users can click on the filter icon in a column to open the filter type selector and choose the appropriate filter type for that column.

## Filter Widget Modes

The widget rendered in the filter row is resolved automatically from the column type:

| Column type | Filter widget |
| --- | --- |
| `TrinaColumnTypeBoolean` | Dropdown with **ALL / True / False** |
| `TrinaColumnTypeSelect` (with `enableColumnFilter: true`, the default) | Checkbox multi-select dropdown with a **Select all** toggle |
| Any other type | Text field |

- **Boolean dropdown**: selecting **True** / **False** keeps only the rows whose cell value is `true` / `false`. Selecting **ALL** clears the filter.
- **Multi-select dropdown**: shows one checkbox per item (the column items, or the values produced by `itemToValue`). Every check/uncheck re-filters the grid immediately and the menu stays open; unchecking everything clears the filter. Rows match when their cell value equals any of the checked items (`TrinaFilterTypeMultiItems`).

```dart
final columns = [
  // Text column: regular text filter.
  TrinaColumn(title: 'Name', field: 'name', type: TrinaColumnType.text()),

  // Boolean column: ALL / True / False dropdown filter.
  TrinaColumn(
    title: 'Is Active',
    field: 'is_active',
    type: TrinaColumnType.boolean(),
  ),

  // Select column: checkbox multi-select filter with the column items.
  TrinaColumn(
    title: 'Hobby',
    field: 'hobby',
    type: TrinaColumnType.select(['swimming', 'gym', 'reading']),
  ),
];
```

### Overriding the Automatic Resolution

Use `TrinaColumn.filterWidgetDelegate` to force a mode on any column, or to opt out:

```dart
// Force the boolean dropdown on any column.
TrinaColumn(
  filterWidgetDelegate: const TrinaFilterColumnWidgetDelegate.booleanSelect(),
),

// Force the checkbox multi-select filter on any column.
TrinaColumn(
  filterWidgetDelegate: const TrinaFilterColumnWidgetDelegate.multiSelect(
    multiSelectItems: ['swimming', 'gym', 'reading'],
    caseSensitive: false,
  ),
),

// Keep the plain text filter on a boolean or select column.
TrinaColumn(
  type: TrinaColumnType.boolean(),
  filterWidgetDelegate: const TrinaFilterColumnWidgetDelegate.textField(),
),
```

A select column can also opt out of the checkbox filter with the column type flag:

```dart
TrinaColumnType.select(hobbies, enableColumnFilter: false)
```

The dropdown labels (ALL, True, False, Select all) are localizable through
`TrinaGridLocaleText.filterAll`, `filterTrue`, `filterFalse` and
`filterSelectAll`.

## Filtering Behavior

### Column-Specific Filtering

By default, filters are applied to specific columns. When a user enters a filter value for a column, only that column's values are checked against the filter criteria.

### All-Column Filtering

TrinaGrid also supports filtering across all columns. This allows users to search for a value anywhere in the grid, regardless of which column it appears in.

### Multiple Filters

Users can apply multiple filters to different columns simultaneously. When multiple filters are applied, rows must match all filter criteria to be displayed (AND logic).

## Configuring Column Filtering

You can customize the column filtering behavior through the `columnFilter` configuration:

```dart
TrinaGridConfiguration(
  columnFilter: TrinaGridColumnFilterConfig(
    // Configuration options for filtering
  ),
  style: TrinaGridStyleConfig(
    // Control visibility and appearance of filter icons
    filterIcon: Icon(Icons.filter_list), // Custom filter icon
    // or
    filterIcon: null, // Hide filter icons
  ),
)
```

### Filter Icon Customization

By default, when a filter is applied to a column, a filter icon appears next to the column title. You can customize or hide this icon with the `filterIcon` property in the style configuration:

```dart
TrinaGridConfiguration(
  style: TrinaGridStyleConfig(
    // Use a custom icon
    filterIcon: Icon(Icons.search),
    
    // Or hide filter icons completely
    filterIcon: null,
  ),
)
```

When `filterIcon` is set to `null`, filter icons will not be displayed in column titles, even when filters are applied. You can also provide a custom icon to change the appearance.

### Disabling Filtering for Specific Columns

You can disable filtering for specific columns by setting the `enableFilterMenuItem` property to `false`:

```dart
TrinaColumn(
  title: 'Actions',
  field: 'actions',
  type: TrinaColumnType.text(),
  enableFilterMenuItem: false, // Disable filtering for this column
)
```

## Custom Filters

You can create custom filter types by implementing the `TrinaFilterType` interface:

```dart
class CustomFilter implements TrinaFilterType {
  @override
  String get title => 'Custom Filter';

  @override
  get compare => ({
        required String? base,
        required String? search,
        required TrinaColumn? column,
      }) {
        // Implement your custom filtering logic here
        // Return true if the row should be included, false otherwise
        return customFilterLogic(base, search);
      };

  const CustomFilter();
}
```

Then add your custom filter to the `filters` list in the `columnFilter` configuration.

## Multi-Items Filter (Multi-line/Comma-separated)

![Multi-Items Filter Demo](https://raw.githubusercontent.com/doonfrs/trina_grid/master/doc/assets/multi-items-filter.gif)

TrinaGrid provides a built-in multi-items filter type for columns, allowing users to filter rows by matching any value from a list of items. This is useful for scenarios where you want to filter by multiple possible values at once, using either comma-separated or multi-line input.

- **Filter type:** `TrinaFilterTypeMultiItems`
- **Widget delegate:** `TrinaFilterColumnWidgetDelegate.multiItems`
- **Case sensitivity:** Configurable (default: true)

### How it works

- The filter value is split by commas or newlines.
- Each item is trimmed.
- The cell value is compared to each item (case-sensitive by default).
- If any item matches, the row is included.

### Example: Case-insensitive multi-items filter

```dart
TrinaColumn(
  title: 'Tags',
  field: 'tags',
  type: TrinaColumnType.text(),
  filterWidgetDelegate: const TrinaFilterColumnWidgetDelegate.multiItems(caseSensitive: false),
)

// In your grid configuration:
TrinaGridConfiguration(
  columnFilter: TrinaGridColumnFilterConfig(
    filters: const [
      ...FilterHelper.defaultFilters,
      TrinaFilterTypeMultiItems(caseSensitive: false),
    ],
    resolveDefaultColumnFilter: (column, resolver) {
      if (column.field == 'tags') {
        return const TrinaFilterTypeMultiItems(caseSensitive: false);
      }
      return resolver<TrinaFilterTypeContains>();
    },
  ),
)
```

### Setting case sensitivity

- Pass `caseSensitive: false` to make the filter ignore case.
- The option is available both in the filter type and the widget delegate.

### UI

- The multi-items filter uses a multi-line text field by default.
- Users can enter values separated by commas or new lines.

### When to use

- When you want to allow users to filter by multiple possible values in a single column.
- For tag, category, or label columns, or any scenario where multi-value matching is needed.

See also: [Column Types](column-types.md), [Custom Filters](#custom-filters)

## Programmatic Filtering

TrinaGrid provides two approaches for programmatically applying filters: the new simplified API methods and the traditional filter row approach.

### New Simplified API (Recommended)

The state manager now provides convenient methods for managing column filters programmatically:

#### Setting Column Filters

```dart
// Set or update a specific column filter
stateManager.setColumnFilter(
  columnField: 'department',
  filterType: const TrinaFilterTypeEquals(),
  filterValue: 'Engineering',
);

// Set boolean filters
stateManager.setColumnFilter(
  columnField: 'active',
  filterType: const TrinaFilterTypeEquals(),
  filterValue: true,
);

// Set numeric filters
stateManager.setColumnFilter(
  columnField: 'salary',
  filterType: const TrinaFilterTypeGreaterThan(),
  filterValue: 60000,
);

// Set text contains filters
stateManager.setColumnFilter(
  columnField: 'name',
  filterType: const TrinaFilterTypeContains(),
  filterValue: 'John',
);
```

#### Removing Column Filters

```dart
// Remove a specific column filter
stateManager.removeColumnFilter('department');

// Clear all column filters at once
stateManager.clearAllColumnFilters();
```

#### Getting Current Filter Values

```dart
// Get the current filter value for a specific column
dynamic currentValue = stateManager.getColumnFilterValue('department');
if (currentValue != null) {
  print('Department is filtered by: $currentValue');
}

// Get the current filter type for a specific column
TrinaFilterType? currentFilterType = stateManager.getColumnFilterType('department');
if (currentFilterType != null) {
  if (currentFilterType is TrinaFilterTypeEquals) {
    print('Department filter uses exact matching');
  } else if (currentFilterType is TrinaFilterTypeContains) {
    print('Department filter uses contains matching');
  }
}

// Check if a column has any filter applied
bool isDepartmentFiltered = stateManager.getColumnFilterValue('department') != null;

// Example: Toggle a filter based on current state
void toggleActiveFilter() {
  dynamic currentValue = stateManager.getColumnFilterValue('active');
  if (currentValue == null) {
    // No filter applied, filter for active records
    stateManager.setColumnFilter(
      columnField: 'active',
      filterType: const TrinaFilterTypeEquals(),
      filterValue: true,
    );
  } else {
    // Filter already applied, remove it
    stateManager.removeColumnFilter('active');
  }
}
```

#### Practical Example

```dart
// Apply multiple filters programmatically
void applyBusinessLogicFilters() {
  // Filter for active employees only
  stateManager.setColumnFilter(
    columnField: 'active',
    filterType: const TrinaFilterTypeEquals(),
    filterValue: true,
  );
  
  // Filter for engineering department
  stateManager.setColumnFilter(
    columnField: 'department',
    filterType: const TrinaFilterTypeEquals(),
    filterValue: 'Engineering',
  );
  
  // Filter for high salaries
  stateManager.setColumnFilter(
    columnField: 'salary',
    filterType: const TrinaFilterTypeGreaterThan(),
    filterValue: 80000,
  );
}

// Clear specific filters
void clearDepartmentFilter() {
  stateManager.removeColumnFilter('department');
}

// Reset all filters
void resetAllFilters() {
  stateManager.clearAllColumnFilters();
}
```

### Traditional Filter Row Approach

You can also programmatically apply filters using the traditional filter row approach:

```dart
// Create a filter row
TrinaRow filterRow = FilterHelper.createFilterRow(
  columnField: 'column_field',
  filterType: const TrinaFilterTypeContains(),
  filterValue: 'search_value',
);

// Apply the filter
stateManager.setFilterRows([filterRow]);
```

To filter across all columns:

```dart
TrinaRow filterRow = FilterHelper.createFilterRow(
  columnField: FilterHelper.filterFieldAllColumns,
  filterType: const TrinaFilterTypeContains(),
  filterValue: 'search_value',
);

stateManager.setFilterRows([filterRow]);
```

To clear all filters:

```dart
stateManager.setFilterRows([]);
```

## Events

When filters are applied, TrinaGrid updates its display and notifies listeners. You can listen to these changes through the `onChanged` callback:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onChanged: (TrinaGridOnChangedEvent event) {
    // Handle grid changes, including filtering
    if (event.type == TrinaGridChangeEventType.filterRows) {
      print('Filters changed');
    }
  },
)
```

## Example

Here's a complete example demonstrating column filtering:

```dart
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

class ColumnFilteringExample extends StatefulWidget {
  @override
  _ColumnFilteringExampleState createState() => _ColumnFilteringExampleState();
}

class _ColumnFilteringExampleState extends State<ColumnFilteringExample> {
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
        title: 'Department',
        field: 'department',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Salary',
        field: 'salary',
        type: TrinaColumnType.number(),
      ),
    ]);

    rows.addAll([
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 1),
          'name': TrinaCell(value: 'John Smith'),
          'department': TrinaCell(value: 'Engineering'),
          'salary': TrinaCell(value: 85000),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 2),
          'name': TrinaCell(value: 'Jane Doe'),
          'department': TrinaCell(value: 'Marketing'),
          'salary': TrinaCell(value: 75000),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 3),
          'name': TrinaCell(value: 'Bob Johnson'),
          'department': TrinaCell(value: 'Engineering'),
          'salary': TrinaCell(value: 90000),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 4),
          'name': TrinaCell(value: 'Alice Williams'),
          'department': TrinaCell(value: 'Sales'),
          'salary': TrinaCell(value: 80000),
        },
      ),
    ]);
  }

  void _filterEngineering() {
    // Filter for Engineering department using the new simplified API
    stateManager.setColumnFilter(
      columnField: 'department',
      filterType: const TrinaFilterTypeEquals(),
      filterValue: 'Engineering',
    );
  }

  void _filterHighSalary() {
    // Filter for salaries > 80000 using the new simplified API
    stateManager.setColumnFilter(
      columnField: 'salary',
      filterType: const TrinaFilterTypeGreaterThan(),
      filterValue: 80000, // Note: numeric value, not string
    );
  }

  void _clearFilters() {
    // Clear all filters using the new simplified API
    stateManager.clearAllColumnFilters();
  }

  void _filterMultiple() {
    // Example of applying multiple filters
    stateManager.setColumnFilter(
      columnField: 'department',
      filterType: const TrinaFilterTypeEquals(),
      filterValue: 'Engineering',
    );
    
    stateManager.setColumnFilter(
      columnField: 'salary',
      filterType: const TrinaFilterTypeGreaterThan(),
      filterValue: 80000,
    );
  }

  void _removeSpecificFilter() {
    // Remove only the department filter
    stateManager.removeColumnFilter('department');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Column Filtering Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _filterEngineering,
                  child: Text('Filter Engineering'),
                ),
                ElevatedButton(
                  onPressed: _filterHighSalary,
                  child: Text('Filter Salary > 80000'),
                ),
                ElevatedButton(
                  onPressed: _filterMultiple,
                  child: Text('Multiple Filters'),
                ),
                ElevatedButton(
                  onPressed: _removeSpecificFilter,
                  child: Text('Remove Dept Filter'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
                ElevatedButton(
                  onPressed: _clearFilters,
                  child: Text('Clear All Filters'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
                // Enable column filtering
                stateManager.setShowColumnFilter(true);
              },
              onChanged: (TrinaGridOnChangedEvent event) {
                print('Grid changed: ${event.type}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## Controlling Keyboard Navigation in Column Filters

By default, when users press the Enter key in a column filter, the focus moves to the next field (usually the grid cell below). This behavior follows the grid's global `enterKeyAction` configuration.

However, in some scenarios you might want to prevent this behavior for specific columns. For example, when a column filter needs to capture the Enter key for submitting a search or when working with multi-line filters.

### Column-Specific Enter Key Behavior

TrinaGrid allows you to override the default Enter key behavior for individual column filters using the `filterEnterKeyAction` property:

```dart
TrinaColumn(
  title: 'Description',
  field: 'description',
  type: TrinaColumnType.text(),
  // Prevent Enter key from moving focus in this column's filter
  filterEnterKeyAction: TrinaGridEnterKeyAction.none,
)
```

### Available Options

The `filterEnterKeyAction` property accepts the same values as the grid-level `enterKeyAction` configuration:

- **`TrinaGridEnterKeyAction.editingAndMoveDown`**: (Default) Moves focus to the cell below when Enter is pressed
- **`TrinaGridEnterKeyAction.editingAndMoveRight`**: Moves focus to the cell to the right when Enter is pressed
- **`TrinaGridEnterKeyAction.toggleEditing`**: Toggles editing state without moving focus
- **`TrinaGridEnterKeyAction.none`**: Disables Enter key navigation, allowing the key press to be handled by other listeners

### Example: Preventing Enter Key Navigation for a Specific Column

```dart
List<TrinaColumn> columns = [
  TrinaColumn(
    title: 'ID',
    field: 'id',
    type: TrinaColumnType.number(),
    // Uses the default Enter key behavior from grid configuration
  ),
  TrinaColumn(
    title: 'Name',
    field: 'name',
    type: TrinaColumnType.text(),
    // Uses the default Enter key behavior from grid configuration
  ),
  TrinaColumn(
    title: 'Description',
    field: 'description',
    type: TrinaColumnType.text(),
    // Override Enter key behavior for this column's filter only
    filterEnterKeyAction: TrinaGridEnterKeyAction.none,
    // This allows the filter to handle the Enter key internally
    // without moving focus to the next field
  ),
];

// Grid configuration with default Enter key behavior
TrinaGridConfiguration configuration = TrinaGridConfiguration(
  enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveDown,
  // Other configuration options...
);
```

In this example, pressing Enter in the ID or Name column filters will move focus to the cell below, following the grid's default configuration. However, pressing Enter in the Description column filter will not move focus, allowing for custom handling of the Enter key.

## Best Practices

1. **Use the New Simplified API**: Prefer `setColumnFilter()`, `removeColumnFilter()`, and `clearAllColumnFilters()` methods over the traditional filter row approach for cleaner, more maintainable code.

2. **Enable Filtering Selectively**: Only enable filtering for columns where it makes sense. For action columns or columns with complex widgets, filtering may not be relevant.

3. **Choose Appropriate Default Filters**: Set default filter types that make sense for each column's data type. For example, use "Contains" for text columns and "Greater Than" for numeric columns.

4. **Provide Clear UI Indicators**: Ensure that users can easily see which filters are currently applied. TrinaGrid automatically highlights filtered columns.

5. **Use Proper Data Types**: When using `setColumnFilter()`, use the appropriate data types (e.g., numeric values for number columns, boolean values for boolean columns) rather than always using strings.

6. **Consider Performance**: For very large datasets, consider implementing server-side filtering to improve performance.

7. **Combine with Sorting**: Filtering works well in combination with sorting, allowing users to find and organize data more efficiently.

8. **Provide Filter Management UI**: Consider adding buttons or controls that allow users to easily clear specific filters or all filters at once using the new API methods.

9. **Save User Preferences**: Consider saving the user's filter preferences to restore them when they return to the grid.

## Related Features

- [Column Types](column-types.md)
- [Column Sorting](column-sorting.md)
- [Column Resizing](column-resizing.md)
- [Column Moving](column-moving.md)
- [Column Hiding](column-hiding.md)
