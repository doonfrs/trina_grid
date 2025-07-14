# Cell Selection

Cell selection is a core feature in TrinaGrid that allows users to select individual cells or ranges of cells for operations such as copying, editing, or applying actions. This feature enhances user interaction with the grid and provides a familiar spreadsheet-like experience.

## Overview

The cell selection feature enables you to:

- Select individual cells with a single click
- Select multiple cells by holding Ctrl key (Cmd on Mac) and clicking
- Select a range of cells by dragging or using keyboard shortcuts
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
    selectingMode: TrinaGridSelectingMode.cellWithCtrl, // Default
  ),
)
```

### Cell Selection Modes

- `TrinaGridSelectingMode.cellWithCtrl`: Allows selection of single or multiple cells using Ctrl key (Cmd on Mac)
- `TrinaGridSelectingMode.cellWithSingleTap`: Allows selection of single or multiple cells with a single tap

## Basic Usage

### Range Selection

You can select a range of cells using one of the following methods:

*Note*: range selection is available by default when using one of the above cell-selecting modes.

#### Drag Selection

1. Click and hold on the first cell.
2. Drag the mouse to the last cell in the desired range.
3. Release the mouse button to complete the selection.

#### Keyboard (Shift + Arrow Keys)

1. Select the starting cell.
2. Hold down the **Shift** key.
3. Use the **arrow keys** (Up, Down, Left, Right) to extend the selection.
4. Release the **Shift** key when the desired range is selected.

#### Keyboard (Shift + Click)

1. Click on a cell to set the starting point of the selection.
2. Hold down the **Shift** key.
3. Click on another cell to select all cells between the starting point and the clicked cell.

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
stateManager.toggleCellSelection(cell, notify: true);

// Check if a cell is selected
bool isSelected = stateManager.isSelectedCell(cell);

// Get current selection information
TrinaCellPosition? currentPosition = stateManager.currentSelectingPosition;

// Clear selection
stateManager.clearCurrentCell(notify: true);

// Set selection mode
stateManager.setSelectingMode(TrinaGridSelectingMode.cellWithCtrl);
```

## Handling Selection Events

You can respond to cell selection events using the `onSelected` callback:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onSelected: (TrinaGridOnSelectedEvent event) {
    final selectedCells = event.selectedCells;
    
    // Perform actions based on selection
    print('Currently selected cell: ${event.lastSelectedCell?.value}');
    print('Number of cells in selection: ${selectedCells.length}');
  },
)
```

## Combining with Other Features

Cell selection integrates with other TrinaGrid features for enhanced functionality:


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
            if (event is TrinaGridChangeSelection) {
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
            selectingMode: TrinaGridSelectingMode.cellWithSingleTap,
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

## Best Practices

- Use the appropriate selection mode for your use case
- Provide visual feedback when cells are selected
- Consider implementing keyboard shortcuts for selection operations
- Handle selection events to update UI or perform actions
- Use programmatic selection for guided user experiences
- Combine with other features like copy/paste for enhanced functionality