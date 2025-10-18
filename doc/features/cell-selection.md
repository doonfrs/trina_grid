# Cell Selection

Cell selection is a core feature in TrinaGrid that allows users to select individual cells or ranges of cells for operations such as copying, editing, or applying actions. This feature enhances user interaction with the grid and provides a familiar spreadsheet-like experience.

## Overview

The cell selection feature enables you to:

- Select individual cells with a single click
- Select ranges of cells by dragging or using keyboard shortcuts
- Select cells in different modes (cell, row, or column)
- Perform operations on selected cells
- Customize the appearance of selected cells
- Programmatically control cell selection

Cell selection provides a foundation for many other features in TrinaGrid, such as copy and paste, cell editing, and keyboard navigation.

## Selection Modes

TrinaGrid supports multiple selection modes that can be configured based on your requirements:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    selectingMode: TrinaGridSelectingMode.cell, // Default
  ),
)
```

### Available Selection Modes

- `TrinaGridSelectingMode.cell`: Allows selection of individual cells or ranges of cells
- `TrinaGridSelectingMode.row`: Selects entire rows when clicking on any cell
- `TrinaGridSelectingMode.horizontal`: Allows selection of cells only in the horizontal direction

## Basic Usage

### Single Cell Selection

To select a single cell, simply click on it:

```dart
// The cell will be selected when clicked
// No additional code required
```

### Range Selection

To select a range of cells:

1. Click on the first cell
2. Drag to the last cell in the range
3. Release to complete the selection

Alternatively, you can use keyboard shortcuts:

1. Click on the first cell
2. Hold Shift
3. Use arrow keys to extend the selection
4. Release Shift when done

## Styling Selected Cells

You can customize the appearance of selected cells through the configuration:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    style: TrinaGridStyleConfig(
      activatedBorderColor: Colors.blue,
      activatedColor: Colors.lightBlue.withOpacity(0.2),
      inactivatedBorderColor: Colors.grey,
      inactivatedColor: Colors.grey.withOpacity(0.1),
    ),
  ),
)
```

Available styling options include:

- `activatedBorderColor`: Border color for the currently active cell
- `activatedColor`: Background color for the currently active cell
- `inactivatedBorderColor`: Border color for selected but inactive cells
- `inactivatedColor`: Background color for selected but inactive cells

## Programmatic Control

You can programmatically control cell selection through the state manager:

```dart
// Select a specific cell
stateManager.setCurrentCell(
  cell,
  rowIdx,
  notify: true,
);

// Check if a cell is selected
bool isSelected = stateManager.isSelectedCell(cell, column, rowIdx);

// Get current selection information
TrinaGridCellPosition? currentPosition = stateManager.currentCellPosition;
List<TrinaGridSelectingCellPosition> selectedPositions = 
    stateManager.currentSelectingPositionList;

// Clear selection
stateManager.clearCurrentCell(notify: true);

// Set selection mode
stateManager.setSelectingMode(TrinaGridSelectingMode.cell);
```

## Handling Selection Events

You can respond to cell selection events using the `onChanged` callback:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onChanged: (PlutoGridOnChangedEvent event) {
    // Check if this is a selection change event
    if (event.type == PlutoGridEventType.selection) {
      // Access the current selection
      final currentCell = event.stateManager.currentCell;
      final selectedPositions = event.stateManager.currentSelectingPositionList;
      
      // Perform actions based on selection
      print('Selected cell: ${currentCell?.value}');
      print('Number of cells in selection: ${selectedPositions.length}');
    }
  },
)
```

## Combining with Other Features

Cell selection integrates with other TrinaGrid features for enhanced functionality:

### Cell Selection with Editing

When a cell is selected, you can start editing by:

- Double-clicking the cell
- Pressing F2 or Enter
- Starting to type (if configured)

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveDown,
    enableMoveDownAfterSelecting: true,
  ),
)
```

### Cell Selection with Copy & Paste

Selected cells can be copied and pasted using standard keyboard shortcuts:

- Ctrl+C (Cmd+C on macOS) to copy
- Ctrl+V (Cmd+V on macOS) to paste

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    enableClipboard: true,
  ),
)
```

## Example

Here's a complete example demonstrating cell selection functionality:

```dart
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

class CellSelectionExample extends StatefulWidget {
  @override
  _CellSelectionExampleState createState() => _CellSelectionExampleState();
}

class _CellSelectionExampleState extends State<CellSelectionExample> {
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
        title: 'Age',
        field: 'age',
        type: TrinaColumnType.number(),
        width: 80,
      ),
      TrinaColumn(
        title: 'Status',
        field: 'status',
        type: TrinaColumnType.select(
          items: [
            TrinaSelectItem(value: 'Active', title: 'Active'),
            TrinaSelectItem(value: 'Inactive', title: 'Inactive'),
          ],
        ),
      ),
    ]);

    // Create sample data
    for (int i = 0; i < 10; i++) {
      rows.add(
        TrinaRow(
          cells: {
            'id': TrinaCell(value: i + 1),
            'name': TrinaCell(value: 'Person ${i + 1}'),
            'age': TrinaCell(value: 20 + i),
            'status': TrinaCell(value: i % 2 == 0 ? 'Active' : 'Inactive'),
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cell Selection Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.select_all),
            onPressed: () {
              // Programmatically select a cell
              if (stateManager.rows.isNotEmpty && stateManager.columns.isNotEmpty) {
                final firstCell = stateManager.rows.first.cells['id'];
                stateManager.setCurrentCell(firstCell, 0);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () {
              // Clear selection
              stateManager.clearCurrentCell();
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: TrinaGrid(
          columns: columns,
          rows: rows,
          onLoaded: (TrinaGridOnLoadedEvent event) {
            stateManager = event.stateManager;
          },
          onChanged: (TrinaGridOnChangedEvent event) {
            if (event.type == TrinaGridEventType.selection) {
              // Handle selection changes
              print('Selection changed');
              
              // Get current selection information
              final currentCell = stateManager.currentCell;
              if (currentCell != null) {
                print('Current cell value: ${currentCell.value}');
              }
            }
          },
          configuration: TrinaGridConfiguration(
            selectingMode: TrinaGridSelectingMode.cell,
            style: TrinaGridStyleConfig(
              activatedBorderColor: Colors.blue,
              activatedColor: Colors.lightBlue.withOpacity(0.2),
            ),
          ),
        ),
      ),
    );
  }
}
```

## Excel-like Selection Features

TrinaGrid supports Excel-like selection behaviors for enhanced productivity.

### Click-and-Drag Selection

Enable drag selection with a configurable hold duration:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    selectingMode: TrinaGridSelectingMode.cell,
    enableDragSelection: true,  // Enable drag-to-select
    dragSelectionDelayDuration: const Duration(milliseconds: 100),  // Optional: customize delay
  ),
)
```

With this enabled:
- Press and hold for a brief moment, then drag to select a range
- Configurable delay duration (default: 200ms, recommended: 100ms for responsive feel)
- Works like Excel's selection behavior
- Auto-scrolls when dragging near edges

**Important: Scroll Conflict**

Drag selection can conflict with drag-to-scroll gestures. To avoid this:

1. **Option 1**: Keep the default delay (200ms) - provides clear distinction between scrolling and selecting
2. **Option 2**: Use a faster delay (100ms) and disable drag-to-scroll:

```dart
TrinaGrid(
  configuration: TrinaGridConfiguration(
    selectingMode: TrinaGridSelectingMode.cell,
    enableDragSelection: true,
    dragSelectionDelayDuration: const Duration(milliseconds: 100),
    scrollbar: const TrinaGridScrollbarConfig(
      // Disable mouse drag for scrolling to avoid conflicts
      dragDevices: {},  // Empty set disables drag-to-scroll
    ),
  ),
)
```

Recommended delays:
- **100ms**: Very responsive, but may conflict with fast scrolling
- **200ms**: Balanced (default) - good distinction from scroll gestures
- **300ms**: Clear separation, less chance of accidental activation

### Ctrl+Click Multi-Select

Enable selecting individual cells with Ctrl+Click:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    selectingMode: TrinaGridSelectingMode.cell,
    enableCtrlClickMultiSelect: true,  // Enable Ctrl+Click
  ),
)
```

With this enabled:
- Ctrl+Click adds/removes individual cells
- Build non-contiguous selections
- Click without Ctrl clears individual selections
- Shift+Click still works for range selection
- All individually selected cells are included in `currentSelectingPositionList`

### Combined Excel-like Behavior

For the full Excel experience, enable both features:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    selectingMode: TrinaGridSelectingMode.cell,
    enableDragSelection: true,
    enableCtrlClickMultiSelect: true,
  ),
)
```

### Keyboard Shortcuts

The following keyboard combinations work with selection:

| Shortcut | Behavior |
|----------|----------|
| Long Press + Drag | Select range (when enableDragSelection is true) |
| Ctrl + Click | Toggle individual cell (when enableCtrlClickMultiSelect is true) |
| Shift + Click | Extend selection to clicked cell |
| Ctrl + A | Select all cells |
| Click (no modifier) | Clear individual selections and select single cell |

## Configuration Reference

### Selection Configuration Options

```dart
TrinaGridConfiguration(
  // Basic selection mode
  selectingMode: TrinaGridSelectingMode.cell,

  // Excel-like features (default: false)
  enableDragSelection: true,
  enableCtrlClickMultiSelect: true,

  // Drag selection delay (default: 200ms)
  dragSelectionDelayDuration: const Duration(milliseconds: 100),
)
```

**enableDragSelection**:
- Type: `bool`
- Default: `false`
- When `true`: Long press (using `dragSelectionDelayDuration`) and drag to select a range of cells
- When `false`: Traditional behavior - long press selects starting cell, then drag extends selection
- Only works when `selectingMode` is `TrinaGridSelectingMode.cell`

**enableCtrlClickMultiSelect**:
- Type: `bool`
- Default: `false`
- When `true`: Ctrl+Click toggles individual cells in/out of selection
- When `false`: Ctrl+Click has no special behavior in cell mode
- Only works when `selectingMode` is `TrinaGridSelectingMode.cell`

**dragSelectionDelayDuration**:
- Type: `Duration`
- Default: `Duration(milliseconds: 200)`
- The time to hold before drag selection activates
- Lower values (100ms) = more responsive but may conflict with scrolling
- Higher values (300ms) = clearer distinction from scroll gestures
- Only applies when `enableDragSelection` is `true`

## Best Practices

- Use the appropriate selection mode for your use case
- Provide visual feedback when cells are selected
- Consider implementing keyboard shortcuts for selection operations
- Handle selection events to update UI or perform actions
- Use programmatic selection for guided user experiences
- Combine with other features like copy/paste for enhanced functionality
- Enable Excel-like features for desktop applications to improve user experience
