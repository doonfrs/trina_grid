# Cell Coloring

Cell coloring is a feature in TrinaGrid that allows you to customize the background color of individual cells based on their content or state. This feature enhances data visualization by providing visual cues that help users quickly identify patterns, categories, or important information within specific cells.

## Overview

The cell coloring feature enables you to dynamically assign colors to cells based on custom logic. This is particularly useful for:

- Highlighting cells that meet specific criteria
- Creating conditional formatting based on cell values
- Visually categorizing data at a granular level
- Indicating status or priority levels for individual cells
- Enhancing the overall user experience with targeted visual feedback

## Implementing Cell Coloring

To implement cell coloring in TrinaGrid, you need to use the `cellColorCallback` parameter when creating your TrinaGrid widget. This callback function receives a `TrinaCellColorContext` object and should return a `Color?` object (or `null` for default cell color).

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  cellColorCallback: (cellColorContext) {
    // Your custom logic to determine cell color
    return yourColorValue;
  },
)
```

## The TrinaCellColorContext

The `cellColorContext` parameter provides context information about the cell being rendered, including:

- `cell`: The TrinaCell object containing the cell's data
- `column`: The TrinaColumn object containing the column's configuration
- `row`: The TrinaRow object containing the row's data
- `rowIdx`: The index of the row in the current view
- `stateManager`: The TrinaGridStateManager instance

This context allows you to make color decisions based on cell data, column type, row data, position, or grid state.

## Examples

### Basic Cell Coloring

Here's a simple example that colors cells based on their value:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  cellColorCallback: (cellColorContext) {
    // Color cells based on their value
    if (cellColorContext.cell.value == 'High Priority') {
      return Colors.red[100]!;
    } else if (cellColorContext.cell.value == 'Medium Priority') {
      return Colors.orange[100]!;
    } else if (cellColorContext.cell.value == 'Low Priority') {
      return Colors.green[100]!;
    }
    
    // Return null for default color
    return null;
  },
)
```

### Column-Specific Cell Coloring

You can apply different coloring logic based on the column:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  cellColorCallback: (cellColorContext) {
    // Color cells in the 'status' column
    if (cellColorContext.column.field == 'status') {
      final status = cellColorContext.cell.value;
      if (status == 'Active') {
        return Colors.green[100]!;
      } else if (status == 'Pending') {
        return Colors.yellow[100]!;
      } else if (status == 'Inactive') {
        return Colors.grey[100]!;
      }
    }
    
    // Color cells in the 'priority' column
    if (cellColorContext.column.field == 'priority') {
      final priority = cellColorContext.cell.value;
      if (priority == 'High') {
        return Colors.red[100]!;
      } else if (priority == 'Medium') {
        return Colors.orange[100]!;
      } else if (priority == 'Low') {
        return Colors.blue[100]!;
      }
    }
    
    // Default color for other cells
    return null;
  },
)
```

### Conditional Cell Coloring Based on Multiple Factors

You can implement complex logic that considers multiple cell and row properties:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  cellColorCallback: (cellColorContext) {
    final cell = cellColorContext.cell;
    final column = cellColorContext.column;
    final row = cellColorContext.row;
    
    // Highlight overdue tasks in the due date column
    if (column.field == 'due_date') {
      final dueDate = cell.value as DateTime?;
      if (dueDate != null && dueDate.isBefore(DateTime.now())) {
        return Colors.red[200]!;
      }
    }
    
    // Highlight completed status cells
    if (column.field == 'status' && cell.value == 'Completed') {
      return Colors.green[200]!;
    }
    
    // Highlight high priority tasks in any text column
    if (column.type.isText) {
      final priority = row.cells['priority']?.value;
      if (priority == 'High') {
        return Colors.orange[50]!;
      }
    }
    
    // Default color
    return null;
  },
)
```

### Numeric Value-Based Coloring

Color cells based on numeric thresholds:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  cellColorCallback: (cellColorContext) {
    if (cellColorContext.column.field == 'score') {
      final score = cellColorContext.cell.value as num?;
      if (score != null) {
        if (score >= 90) {
          return Colors.green[100]!; // Excellent
        } else if (score >= 70) {
          return Colors.yellow[100]!; // Good
        } else if (score >= 50) {
          return Colors.orange[100]!; // Average
        } else {
          return Colors.red[100]!; // Poor
        }
      }
    }
    
    return null;
  },
)
```

## Dynamic Cell Coloring

One of the powerful aspects of the `cellColorCallback` is that it's called whenever the grid is redrawn, which means cell colors will update dynamically when:

- Cell values change
- Rows are added or removed
- The grid is sorted or filtered
- Any other operation that causes the grid to redraw

This allows for responsive visual feedback as users interact with the grid.

## Combining with Row Coloring

Cell coloring works independently of row coloring and can be used together. When both are used:

1. Row colors are applied first as the base background
2. Cell colors are applied on top and will override row colors for specific cells
3. This allows for sophisticated highlighting strategies

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  rowColorCallback: (rowColorContext) {
    // Apply subtle row coloring
    return rowColorContext.rowIdx % 2 == 0 
        ? Colors.grey[50]! 
        : Colors.white;
  },
  cellColorCallback: (cellColorContext) {
    // Override with specific cell coloring
    if (cellColorContext.cell.value == 'Important') {
      return Colors.yellow[200]!;
    }
    return null; // Keep row color
  },
)
```

## Combining with Other Features

Cell coloring works well with other TrinaGrid features:

### With Cell Selection

When combining cell coloring with cell selection, be aware that the selection highlight may temporarily override your custom cell colors. The colors will reappear when the cell is deselected.

### With Cell Editing

During cell editing, the edit mode colors may temporarily override custom cell colors. Your colors will return when editing is completed.

### With Cell Validation

You can combine cell coloring with validation to highlight invalid cells:

```dart
cellColorCallback: (cellColorContext) {
  // Highlight validation errors
  if (cellColorContext.cell.hasError) {
    return Colors.red[100]!;
  }
  
  // Your other coloring logic...
  return null;
}
```

## Best Practices

1. **Use Subtle Colors**: Choose light background colors that don't interfere with text readability.

2. **Maintain Contrast**: Ensure sufficient contrast between the text and background colors for accessibility.

3. **Be Consistent**: Use colors consistently throughout your application to maintain a coherent user experience.

4. **Consider Accessibility**: Keep in mind users with color vision deficiencies when choosing your color scheme.

5. **Performance**: Keep your `cellColorCallback` logic efficient, especially for large datasets, as it will be called frequently during scrolling and updates.

6. **Return null for Default**: Return `null` instead of a color when you want to use the default cell color to avoid unnecessary overrides.

7. **Documentation**: Document the meaning of different colors in your application to help users understand the visual cues.

## Complete Example

Here's a complete example demonstrating cell coloring in TrinaGrid:

```dart
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

class CellColorExample extends StatefulWidget {
  @override
  _CellColorExampleState createState() => _CellColorExampleState();
}

class _CellColorExampleState extends State<CellColorExample> {
  List<TrinaColumn> columns = [];
  List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();
    
    columns = [
      TrinaColumn(
        title: 'Task',
        field: 'task',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Priority',
        field: 'priority',
        type: TrinaColumnType.select(['High', 'Medium', 'Low']),
      ),
      TrinaColumn(
        title: 'Status',
        field: 'status',
        type: TrinaColumnType.select(['Completed', 'Pending', 'Cancelled']),
      ),
      TrinaColumn(
        title: 'Score',
        field: 'score',
        type: TrinaColumnType.number(),
      ),
    ];

    rows = [
      TrinaRow(cells: {
        'task': TrinaCell(value: 'Complete project'),
        'priority': TrinaCell(value: 'High'),
        'status': TrinaCell(value: 'Pending'),
        'score': TrinaCell(value: 95),
      }),
      TrinaRow(cells: {
        'task': TrinaCell(value: 'Review code'),
        'priority': TrinaCell(value: 'Medium'),
        'status': TrinaCell(value: 'Completed'),
        'score': TrinaCell(value: 78),
      }),
      // Add more rows...
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cell Color Example')),
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        cellColorCallback: (TrinaCellColorContext context) {
          // Priority column coloring
          if (context.column.field == 'priority') {
            switch (context.cell.value) {
              case 'High':
                return Colors.red[100]!;
              case 'Medium':
                return Colors.orange[100]!;
              case 'Low':
                return Colors.green[100]!;
            }
          }
          
          // Status column coloring
          if (context.column.field == 'status') {
            switch (context.cell.value) {
              case 'Completed':
                return Colors.green[200]!;
              case 'Pending':
                return Colors.yellow[200]!;
              case 'Cancelled':
                return Colors.grey[200]!;
            }
          }
          
          // Score column coloring
          if (context.column.field == 'score') {
            final score = context.cell.value as num?;
            if (score != null) {
              if (score >= 90) return Colors.green[100]!;
              if (score >= 70) return Colors.yellow[100]!;
              if (score >= 50) return Colors.orange[100]!;
              return Colors.red[100]!;
            }
          }
          
          return null; // Default color
        },
      ),
    );
  }
}
```

This example demonstrates comprehensive cell coloring based on different column types and values, providing a rich visual experience for users.

## Cell Text Style

In addition to the cell background color, you can customize the **text style** for an individual cell via `cellTextStyleCallback`. The callback returns a `TextStyle?` that is merged on top of `TrinaGridStyleConfig.cellTextStyle` and any value returned by `rowTextStyleCallback`. Return `null` to leave the cell's text style unchanged.

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  cellTextStyleCallback: (cellColorContext) {
    final value = cellColorContext.cell.value;
    if (value is num && value < 0) {
      return const TextStyle(color: Colors.red);
    }
    return null;
  },
)
```

### Merge Order

When both row- and cell-level text style callbacks are set, the styles are merged in this order:

1. `TrinaGridStyleConfig.cellTextStyle` (base)
2. `rowTextStyleCallback` result (if non-null)
3. `cellTextStyleCallback` result (if non-null) — wins per-field

Each callback only needs to set the fields it wants to override (typically `color`); all other fields remain inherited from the base.

### Where the Style Is Applied

- The default cell display widget.
- The in-place editor for text-based typed cells (`text`, `number`, `currency`, `percentage`).
- The closed (display) state of date / time / datetime popup cells.

### Limitations

- Cells using a custom renderer (`TrinaColumn.renderer` or `TrinaCell.renderer`) are not affected — those renderers fully own their look. If you need conditional styling for a custom renderer, do it inside the renderer.
- For `TrinaSelectCell` / `TrinaBooleanCell`, the callback applies to the closed display state but not to the open menu trigger, which uses Material's `MenuStyle`.
- For date / time popup cells, the resolved style is captured once when editing begins; mid-edit row mutations do not re-evaluate the callbacks for the editing field.
