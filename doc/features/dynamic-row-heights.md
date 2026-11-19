# Dynamic Row Heights

Dynamic row heights is a powerful feature in TrinaGrid that allows individual rows to have custom heights while maintaining backward compatibility with the global row height configuration.

## Overview

By default, TrinaGrid uses a uniform row height defined in `TrinaGridConfiguration.style.rowHeight`. The dynamic row heights feature extends this by allowing you to:

- Set custom heights for specific rows
- Mix rows with custom heights and default heights
- Dynamically change row heights at runtime
- Maintain all existing grid functionality with variable heights

![Dynamic Row Heights Demo](https://raw.githubusercontent.com/doonfrs/trina_grid/master/doc/assets/dynamic-row-heights.gif)

## Basic Usage

### Setting Custom Heights When Creating Rows

You can set custom heights when creating `TrinaRow` instances:

```dart
TrinaRow(
  cells: {
    'id': TrinaCell(value: '1'),
    'name': TrinaCell(value: 'Custom Height Row'),
  },
  height: 80.0, // Custom height in pixels
)
```

### Setting Heights at Runtime

Use the `TrinaGridStateManager` to modify row heights after the grid is created:

```dart
// Set a specific row height
stateManager.setRowHeight(rowIndex, 100.0);

// Reset a specific row to default height
stateManager.resetRowHeight(rowIndex);

// Reset all rows to default heights
stateManager.resetAllRowHeights();

// Get the effective height of a specific row
double height = stateManager.getRowHeight(rowIndex);
```

## API Reference

### TrinaRow.height

```dart
class TrinaRow<T> {
  /// Custom height for this specific row
  /// If null, uses the global rowHeight from configuration
  final double? height;
  
  // ... other properties
}
```

### TrinaGridStateManager Methods

#### setRowHeight(int rowIndex, double height)

Sets the height of a specific row by index.

**Parameters:**
- `rowIndex`: The index of the row to modify (0-based)
- `height`: The new height in pixels (must be > 0)

**Example:**
```dart
stateManager.setRowHeight(0, 80.0);
```

#### resetRowHeight(int rowIndex)

Resets a specific row to use the default height from configuration.

**Parameters:**
- `rowIndex`: The index of the row to reset (0-based)

**Example:**
```dart
stateManager.resetRowHeight(0);
```

#### resetAllRowHeights()

Resets all rows to use the default height from configuration.

**Example:**
```dart
stateManager.resetAllRowHeights();
```

#### getRowHeight(int rowIndex)

Gets the effective height of a specific row.

**Parameters:**
- `rowIndex`: The index of the row (0-based)

**Returns:** The effective height in pixels. If the row has a custom height, returns that value. Otherwise, returns the global `rowHeight` from configuration.

**Example:**
```dart
double height = stateManager.getRowHeight(0);
print('Row 0 height: ${height}px');
```

## Complete Example

Here's a complete example demonstrating dynamic row heights:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

class DynamicRowHeightExample extends StatefulWidget {
  @override
  _DynamicRowHeightExampleState createState() => _DynamicRowHeightExampleState();
}

class _DynamicRowHeightExampleState extends State<DynamicRowHeightExample> {
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

  void _setRowHeight(int rowIndex, double height) {
    if (stateManager != null) {
      stateManager!.setRowHeight(rowIndex, height);
      setState(() {}); // Trigger rebuild to show changes
    }
  }

  void _resetRowHeight(int rowIndex) {
    if (stateManager != null) {
      stateManager!.resetRowHeight(rowIndex);
      setState(() {}); // Trigger rebuild to show changes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dynamic Row Heights Example')),
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
                      child: Text('Set Row 0 to 60px'),
                    ),
                    ElevatedButton(
                      onPressed: () => _resetRowHeight(0),
                      child: Text('Reset Row 0'),
                    ),
                    ElevatedButton(
                      onPressed: () => _setRowHeight(1, 100.0),
                      child: Text('Set Row 1 to 100px'),
                    ),
                    ElevatedButton(
                      onPressed: () => _resetRowHeight(1),
                      child: Text('Reset Row 1'),
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

## Performance Considerations

### Current Implementation
- **Pros**: Simple, clean API, maintains immutability
- **Cons**: Creates new row instances when changing heights (memory allocation)

### Best Practices
1. **Set heights at creation time** when possible to avoid runtime modifications
2. **Batch height changes** if modifying multiple rows
3. **Use visual indicators** to help users understand which rows have custom heights
4. **Consider the impact** on scrolling performance with many variable-height rows

## Backward Compatibility

✅ **Fully Maintained**
- Existing code continues to work without changes
- Global `rowHeight` configuration remains the default
- New functionality is opt-in via `setRowHeight` calls
- All existing features (frozen rows, grouping, etc.) work with variable heights

## Use Cases

### Content-Based Heights
Set row heights based on content requirements:

```dart
TrinaRow(
  cells: {
    'id': TrinaCell(value: '1'),
    'content': TrinaCell(value: 'Very long content that needs more space...'),
  },
  height: 80.0, // Extra height for content
)
```

### Status-Based Heights
Different heights for different row types:

```dart
TrinaRow(
  cells: {
    'id': TrinaCell(value: '1'),
    'status': TrinaCell(value: 'expanded'),
  },
  height: context.row.cells['status']?.value == 'expanded' ? 100.0 : 45.0,
)
```

### User Preferences
Allow users to customize row heights:

```dart
void _setUserPreferredHeight(int rowIndex) {
  final preferredHeight = getUserPreferredHeight(rowIndex);
  stateManager.setRowHeight(rowIndex, preferredHeight);
}
```

## Limitations

1. **Height must be positive**: Negative or zero heights are not supported
2. **Performance impact**: Variable heights disable the efficient `ListView.builder` with `itemExtent`
3. **Scroll calculations**: More complex scroll calculations for variable heights
4. **Memory allocation**: Creating new row instances when changing heights

## Related Features

- [Row Coloring](row-color.md) - Customize row background colors
- [Row Selection](row-selection.md) - Select rows with custom heights
- [Row Moving](row-moving.md) - Move rows while preserving custom heights
- [Row Groups](row-groups.md) - Group rows with variable heights
- [Frozen Rows](frozen-rows.md) - Freeze rows with custom heights

## Migration Guide

### For Existing Users
1. **No changes required** - existing code continues to work
2. **New functionality is opt-in** via `setRowHeight` calls
3. **Global `rowHeight` configuration** remains the default

### For New Users
1. Use `stateManager.setRowHeight(rowIndex, height)` to set custom heights
2. Use `stateManager.resetRowHeight(rowIndex)` to reset to default
3. Use `stateManager.getRowHeight(rowIndex)` to get effective height
4. Set `height` parameter when creating `TrinaRow` instances

## Troubleshooting

### Common Issues

**Q: My row heights aren't updating visually**
A: Make sure to call `setState()` after modifying row heights to trigger a rebuild.

**Q: Scrolling seems slower with custom heights**
A: This is expected behavior. Variable heights disable some scroll optimizations.

**Q: Can I animate height changes?**
A: Currently not supported, but this is a planned future enhancement.

**Q: Do custom heights work with frozen rows?**
A: Yes, frozen rows support custom heights just like regular rows.

## Future Enhancements

Planned improvements for future versions:
1. **Content-aware height calculation** based on cell content
2. **Animation support** for height transitions
3. **Bulk height operations** for multiple rows
4. **Height constraints** (min/max heights)
5. **Height persistence** across grid sessions
