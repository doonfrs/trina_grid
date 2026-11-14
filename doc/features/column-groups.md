# Column Groups

Column groups are a feature that allows you to organize columns into hierarchical groups, providing a more structured and intuitive way to present complex data in TrinaGrid.

## Overview

Column groups enable you to create a multi-level header structure by grouping related columns together. This helps users understand the relationship between different columns and makes it easier to navigate and comprehend large datasets with many columns.

## Creating Column Groups

Column groups are defined using the `TrinaColumnGroup` class. You can create a column group in two ways:

1. By specifying a list of column fields that belong to the group
2. By specifying a list of child column groups to create a nested hierarchy

### Basic Column Group

To create a basic column group that contains specific columns:

```dart
TrinaColumnGroup(
  title: 'Personal Information',
  fields: ['firstName', 'lastName', 'email'],
)
```

This creates a group titled "Personal Information" that spans the columns with fields 'firstName', 'lastName', and 'email'.

### Nested Column Groups

You can create a hierarchical structure by nesting column groups:

```dart
TrinaColumnGroup(
  title: 'Contact Information',
  children: [
    TrinaColumnGroup(
      title: 'Name',
      fields: ['firstName', 'lastName'],
    ),
    TrinaColumnGroup(
      title: 'Communication',
      fields: ['email', 'phone'],
    ),
  ],
)
```

This creates a parent group "Contact Information" with two child groups: "Name" and "Communication".

## Expanded Columns

You can designate a column as an "expanded column" within a group. This is useful for columns that should take up more visual space:

```dart
TrinaColumnGroup(
  title: 'Description',
  fields: ['description'],
  expandedColumn: true,
)
```

When a column group has `expandedColumn` set to `true`:

- The group must contain exactly one column
- The column will expand to fill available space
- The group title is not shown
- The height is set to the maximum depth of the group hierarchy

## Styling Column Groups

You can customize the appearance of column groups:

```dart
TrinaColumnGroup(
  title: 'Financial Data',
  fields: ['revenue', 'expenses', 'profit'],
  backgroundColor: Colors.lightBlue.shade100,
  titleTextAlign: TrinaColumnTextAlign.center,
  titlePadding: EdgeInsets.symmetric(vertical: 8.0),
)
```

### Available Styling Options

- **backgroundColor**: Sets the background color of the group header
- **titleTextAlign**: Controls the alignment of the title text (left, center, right)
- **titlePadding**: Adjusts the padding around the title
- **titleSpan**: Allows for rich text formatting using TextSpan or WidgetSpan

## Using Column Groups in TrinaGrid

To use column groups in your TrinaGrid, pass a list of column groups to the `columnGroups` parameter:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  columnGroups: columnGroups,
  // other parameters...
)
```

## Column Group Behavior

### Column Movement

When columns are moved:

- If a column is moved outside its group, it is removed from the group
- If all columns are removed from a group, the group is automatically removed
- Columns can be moved between groups, which will update the group structure accordingly

### Column Hiding

When columns are hidden:

- If all columns in a group are hidden, the group is not displayed
- When a hidden column is shown again, it returns to its original group

### Column Resizing

Column resizing works normally within column groups:

- Resizing a column affects only that column, not the entire group
- The group width automatically adjusts to accommodate the total width of its columns

## Example

Here's a complete example demonstrating column groups:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

class ColumnGroupExample extends StatefulWidget {
  @override
  _ColumnGroupExampleState createState() => _ColumnGroupExampleState();
}

class _ColumnGroupExampleState extends State<ColumnGroupExample> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];
  final List<TrinaColumnGroup> columnGroups = [];
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
        title: 'First Name',
        field: 'firstName',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Last Name',
        field: 'lastName',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Email',
        field: 'email',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Phone',
        field: 'phone',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Department',
        field: 'department',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Position',
        field: 'position',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Notes',
        field: 'notes',
        type: TrinaColumnType.text(),
        width: 200,
      ),
    ]);

    // Define rows
    rows.addAll([
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 1),
          'firstName': TrinaCell(value: 'John'),
          'lastName': TrinaCell(value: 'Smith'),
          'email': TrinaCell(value: 'john.smith@example.com'),
          'phone': TrinaCell(value: '555-123-4567'),
          'department': TrinaCell(value: 'Engineering'),
          'position': TrinaCell(value: 'Senior Developer'),
          'notes': TrinaCell(value: 'Team lead for Project X'),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 2),
          'firstName': TrinaCell(value: 'Jane'),
          'lastName': TrinaCell(value: 'Doe'),
          'email': TrinaCell(value: 'jane.doe@example.com'),
          'phone': TrinaCell(value: '555-987-6543'),
          'department': TrinaCell(value: 'Marketing'),
          'position': TrinaCell(value: 'Marketing Manager'),
          'notes': TrinaCell(value: 'Handles social media campaigns'),
        },
      ),
      // Add more rows as needed
    ]);

    // Define column groups
    columnGroups.addAll([
      TrinaColumnGroup(
        title: 'ID',
        fields: ['id'],
      ),
      TrinaColumnGroup(
        title: 'Personal Information',
        backgroundColor: Colors.lightBlue.shade100,
        children: [
          TrinaColumnGroup(
            title: 'Name',
            fields: ['firstName', 'lastName'],
            backgroundColor: Colors.lightBlue.shade50,
          ),
          TrinaColumnGroup(
            title: 'Contact',
            fields: ['email', 'phone'],
            backgroundColor: Colors.lightBlue.shade50,
          ),
        ],
      ),
      TrinaColumnGroup(
        title: 'Job Information',
        backgroundColor: Colors.amber.shade100,
        fields: ['department', 'position'],
      ),
      TrinaColumnGroup(
        title: 'Additional Information',
        fields: ['notes'],
        expandedColumn: true,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Column Groups Example')),
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        columnGroups: columnGroups,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
        },
      ),
    );
  }
}
```

## Best Practices

1. **Logical Grouping**: Group columns based on logical relationships or categories that make sense for your data.

2. **Limit Nesting Depth**: While you can nest groups to any depth, too many levels can become confusing. Try to limit nesting to 2-3 levels for better usability.

3. **Consistent Styling**: Use consistent styling for groups of the same level to create a visual hierarchy. For example, use darker colors for top-level groups and lighter shades for nested groups.

4. **Clear Naming**: Use clear, concise titles for your column groups that accurately describe the data they contain.

5. **Consider Expanded Columns**: Use the `expandedColumn` property for columns that contain lengthy text or detailed information that benefits from additional space.

6. **Combine with Freezing**: Consider freezing important column groups on the left side of the grid to keep them visible while scrolling horizontally.

## Related Features

- [Column Types](column-types.md)
- [Column Resizing](column-resizing.md)
- [Column Moving](column-moving.md)
- [Column Hiding](column-hiding.md)
- [Column Freezing](column-freezing.md)
