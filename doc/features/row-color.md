# Row Coloring

Row coloring is a feature in TrinaGrid that allows you to customize the background color of rows based on their content or state. This feature enhances data visualization by providing visual cues that help users quickly identify patterns, categories, or important information within the grid.

## Overview

The row coloring feature enables you to dynamically assign colors to rows based on custom logic. This is particularly useful for:

- Highlighting rows that meet specific criteria
- Creating alternating row colors for better readability
- Visually categorizing data
- Indicating status or priority levels
- Enhancing the overall user experience with visual feedback

## Implementing Row Coloring

To implement row coloring in TrinaGrid, you need to use the `rowColorCallback` parameter when creating your TrinaGrid widget. This callback function receives a `RowColorContext` object and should return a `Color` object.

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  rowColorCallback: (rowColorContext) {
    // Your custom logic to determine row color
    return yourColorValue;
  },
)
```

## The RowColorContext

The `rowColorContext` parameter provides context information about the row being rendered, including:

- `row`: The TrinaRow object containing the row's data
- `rowIdx`: The index of the row in the current view
- `stateManager`: The TrinaGridStateManager instance

This context allows you to make color decisions based on row data, position, or grid state.

## Examples

### Basic Row Coloring

Here's a simple example that colors rows based on a specific cell value:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  rowColorCallback: (rowColorContext) {
    // Get the value of the 'status' cell
    final status = rowColorContext.row.cells['status']?.value;
    
    // Return different colors based on status
    if (status == 'Active') {
      return Colors.green[100]!;
    } else if (status == 'Pending') {
      return Colors.yellow[100]!;
    } else if (status == 'Inactive') {
      return Colors.grey[100]!;
    }
    
    // Default color for other cases
    return Colors.white;
  },
)
```

### Alternating Row Colors

You can create a zebra-striped pattern for better readability:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  rowColorCallback: (rowColorContext) {
    // Use row index to determine color
    return rowColorContext.rowIdx % 2 == 0
        ? Colors.white
        : Colors.grey[100]!;
  },
)
```

### Coloring Based on Multiple Conditions

You can implement complex logic to determine row colors:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  rowColorCallback: (rowColorContext) {
    final row = rowColorContext.row;
    final priority = row.cells['priority']?.value;
    final dueDate = row.cells['dueDate']?.value as DateTime?;
    final isCompleted = row.cells['isCompleted']?.value as bool? ?? false;
    
    // First priority: completed items are light green
    if (isCompleted) {
      return Colors.green[50]!;
    }
    
    // Second priority: overdue items are light red
    if (dueDate != null && dueDate.isBefore(DateTime.now())) {
      return Colors.red[50]!;
    }
    
    // Third priority: color by priority level
    if (priority == 'High') {
      return Colors.orange[50]!;
    } else if (priority == 'Medium') {
      return Colors.yellow[50]!;
    } else if (priority == 'Low') {
      return Colors.blue[50]!;
    }
    
    // Default color
    return Colors.white;
  },
)
```

## Dynamic Row Coloring

One of the powerful aspects of the `rowColorCallback` is that it's called whenever the grid is redrawn, which means row colors will update dynamically when:

- Cell values change
- Rows are added or removed
- The grid is sorted or filtered
- Any other operation that causes the grid to redraw

This allows for responsive visual feedback as users interact with the grid.

## Combining with Other Features

Row coloring works well with other TrinaGrid features:

### With Row Selection

When combining row coloring with row selection, be aware that the selection highlight may override your custom row colors. You can adjust the selection colors to work harmoniously with your row coloring scheme.

### With Row Hover

Row hover effects may temporarily change the row color. Consider this when designing your color scheme to ensure good contrast and usability.

## Best Practices

1. **Use Subtle Colors**: Choose light background colors that don't interfere with text readability.

2. **Maintain Contrast**: Ensure sufficient contrast between the text and background colors for accessibility.

3. **Be Consistent**: Use colors consistently throughout your application to maintain a coherent user experience.

4. **Consider Accessibility**: Keep in mind users with color vision deficiencies when choosing your color scheme.

5. **Performance**: Keep your `rowColorCallback` logic efficient, especially for large datasets, as it will be called frequently during scrolling and updates.

6. **Documentation**: Document the meaning of different colors in your application to help users understand the visual cues.

## Complete Example

Here's a complete example demonstrating row coloring in TrinaGrid:

```dart
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

class RowColorExample extends StatefulWidget {
  @override
  _RowColorExampleState createState() => _RowColorExampleState();
}

class _RowColorExampleState extends State<RowColorExample> {
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
        title: 'Category',
        field: 'category',
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
          'name': TrinaCell(value: 'Project Alpha'),
          'category': TrinaCell(value: 'Development'),
          'status': TrinaCell(value: 'Active'),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 2),
          'name': TrinaCell(value: 'Project Beta'),
          'category': TrinaCell(value: 'Design'),
          'status': TrinaCell(value: 'Pending'),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 3),
          'name': TrinaCell(value: 'Project Gamma'),
          'category': TrinaCell(value: 'Testing'),
          'status': TrinaCell(value: 'Inactive'),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 4),
          'name': TrinaCell(value: 'Project Delta'),
          'category': TrinaCell(value: 'Development'),
          'status': TrinaCell(value: 'Active'),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 5),
          'name': TrinaCell(value: 'Project Epsilon'),
          'category': TrinaCell(value: 'Marketing'),
          'status': TrinaCell(value: 'Pending'),
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Row Coloring Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Rows are colored based on their status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
              rowColorCallback: (rowColorContext) {
                // Color rows based on status
                final status = rowColorContext.row.cells['status']?.value;
                
                switch (status) {
                  case 'Active':
                    return Colors.green[50]!;
                  case 'Pending':
                    return Colors.yellow[50]!;
                  case 'Inactive':
                    return Colors.grey[50]!;
                  default:
                    return Colors.white;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## Row Text Style

In addition to the row background color, you can customize the **text style** for every cell in a row via `rowTextStyleCallback`. The callback returns a `TextStyle?` that is merged on top of `TrinaGridStyleConfig.cellTextStyle`. Return `null` to leave the row's text style unchanged.

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  rowTextStyleCallback: (rowColorContext) {
    final status = rowColorContext.row.cells['status']?.value;
    if (status == 'urgent') {
      return const TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
    }
    return null;
  },
)
```

Notes:

- Only specify the fields you want to override (typically `color`). All other fields are inherited from `cellTextStyle`.
- If both `rowTextStyleCallback` and `cellTextStyleCallback` are set, the cell-level result is merged on top and wins per-field.
- The style applies to the default cell display **and** to the in-place editor for text-based typed cells (text, number, currency, percentage, date, time).
- Cells using `TrinaColumn.renderer` or `TrinaCell.renderer` are not affected — those renderers fully own their look.

## Related Features

- [Cell Color & Text Style](cell-color.md)
- [Row Selection](row-selection.md)
- [Row Moving](row-moving.md)
- [Row Checking](row-checking.md)
- [Row Groups](row-groups.md)
