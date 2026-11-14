# Column Footer

Column footers provide a way to display aggregated information at the bottom of each column in TrinaGrid, such as sum, average, minimum, maximum, or count of values.

## Overview

The column footer feature allows you to add a footer section to each column in your grid, which can be used to display summary information about the data in that column. This is particularly useful for numerical data where you want to show totals or other statistical information.

## Enabling Column Footers

Column footers are enabled on a per-column basis by setting the `footerRenderer` property of a `TrinaColumn`. The `footerRenderer` is a callback function that returns a widget to be displayed in the footer of the column.

```dart
TrinaColumn(
  title: 'Revenue',
  field: 'revenue',
  type: TrinaColumnType.number(format: '#,###.##'),
  footerRenderer: (rendererContext) {
    // Return a widget to be displayed in the footer
    return TrinaAggregateColumnFooter(
      rendererContext: rendererContext,
      type: TrinaAggregateColumnType.sum,
      numberFormat: NumberFormat('Total: #,###.##'),
      alignment: Alignment.center,
    );
  },
)
```

## Using the TrinaAggregateColumnFooter Widget

TrinaGrid provides a built-in widget called `TrinaAggregateColumnFooter` that makes it easy to display aggregated values in column footers. This widget can calculate and display various types of aggregations:

### Aggregation Types

The `TrinaAggregateColumnFooter` widget supports the following aggregation types:

- **Sum**: Calculates the sum of all values in the column
- **Average**: Calculates the average of all values in the column
- **Min**: Displays the minimum value in the column
- **Max**: Displays the maximum value in the column
- **Count**: Counts the number of rows that match a specified condition

### Basic Usage

Here's a basic example of using `TrinaAggregateColumnFooter` to display the sum of values in a column:

```dart
TrinaColumn(
  title: 'Revenue',
  field: 'revenue',
  type: TrinaColumnType.number(format: '#,###.##'),
  footerRenderer: (rendererContext) {
    return TrinaAggregateColumnFooter(
      rendererContext: rendererContext,
      type: TrinaAggregateColumnType.sum,
      numberFormat: NumberFormat('#,###.##'),
      alignment: Alignment.center,
    );
  },
)
```

### Customizing the Display Format

You can customize the format of the displayed value using the `numberFormat` parameter:

```dart
TrinaAggregateColumnFooter(
  rendererContext: rendererContext,
  type: TrinaAggregateColumnType.sum,
  numberFormat: NumberFormat('Total: #,###.##'),  
  alignment: Alignment.center,
)
```

For example, to format the aggregated value as currency, you can use:

```dart
TrinaAggregateColumnFooter(
  rendererContext: rendererContext,
  type: TrinaAggregateColumnType.sum,
  numberFormat: NumberFormat.simpleCurrency(),
  alignment: Alignment.center,
)
```

### Filtering Values for Aggregation

You can use the `filter` parameter to specify which cells should be included in the aggregation:

```dart
TrinaAggregateColumnFooter(
  rendererContext: rendererContext,
  type: TrinaAggregateColumnType.count,
  numberFormat: NumberFormat('checked: #,###'),
  filter: (cell) => cell.row.checked == true,
  alignment: Alignment.center,
)
```

### Customizing the Text Appearance

You can customize the appearance of the text using the `titleSpanBuilder` parameter:

```dart
TrinaAggregateColumnFooter(
  rendererContext: rendererContext,
  type: TrinaAggregateColumnType.sum,
  numberFormat: NumberFormat('#,###.##'),
  alignment: Alignment.center,
  titleSpanBuilder: (text) {
    return [
      const TextSpan(
        text: 'Total: ',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      TextSpan(text: text),
    ];
  },
)
```

## Controlling Which Rows are Included in Aggregation

### Row Iteration Type

The `iterateRowType` parameter controls which rows are included in the aggregation:

- **All**: Includes all rows in the grid, regardless of filtering or pagination
- **Filtered**: Includes only rows that match the current filter criteria
- **FilteredAndPaginated**: Includes only rows that are both filtered and visible on the current page (default)

```dart
TrinaAggregateColumnFooter(
  rendererContext: rendererContext,
  type: TrinaAggregateColumnType.sum,
  iterateRowType: TrinaAggregateColumnIterateRowType.all,
  numberFormat: NumberFormat('Total (All): #,###.##'),
)
```

### Row Grouping Type

When row grouping is enabled, the `groupedRowType` parameter controls how grouped rows are handled:

- **All**: Processes both groups and rows (default)
- **ExpandedAll**: Processes only the group and the children of expanded groups
- **Rows**: Processes non-group rows only
- **ExpandedRows**: Processes only expanded rows, not groups

```dart
TrinaAggregateColumnFooter(
  rendererContext: rendererContext,
  type: TrinaAggregateColumnType.sum,
  groupedRowType: TrinaAggregateColumnGroupedRowType.rows,
  numberFormat: NumberFormat('Total (Non-Group): #,###.##'),
)
```

## Creating Custom Footer Widgets

While `TrinaAggregateColumnFooter` provides a convenient way to display aggregated values, you can also create your own custom footer widgets. The `footerRenderer` callback provides a `TrinaColumnFooterRendererContext` that contains the column and state manager, which you can use to access the grid's data and state.

```dart
TrinaColumn(
  title: 'Status',
  field: 'status',
  footerRenderer: (rendererContext) {
    // Create a custom footer widget
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: Text(
        'Custom Footer',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  },
)
```

When creating custom footer widgets, you'll need to handle updates to the widget when the grid's data changes. Consider extending `TrinaStatefulWidget` and implementing `TrinaStateWithChange` to properly handle updates.

## Example

Here's a complete example demonstrating various types of column footers:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

class ColumnFooterExample extends StatefulWidget {
  @override
  _ColumnFooterExampleState createState() => _ColumnFooterExampleState();
}

class _ColumnFooterExampleState extends State<ColumnFooterExample> {
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
        type: TrinaColumnType.number(),
        enableRowChecked: true,
        footerRenderer: (rendererContext) {
          return TrinaAggregateColumnFooter(
            rendererContext: rendererContext,
            type: TrinaAggregateColumnType.count,
            numberFormat: NumberFormat('Checked: #,###'),
            filter: (cell) => cell.row.checked == true,
            alignment: Alignment.center,
          );
        },
      ),
      TrinaColumn(
        title: 'Revenue',
        field: 'revenue',
        type: TrinaColumnType.number(),
        textAlign: TrinaColumnTextAlign.right,
        footerRenderer: (rendererContext) {
          return TrinaAggregateColumnFooter(
            rendererContext: rendererContext,
            type: TrinaAggregateColumnType.sum,
            numberFormat: NumberFormat('#,###'),
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(
                  text: 'Sum',
                  style: TextStyle(color: Colors.red),
                ),
                const TextSpan(text: ' : '),
                TextSpan(text: text),
              ];
            },
          );
        },
      ),
      TrinaColumn(
        title: 'Profit',
        field: 'profit',
        type: TrinaColumnType.number(format: '#,###.###'),
        textAlign: TrinaColumnTextAlign.right,
        footerRenderer: (rendererContext) {
          return TrinaAggregateColumnFooter(
            rendererContext: rendererContext,
            type: TrinaAggregateColumnType.average,
            numberFormat: NumberFormat('#,###.###'),
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(text: 'Average: '),
                TextSpan(text: text),
              ];
            },
          );
        },
      ),
      TrinaColumn(
        title: 'Quantity',
        field: 'quantity',
        type: TrinaColumnType.number(),
        textAlign: TrinaColumnTextAlign.right,
        footerRenderer: (rendererContext) {
          return TrinaAggregateColumnFooter(
            rendererContext: rendererContext,
            type: TrinaAggregateColumnType.min,
            numberFormat: NumberFormat('#,###'),
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(text: 'Min: '),
                TextSpan(text: text),
              ];
            },
          );
        },
      ),
      TrinaColumn(
        title: 'Price',
        field: 'price',
        type: TrinaColumnType.number(),
        textAlign: TrinaColumnTextAlign.right,
        footerRenderer: (rendererContext) {
          return TrinaAggregateColumnFooter(
            rendererContext: rendererContext,
            type: TrinaAggregateColumnType.max,
            numberFormat: NumberFormat('#,###'),
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(text: 'Max: '),
                TextSpan(text: text),
              ];
            },
          );
        },
      ),
      TrinaColumn(
        title: 'Category',
        field: 'category',
        type: TrinaColumnType.select(['Electronics', 'Clothing', 'Food', 'Books']),
        footerRenderer: (rendererContext) {
          return TrinaAggregateColumnFooter(
            rendererContext: rendererContext,
            type: TrinaAggregateColumnType.count,
            filter: (cell) => cell.value == 'Electronics',
            numberFormat: NumberFormat('Electronics: #,###'),
            alignment: Alignment.center,
          );
        },
      ),
    ];

    // Create sample data
    rows = List.generate(100, (index) => 
      TrinaRow(
        cells: {
          'id': TrinaCell(value: index + 1),
          'revenue': TrinaCell(value: (index + 1) * 1000),
          'profit': TrinaCell(value: (index + 1) * 100 + (index % 10) * 0.5),
          'quantity': TrinaCell(value: (index % 10) + 1),
          'price': TrinaCell(value: (index % 5) * 100 + 50),
          'category': TrinaCell(value: ['Electronics', 'Clothing', 'Food', 'Books'][index % 4]),
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Column Footer Example')),
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setShowColumnFilter(true);
        },
      ),
    );
  }
}
```

## Best Practices

1. **Use Appropriate Aggregation Types**: Choose the aggregation type that makes the most sense for your data. For example, use `sum` for financial data, `average` for performance metrics, and `count` for tracking occurrences.

2. **Format Values Clearly**: Use clear and consistent formatting for your aggregated values. Include appropriate prefixes or suffixes to make the meaning of the values obvious.

3. **Consider Performance**: When working with large datasets, be mindful of the performance impact of complex aggregations. Consider using the `iterateRowType` parameter to limit the scope of the aggregation.

4. **Provide Visual Cues**: Use styling and alignment to visually distinguish footer values from regular cell values. This helps users quickly identify summary information.

5. **Combine with Filtering**: Column footers work well with column filtering, allowing users to see aggregated values for filtered subsets of data.

6. **Update Dynamically**: Remember that column footers automatically update when the grid's data changes, including when rows are filtered, sorted, or modified.

## Related Features

- [Column Types](column-types.md)
- [Column Filtering](column-filtering.md)
- [Column Sorting](column-sorting.md)
- [Column Groups](column-groups.md)
