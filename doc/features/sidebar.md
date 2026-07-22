# Record Sidebar

The record sidebar is a built-in panel that shows every field of the currently selected row as a `label -> value` list, with a search box to filter fields. Tapping a field edits it using the grid's own per-type editor and writes the change back to the grid.

## Overview

The sidebar is configured through the `sidebar` property in `TrinaGridConfiguration` and toggled at runtime through the `TrinaGridStateManager`. It supports two display modes:

- **Docked** (default): the sidebar takes horizontal space and pushes the grid area to the left.
- **Floating**: the sidebar slides in from the right over the grid as an overlay with a close button, and slides back out when hidden.

The sidebar is hidden by default. It updates automatically as the selected (active) row changes.

The panel is styled with shadcn components (it follows the app's light/dark mode).

## Editing fields

Each field is displayed with its formatted value. Tapping a field (that is not read-only) switches it into the grid's own editor for that column type, so editing behaves exactly like editing the cell in the grid - including custom `editCellRenderer`s and custom column types:

- text / number / currency / percentage: the grid's formatted text input
- select / boolean: the grid's dropdown
- date / time / dateTime: the grid's date/time picker

Tapping a field makes that cell the grid's current cell (the grid highlights it), and one field is edited at a time. Text fields commit on Enter or when focus leaves the field. Read-only columns show a lock icon and are not editable. Committed edits go through the grid's value pipeline (formatting, validation, `onChanged`).

Because the editors are the grid's own, grid keyboard navigation applies while editing: for example Enter and arrow keys behave as they do when editing a cell in the grid.

## Basic Usage

Enable and size the sidebar via configuration, then toggle it through the state manager:

```dart
late TrinaGridStateManager stateManager;

TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: const TrinaGridConfiguration(
    sidebar: TrinaGridSidebarConfig(
      width: 340,
      mode: TrinaGridSidebarMode.docked,
    ),
  ),
  onLoaded: (event) {
    stateManager = event.stateManager;
    // Highlight whole rows so the sidebar tracks the selected record.
    stateManager.setSelectingMode(TrinaGridSelectingMode.row);
  },
)

// Somewhere in your UI (e.g. a toolbar button):
ElevatedButton(
  onPressed: () => stateManager.toggleSidebar(),
  child: const Text('Toggle sidebar'),
)
```

## Controlling the sidebar

The following actions are available on `TrinaGridStateManager`:

```dart
stateManager.showSidebar();                                  // show (default mode)
stateManager.showSidebar(mode: TrinaGridSidebarMode.floating); // show as floating
stateManager.hideSidebar();                                  // hide
stateManager.toggleSidebar();                                // flip visibility
stateManager.toggleSidebar(mode: TrinaGridSidebarMode.docked); // flip + set mode
stateManager.setSidebarMode(TrinaGridSidebarMode.floating);  // change mode
stateManager.setSidebarWidth(420);                           // change width
```

Read the current state:

```dart
stateManager.isSidebarVisible; // bool
stateManager.sidebarMode;      // TrinaGridSidebarMode
stateManager.sidebarWidth;     // double
```

## Custom content

By default the sidebar renders the built-in record view (field list + search + inline editing). To render your own content, provide a `contentBuilder`. It receives the grid's `stateManager`, so you can read the current row (`stateManager.currentRow`) and write values back.

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    sidebar: TrinaGridSidebarConfig(
      contentBuilder: (context, stateManager) {
        final row = stateManager.currentRow;
        if (row == null) {
          return const Center(child: Text('Select a row'));
        }
        return ListView(
          children: [
            for (final column in stateManager.columns)
              ListTile(
                title: Text(column.title),
                subtitle: Text(
                  row.cells[column.field]?.value?.toString() ?? '',
                ),
              ),
          ],
        );
      },
    ),
  ),
)
```

> Note: in floating mode the built-in view shows a close button next to its search field. Custom content is responsible for its own close affordance - call `stateManager.hideSidebar()` from your widget.

> Note: passing an inline closure to `contentBuilder` makes each `TrinaGridConfiguration` compare as unequal (closures compare by identity). Use a stable function reference if you rely on configuration equality.

## Configuration Options

### TrinaGridSidebarConfig

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `enabled` | `bool` | `true` | Whether the sidebar feature responds to show/toggle actions. |
| `mode` | `TrinaGridSidebarMode` | `docked` | Default display mode when none is passed to show/toggle. |
| `width` | `double` | `320` | Default panel width in logical pixels. |
| `animationDuration` | `Duration` | `250ms` | Slide animation duration used in floating mode. |
| `contentBuilder` | `TrinaGridSidebarContentBuilder?` | `null` | Optional builder to replace the built-in record view. |

### TrinaGridSidebarMode

| Value | Description |
|-------|-------------|
| `docked` | Takes horizontal space and pushes the grid. |
| `floating` | Slides in over the grid with a close button. |
