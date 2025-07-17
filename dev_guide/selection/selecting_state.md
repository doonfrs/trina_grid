# Core Logic: The `SelectingState` Mixin

**File:** `lib/src/manager/state/selecting_state.dart`

The `SelectingState` mixin is the heart of the selection feature. It is mixed into `TrinaGridStateManager` and encapsulates all state and logic related to selecting cells and rows.

## Key Responsibilities

-   Managing the current `TrinaGridSelectingMode`.
-   Tracking the list of selected cells (`selectedCells`) and rows (`selectedRows`).
-   Handling the logic for different selection types (single, multiple, range).
-   Providing methods to programmatically modify the selection.

## State Properties

The mixin manages several key properties to track the grid's selection state:

-   `selectingMode: TrinaGridSelectingMode`: Determines the current selection behavior (e.g., `cell`, `row`). The entire logic of the mixin adapts based on this mode.
-   `isSelecting: bool`: A boolean flag that indicates if a multi-selection action (like dragging) is currently in progress.
-   `selectedRows: List<TrinaRow>`: A list of the currently selected `TrinaRow` objects. This is primarily used when `selectingMode` is `row`.
-   `selectedCells: List<TrinaCell>`: A list of the currently selected `TrinaCell` objects. This is used when `selectingMode` is `cell`.
-   `currentSelectingPosition: TrinaGridCellPosition?`: Stores the position of the second cell in a range selection, allowing the grid to draw the selection rectangle between the `currentCell` and this position.

## Key Methods

These methods are the primary API for interacting with the selection state from the `TrinaGridStateManager`.

-   `setSelectingMode(TrinaGridSelectingMode mode)`: Switches the selection behavior of the grid. Calling this method will clear any existing selection.
-   `setSelecting(bool flag)`: Manages the `isSelecting` flag. This is typically called when a user starts or stops a multi-selection gesture like a drag.
-   `clearCurrentSelecting()`: Clears all selected cells and rows and resets any range selection.
-   `toggleRowSelection(int rowIdx)`: Adds or removes a row from the `selectedRows` list..
-   `toggleCellSelection(TrinaCell cell)`: Adds or removes a cell from the `selectedCells` list.
-   `selectRowsInRange(int from, int to)`: Selects all rows between the `from` and `to` indices. This is used for shift-click range selection on rows.
-   `selectCellsInRange(TrinaGridCellPosition start, TrinaGridCellPosition end)`: Selects all cells within the rectangle defined by the `start` and `end` positions.

---
