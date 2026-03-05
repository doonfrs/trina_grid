# Cell Value Change and Keyboard Event Handling in TrinaGrid

TrinaGrid provides a flexible system for handling cell value changes and keyboard events through callbacks at both the cell level and the grid level. This dual approach gives you fine-grained control over how changes and keyboard interactions are processed in your application.

## Overview

When a cell value changes in TrinaGrid, the following sequence occurs:

1. The cell value is updated in the data model
2. If present, the cell-level `onChanged` callback is triggered
3. If present, the grid-level `onChanged` callback is triggered
4. The UI is updated to reflect the change

This sequence allows you to implement different strategies for handling changes based on your application's architecture.

## Cell-Level onChanged Callback

The cell-level `onChanged` callback is defined directly on the `TrinaCell` object and is specific to that individual cell.

### Syntax

```dart
TrinaCell(
  value: initialValue,
  onChanged: (TrinaGridOnChangedEvent event) {
    // Handle the cell value change
  },
)
```

### When to Use Cell-Level Callbacks

Cell-level callbacks are ideal for:

- Cell-specific validation or formatting
- Triggering different actions based on which specific cell changed
- Implementing cell-specific business logic
- Creating interdependent cells (where one cell's value affects another)
- Tracking changes to specific high-importance cells

### Example: Cell-Level Validation

```dart
TrinaCell(
  value: 'Initial Value',
  onChanged: (event) {
    // Validate this specific cell's value
    if (event.value.toString().isEmpty) {
      showToast('This field cannot be empty');
      // You could also revert the change or apply a default value
    }
    
    // You can also update other UI elements based on this cell's value
    if (event.value == 'Special Value') {
      showDialog(context, 'Special value detected!');
    }
  },
)
```

## Grid-Level onChanged Callback (State Manager)

The grid-level `onChanged` callback is defined on the `TrinaGrid` widget and is triggered for any cell change in the entire grid.

### onChanged callback syntax

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onChanged: (TrinaGridOnChangedEvent event) {
    // Handle any cell value change in the grid
  },
)
```

### When to Use Grid-Level Callbacks

Grid-level callbacks are ideal for:

- Centralized handling of all changes
- Saving changes to a database
- Logging all modifications
- Implementing undo/redo functionality
- Syncing data with external systems
- Applying global validation rules

### Example: Grid-Level Change Handling

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onChanged: (event) {
    // Log all changes
    logger.info('Cell changed: ${event.column.field} = ${event.value}');
    
    // Save changes to database
    databaseService.updateField(
      rowId: event.row.cells['id']?.value,
      field: event.column.field,
      value: event.value,
    );
    
    // Update application state
    appStateManager.notifyDataChanged();
  },
)
```

## Combined Approach

You can use both cell-level and grid-level callbacks together to create a comprehensive change handling system.

### Example: Combined Approach

```dart
// Cell-level handling for specific validation
TrinaCell(
  value: 'John',
  onChanged: (event) {
    // Cell-specific validation
    if (event.value.toString().length < 3) {
      showToast('Name must be at least 3 characters');
    }
  },
)

// Grid-level handling for global operations
TrinaGrid(
  columns: columns,
  rows: rows,
  onChanged: (event) {
    // Global handling for all cells
    saveChangesToDatabase(event.row, event.column.field, event.value);
    updateUIState();
  },
)
```

## The TrinaGridOnChangedEvent Object

Both callback types receive a `TrinaGridOnChangedEvent` object that contains information about the change:

| Property | Type | Description |
|----------|------|-------------|
| `columnIdx` | `int` | The index of the column in the current view |
| `column` | `TrinaColumn` | The column object |
| `rowIdx` | `int` | The index of the row in the current view |
| `row` | `TrinaRow` | The row object |
| `cell` | `TrinaCell` | The cell that was changed |
| `value` | `dynamic` | The new value |
| `oldValue` | `dynamic` | The previous value |

### Example: Using the Event Object

```dart
onChanged: (event) {
  print('Column: ${event.column.title}');
  print('Field: ${event.column.field}');
  print('Row index: ${event.rowIdx}');
  print('Changed from: ${event.oldValue} to ${event.value}');
  
  // Direct access to the changed cell
  print('Cell key: ${event.cell.key}');
  print('Original value: ${event.cell.originalValue}');
  print('Is dirty: ${event.cell.isDirty}');
  
  // Access formatted value
  String formattedValue = event.column.formattedValueForDisplay(event.value);
  print('Formatted value: $formattedValue');
  
  // Access other cells in the same row
  final otherCellValue = event.row.cells['otherField']?.value;
}
```

## Keyboard Event Handling

In addition to value changes, TrinaGrid also provides keyboard event handling through the `onKeyPressed` callback at the cell level. This allows you to capture and respond to keyboard interactions like Enter, Tab, Escape, and modifier key combinations.

### Cell-Level onKeyPressed Callback

The `onKeyPressed` callback is defined on the `TrinaCell` object and is triggered when any key is pressed while the cell is being edited.

### Syntax

```dart
TrinaCell(
  value: initialValue,
  onKeyPressed: (TrinaGridOnKeyEvent event) {
    // Handle keyboard events
  },
)
```

### When to Use Keyboard Event Callbacks

Keyboard event callbacks are ideal for:

- Implementing custom navigation patterns (e.g., Shift+Enter to move up)
- Creating keyboard shortcuts for specific cells
- Validating input as users type
- Triggering actions based on special keys (Enter, Escape, Tab)
- Implementing auto-completion or suggestion features
- Handling modifier key combinations (Ctrl+Enter, Shift+Tab, etc.)

### The TrinaGridOnKeyEvent Object

The `onKeyPressed` callback receives a `TrinaGridOnKeyEvent` object with the following properties:

| Property | Type | Description |
|----------|------|-------------|
| `column` | `TrinaColumn` | The column where the key was pressed |
| `row` | `TrinaRow` | The row where the key was pressed |
| `rowIdx` | `int` | The index of the row |
| `cell` | `TrinaCell` | The cell where the key was pressed |
| `event` | `KeyEvent` | The raw Flutter KeyEvent |
| `isEnter` | `bool` | Whether the Enter key was pressed |
| `isEscape` | `bool` | Whether the Escape key was pressed |
| `isTab` | `bool` | Whether the Tab key was pressed |
| `isShiftPressed` | `bool` | Whether Shift is pressed |
| `isCtrlPressed` | `bool` | Whether Ctrl/Cmd is pressed |
| `isAltPressed` | `bool` | Whether Alt is pressed |
| `logicalKey` | `LogicalKeyboardKey` | The logical key that was pressed |
| `currentValue` | `String?` | The current text value in the cell (if editing) |

### Example: Keyboard Event Handling

```dart
TrinaCell(
  value: 'Press Enter to submit',
  onKeyPressed: (event) {
    // Handle Enter key
    if (event.isEnter && !event.isShiftPressed) {
      print('Enter pressed - submitting value: ${event.currentValue}');
      // Perform submission logic
    } 
    // Handle Shift+Enter for new line (in multi-line cells)
    else if (event.isEnter && event.isShiftPressed) {
      print('Shift+Enter pressed - new line');
      // Allow new line in multi-line cells
    }
    // Handle Tab navigation
    else if (event.isTab) {
      if (event.isShiftPressed) {
        print('Shift+Tab - moving to previous cell');
      } else {
        print('Tab - moving to next cell');
      }
    }
    // Handle Escape to cancel
    else if (event.isEscape) {
      print('Escape pressed - canceling edit');
      // The grid will handle reverting the value
    }
    // Handle Ctrl+S for save
    else if (event.isCtrlPressed && event.logicalKey.keyLabel == 'S') {
      print('Ctrl+S pressed - saving data');
      // Trigger save operation
    }
  },
)
```

### Combined Value Change and Keyboard Event Handling

You can use both `onChanged` and `onKeyPressed` callbacks together for comprehensive cell interaction handling:

```dart
TrinaCell(
  value: 'Initial Value',
  onChanged: (event) {
    // Handle value changes
    print('Value changed from ${event.oldValue} to ${event.value}');
    saveToDatabase(event.value);
  },
  onKeyPressed: (event) {
    // Handle keyboard events
    if (event.isEnter && event.isCtrlPressed) {
      // Ctrl+Enter to submit and move to next row
      submitAndMoveToNextRow();
    } else if (event.isEscape) {
      // Escape to cancel (handled by grid)
      showToast('Edit canceled');
    }
  },
)
```

## Batch Cell Updates with updateRowCells

When you need to update multiple cells in a single row (e.g., syncing with backend data), use `updateRowCells` instead of calling `changeCellValue` multiple times. It applies all changes and only triggers a single UI notification at the end.

### Syntax

```dart
stateManager.updateRowCells(
  row,
  {
    'name': 'Updated Name',
    'age': 25,
    'status': 'active',
  },
);
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `row` | `TrinaRow` | required | The row whose cells should be updated |
| `values` | `Map<String, dynamic>` | required | Map of column field names to new values |
| `callOnChangedEvent` | `bool` | `true` | Whether to trigger onChanged callbacks |
| `force` | `bool` | `false` | Bypass read-only and editability checks |
| `notify` | `bool` | `true` | Whether to notify listeners (trigger UI rebuild) |
| `validate` | `bool` | `true` | Whether to validate values before setting |

### Example: Syncing a Row with Backend Data

```dart
// Fetch updated data from API
final updatedData = await api.getRecord(recordId);

// Find the row to update
final row = stateManager.rows.firstWhere(
  (r) => r.cells['id']?.value == recordId,
);

// Update all cells in one call
stateManager.updateRowCells(row, {
  'name': updatedData['name'],
  'email': updatedData['email'],
  'status': updatedData['status'],
});
```

Fields that don't exist in the row's cells are silently skipped. Cells that fail validation or are read-only are also skipped without affecting the other updates.

## Best Practices

1. **Use cell-level callbacks for cell-specific logic** and grid-level callbacks for application-wide concerns.

2. **Keep callbacks lightweight** to ensure smooth performance, especially in large grids.

3. **Consider the callback order**: cell-level callbacks are called before grid-level callbacks, so you can use this to your advantage in your application architecture.

4. **Handle errors gracefully** in both callback types to prevent UI freezes.

5. **Use the appropriate callback type** based on your needs:
   - For isolated cell behavior: use cell-level callbacks
   - For centralized data management: use grid-level callbacks
   - For comprehensive solutions: use both

## Complete Example

Here's a complete example demonstrating value change and keyboard event handling:

```dart
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

class CellChangeHandlingExample extends StatefulWidget {
  @override
  _CellChangeHandlingExampleState createState() => _CellChangeHandlingExampleState();
}

class _CellChangeHandlingExampleState extends State<CellChangeHandlingExample> {
  late List<TrinaColumn> columns;
  late List<TrinaRow> rows;
  late TrinaGridStateManager stateManager;
  
  // Track changes and keyboard events for display
  final List<String> changeLog = [];
  
  @override
  void initState() {
    super.initState();
    
    // Define columns
    columns = [
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Age',
        field: 'age',
        type: TrinaColumnType.number(),
      ),
      TrinaColumn(
        title: 'Notes',
        field: 'notes',
        type: TrinaColumnType.text(),
      ),
    ];
    
    // Create rows with cell-level callbacks
    rows = [
      TrinaRow(
        cells: {
          'name': TrinaCell(
            value: 'John',
            onChanged: (event) {
              // Cell-level handling
              _logChange('CELL-LEVEL: Name changed to ${event.value}');
              
              // Cell-specific validation
              if (event.value.toString().length < 2) {
                _logChange('VALIDATION: Name too short!');
              }
            },
            onKeyPressed: (event) {
              // Handle keyboard events for name field
              if (event.isEnter && event.isCtrlPressed) {
                _logChange('KEYBOARD: Ctrl+Enter pressed in Name field');
                // Could trigger form submission here
              } else if (event.isTab) {
                _logChange('KEYBOARD: Tab pressed, moving to next field');
              }
            },
          ),
          'age': TrinaCell(
            value: 30,
            onChanged: (event) {
              // Cell-level handling
              _logChange('CELL-LEVEL: Age changed to ${event.value}');
              
              // Cell-specific validation
              if (event.value < 18) {
                _logChange('VALIDATION: Must be 18 or older!');
              }
            },
            onKeyPressed: (event) {
              // Handle keyboard events for age field
              if (event.isEnter) {
                _logChange('KEYBOARD: Enter pressed in Age field');
              }
            },
          ),
          'notes': TrinaCell(
            value: 'Press Shift+Enter for special action',
            onKeyPressed: (event) {
              // Demonstrate various keyboard interactions
              if (event.isEnter && event.isShiftPressed) {
                _logChange('KEYBOARD: Shift+Enter - Special action triggered!');
                // Could insert line break or perform special action
              } else if (event.isEscape) {
                _logChange('KEYBOARD: Escape pressed - Edit canceled');
              } else if (event.isCtrlPressed && event.logicalKey.keyLabel == 'S') {
                _logChange('KEYBOARD: Ctrl+S - Save triggered');
                // Could trigger save operation
              }
            },
          ),
        },
      ),
      // Add more rows as needed
    ];
  }
  
  void _logChange(String message) {
    setState(() {
      changeLog.add(message);
      // Keep log size manageable
      if (changeLog.length > 10) changeLog.removeAt(0);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cell Change & Keyboard Event Handling')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (event) {
                stateManager = event.stateManager;
              },
              onChanged: (event) {
                // Grid-level handling for all cells
                _logChange('GRID-LEVEL: ${event.column.field} changed to ${event.value}');
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Change Log:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: changeLog.length,
                      itemBuilder: (context, index) {
                        return Text(changeLog[changeLog.length - 1 - index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

This example demonstrates how to use cell-level callbacks for both value changes and keyboard events, along with grid-level callbacks to handle changes in a TrinaGrid, with a visual log showing the sequence of events and keyboard interactions.
