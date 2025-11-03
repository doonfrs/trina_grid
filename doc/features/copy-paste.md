# Copy & Paste

TrinaGrid provides a robust copy and paste functionality that allows users to easily transfer data between cells within the grid or between the grid and external applications.

## Overview

The copy and paste feature in TrinaGrid enables users to:

- Copy a single cell value
- Copy a range of selected cells
- Copy entire rows
- Paste data into a single cell
- Paste data into a range of cells
- Paste data into selected rows

This functionality is implemented through keyboard shortcuts and integrates with the system clipboard, allowing for seamless data transfer between TrinaGrid and other applications.

## Benefits

- **Improved Productivity**: Quickly duplicate or move data within the grid
- **Data Transfer**: Easily move data between TrinaGrid and external applications like spreadsheets
- **Bulk Editing**: Make changes to multiple cells at once by copying and pasting
- **Data Formatting**: Maintain tabular structure when copying and pasting multiple cells

## Implementation

### Keyboard Shortcuts

TrinaGrid uses standard keyboard shortcuts for copy and paste operations:

- **Ctrl+C** (Cmd+C on macOS): Copy selected cells or rows
- **Ctrl+V** (Cmd+V on macOS): Paste clipboard content into the grid

### Copy Functionality

The copy operation depends on what is currently selected in the grid:

1. **Single Cell**: When a single cell is selected, its value is copied to the clipboard.
2. **Cell Range**: When multiple cells are selected, their values are copied as a tab-separated, newline-delimited text.
3. **Rows**: When rows are selected, all visible columns for those rows are copied as tab-separated, newline-delimited text.

```dart
// Example of how copy works internally
Clipboard.setData(ClipboardData(text: stateManager.currentSelectingText));
```

### Paste Functionality

The paste operation depends on the current selection and the clipboard content:

1. **Single Cell**: When pasting into a single cell, if the clipboard contains a table of data, it will be pasted starting from the selected cell.
2. **Cell Range**: When a range of cells is selected, the clipboard content will be pasted within that range, repeating if necessary.
3. **Selected Rows**: When rows are selected, the clipboard content will be pasted into those rows across all columns.

```dart
// Example of how paste works internally
Clipboard.getData('text/plain').then((value) {
  if (value == null) {
    return;
  }
  List<List<String>> textList = TrinaClipboardTransformation.stringToList(
    value.text!,
    cellSeparator: stateManager.configuration.copyPasteCellSeparator ?? '\t',
    lineSeparator: stateManager.configuration.copyPasteLineSeparator ?? '\n',
  );
  stateManager.pasteCellValue(textList);
});
```

## Clipboard Data Format

When copying data from TrinaGrid, the data is formatted as follows:

- **Cell Separator**: Cells in the same row are separated by tab characters (`\t`) by default
- **Line Separator**: Rows are separated by platform-specific line endings by default:
  - Windows: CRLF (`\r\n`)
  - macOS/Linux: LF (`\n`)

For example, a 2x2 selection on Windows would be formatted as:
```
value1\tvalue2\r\n
value3\tvalue4
```

When pasting data into TrinaGrid, the same format is expected. TrinaGrid will parse the clipboard text and convert it into a two-dimensional array of values before applying it to the grid. The paste operation accepts both LF and CRLF line endings regardless of platform for maximum compatibility.

## Paste Behavior

When pasting data, TrinaGrid follows these rules:

1. **Data Type Conversion**: Values are automatically converted to match the column's data type
2. **Validation**: Cell-level validation is applied to pasted values
3. **Events**: Cell change events are triggered for each modified cell
4. **Row State**: Rows with modified cells are marked as updated
5. **Repeating Pattern**: If the pasted data is smaller than the target range, it will be repeated to fill the range

## Example Usage

### Basic Copy and Paste

1. Select a cell or range of cells using the mouse or keyboard
2. Press Ctrl+C (Cmd+C on macOS) to copy the values
3. Select the target cell or range where you want to paste
4. Press Ctrl+V (Cmd+V on macOS) to paste the values

### Copying from External Applications

1. Copy data from an external application (e.g., Excel, Google Sheets)
2. Select the target cell in TrinaGrid where you want to begin pasting
3. Press Ctrl+V (Cmd+V on macOS) to paste the values

### Copying to External Applications

1. Select cells or rows in TrinaGrid
2. Press Ctrl+C (Cmd+C on macOS) to copy the values
3. Switch to the external application
4. Paste the values using the application's paste command

## Configuration

The copy and paste functionality is enabled by default and does not require additional configuration. However, you can customize the behavior in several ways:

### Custom Separators

You can configure custom separators for copy and paste operations using `TrinaGridConfiguration`:

```dart
TrinaGrid(
  configuration: TrinaGridConfiguration(
    // Customize cell separator (default: tab character '\t')
    copyPasteCellSeparator: ',',  // Use comma for CSV-compatible format

    // Customize line separator (default: platform-specific)
    // null = platform-specific (\r\n on Windows, \n on macOS/Linux)
    copyPasteLineSeparator: '\n',  // Force LF on all platforms
  ),
  // Other properties...
)
```

**Separator Options:**

- `copyPasteCellSeparator`: Separator between cells in the same row
  - Default: `null` (uses tab `\t`)
  - Common alternatives: `,` for CSV, `;` for some locales

- `copyPasteLineSeparator`: Separator between rows
  - Default: `null` (uses platform-specific line endings)
  - Common alternatives: `\n` for cross-platform consistency

**Use Cases:**

```dart
// CSV format - comma-separated with LF line endings
TrinaGridConfiguration(
  copyPasteCellSeparator: ',',
  copyPasteLineSeparator: '\n',
)

// Excel-compatible format with platform-specific line endings
TrinaGridConfiguration(
  copyPasteCellSeparator: '\t',
  copyPasteLineSeparator: null,  // Platform-specific
)

// Custom format - pipe-separated
TrinaGridConfiguration(
  copyPasteCellSeparator: '|',
  copyPasteLineSeparator: '\n',
)
```

### Other Customization Options

1. **Custom Cell Handling**: Implement custom `onChanged` handlers for cells to control how pasted values are processed
2. **Keyboard Shortcuts**: Customize the keyboard shortcuts by overriding the default shortcut handlers

```dart
TrinaGrid(
  // Other properties...
  onLoaded: (TrinaGridOnLoadedEvent event) {
    // Access the state manager
    final stateManager = event.stateManager;

    // Customize keyboard shortcuts if needed
    stateManager.setShortcuts([
      // Your custom shortcuts
    ]);
  },
)
```

## Limitations

- Editing mode: Copy and paste operations are disabled when a cell is in editing mode
- Read-only cells: Values cannot be pasted into read-only cells
- Complex widgets: When copying cells containing complex widgets, only their string representation will be copied

## Related Features

- [Cell Selection](cell-selection.md) - Learn how to select cells and rows
- [Keyboard Navigation](keyboard-navigation.md) - Navigate the grid using keyboard shortcuts
- [Cell Editing](cell-editing.md) - Edit cell values directly in the grid
