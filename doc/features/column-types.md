# Column Types

TrinaGrid supports various column types to handle different kinds of data efficiently. Each column type provides specialized rendering, editing, filtering, and sorting capabilities tailored to specific data types.

## Overview

When creating columns for your TrinaGrid, you can specify the column type using the `type` property of `TrinaColumn`. The column type determines:

- How cell values are displayed
- The editor widget used for editing cells
- How values are sorted
- Available filtering options

## Available Column Types

TrinaGrid provides the following built-in column types:

### Text Column

The default column type for displaying and editing text values.

```dart
TrinaColumn(
  title: 'Name',
  field: 'name',
  type: TrinaColumnType.text(),
)
```

#### Text Column Properties

| Property | Type | Description |
|----------|------|-------------|
| `textAlign` | `TextAlign` | Alignment of text within cells |
| `maxLines` | `int?` | Maximum number of lines to display |
| `overflow` | `TextOverflow` | How to handle text overflow |
| `enableAutoSize` | `bool` | Whether to automatically resize text to fit |

### Number Column

Specialized for numeric values with formatting options.

```dart
TrinaColumn(
  title: 'Price',
  field: 'price',
  type: TrinaColumnType.number(
    format: '#,##0.00',
    negative: true,
    decimal: true,
  ),
)
```

#### Number Column Properties

| Property | Type | Description |
|----------|------|-------------|
| `format` | `String?` | Number format pattern |
| `negative` | `bool` | Whether to allow negative values |
| `decimal` | `bool` | Whether to allow decimal values |
| `decimalDigits` | `int?` | Number of decimal places to display |
| `thousandSeparator` | `String` | Character used as thousand separator |
| `decimalSeparator` | `String` | Character used as decimal separator |
| `prefix` | `String?` | Text to display before the number (e.g., currency symbol) |
| `suffix` | `String?` | Text to display after the number (e.g., unit) |

### Date Column

For displaying and editing date values.

```dart
TrinaColumn(
  title: 'Birthday',
  field: 'birthday',
  type: TrinaColumnType.date(
    format: 'yyyy-MM-dd',
  ),
)
```

#### Date Column Properties

| Property | Type | Description |
|----------|------|-------------|
| `format` | `String` | Date format pattern |
| `startDate` | `DateTime?` | Minimum selectable date |
| `endDate` | `DateTime?` | Maximum selectable date |
| `firstDate` | `DateTime?` | First date visible in calendar |
| `lastDate` | `DateTime?` | Last date visible in calendar |
| `closePopupOnSelection` | `bool` | Whether to close the popup immediately after a date is selected. Defaults to `true`. |
| `popupIcon` | `IconData?` | Custom icon for the popup button (defaults to `Icons.date_range`) |

### Time Column

For displaying and editing time values.

```dart
TrinaColumn(
  title: 'Start Time',
  field: 'startTime',
  type: TrinaColumnType.time(
    format: 'HH:mm',
  ),
)
```

#### Time Column Properties

| Property | Type | Description |
|----------|------|-------------|
| `format` | `String` | Time format pattern |
| `minTime` | `TimeOfDay?` | The minimum selectable time. |
| `maxTime` | `TimeOfDay?` | The maximum selectable time. |
| `saveAndClosePopupWithEnter` | `bool` | If true, pressing Enter will save the value and close the popup. |


### DateTime Column

For displaying and editing both date and time values in a single field.

```dart
TrinaColumn(
  title: 'Created At',
  field: 'createdAt',
  type: TrinaColumnType.dateTime(
    format: 'yyyy-MM-dd HH:mm',
    headerFormat: 'MMMM yyyy',
    startDate: DateTime(2023, 1, 1),
    endDate: DateTime(2025, 12, 31),
    popupIcon: Icons.event_available,
  ),
)
```

#### DateTime Column Properties

| Property | Type | Description |
|----------|------|-------------|
| `format` | `String` | DateTime format pattern (defaults to 'yyyy-MM-dd HH:mm') |
| `headerFormat` | `String` | Format for the header in date picker (defaults to 'yyyy-MM') |
| `startDate` | `DateTime?` | Minimum selectable date (optional) |
| `endDate` | `DateTime?` | Maximum selectable date (optional) |
| `applyFormatOnInit` | `bool` | Whether to apply format when initializing (defaults to `true`) |
| `popupIcon` | `IconData?` | Custom icon for the popup button (defaults to calendar icon) |

### Select Column

For selecting a value from a predefined list of items.  

```dart
TrinaColumn(
  title: 'Status',
  field: 'status',
  type: TrinaColumnType.select(
    items: ['pending', 'in_progress', 'completed', 'cancelled'],
    itemToString: (value) => value.toString().toUpperCase(),
  ),
)
```

#### Select Column Properties

| Property | Type | Description |
|----------|------|-------------|
| `items` | `List<dynamic>` | The list of items to display in the select menu. |
| `itemToString` | `String Function(dynamic)?` | A function that returns the string representation of an item. This is required for search and filtering. |
| `itemToValue` | `dynamic Function(dynamic)?` | A function that returns a unique value for an item, used for comparison and selection. |
| `variant` | `TrinaDropdownMenuVariant` | The select menu variant; one of `select`, `selectWithSearch`, or `selectWithFilters`. |
| `filters` | `List<TrinaDropdownMenuFilter>` | A list of filters to be used when `variant` is `TrinaDropdownMenuVariant.selectWithFilters`. |
| `filtersInitiallyExpanded` | `bool` | Whether the filters section is initially expanded. Defaults to `true`. |
| `emptySearchResultBuilder` | `WidgetBuilder?` | A builder function to create a widget to display when a search yields no results. |
| `emptyFilterResultBuilder` | `WidgetBuilder?` | A builder function to create a widget to display when filtering yields no results. |
| `menuItemBuilder` | `Widget Function(dynamic item)?` | A builder function to create a custom widget for each item in the list. |

### Boolean Column

For displaying and editing boolean values.

```dart
TrinaColumn(
  title: 'Active',
  field: 'isActive',
  type: TrinaColumnType.boolean(
    trueText: 'Yes',
    falseText: 'No',
    allowEmpty: false,
    defaultValue: false,
    width: 120,
    popupIcon: Icons.check_box,
    menuItemBuilder: (bool item) => CustomBooleanWidget(value: item),
    onItemSelected: (bool item) {},
  ),
)
```

#### Boolean Column Properties

| Property | Type | Description |
|----------|------|-------------|
| `defaultValue` | `dynamic` | Default value for new cells (defaults to `false`) |
| `allowEmpty` | `bool` | Whether to allow null/empty values (defaults to `false`) |
| `trueText` | `String` | Text to display for true values (defaults to "Yes") |
| `falseText` | `String` | Text to display for false values (defaults to "No") |
| `width` | `double?` | Width of the popup selector |
| `popupIcon` | `IconData?` | Icon to display for opening the popup selector |
| `menuItemBuilder` | `Widget Function(dynamic item)?` | Custom widget builder for rendering boolean values |
| `onItemSelected` | `void Function(dynamic value)?` | Callback when a value is selected |

### Currency Column

Specialized for monetary values.

```dart
TrinaColumn(
  title: 'Price',
  field: 'price',
  type: TrinaColumnType.currency(
    symbol: '\$',
    decimalDigits: 2,
  ),
)
```

#### Currency Column Properties

| Property | Type | Description |
|----------|------|-------------|
| `symbol` | `String` | Currency symbol |
| `symbolPosition` | `CurrencySymbolPosition` | Position of currency symbol (before/after) |
| `decimalDigits` | `int` | Number of decimal places |
| `thousandSeparator` | `String` | Character used as thousand separator |
| `decimalSeparator` | `String` | Character used as decimal separator |
| `negativeFormat` | `CurrencyNegativeFormat` | How to format negative values |

### Percentage Column

For displaying and editing percentage values.

```dart
TrinaColumn(
  title: 'Completion',
  field: 'completion',
  type: TrinaColumnType.percentage(
    decimalDigits: 1,
    showSymbol: true,
  ),
)
```

#### Percentage Column Properties

| Property | Type | Description |
|----------|------|-------------|
| `defaultValue` | `dynamic` | Default value for new cells (defaults to `0`) |
| `decimalDigits` | `int` | Number of decimal places (defaults to `2`) |
| `showSymbol` | `bool` | Whether to show the % symbol (defaults to `true`) |
| `symbolPosition` | `PercentageSymbolPosition` | Position of % symbol (before/after, defaults to `after`) |
| `negative` | `bool` | Whether to allow negative values (defaults to `true`) |
| `applyFormatOnInit` | `bool` | When the editor loads, it resets the value to formatted value (defaults to `true`) |
| `allowFirstDot` | `bool` | Allow a dot at the beginning when accepting negative numbers (defaults to `false`) |
| `locale` | `String?` | Specifies the numeric locale of the column (if not specified, uses default locale) |
| `decimalInput` | `bool` | When true, users can input direct percentage values (42 for 42%) rather than decimal values (0.42) (defaults to `false`) |

#### Using `decimalInput`

When `decimalInput` is set to `true`, the column will:

1. Accept direct percentage values as input (e.g., 42 for 42%)
2. Display values as percentages (e.g., 42.0%)
3. Store values internally as percentages (not as decimals)

```dart
// Example of a column with decimalInput enabled
TrinaColumn(
  title: 'Percentage',
  field: 'percentage',
  type: TrinaColumnType.percentage(
    decimalInput: true,
    decimalDigits: 1,
  ),
)

// Usage with decimalInput: true
TrinaCell(value: 42)  // Displays as "42.0%"

// Regular percentage column (decimalInput: false)
TrinaCell(value: 0.42)  // Displays as "42.00%"
```

### Custom Column

For storing complex objects (maps, custom classes, etc.) that don't fit the built-in column types.

```dart
TrinaColumn(
  title: 'Address',
  field: 'address',
  type: TrinaColumnType.custom(
    defaultValue: {'street': '', 'city': ''},
    toDisplayString: (value) => '${value['street']}, ${value['city']}',
    compare: (a, b) => a['city'].compareTo(b['city']),
    isValid: (value) => value is Map && value.containsKey('city'),
  ),
)
```

By default, all values are considered valid, sorting uses `toString()` comparison,
and display text uses `toString()`. All callbacks are optional.

For custom rendering, combine with `TrinaColumn.renderer`:

```dart
TrinaColumn(
  title: 'Rating',
  field: 'rating',
  type: TrinaColumnType.custom(
    toDisplayString: (value) => '${value} stars',
    compare: (a, b) => (a as num).compareTo(b as num),
  ),
  renderer: (rendererContext) {
    return StarRating(rating: rendererContext.cell.value);
  },
)
```

#### Custom Column Properties

| Property | Type | Description |
|----------|------|-------------|
| `defaultValue` | `dynamic` | Default value for new cells (defaults to `null`) |
| `isValid` | `bool Function(dynamic)` | Validates cell values (defaults to always `true`) |
| `compare` | `int Function(dynamic, dynamic)` | Comparator for sorting (defaults to `toString()` comparison) |
| `toDisplayString` | `String Function(dynamic)` | Converts value to display text (defaults to `toString()`) |

## Column Type Configuration

### Default Column Type

You can set a default column type for all columns in your grid:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  configuration: TrinaGridConfiguration(
    defaultColumnType: TrinaColumnType.text(),
  ),
)
```

### Type Inheritance

Column types can inherit properties from other column types:

```dart
// Create a base column type with common properties
final baseTextColumn = TrinaColumnType.text(
  textAlign: TextAlign.start,
  maxLines: 2,
);

// Create columns that inherit from the base type
TrinaColumn(
  title: 'Description',
  field: 'description',
  type: baseTextColumn.copyWith(
    maxLines: 3,
    overflow: TextOverflow.ellipsis,
  ),
)
```

## Best Practices

1. **Choose the appropriate column type** for your data to leverage built-in formatting, editing, and validation
2. **Use custom column types** when you need specialized behavior not covered by built-in types
3. **Create reusable column type configurations** for consistent appearance across your grid
4. **Consider performance implications** when using complex custom renderers or editors
5. **Provide clear validation feedback** to users when they enter invalid data

## Examples

### Mixed Column Types

```dart
List<TrinaColumn> columns = [
  TrinaColumn(
    title: 'ID',
    field: 'id',
    type: TrinaColumnType.number(format: '#'),
    width: 80,
    frozen: true,
  ),
  TrinaColumn(
    title: 'Name',
    field: 'name',
    type: TrinaColumnType.text(),
    width: 150,
  ),
  TrinaColumn(
    title: 'Birth Date',
    field: 'birthDate',
    type: TrinaColumnType.date(format: 'yyyy-MM-dd'),
    width: 120,
  ),
  TrinaColumn(
    title: 'Created At',
    field: 'createdAt',
    type: TrinaColumnType.dateTime(
      format: 'yyyy-MM-dd HH:mm',
    ),
    width: 150,
  ),
  TrinaColumn(
    title: 'Salary',
    field: 'salary',
    type: TrinaColumnType.currency(
      symbol: '\$',
      decimalDigits: 2,
    ),
    width: 120,
  ),
  TrinaColumn(
    title: 'Completion',
    field: 'completion',
    type: TrinaColumnType.percentage(
      decimalDigits: 1,
      showSymbol: true,
    ),
    width: 100,
  ),
  TrinaColumn(
    title: 'Active',
    field: 'isActive',
    type: TrinaColumnType.boolean(),
    width: 100,
  ),
  TrinaColumn(
    title: 'Department',
    field: 'department',
    type: TrinaColumnType.select(
      items: ['engineering', 'marketing', 'sales', 'hr'],
    ),
    width: 150,
  ),
];
```

### Custom Rating Column

```dart
TrinaColumn(
  title: 'Rating',
  field: 'rating',
  type: TrinaColumnType.custom(
    renderer: (rendererContext) {
      final rating = rendererContext.cell.value as double;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 16,
          );
        }),
      );
    },
    editor: (editorContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          double rating = editorContext.cell.value ?? 0.0;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () {
                  setState(() {
                    rating = index + 1.0;
                    editorContext.onChanged(rating);
                  });
                },
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 24, minHeight: 24),
              );
            }),
          );
        },
      );
    },
  ),
  width: 150,
)
```

## Related Features

- [Column Renderers](column-renderer.md) - For more advanced column rendering
- [Cell Editing](cell-editing.md) - For more details on cell editing behavior
- [Cell Validation](cell-validation.md) - For validating cell input
- [Column Filtering](column-filtering.md) - For filtering data based on column values
- [Column Sorting](column-sorting.md) - For sorting data based on column values
