# Dynamic Row Heights Example

This example demonstrates how to use TrinaGrid's dynamic row heights feature to create rows with different heights.

## Basic Example

Here's a simple example showing how to create rows with custom heights:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

class DynamicRowHeightExample extends StatefulWidget {
  @override
  _DynamicRowHeightExampleState createState() => _DynamicRowHeightExampleState();
}

class _DynamicRowHeightExampleState extends State<DynamicRowHeightExample> {
  late List<TrinaColumn> columns;
  late List<TrinaRow> rows;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    columns = [
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.text(),
        width: 80,
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        width: 200,
      ),
      TrinaColumn(
        title: 'Description',
        field: 'description',
        type: TrinaColumnType.text(),
        width: 300,
      ),
    ];

    rows = [
      TrinaRow(
        cells: {
          'id': TrinaCell(value: '1'),
          'name': TrinaCell(value: 'Normal Row'),
          'description': TrinaCell(value: 'This row uses the default height'),
        },
        // No height specified - uses default
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: '2'),
          'name': TrinaCell(value: 'Tall Row'),
          'description': TrinaCell(value: 'This row has a custom height of 80px'),
        },
        height: 80.0, // Custom height
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: '3'),
          'name': TrinaCell(value: 'Very Tall Row'),
          'description': TrinaCell(value: 'This row has a custom height of 120px'),
        },
        height: 120.0, // Custom height
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dynamic Row Heights Example')),
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        configuration: TrinaGridConfiguration(
          style: TrinaGridStyleConfig(
            rowHeight: 45.0, // Default height
            enableCellBorderHorizontal: true,
            enableCellBorderVertical: true,
          ),
        ),
      ),
    );
  }
}
```

## Interactive Example

Here's a more advanced example that allows users to modify row heights at runtime:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

class InteractiveRowHeightExample extends StatefulWidget {
  @override
  _InteractiveRowHeightExampleState createState() => _InteractiveRowHeightExampleState();
}

class _InteractiveRowHeightExampleState extends State<InteractiveRowHeightExample> {
  TrinaGridStateManager? stateManager;
  late List<TrinaColumn> columns;
  late List<TrinaRow> rows;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    columns = [
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.text(),
        width: 80,
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        width: 200,
      ),
      TrinaColumn(
        title: 'Height',
        field: 'height',
        type: TrinaColumnType.text(),
        width: 100,
      ),
    ];

    rows = List.generate(5, (index) {
      return TrinaRow(
        cells: {
          'id': TrinaCell(value: '${index + 1}'),
          'name': TrinaCell(value: 'Row ${index + 1}'),
          'height': TrinaCell(value: '45px'),
        },
      );
    });
  }

  void _setRowHeight(int rowIndex, double height) {
    if (stateManager != null) {
      stateManager!.setRowHeight(rowIndex, height);
      
      // Update the height display in the grid
      final row = rows[rowIndex];
      row.cells['height']!.value = '${height.toInt()}px';
      
      setState(() {});
    }
  }

  void _resetRowHeight(int rowIndex) {
    if (stateManager != null) {
      stateManager!.resetRowHeight(rowIndex);
      
      // Update the height display in the grid
      final row = rows[rowIndex];
      row.cells['height']!.value = '45px';
      
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Interactive Row Heights Example')),
      body: Column(
        children: [
          // Control Panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Row Height Controls', 
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => _setRowHeight(0, 60.0),
                      child: Text('Row 0 → 60px'),
                    ),
                    ElevatedButton(
                      onPressed: () => _setRowHeight(1, 80.0),
                      child: Text('Row 1 → 80px'),
                    ),
                    ElevatedButton(
                      onPressed: () => _setRowHeight(2, 100.0),
                      child: Text('Row 2 → 100px'),
                    ),
                    ElevatedButton(
                      onPressed: () => _resetRowHeight(0),
                      child: Text('Reset Row 0'),
                    ),
                    ElevatedButton(
                      onPressed: () => _resetRowHeight(1),
                      child: Text('Reset Row 1'),
                    ),
                    ElevatedButton(
                      onPressed: () => _resetRowHeight(2),
                      child: Text('Reset Row 2'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Grid
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
              rowColorCallback: (TrinaRowColorContext context) {
                // Highlight rows with custom heights
                if (context.row.height != null) {
                  return Colors.blue.withValues(alpha: 0.1);
                }
                // Use default alternating row colors
                return context.rowIdx % 2 == 0 ? Colors.white : Colors.grey[50]!;
              },
              configuration: TrinaGridConfiguration(
                style: TrinaGridStyleConfig(
                  rowHeight: 45.0, // Default height
                  enableCellBorderHorizontal: true,
                  enableCellBorderVertical: true,
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

## Visual Indicators

You can use the `rowColorCallback` to visually distinguish rows with custom heights:

```dart
rowColorCallback: (TrinaRowColorContext context) {
  if (context.row.height != null) {
    return Colors.blue.withValues(alpha: 0.1); // Custom height rows
  }
  return context.rowIdx % 2 == 0 ? Colors.white : Colors.grey[50]!; // Default
},
```

## Content-Based Heights

You can set row heights based on content requirements:

```dart
rows = [
  TrinaRow(
    cells: {
      'id': TrinaCell(value: '1'),
      'content': TrinaCell(value: 'Short content'),
    },
    // Uses default height
  ),
  TrinaRow(
    cells: {
      'id': TrinaCell(value: '2'),
      'content': TrinaCell(value: 'Very long content that needs more space to display properly without truncation'),
    },
    height: 80.0, // Extra height for long content
  ),
];
```

## Status-Based Heights

Different heights for different row types:

```dart
rows = List.generate(10, (index) {
  final isExpanded = index % 3 == 0; // Every 3rd row is expanded
  
  return TrinaRow(
    cells: {
      'id': TrinaCell(value: '${index + 1}'),
      'status': TrinaCell(value: isExpanded ? 'expanded' : 'normal'),
    },
    height: isExpanded ? 100.0 : null, // Custom height for expanded rows
  );
});
```

## Best Practices

1. **Set heights at creation time** when possible for better performance
2. **Use visual indicators** to help users understand which rows have custom heights
3. **Consider the impact** on scrolling performance with many variable-height rows
4. **Update UI elements** after changing heights to reflect the new state
5. **Use meaningful height values** that provide better content display

## Common Patterns

### Expanding/Collapsing Rows
```dart
void _toggleRowExpansion(int rowIndex) {
  if (stateManager != null) {
    final currentHeight = stateManager!.getRowHeight(rowIndex);
    final isExpanded = currentHeight > 45.0;
    
    if (isExpanded) {
      stateManager!.resetRowHeight(rowIndex);
    } else {
      stateManager!.setRowHeight(rowIndex, 100.0);
    }
    
    setState(() {});
  }
}
```

### Batch Height Operations
```dart
void _setAllRowsToHeight(double height) {
  if (stateManager != null) {
    for (int i = 0; i < rows.length; i++) {
      stateManager!.setRowHeight(i, height);
    }
    setState(() {});
  }
}
```

### Height Validation
```dart
void _setRowHeightWithValidation(int rowIndex, double height) {
  if (height < 30.0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Height must be at least 30px')),
    );
    return;
  }
  
  if (height > 200.0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Height cannot exceed 200px')),
    );
    return;
  }
  
  if (stateManager != null) {
    stateManager!.setRowHeight(rowIndex, height);
    setState(() {});
  }
}
```

This example demonstrates the key concepts of dynamic row heights in TrinaGrid. You can now create grids with rows of different heights and modify them dynamically at runtime!
