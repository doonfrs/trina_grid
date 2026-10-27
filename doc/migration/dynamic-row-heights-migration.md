# Dynamic Row Heights Migration Guide

This guide helps existing TrinaGrid users migrate to the new dynamic row heights feature.

## Overview

The dynamic row heights feature has been added to TrinaGrid while maintaining full backward compatibility. This means:

- ✅ **Existing code continues to work** without any changes
- ✅ **New functionality is opt-in** via new method calls
- ✅ **Global row height configuration** remains the default behavior
- ✅ **All existing features** work with variable heights

## What's New

### New Properties

#### TrinaRow.height
```dart
class TrinaRow<T> {
  /// Custom height for this specific row
  /// If null, uses the global rowHeight from configuration
  final double? height;
  
  // ... existing properties
}
```

### New Methods

#### TrinaGridStateManager.setRowHeight()
```dart
void setRowHeight(int rowIndex, double height)
```

#### TrinaGridStateManager.resetRowHeight()
```dart
void resetRowHeight(int rowIndex)
```

#### TrinaGridStateManager.resetAllRowHeights()
```dart
void resetAllRowHeights()
```

#### TrinaGridStateManager.getRowHeight()
```dart
double getRowHeight(int rowIndex)
```

## Migration Scenarios

### Scenario 1: No Changes Required (Recommended)

If you're happy with uniform row heights, you don't need to make any changes:

```dart
// This code continues to work exactly as before
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    style: TrinaGridStyleConfig(
      rowHeight: 45.0, // Global row height
    ),
  ),
)
```

### Scenario 2: Add Custom Heights to Specific Rows

If you want some rows to have different heights:

```dart
// Before: All rows had the same height
List<TrinaRow> rows = [
  TrinaRow(cells: {'id': TrinaCell(value: '1'), 'name': TrinaCell(value: 'John')}),
  TrinaRow(cells: {'id': TrinaCell(value: '2'), 'name': TrinaCell(value: 'Jane')}),
];

// After: Some rows have custom heights
List<TrinaRow> rows = [
  TrinaRow(
    cells: {'id': TrinaCell(value: '1'), 'name': TrinaCell(value: 'John')},
    height: 60.0, // Custom height
  ),
  TrinaRow(
    cells: {'id': TrinaCell(value: '2'), 'name': TrinaCell(value: 'Jane')},
    // Uses default height (45.0)
  ),
];
```

### Scenario 3: Dynamic Height Changes

If you want to change row heights at runtime:

```dart
class MyGridScreen extends StatefulWidget {
  @override
  _MyGridScreenState createState() => _MyGridScreenState();
}

class _MyGridScreenState extends State<MyGridScreen> {
  TrinaGridStateManager? stateManager;

  @override
  Widget build(BuildContext context) {
    return TrinaGrid(
      columns: columns,
      rows: rows,
      onLoaded: (TrinaGridOnLoadedEvent event) {
        stateManager = event.stateManager;
      },
      // ... other properties
    );
  }

  // New method: Change row height dynamically
  void _expandRow(int rowIndex) {
    if (stateManager != null) {
      stateManager!.setRowHeight(rowIndex, 80.0);
      setState(() {}); // Trigger rebuild
    }
  }

  // New method: Reset row to default height
  void _collapseRow(int rowIndex) {
    if (stateManager != null) {
      stateManager!.resetRowHeight(rowIndex);
      setState(() {}); // Trigger rebuild
    }
  }
}
```

## Step-by-Step Migration

### Step 1: Verify Current Setup

Ensure your current TrinaGrid implementation is working correctly:

```dart
// Your existing code should work unchanged
TrinaGrid(
  columns: columns,
  rows: rows,
  onLoaded: (TrinaGridOnLoadedEvent event) {
    // Store stateManager reference
    stateManager = event.stateManager;
  },
  configuration: TrinaGridConfiguration(
    style: TrinaGridStyleConfig(
      rowHeight: 45.0, // Your current row height
    ),
  ),
)
```

### Step 2: Add StateManager Reference

Store the `TrinaGridStateManager` reference for later use:

```dart
class _MyGridScreenState extends State<MyGridScreen> {
  TrinaGridStateManager? stateManager;

  @override
  Widget build(BuildContext context) {
    return TrinaGrid(
      // ... existing properties
      onLoaded: (TrinaGridOnLoadedEvent event) {
        setState(() {
          stateManager = event.stateManager;
        });
      },
    );
  }
}
```

### Step 3: Add Custom Heights (Optional)

If you want some rows to have custom heights from the start:

```dart
void _initializeData() {
  rows = [
    TrinaRow(
      cells: {'id': TrinaCell(value: '1'), 'name': TrinaCell(value: 'Header')},
      height: 60.0, // Custom height for header
    ),
    TrinaRow(
      cells: {'id': TrinaCell(value: '2'), 'name': TrinaCell(value: 'Data')},
      // Uses default height
    ),
  ];
}
```

### Step 4: Add Dynamic Height Controls (Optional)

If you want users to control row heights:

```dart
Widget _buildHeightControls() {
  return Row(
    children: [
      ElevatedButton(
        onPressed: () => _setRowHeight(0, 60.0),
        child: Text('Expand Row 0'),
      ),
      ElevatedButton(
        onPressed: () => _resetRowHeight(0),
        child: Text('Reset Row 0'),
      ),
    ],
  );
}

void _setRowHeight(int rowIndex, double height) {
  if (stateManager != null) {
    stateManager!.setRowHeight(rowIndex, height);
    setState(() {}); // Trigger rebuild
  }
}

void _resetRowHeight(int rowIndex) {
  if (stateManager != null) {
    stateManager!.resetRowHeight(rowIndex);
    setState(() {}); // Trigger rebuild
  }
}
```

### Step 5: Add Visual Indicators (Optional)

Use `rowColorCallback` to highlight rows with custom heights:

```dart
TrinaGrid(
  // ... existing properties
  rowColorCallback: (TrinaRowColorContext context) {
    if (context.row.height != null) {
      return Colors.blue.withValues(alpha: 0.1); // Custom height rows
    }
    return context.rowIdx % 2 == 0 ? Colors.white : Colors.grey[50]!; // Default
  },
)
```

## Common Migration Patterns

### Pattern 1: Header Rows with Custom Heights

```dart
// Before: All rows had uniform height
List<TrinaRow> rows = [
  TrinaRow(cells: {'title': TrinaCell(value: 'Section 1')}),
  TrinaRow(cells: {'id': TrinaCell(value: '1'), 'name': TrinaCell(value: 'Item 1')}),
  TrinaRow(cells: {'id': TrinaCell(value: '2'), 'name': TrinaCell(value: 'Item 2')}),
];

// After: Header rows have custom heights
List<TrinaRow> rows = [
  TrinaRow(
    cells: {'title': TrinaCell(value: 'Section 1')},
    height: 60.0, // Taller header
  ),
  TrinaRow(cells: {'id': TrinaCell(value: '1'), 'name': TrinaCell(value: 'Item 1')}),
  TrinaRow(cells: {'id': TrinaCell(value: '2'), 'name': TrinaCell(value: 'Item 2')}),
];
```

### Pattern 2: Expandable Rows

```dart
// Before: Fixed row heights
List<TrinaRow> rows = List.generate(10, (index) {
  return TrinaRow(cells: {
    'id': TrinaCell(value: '${index + 1}'),
    'content': TrinaCell(value: 'Content ${index + 1}'),
  });
});

// After: Expandable rows with custom heights
List<TrinaRow> rows = List.generate(10, (index) {
  final isExpanded = index % 3 == 0; // Every 3rd row is expanded
  
  return TrinaRow(
    cells: {
      'id': TrinaCell(value: '${index + 1}'),
      'content': TrinaCell(value: 'Content ${index + 1}'),
    },
    height: isExpanded ? 80.0 : null, // Custom height for expanded rows
  );
});
```

### Pattern 3: Content-Based Heights

```dart
// Before: All rows had the same height
List<TrinaRow> rows = [
  TrinaRow(cells: {'id': TrinaCell(value: '1'), 'text': TrinaCell(value: 'Short text')}),
  TrinaRow(cells: {'id': TrinaCell(value: '2'), 'text': TrinaCell(value: 'Very long text that needs more space to display properly without truncation')}),
];

// After: Rows with long content have custom heights
List<TrinaRow> rows = [
  TrinaRow(cells: {'id': TrinaCell(value: '1'), 'text': TrinaCell(value: 'Short text')}),
  TrinaRow(
    cells: {'id': TrinaCell(value: '2'), 'text': TrinaCell(value: 'Very long text that needs more space to display properly without truncation')},
    height: 80.0, // Extra height for long content
  ),
];
```

## Testing Your Migration

### Test 1: Verify Existing Functionality

Ensure your current grid still works:

```dart
// Test that existing features still work
// - Row selection
// - Column sorting
// - Column filtering
// - Row movement
// - Cell editing
// - etc.
```

### Test 2: Test Custom Heights

Verify that custom heights work correctly:

```dart
// Test setting custom heights
stateManager.setRowHeight(0, 80.0);

// Test getting custom heights
final height = stateManager.getRowHeight(0);
assert(height == 80.0);

// Test resetting heights
stateManager.resetRowHeight(0);
final resetHeight = stateManager.getRowHeight(0);
assert(resetHeight == 45.0); // Default height
```

### Test 3: Test Visual Indicators

Verify that custom height rows are visually distinct:

```dart
// Check that rows with custom heights have different colors
// Check that height changes trigger UI updates
// Check that scrolling works correctly with variable heights
```

## Performance Considerations

### Before Migration
- All rows had uniform heights
- Efficient `ListView.builder` with `itemExtent`
- Simple scroll calculations

### After Migration
- Rows can have variable heights
- `ListView.builder` without `itemExtent` (less efficient)
- More complex scroll calculations

### Mitigation Strategies
1. **Set heights at creation time** when possible
2. **Limit the number of variable-height rows**
3. **Use visual indicators** to help users understand the layout
4. **Consider performance impact** for large datasets

## Troubleshooting

### Issue: Row heights not updating visually
**Solution:** Make sure to call `setState()` after modifying row heights.

### Issue: Scrolling seems slower
**Solution:** This is expected behavior with variable heights. Consider limiting custom heights to essential rows.

### Issue: Layout issues with custom heights
**Solution:** Ensure custom heights are reasonable (e.g., between 30px and 200px).

### Issue: Performance problems with many custom heights
**Solution:** Consider using custom heights only for important rows or implementing lazy height calculation.

## Rollback Plan

If you encounter issues, you can easily rollback:

1. **Remove custom height properties** from `TrinaRow` instances
2. **Remove calls** to `setRowHeight()`, `resetRowHeight()`, etc.
3. **Remove visual indicators** from `rowColorCallback`
4. **Your grid will return** to the previous uniform height behavior

## Next Steps

After successful migration:

1. **Explore advanced features** like content-based height calculation
2. **Implement user controls** for height management
3. **Add visual feedback** for height changes
4. **Consider performance optimizations** for your specific use case

## Support

If you encounter issues during migration:

1. Check the [Dynamic Row Heights](../features/dynamic-row-heights.md) documentation
2. Review the [examples](../examples/dynamic-row-heights.md)
3. Check the [API reference](https://pub.dev/documentation/trina_grid/latest/trina_grid/TrinaGridStateManager-class.html)
4. Report issues on the project's issue tracker

The dynamic row heights feature is designed to be a smooth, opt-in enhancement to your existing TrinaGrid implementation. Take your time with the migration and test thoroughly at each step!
