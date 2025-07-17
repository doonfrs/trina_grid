# Configuration

TrinaGrid offers extensive configuration options to customize its appearance and behavior. This guide covers the main configuration options available.

## TrinaGridConfiguration

The `TrinaGridConfiguration` class is the main way to configure TrinaGrid. You can pass it to the `configuration` parameter of the `TrinaGrid` widget:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    // Configuration options here
  ),
)
```

## Basic Configuration

### Style Configuration

The `style` property allows you to customize the visual appearance of the grid:

```dart
TrinaGridConfiguration(
  style: TrinaGridStyleConfig(
    // Colors
    gridBackgroundColor: Colors.white,
    borderColor: Colors.grey[300]!,
    activatedBorderColor: Colors.blue,
    activatedColor: Colors.blue.withOpacity(0.2),
    inactivatedBorderColor: Colors.grey[300]!,
    
    // Cell styles
    cellColorInEditState: Colors.white,
    cellColorInReadOnlyState: Colors.grey[200]!,
    cellHorizontalBorderWidth: 1.0,
    cellVerticalBorderWidth: 1.0,
    
    // Text styles
    columnTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    cellTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 14,
    ),
    
    // Sizes
    rowHeight: 45,
    columnHeight: 45,
    columnFilterHeight: 45,
    
    // Icons
    iconSize: 18,
    iconColor: Colors.black54,
    
    // Even/odd row colors
    oddRowColor: Colors.grey[100],
    evenRowColor: Colors.white,
  ),
)
```

### Scrollbar Configuration

Configure the scrollbars with the `scrollbar` property:

```dart
TrinaGridConfiguration(
  scrollbar: TrinaGridScrollbarConfig(
    // Visibility settings
    isAlwaysShown: true,      // Prevents scrollbars from fading out after scrolling stops
    thumbVisible: true,       // Whether the scrollbar thumb is visible at all
    showTrack: true,          // Whether to show the scrollbar track background
    showHorizontal: true,     // Whether to show the horizontal scrollbar
    showVertical: true,       // Whether to show the vertical scrollbar
    
    // Appearance settings
    thickness: 8.0,
    minThumbLength: 40.0,
    thumbColor: Colors.blue.withOpacity(0.6),
    trackColor: Colors.grey.withOpacity(0.2),
    thumbHoverColor: Colors.blue.withOpacity(0.8),
    trackHoverColor: Colors.grey.withOpacity(0.3),
    isDraggable: true,
  ),
)
```

The `TrinaGridScrollbarConfig` provides the following options:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `isAlwaysShown` | `bool` | `false` | If true, scrollbars remain visible all the time. If false, they appear during scrolling and fade out after about 3 seconds of inactivity. |
| `thumbVisible` | `bool` | `true` | Whether the scrollbar thumb is visible at all. If false, scrollbars won't show even during scrolling. |
| `showTrack` | `bool` | `true` | Whether to show the scrollbar track background. |
| `showHorizontal` | `bool` | `true` | Whether to show the horizontal scrollbar. |
| `showVertical` | `bool` | `true` | Whether to show the vertical scrollbar. |
| `thickness` | `double` | `8.0` | Thickness of the scrollbar. |
| `minThumbLength` | `double` | `40.0` | Minimum length of the scrollbar thumb. |
| `thumbColor` | `Color?` | `null` | Color of the scrollbar thumb. |
| `trackColor` | `Color?` | `null` | Color of the scrollbar track. |
| `thumbHoverColor` | `Color?` | `null` | Color of the scrollbar thumb when hovered. |
| `trackHoverColor` | `Color?` | `null` | Color of the scrollbar track when hovered. |
| `isDraggable` | `bool` | `true` | Whether scrollbar thumbs can be dragged with mouse or touch to scroll. |

For more detailed information about scrollbar customization, see the [Scrollbars](../features/scrollbars.md) feature documentation.

### Column Configuration

Set default column behavior:

```dart
TrinaGridConfiguration(
  columnSize: TrinaGridColumnSizeConfig(
    autoSizeMode: TrinaAutoSizeMode.scale,
    resizeMode: TrinaResizeMode.normal,
  ),
)
```

## Behavior Configuration

### Selection Mode

Configure how cells or rows can be selected:

```dart
TrinaGridConfiguration(
  selectingMode: TrinaGridSelectingMode.cell, // or TrinaGridSelectingMode.row 
)
```

The available selection modes are:
- `TrinaGridSelectingMode.cell`: Allows selection of individual cells with mouse clicks or keyboard navigation
- `TrinaGridSelectingMode.row`: Enables selection of entire rows when clicking any cell within that row
- `TrinaGridSelectingMode.disable`: 


### Editing Configuration

Control editing behavior:

```dart
TrinaGridConfiguration(
  enableMoveDownAfterSelecting: true,
  enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveDown,
  enableEditingMode: true,
)
```

### Keyboard Navigation

Configure keyboard shortcuts:

```dart
TrinaGridConfiguration(
  shortcut: TrinaGridShortcut(
    actions: {
      // Custom shortcuts
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyA): 
          TrinaGridShortcutAction.selectAll,
    },
  ),
)
```

## Predefined Configurations

TrinaGrid provides some predefined configurations:

### Dark Mode

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration.dark(),
)
```

### Custom Theme

You can create your own theme by extending the default configuration:

```dart
final myTheme = TrinaGridConfiguration(
  style: TrinaGridStyleConfig(
    gridBackgroundColor: Colors.indigo[50]!,
    borderColor: Colors.indigo[300]!,
    activatedBorderColor: Colors.indigo,
    activatedColor: Colors.indigo.withOpacity(0.2),
    columnTextStyle: const TextStyle(
      color: Colors.indigo[900]!,
      fontWeight: FontWeight.bold,
    ),
    cellTextStyle: TextStyle(
      color: Colors.indigo[900]!,
    ),
    iconColor: Colors.indigo,
  ),
);

TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: myTheme,
)
```

## Column-Specific Configuration

Many configuration options can be set at the column level, which will override the global configuration:

```dart
TrinaColumn(
  title: 'Name',
  field: 'name',
  type: TrinaColumnType.text(),
  width: 200,
  // Column-specific configuration
  textAlign: TrinaColumnTextAlign.center,
  titleTextAlign: TrinaColumnTextAlign.center,
  enableSorting: true,
  enableFilterMenuItem: true,
  enableContextMenu: true,
  enableDropToResize: true,
  enableRowDrag: false,
  enableRowChecked: false,
  enableEditingMode: true,
  readOnly: false,
  // Override Enter key behavior for this column's filter
  filterEnterKeyAction: TrinaGridEnterKeyAction.none,
)
```

## Row-Specific Configuration

Rows can also have specific configurations:

```dart
TrinaRow(
  cells: {
    'id': TrinaCell(value: '1'),
    'name': TrinaCell(value: 'John Doe'),
  },
  // Row-specific configuration
  checked: true,
  type: TrinaRowType.normal(), // or group
)
```

## Cell-Specific Configuration

Individual cells can have their own configuration:

```dart
TrinaCell(
  value: 'John Doe',
  // Cell-specific configuration
  renderer: (context) => Text(
    context.cell.value.toString(),
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
)
```

## Complete Configuration Example

Here's a complete example showing various configuration options:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onLoaded: (TrinaGridOnLoadedEvent event) {
    stateManager = event.stateManager;
  },
  configuration: TrinaGridConfiguration(
    // Style configuration
    style: TrinaGridStyleConfig(
      gridBackgroundColor: Colors.white,
      borderColor: Colors.grey[300]!,
      activatedBorderColor: Colors.blue,
      activatedColor: Colors.blue.withOpacity(0.2),
      cellTextStyle: const TextStyle(fontSize: 14),
      columnTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      rowHeight: 45,
      columnHeight: 45,
      iconSize: 18,
      iconColor: Colors.blue,
      enableCellBorderHorizontal: true,
      enableCellBorderVertical: true,
      cellVerticalBorderWidth: 1.0,
      cellHorizontalBorderWidth: 1.0,
      gridBorderRadius: BorderRadius.circular(8),
      gridPopupBorderRadius: BorderRadius.circular(8),
      enableGridBorderShadow: true,
      oddRowColor: Colors.grey[100],
      evenRowColor: Colors.white,
    ),
    
    // Scrollbar configuration
    scrollbar: TrinaGridScrollbarConfig(
      isAlwaysShown: true,         // Always show scrollbars
      thumbVisible: true,          // Show scrollbar thumbs
      showTrack: true,             // Show scrollbar tracks
      thickness: 8.0,              // Scrollbar thickness
      minThumbLength: 40.0,        // Minimum thumb length
      thumbColor: Colors.blue.withOpacity(0.6),  // Thumb color
      trackColor: Colors.grey.withOpacity(0.2),  // Track color
      thumbHoverColor: Colors.blue.withOpacity(0.8),
      trackHoverColor: Colors.grey.withOpacity(0.3),
      isDraggable: true,
    ),
    
    // Column configuration
    columnSize: const TrinaGridColumnSizeConfig(
      autoSizeMode: TrinaAutoSizeMode.scale,
      resizeMode: TrinaResizeMode.normal,
    ),
    
    // Behavior configuration
    enableMoveDownAfterSelecting: true,
    enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveDown,
    selectingMode: TrinaGridSelectingMode.cellWithSingleTap,
    
    // Keyboard shortcuts
    shortcut: TrinaGridShortcut(
      actions: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyA): 
            TrinaGridShortcutAction.selectAll,
      },
    ),
  ),
)
```

> **Note:** While most keyboard behavior is configured at the grid level with `enterKeyAction`, you can override the Enter key behavior for specific column filters using the `filterEnterKeyAction` property on individual columns. See [Column Filtering](../features/column-filtering.md#controlling-keyboard-navigation-in-column-filters) for more details.

## Next Steps

- [Column Types](../features/column-types.md)
- [Cell Renderers](../features/cell-renderer.md)
- [Custom Styling](../features/custom-styling.md)
