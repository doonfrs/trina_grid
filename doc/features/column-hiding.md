# Column Hiding

Column hiding is a feature that allows users to show or hide specific columns in TrinaGrid. This feature provides flexibility in displaying data and helps users focus on the most relevant information by removing columns that are not currently needed.

## Overview

TrinaGrid provides a comprehensive column hiding system with both programmatic and UI-based methods for controlling column visibility. Users can hide columns through the column menu or a dedicated column visibility popup, and developers can hide columns programmatically through the state manager API.

## How to Hide Columns

### Using the Column Menu (UI)

The most direct way for users to hide a column is through the column menu:

1. Click on the menu icon (⋮) on the right side of a column header
2. Select "Hide column" from the dropdown menu

This will immediately hide the column from view.

### Using the Set Columns Popup (UI)

TrinaGrid provides a dedicated popup for managing column visibility:

1. The popup can be triggered programmatically or through a UI element
2. It displays a list of all columns with checkboxes
3. Users can check or uncheck columns to show or hide them
4. Users can also use the header checkbox to show or hide all columns at once

### Using the State Manager (Programmatic)

You can hide or show columns programmatically using the state manager:

```dart
// Hide a single column
stateManager.hideColumn(column, true);

// Show a previously hidden column
stateManager.hideColumn(column, false);

// Hide multiple columns at once
stateManager.hideColumns(columnsList, true);

// Show multiple columns at once
stateManager.hideColumns(columnsList, false);

// Show the column visibility popup
stateManager.showSetColumnsPopup(context);
```

## Behavior with Frozen Columns

Column hiding has special behavior when working with frozen columns:

1. When unhiding a frozen column, the system checks if there's enough space in the frozen area
2. If there isn't enough space, the column will be unfrozen automatically (its frozen state will be set to `TrinaColumnFrozen.none`)
3. This ensures that the frozen area doesn't exceed the available space

## Auto-Size Restoration

By default, TrinaGrid will restore auto-sizing after hiding or showing columns. You can control this behavior through the configuration:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: const TrinaGridConfiguration(
    columnSize: TrinaGridColumnSizeConfig(
      // Set to false to prevent auto-size restoration after hiding/showing columns
      restoreAutoSizeAfterHideColumn: false,
    ),
  ),
)
```

## Events

When columns are hidden or shown, TrinaGrid dispatches a `TrinaGridColumnHiddenEvent` through the event manager. This allows your application to respond to visibility changes and persist user preferences.

### Listening for Column Visibility Changes

You can listen to column visibility events using the event manager:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onLoaded: (event) {
    stateManager = event.stateManager;

    // Listen to column visibility events
    stateManager.eventManager!.listener((event) {
      if (event is TrinaGridColumnHiddenEvent) {
        print('Columns ${event.isHidden ? "hidden" : "shown"}: ${event.columns.length}');

        // Store visibility state for next usage
        saveColumnVisibility(event.columns, event.isHidden);
      }
    });
  },
)
```

### The TrinaGridColumnHiddenEvent Object

The event contains the following properties:

| Property | Type | Description |
|----------|------|-------------|
| `columns` | `List<TrinaColumn>` | The columns that were hidden or shown |
| `isHidden` | `bool` | `true` if columns were hidden, `false` if shown |

### Example: Persisting Column Visibility

```dart
// Save column visibility to SharedPreferences
void saveColumnVisibility(List<TrinaColumn> columns, bool isHidden) {
  final prefs = await SharedPreferences.getInstance();
  final hiddenColumns = prefs.getStringList('hiddenColumns') ?? [];

  for (final column in columns) {
    if (isHidden) {
      hiddenColumns.add(column.field);
    } else {
      hiddenColumns.remove(column.field);
    }
  }

  prefs.setStringList('hiddenColumns', hiddenColumns);
}
```

## Example

Here's a complete example demonstrating column hiding:

```dart
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

class ColumnHidingExample extends StatefulWidget {
  @override
  _ColumnHidingExampleState createState() => _ColumnHidingExampleState();
}

class _ColumnHidingExampleState extends State<ColumnHidingExample> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];
  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'Column A',
        field: 'column_a',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Column B',
        field: 'column_b',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Column C',
        field: 'column_c',
        type: TrinaColumnType.text(),
      ),
    ]);

    rows.addAll([
      TrinaRow(
        cells: {
          'column_a': TrinaCell(value: 'a1'),
          'column_b': TrinaCell(value: 'b1'),
          'column_c': TrinaCell(value: 'c1'),
        },
      ),
      TrinaRow(
        cells: {
          'column_a': TrinaCell(value: 'a2'),
          'column_b': TrinaCell(value: 'b2'),
          'column_c': TrinaCell(value: 'c2'),
        },
      ),
      TrinaRow(
        cells: {
          'column_a': TrinaCell(value: 'a3'),
          'column_b': TrinaCell(value: 'b3'),
          'column_c': TrinaCell(value: 'c3'),
        },
      ),
    ]);
  }

  void _toggleColumnA() {
    // Find Column A
    TrinaColumn columnA = columns.firstWhere((col) => col.field == 'column_a');
    
    // Toggle its visibility
    stateManager.hideColumn(columnA, !columnA.hide);
  }

  void _showColumnsPopup() {
    stateManager.showSetColumnsPopup(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Column Hiding Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _toggleColumnA,
                  child: Text('Toggle Column A'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _showColumnsPopup,
                  child: Text('Show Columns Popup'),
                ),
              ],
            ),
          ),
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## Initializing Hidden Columns

You can initialize columns as hidden when creating them:

```dart
TrinaColumn(
  title: 'Hidden Column',
  field: 'hidden_column',
  type: TrinaColumnType.text(),
  hide: true, // This column will be hidden initially
)
```

## Customizing the Column Menu Text

You can customize the text used for the "Hide column" option in the column menu:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    localeText: const TrinaGridLocaleText(
      hideColumn: 'Hide this column', // Custom text for the hide column option
    ),
  ),
)
```

## Best Practices

1. **Provide Column Management UI**: Always provide users with a way to manage column visibility, either through the column menu or a dedicated UI element that triggers the `showSetColumnsPopup` method.

2. **Consider Initial Visibility**: For grids with many columns, consider which columns should be visible by default. Hide less important columns initially to avoid overwhelming users.

3. **Combine with Column Freezing**: When using column hiding with column freezing, be aware of the automatic unfreezing behavior when there's not enough space in the frozen area.

4. **Auto-Size Configuration**: Decide whether to restore auto-sizing after hiding/showing columns based on your application's needs. For data-dense grids, you might want to maintain user-defined column sizes.

5. **Save User Preferences**: Consider saving the user's column visibility preferences to restore them when they return to the grid.

## Related Features

- [Column Types](column-types.md)
- [Column Freezing](column-freezing.md)
- [Column Resizing](column-resizing.md)
- [Column Moving](column-moving.md)
