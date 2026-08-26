# Themes

TrinaGrid gives you three ways to style a grid:

1. **The built-in palettes** - `TrinaGridConfiguration()` (light) and `TrinaGridConfiguration.dark()`. Fixed colors, unchanged since the earliest versions.
2. **Material theme integration** - `TrinaGridConfiguration.fromTheme(context)` derives the grid colors from your app's `ColorScheme`.
3. **Manual styling** - spell out the fields of `TrinaGridStyleConfig` yourself.

All three can be combined with `copyWith`.

## Material theme integration

By default the grid does **not** follow your app theme. A grid dropped into a `deepPurple`-seeded `MaterialApp` still renders white with light-blue selection, because the defaults are compile-time constants and a `const` constructor cannot read `Theme.of(context)`.

`fromTheme` closes that gap:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration.fromTheme(context),
)
```

The grid now uses your seed color, and follows light/dark automatically because `ColorScheme.brightness` decides `isDarkStyle`.

> Call it inside `build`. It reads the ambient theme, so it cannot be `const`, and calling it from `initState` would freeze the grid on whatever theme was active at the time.

### Setting other options

`fromTheme` only sets `style`. Chain `copyWith` for everything else:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration.fromTheme(context).copyWith(
    selectingMode: TrinaGridSelectingMode.row,
    enableMoveDownAfterSelecting: true,
  ),
)
```

### Overriding individual colors

Use `TrinaGridStyleConfig.copyWith` to keep the theme mapping but change a few values:

```dart
final theme = Theme.of(context);

TrinaGridConfiguration(
  style: TrinaGridStyleConfig.fromTheme(theme).copyWith(
    rowHeight: 56,
    oddRowColor: TrinaOptional(theme.colorScheme.surfaceContainerLowest),
  ),
)
```

### Starting from a ColorScheme

When you have a scheme but no full `ThemeData`:

```dart
TrinaGridStyleConfig.fromColorScheme(
  ColorScheme.fromSeed(seedColor: Colors.indigo),
)
```

`fromTheme` delegates to this, passing `theme.textTheme` so `columnTextStyle` and `cellTextStyle` inherit your font.

## What gets mapped

| Style field | ColorScheme role |
|---|---|
| `gridBackgroundColor`, `rowColor`, `cellColorInEditState` | `surface` |
| `frozenRowColor` | `surfaceContainerLow` |
| `menuBackgroundColor` | `surfaceContainer` |
| `cellColorInReadOnlyState`, `unfocusedSelectionColor` | `surfaceContainerHighest` |
| `activatedColor`, `columnCheckedColor`, `cellCheckedColor` | `primaryContainer` |
| `dragTargetColumnColor` | `primaryContainer` at 50% alpha |
| `activatedBorderColor`, `columnActiveColor`, `cellActiveColor` | `primary` |
| `rowCheckedColor` | `primary` at 8% alpha |
| `rowHoveredColor` | `onSurface` at 8% alpha |
| `borderColor`, `inactivatedBorderColor`, `frozenRowBorderColor` | `outlineVariant` |
| `gridBorderColor` | `outline` |
| `iconColor`, `columnUnselectedColor`, `cellUnselectedColor` | `onSurfaceVariant` |
| `disabledIconColor` | `onSurface` at 38% alpha |
| `cellDirtyColor` | `tertiaryContainer` |
| `columnTextStyle` | `textTheme.titleSmall` recolored to `onSurface` |
| `cellTextStyle` | `textTheme.bodyMedium` recolored to `onSurface` |
| `isDarkStyle` | `scheme.brightness == Brightness.dark` |

Everything that is not a color keeps the default value: `rowHeight`, `columnHeight`, paddings, icon sizes, border widths, and the sort/group/context icons.

The opt-in nullable colors stay `null` so their existing fallbacks still apply: `oddRowColor`, `evenRowColor`, `cellReadonlyColor`, `cellDefaultColor`, `cellColorGroupedRow`, `filterHeaderColor`, `filterPopupHeaderColor`, `filterHeaderIconColor`.

## Backward compatibility

`fromTheme` is entirely opt-in. `TrinaGridConfiguration()` and `TrinaGridConfiguration.dark()` keep the exact colors they have always had, so upgrading changes nothing until you call `fromTheme` yourself.

## Known gaps

A few colors are not reachable through `TrinaGridStyleConfig` yet, so they stay fixed even under `fromTheme`:

- the green and red default sort icons in column titles
- the blue column-drag indicator
- the column resize divider
- some popup chrome (background, arrow, barrier)
- the default checkbox colors

These need their own configuration fields before they can follow a theme. Track this with [issue #336](https://github.com/doonfrs/trina_grid/issues/336).

## Dark mode without theme integration

If you only want the built-in dark palette:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: const TrinaGridConfiguration.dark(),
)
```

## Related

- [Configuration](../getting-started/configuration.md) - the full list of style fields
- [Cell Color](cell-color.md) - per-cell coloring
- [Row Color](row-color.md) - per-row coloring
