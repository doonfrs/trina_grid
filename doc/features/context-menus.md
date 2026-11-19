# Context Menus

Context menus in TrinaGrid provide an intuitive way for users to access column-specific actions and settings. These menus enhance the user experience by offering quick access to common operations like column freezing, resizing, filtering, and visibility controls.

![Context Menus Demo](https://raw.githubusercontent.com/doonfrs/trina_grid/master/doc/assets/context-menus.gif)

## Overview

TrinaGrid's context menu system allows users to interact with columns through a popup menu that appears when clicking on a context icon in the column header. The menu provides access to various column operations, and developers can customize both the appearance and functionality of these menus.

## Enabling Context Menus

Context menus can be enabled or disabled for each column individually:

```dart
TrinaColumn(
  title: 'Name',
  field: 'name',
  type: TrinaColumnType.text(),
  enableContextMenu: true, // Enable context menu for this column (default is true)
)
```

## Context Menu Features

When enabled, the context menu provides access to several column operations:

### Column Freezing

- **Freeze to Start**: Freezes the column to the left side of the grid
- **Freeze to End**: Freezes the column to the right side of the grid
- **Unfreeze**: Unfreezes a previously frozen column

### Column Sizing

- **Auto Fit**: Automatically adjusts the column width to fit its content

### Column Visibility

- **Hide Column**: Hides the column from view (requires `enableHideColumnMenuItem: true`)
- **Set Columns**: Opens a popup to manage the visibility of all columns (requires `enableSetColumnsMenuItem: true`)

### Column Filtering

- **Set Filter**: Opens the filter popup for the column (requires `enableFilterMenuItem: true`)
- **Reset Filter**: Clears all active filters (requires `enableFilterMenuItem: true`)

## Customizing Context Menu Items

You can control which menu items appear in the context menu by configuring the column properties:

```dart
TrinaColumn(
  title: 'Name',
  field: 'name',
  type: TrinaColumnType.text(),
  enableContextMenu: true,
  enableFilterMenuItem: true,      // Show filter-related menu items
  enableHideColumnMenuItem: true,  // Show hide column menu item
  enableSetColumnsMenuItem: true,  // Show set columns menu item
)
```

## Context Menu Icon and Resizing

The context menu icon appears on the right side of the column header when `enableContextMenu` is set to `true`. This icon serves two purposes:

1. **Menu Access**: Clicking the icon opens the context menu
2. **Column Resizing**: If `enableDropToResize` is also enabled, dragging the icon allows users to resize the column

```dart
TrinaColumn(
  title: 'Name',
  field: 'name',
  type: TrinaColumnType.text(),
  enableContextMenu: true,
  enableDropToResize: true, // Allow resizing by dragging the context menu icon
)
```

## Customizing the Context Menu

TrinaGrid allows you to fully customize the context menu by implementing your own `TrinaColumnMenuDelegate`:

```dart
class CustomColumnMenu implements TrinaColumnMenuDelegate<dynamic> {
  @override
  List<PopupMenuEntry<dynamic>> buildMenuItems({
    required TrinaGridStateManager stateManager,
    required TrinaColumn column,
  }) {
    // Return custom menu items
    return [
      PopupMenuItem<String>(
        value: 'custom_action',
        child: Text('Custom Action'),
      ),
      // Add more menu items as needed
    ];
  }

  @override
  void onSelected({
    required BuildContext context,
    required TrinaGridStateManager stateManager,
    required TrinaColumn column,
    required bool mounted,
    required String? selected,
  }) {
    // Handle menu item selection
    if (selected == 'custom_action') {
      // Perform custom action
    }
  }
}

// Use the custom menu delegate
TrinaGrid(
  columns: columns,
  rows: rows,
  columnMenuDelegate: CustomColumnMenu(),
)
```

### Extending the Default Menu

If you want to keep the default menu items and add your own custom items, you can extend the default menu using the following pattern:

```dart
class ExtendedColumnMenuDelegate implements TrinaColumnMenuDelegate<dynamic> {
  // Custom menu item keys
  static const String customAction1 = 'custom_action_1';
  static const String customAction2 = 'custom_action_2';

  // Default delegate to handle standard menu items
  final TrinaColumnMenuDelegateDefault _defaultDelegate = 
      const TrinaColumnMenuDelegateDefault();

  @override
  List<PopupMenuEntry<dynamic>> buildMenuItems({
    required TrinaGridStateManager stateManager,
    required TrinaColumn column,
  }) {
    // Get default menu items
    final defaultItems = _defaultDelegate.buildMenuItems(
      stateManager: stateManager,
      column: column,
    );
    
    // Add custom menu items with a divider
    return [
      ...defaultItems,
      const PopupMenuDivider(),
      // Custom menu items
      PopupMenuItem<String>(
        value: customAction1,
        height: 36,
        enabled: true,
        child: Text('Custom Action 1'),
      ),
      PopupMenuItem<String>(
        value: customAction2,
        height: 36,
        enabled: true,
        child: Text('Custom Action 2'),
      ),
    ];
  }

  @override
  void onSelected({
    required BuildContext context,
    required TrinaGridStateManager stateManager,
    required TrinaColumn column,
    required bool mounted,
    required dynamic selected,
  }) {
    // Handle custom menu items first
    switch (selected) {
      case customAction1:
        // Handle custom action 1
        break;
      case customAction2:
        // Handle custom action 2
        break;
      default:
        // Pass anything else to the default delegate
        if (selected is TrinaGridColumnMenuItem) {
          _defaultDelegate.onSelected(
            context: context,
            stateManager: stateManager,
            column: column,
            mounted: mounted,
            selected: selected,
          );
        }
        break;
    }
  }
}
```

You can also selectively remove or modify default menu items before adding your custom ones:

```dart
@override
List<PopupMenuEntry<dynamic>> buildMenuItems({
  required TrinaGridStateManager stateManager,
  required TrinaColumn column,
}) {
  // Get default menu items
  final defaultItems = _defaultDelegate.buildMenuItems(
    stateManager: stateManager,
    column: column,
  );
  
  // Remove specific default items if needed
  defaultItems.removeWhere((element) {
    if (element is PopupMenuItem && element.value is TrinaGridColumnMenuItem) {
      return element.value == TrinaGridColumnMenuItem.freezeToStart;
    }
    return false;
  });
  
  // Add custom menu items
  return [
    ...defaultItems,
    const PopupMenuDivider(),
    // Your custom menu items...
  ];
}
```

### Column-Specific Menu Items

You can display different menu items for specific columns by checking the column properties in your `buildMenuItems` method:

```dart
@override
List<PopupMenuEntry<dynamic>> buildMenuItems({
  required TrinaGridStateManager stateManager,
  required TrinaColumn column,
}) {
  // Get default menu items
  final defaultItems = _defaultDelegate.buildMenuItems(
    stateManager: stateManager,
    column: column,
  );
  
  // Create a list to hold all menu items
  final allItems = [...defaultItems];
  
  // Add a divider if we have default items
  if (defaultItems.isNotEmpty) {
    allItems.add(const PopupMenuDivider());
  }
  
  // Add column-specific menu items
  if (column.field == '0') {
    // Special menu items only for the first column
    allItems.add(
      PopupMenuItem<String>(
        value: 'first_column_action',
        height: 36,
        enabled: true,
        child: Container(
          color: Colors.amber,
          child: Text('Only show in first column', 
            style: TextStyle(fontSize: 13)),
        ),
      ),
    );
  }
  
  // Add menu items specific to numeric columns
  if (column.type.isNumber) {
    allItems.add(
      const PopupMenuItem<String>(
        value: 'sum_column',
        height: 36,
        enabled: true,
        child: Text('Calculate sum', style: TextStyle(fontSize: 13)),
      ),
    );
  }
  
  // Add standard custom menu items for all columns
  if (column.key != stateManager.columns.last.key) {
    allItems.add(
      const PopupMenuItem<String>(
        value: 'move_next',
        height: 36,
        enabled: true,
        child: Text('Move next', style: TextStyle(fontSize: 13)),
      ),
    );
  }
  
  return allItems;
}
```

Remember to handle these column-specific actions in your `onSelected` method:

```dart
@override
void onSelected({
  required BuildContext context,
  required TrinaGridStateManager stateManager,
  required TrinaColumn column,
  required bool mounted,
  required dynamic selected,
}) {
  switch (selected) {
    case 'first_column_action':
      // Handle first column specific action
      break;
    case 'sum_column':
      // Calculate and display sum for numeric column
      break;
    case 'move_next':
      // Move column to next position
      break;
    default:
      // Pass anything else to the default delegate
      if (selected is TrinaGridColumnMenuItem) {
        _defaultDelegate.onSelected(
          context: context,
          stateManager: stateManager,
          column: column,
          mounted: mounted,
          selected: selected,
        );
      }
      break;
  }
}
```

## Styling the Context Menu

You can customize the appearance of the context menu icon and the menu itself through the `TrinaGridStyleConfig`:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    style: TrinaGridStyleConfig(
      // Customize the context menu icon
      columnContextIcon: Icons.more_vert,
      
      // Customize menu colors
      menuBackgroundColor: Colors.white,
      iconColor: Colors.blue,
    ),
  ),
)
```

## Example

Here's a complete example demonstrating context menus:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

class ContextMenuExample extends StatefulWidget {
  @override
  _ContextMenuExampleState createState() => _ContextMenuExampleState();
}

class _ContextMenuExampleState extends State<ContextMenuExample> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.number(),
        enableContextMenu: true,
        enableFilterMenuItem: true,
        enableHideColumnMenuItem: true,
        enableSetColumnsMenuItem: true,
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        enableContextMenu: true,
        enableDropToResize: true,
      ),
      TrinaColumn(
        title: 'Role',
        field: 'role',
        type: TrinaColumnType.text(),
        enableContextMenu: false, // Disable context menu for this column
      ),
    ]);

    rows.addAll([
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 1),
          'name': TrinaCell(value: 'John Doe'),
          'role': TrinaCell(value: 'Developer'),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 2),
          'name': TrinaCell(value: 'Jane Smith'),
          'role': TrinaCell(value: 'Designer'),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: 3),
          'name': TrinaCell(value: 'Bob Johnson'),
          'role': TrinaCell(value: 'Manager'),
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Context Menu Example')),
      body: TrinaGrid(
        columns: columns,
        rows: rows,
      ),
    );
  }
}
```

## Interaction with Other Features

Context menus work seamlessly with other TrinaGrid features:

- **Column Freezing**: The context menu provides options to freeze and unfreeze columns
- **Column Resizing**: When both `enableContextMenu` and `enableDropToResize` are enabled, the context menu icon can be dragged to resize the column
- **Column Filtering**: The context menu provides access to filtering options when `enableFilterMenuItem` is true
- **Column Visibility**: The context menu provides options to hide columns and manage column visibility

## Best Practices

- Enable context menus for columns that users might need to configure frequently
- Consider enabling all menu item types (`enableFilterMenuItem`, `enableHideColumnMenuItem`, and `enableSetColumnsMenuItem`) for a consistent user experience
- If you need custom menu items, implement a custom `TrinaColumnMenuDelegate`
- If you want to allow column resizing, enable both `enableContextMenu` and `enableDropToResize`
