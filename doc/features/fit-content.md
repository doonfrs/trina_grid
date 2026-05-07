# Fit Content (Auto-Size to Rows)

By default, `TrinaGrid` expands to fill its parent's height — placing it inside an unbounded layout (e.g. a `Column` without `Expanded`, a `Card`, a dialog) results in a layout error or an over-sized grid. The `fitContent` option lets the grid size itself to its rows instead.

## Quick start

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  fitContent: true, // grid height = header + rows + footer + borders
)
```

With `fitContent: true`, the grid no longer needs `Expanded`, an explicit `SizedBox`, or `IntrinsicHeight` from the surrounding code. It computes its content height from:

- header (if `createHeader` is provided)
- column titles, column groups, and column filter row (when visible)
- the sum of every visible row's height (`row.height ?? configuration.style.rowHeight`)
- column footer (if any column has a `footerRenderer`)
- footer (if `createFooter` is provided)
- internal dividers, plus the grid's outer padding

## When to use it

`fitContent` is intended for grids with a **bounded number of visible rows** placed inside layouts that don't supply a fixed height:

- A grid inside a `Column` next to other widgets, scrolled by an outer `SingleChildScrollView`.
- A grid in a `Card` or `Dialog` that should hug its content.
- A grid in a `Column` of a `ListView` item.

For data-heavy grids with hundreds of rows, leave `fitContent: false` (the default) and provide a bounded height via `Expanded`, `SizedBox`, or a `Container(height: …)` so the row virtualization in `ListView.builder` keeps doing its job.

## Custom header / footer height

When you supply `createHeader` or `createFooter`, the grid normally measures their actual height during layout. With `fitContent: true` the height has to be computed *before* layout runs, so the grid uses `stateManager.headerHeight` / `stateManager.footerHeight` instead. Set these from inside your callback:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  fitContent: true,
  createHeader: (stateManager) {
    stateManager.headerHeight = 48; // declare the header's height
    return MyHeader();
  },
)
```

If you don't set these values, the grid falls back to `TrinaGridSettings.rowTotalHeight` (≈ 46 px). If your custom header/footer is taller, you'll see clipping or an oversized empty band — declaring the height explicitly avoids both.

## Interaction with other features

- **Filtering, sorting, pagination**: `fitContent` follows the visible row set (`stateManager.refRows`), so the grid resizes when the user filters, when a `TrinaPagination` page changes, or when `stateManager.setRowHeight` is called.
- **Frozen rows / columns**: fully supported.
- **`noRowsWidget`**: when there are no rows the body region collapses to zero height. If you need space for a "no rows" placeholder, leave `fitContent: false` and provide an explicit height.
- **`scrollPhysics`**: vertical scrolling is normally unnecessary, but if a parent ever shrinks the grid below the computed height (e.g. a small dialog), the inner `ListView` still scrolls.

## When *not* to use it

- Grids with thousands of rows — you'll lose the virtualization that lets the grid stay smooth, since every row contributes to the computed height.
- `TrinaDualGrid` — the dual grid forces tight constraints on its inner grids, so `fitContent` has no effect there.
