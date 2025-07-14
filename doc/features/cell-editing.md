# Cell Editing

Cell editing is a fundamental feature in TrinaGrid that allows users to modify cell values directly within the grid. This feature provides a spreadsheet-like experience, enabling efficient data entry and manipulation.

![Cell Editing Demo](https://raw.githubusercontent.com/doonfrs/trina_grid/master/doc/assets/cell-editing.gif)

## Overview

The cell editing feature enables you to:

- Edit cell values directly in the grid
- Configure which columns are editable
- Customize the editing experience for different data types
- Validate input data before committing changes
- Handle cell value changes through events
- Integrate with keyboard navigation for efficient editing

Cell editing works seamlessly with other TrinaGrid features such as cell selection, keyboard navigation, and data validation.

## Enabling Cell Editing

To enable cell editing for specific columns, set the `enableEditingMode` property to `true` in your column definition:

```dart
TrinaColumn(
  title: 'Name',
  field: 'name',
  type: TrinaColumnType.text(),
  enableEditingMode: true, // Enable editing for this column
)
```

You can also make a column read-only by setting the `readOnly` property:

```dart
TrinaColumn(
  title: 'ID',
  field: 'id',
  type: TrinaColumnType.text(),
  readOnly: true, // This column cannot be edited
)
```

## Editing Modes

### Manual Editing

By default, cells enter edit mode when:

1. The user selects a cell and presses Enter
2. The user double-clicks on a cell

#### Note: when selectingMode is `cellWithSingleTap` or `rowWithSingleTap`:

The user can edit the cell **only** by:

1. Navigating with keyboard and pressing Enter.
2. Right clicking on the cell.


### Auto Editing

You can configure columns to automatically enter edit mode when selected:

```dart
TrinaColumn(
  title: 'Name',
  field: 'name',
  type: TrinaColumnType.text(),
  enableEditingMode: true,
  enableAutoEditing: true, // Automatically enter edit mode when cell is selected
)
```

Alternatively, you can set auto editing mode for the entire grid:

```dart
stateManager.setAutoEditing(true);
```

> Note: When using `cellWithSingleTap` or `rowWithSingleTap`, auto editing will not work because these selection modes works with single tap gestures, which would conflict with the automatic editing trigger.

## Customizing Edit Cell Renderer

You can customize the appearance and behavior of cells in edit mode using the `editCellRenderer` property. This can be set at either the grid level or the column level.

### Column-Level Edit Cell Renderer

To customize the edit cell renderer for a specific column:

```dart
TrinaColumn(
  title: 'Name',
  field: 'name',
  type: TrinaColumnType.text(),
  enableEditingMode: true,
  editCellRenderer: (defaultEditCellWidget, cell, controller, focusNode, handleSelected) {
    // Return a custom widget that wraps the default edit cell widget
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: defaultEditCellWidget, // Uses the controller automatically
    );
  },
)
```

### Grid-Level Edit Cell Renderer

To apply a custom edit cell renderer to all editable columns:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  editCellRenderer: (defaultEditCellWidget, cell, controller, focusNode, handleSelected) {
    // This will be used for all columns unless they have their own editCellRenderer
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: defaultEditCellWidget,
    );
  },
)
```

The `editCellRenderer` function provides:

- `defaultEditCellWidget`: The default edit cell widget (usually a TextField)
- `cell`: The current cell being edited
- `controller`: The TextEditingController for the edit field
- `focusNode`: The FocusNode for the edit field, allowing you to control focus
- `handleSelected`: A callback function to notify the grid when a value is selected (required for select and date fields)

Column-level renderers take precedence over grid-level renderers.

### Handling Different Column Types

For different column types, you may need to implement custom widgets instead of using the default edit widget:

#### Select/Dropdown Columns

For select columns, you need to use the `handleSelected` callback to notify the grid of value changes:

```dart
TrinaColumn(
  title: 'Status',
  field: 'status',
  type: TrinaColumnType.select(['Active', 'Inactive', 'Pending']),
  enableEditingMode: true,
  editCellRenderer: (defaultEditCellWidget, cell, controller, focusNode, handleSelected) {
    String? value = cell.value;
    Color indicatorColor = Colors.grey;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: indicatorColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: StatefulBuilder(builder: (context, mSetState) {
        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            focusNode: focusNode, // Use the provided focus node
            onChanged: (String? newValue) {
              // Important: Call handleSelected to notify the grid of the value change
              handleSelected?.call(newValue);
              
              // Update local state if needed
              mSetState(() {
                value = newValue;
              });
            },
            items: (cell.column.type as TrinaColumnTypeSelect)
                .items
                .map<DropdownMenuItem<String>>((dynamic value) {
              return DropdownMenuItem<String>(
                value: value as String,
                child: Text(value),
              );
            }).toList(),
          ),
        );
      }),
    );
  },
)
```

#### Date Columns

For date columns, you also need to use the `handleSelected` callback:

```dart
TrinaColumn(
  title: 'Date',
  field: 'date',
  type: TrinaColumnType.date(),
  enableEditingMode: true,
  editCellRenderer: (defaultEditCellWidget, cell, controller, focusNode, handleSelected) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              // Show date picker
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(cell.value.toString()) ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              
              // Important: Call handleSelected to notify the grid of the value change
              if (picked != null) {
                handleSelected?.call(picked);
              }
            },
          ),
        ],
      ),
    );
  },
)
```

#### Number Columns

For number columns, you can either use the controller (which automatically updates the grid) or manually call `stateManager.changeCellValue()`:

```dart
TrinaColumn(
  title: 'Quantity',
  field: 'quantity',
  type: TrinaColumnType.number(),
  enableEditingMode: true,
  editCellRenderer: (defaultEditCellWidget, cell, controller, focusNode, handleSelected) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () {
            // Option 1: Update the controller (automatically updates the grid)
            final currentValue = int.tryParse(controller.text) ?? 0;
            controller.text = (currentValue - 1).toString();
            
            // Option 2: Manually update the cell value
            // stateManager.changeCellValue(cell, currentValue - 1);
            
            // Maintain focus
            focusNode.requestFocus();
          },
        ),
        Expanded(
          child: TextField(
            controller: controller, // Using the controller automatically updates the grid
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            // No need for onChanged if using the controller
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            final currentValue = int.tryParse(controller.text) ?? 0;
            controller.text = (currentValue + 1).toString();
            focusNode.requestFocus();
          },
        ),
      ],
    );
  },
)
```

### Important Notes

1. **Maintaining Focus**: Always use the provided `focusNode` to maintain grid focus control.
2. **Updating Values**:
   - For text-based fields, use the provided `controller` to automatically update the grid.
   - If not using the controller, call `stateManager.changeCellValue(cell, newValue)` to update cell values.
   - For select and date fields, use the `handleSelected` callback to notify the grid of value changes.
3. **Controller Synchronization**: For custom inputs, make sure to update the `controller.text` to reflect the new value.
4. **Type Casting**: Be careful with type casting when working with different column types.

### Understanding Value Change Handling by Column Type

Different column types handle value changes differently:

| Column Type | How to Handle Value Changes |
|-------------|----------------------------|
| Text        | Use the provided `controller` which automatically updates the grid. If not using the controller, call `stateManager.changeCellValue(cell, newValue)`. |
| Number      | Use the provided `controller` or call `stateManager.changeCellValue(cell, numValue)`. |
| Select      | Call `handleSelected?.call(newValue)` to notify the grid of the selection. |
| Date        | Call `handleSelected?.call(pickedDate)` to notify the grid of the date selection. |
| Time        | Call `handleSelected?.call(pickedTime)` to notify the grid of the time selection. |

The key differences:

1. **Text and Number columns**:
   - When using the provided `controller`, the grid automatically detects changes.
   - If implementing a custom input that doesn't use the controller, you must manually call `stateManager.changeCellValue()`.

2. **Select, Date, and Time columns**:
   - These columns implement `PopupCell` which requires using the `handleSelected` callback.
   - The `handleSelected` callback properly updates the cell and handles any necessary state changes.
   - Do not use `stateManager.changeCellValue()` directly for these column types as it may not properly update the grid's internal state.

## Keyboard Navigation

TrinaGrid supports keyboard navigation during editing:

- **Enter**: Completes editing and moves to the cell below (configurable)
- **Tab**: Completes editing and moves to the next cell
- **Escape**: Cancels editing and reverts to the original value
- **Arrow keys**: Navigate between cells when not in edit mode

You can configure the Enter key behavior through the grid configuration:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveDown, // Default
    // Other options: editingAndMoveRight, toggleEditing, none
  ),
)
```

## Data Validation

TrinaGrid provides built-in validation for cell values based on column types. You can also implement custom validation:

```dart
TrinaColumn(
  title: 'Age',
  field: 'age',
  type: TrinaColumnType.number(),
  enableEditingMode: true,
  validator: (dynamic value, TrinaValidationContext context) {
    if (value != null && (value < 0 || value > 120)) {
      return 'Age must be between 0 and 120';
    }
    return null; // Return null if validation passes
  },
)
```

When validation fails, the `onValidationFailed` callback is triggered:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onValidationFailed: (TrinaGridValidationEvent event) {
    // Handle validation failure
    print('Validation failed: ${event.errorMessage}');
  },
)
```

## Event Handling

TrinaGrid provides several callbacks for handling cell editing events:

### Cell Value Changed

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onChanged: (TrinaGridOnChangedEvent event) {
    // Handle cell value change
    print('Cell value changed: ${event.value}');
  },
)
```

You can also set an `onChanged` callback for individual cells:

```dart
TrinaCell(
  value: 'Initial value',
  onChanged: (TrinaGridOnChangedEvent event) {
    // Handle cell value change
    print('Cell value changed: ${event.value}');
  },
)
```

## Programmatic Control

You can programmatically control cell editing through the state manager:

```dart
// Check if a cell is currently in edit mode
bool isEditing = stateManager.isEditing;

// Set a cell to edit mode
stateManager.setEditing(true);

// Toggle edit mode
stateManager.toggleEditing();

// Change a cell value programmatically
stateManager.changeCellValue(cell, newValue);
```

## Copy and Paste

TrinaGrid supports copy and paste functionality for cell values:

```dart
// Paste values from clipboard
stateManager.pasteCellValue(textList);
```

The paste operation respects the current selection:

- If a single cell is selected, pasting starts from that cell
- If a range is selected, pasting is constrained to that range
- If rows are selected, pasting applies to the selected rows

## Custom Cell Editors

You can customize the cell editing experience by implementing custom cell renderers:

```dart
TrinaColumn(
  title: 'Status',
  field: 'status',
  type: TrinaColumnType.select([
    'Active',
    'Inactive',
    'Pending',
  ]),
  enableEditingMode: true,
)
```

## Complete Example

Here's a complete example demonstrating cell editing functionality:

```dart
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

class CellEditingExample extends StatefulWidget {
  @override
  _CellEditingExampleState createState() => _CellEditingExampleState();
}

class _CellEditingExampleState extends State<CellEditingExample> {
  late List<TrinaColumn> columns;
  late List<TrinaRow> rows;
  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    
    columns = [
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.text(),
        readOnly: true, // This column cannot be edited
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        enableEditingMode: true, // Enable editing for this column
      ),
      TrinaColumn(
        title: 'Age',
        field: 'age',
        type: TrinaColumnType.number(),
        enableEditingMode: true,
        validator: (dynamic value, TrinaValidationContext context) {
          if (value != null && (value < 0 || value > 120)) {
            return 'Age must be between 0 and 120';
          }
          return null; // Return null if validation passes
        },
      ),
      TrinaColumn(
        title: 'Status',
        field: 'status',
        type: TrinaColumnType.select([
          'Active',
          'Inactive',
          'Pending',
        ]),
        enableEditingMode: true,
      ),
    ];
    
    rows = [
      TrinaRow(cells: {
        'id': TrinaCell(value: '1'),
        'name': TrinaCell(value: 'John Doe'),
        'age': TrinaCell(value: 30),
        'status': TrinaCell(value: 'Active'),
      }),
      TrinaRow(cells: {
        'id': TrinaCell(value: '2'),
        'name': TrinaCell(value: 'Jane Smith'),
        'age': TrinaCell(value: 25),
        'status': TrinaCell(value: 'Inactive'),
      }),
      TrinaRow(cells: {
        'id': TrinaCell(value: '3'),
        'name': TrinaCell(value: 'Bob Johnson'),
        'age': TrinaCell(value: 45),
        'status': TrinaCell(value: 'Pending'),
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cell Editing Example'),
      ),
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
        },
        onChanged: (TrinaGridOnChangedEvent event) {
          print('Cell value changed: ${event.value}');
        },
        onValidationFailed: (TrinaGridValidationEvent event) {
          print('Validation failed: ${event.errorMessage}');
        },
        configuration: TrinaGridConfiguration(
          enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveDown,
          enableMoveHorizontalInEditing: true,
        ),
        mode: TrinaGridMode.normal,
      ),
    );
  }
}

## Best Practices

- **Enable editing only for columns that need it**: Keep read-only columns for data that shouldn't be modified
- **Implement validation**: Always validate user input to maintain data integrity
- **Handle validation failures**: Provide clear feedback when validation fails
- **Use appropriate column types**: Choose column types that match your data (text, number, select, etc.)
- **Consider keyboard navigation**: Configure keyboard shortcuts for efficient editing
- **Test with different input methods**: Ensure your editing experience works well with keyboard, mouse, and touch input
