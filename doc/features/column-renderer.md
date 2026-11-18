# Column Renderer

The column renderer feature allows you to customize the appearance and behavior of entire columns in TrinaGrid. This is particularly useful when you want to:

- Apply consistent formatting to all cells in a column
- Create specialized visualizations for specific data types
- Implement interactive column-wide features
- Maintain a consistent look and feel for related data

## Overview

Column renderers provide a way to define how all cells within a column should be displayed. This is different from cell-level renderers, which apply to individual cells. Column renderers are:

- Applied to all cells in the column
- Defined at the column level
- Overridden by cell-level renderers when both are present

## Basic Usage

To apply a custom renderer to a column, provide a `renderer` function when creating the `TrinaColumn`:

```dart
TrinaColumn(
  title: 'Status',
  field: 'status',
  renderer: (rendererContext) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(rendererContext.cell.value),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        rendererContext.cell.value.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  },
)
```

## The TrinaColumnRendererContext

The renderer function receives a `TrinaColumnRendererContext` object that provides access to:

- `column`: The column definition
- `rowIdx`: The row index
- `row`: The row data
- `cell`: The cell being rendered
- `stateManager`: The grid's state manager

This context is similar to the cell renderer context but is applied at the column level.

## Examples

### Progress Bar Column

Create a column that displays progress bars for percentage values:

```dart
TrinaColumn(
  title: 'Progress',
  field: 'progress',
  renderer: (rendererContext) {
    final progress = (rendererContext.cell.value as num).toDouble();
    
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          width: (progress / 100) * rendererContext.column.width,
          height: 20,
          decoration: BoxDecoration(
            color: _getProgressColor(progress),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Center(
          child: Text(
            '${progress.toStringAsFixed(1)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: progress > 50 ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  },
)

Color _getProgressColor(double progress) {
  if (progress < 30) return Colors.red;
  if (progress < 70) return Colors.orange;
  return Colors.green;
}
```

### Rating Stars Column

Create a column that displays star ratings:

```dart
TrinaColumn(
  title: 'Rating',
  field: 'rating',
  renderer: (rendererContext) {
    final rating = (rendererContext.cell.value as num).toDouble();
    
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
)
```

### Trend Indicator Column

Create a column that shows trend indicators with arrows:

```dart
TrinaColumn(
  title: 'Trend',
  field: 'trend',
  renderer: (rendererContext) {
    final trend = rendererContext.cell.value as double;
    
    IconData iconData;
    Color iconColor;
    String trendText;
    
    if (trend > 10) {
      iconData = Icons.trending_up;
      iconColor = Colors.green;
      trendText = '+${trend.toStringAsFixed(1)}%';
    } else if (trend < -10) {
      iconData = Icons.trending_down;
      iconColor = Colors.red;
      trendText = '${trend.toStringAsFixed(1)}%';
    } else {
      iconData = Icons.trending_flat;
      iconColor = Colors.grey;
      trendText = '${trend.toStringAsFixed(1)}%';
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          iconData,
          color: iconColor,
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          trendText,
          style: TextStyle(
            color: iconColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  },
)
```

### Interactive Toggle Column

Create a column with interactive toggle switches:

```dart
TrinaColumn(
  title: 'Enabled',
  field: 'enabled',
  renderer: (rendererContext) {
    return Switch(
      value: rendererContext.cell.value as bool,
      onChanged: (newValue) {
        rendererContext.stateManager.changeCellValue(
          rendererContext.cell,
          newValue,
        );
      },
      activeColor: Colors.green,
    );
  },
)
```

### Conditional Formatting Column

Apply different styles based on thresholds:

```dart
TrinaColumn(
  title: 'Score',
  field: 'score',
  renderer: (rendererContext) {
    final score = rendererContext.cell.value as int;
    
    Color backgroundColor;
    Color textColor = Colors.white;
    
    if (score >= 90) {
      backgroundColor = Colors.green;
    } else if (score >= 70) {
      backgroundColor = Colors.blue;
    } else if (score >= 50) {
      backgroundColor = Colors.orange;
    } else {
      backgroundColor = Colors.red;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        score.toString(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  },
)
```

## Combining with Column Types

Column renderers can be combined with column types to leverage both type-specific behavior and custom rendering:

```dart
TrinaColumn(
  title: 'Price',
  field: 'price',
  type: TrinaColumnType.currency(
    symbol: '\$',
    decimalDigits: 2,
  ),
  renderer: (rendererContext) {
    final price = rendererContext.cell.value as double;
    final formattedPrice = '\$${price.toStringAsFixed(2)}';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: price > 1000 ? Colors.amber[100] : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        formattedPrice,
        style: TextStyle(
          fontWeight: price > 1000 ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.right,
      ),
    );
  },
)
```

## Reusable Column Renderers

For better code organization and reusability, you can define renderer functions separately:

```dart
Widget statusRenderer(TrinaColumnRendererContext context) {
  Color backgroundColor;
  Color textColor = Colors.white;

  switch (context.cell.value) {
    case 'Completed':
      backgroundColor = Colors.green;
      break;
    case 'In Progress':
      backgroundColor = Colors.orange;
      break;
    case 'Pending':
      backgroundColor = Colors.blue;
      break;
    case 'Cancelled':
      backgroundColor = Colors.red;
      break;
    default:
      backgroundColor = Colors.grey;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      context.cell.value.toString(),
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

// Then use it in your column definition
TrinaColumn(
  title: 'Status',
  field: 'status',
  renderer: statusRenderer,
)
```

## Best Practices

1. **Performance**: Keep your renderer functions efficient to maintain smooth scrolling
2. **Reusability**: Create reusable renderer functions for common patterns
3. **Responsiveness**: Make your custom widgets adapt to different column widths
4. **Consistency**: Maintain a consistent look and feel across your grid
5. **Accessibility**: Ensure your custom renderers maintain accessibility features
6. **Cell vs. Column Renderers**: Use column renderers for consistent formatting across a column, and cell renderers for exceptions
7. **Auto-sizing**: The `fitContent` auto-size mode and `autoFitColumn` measure the cell value as text, so they cannot see what a renderer draws. Give the column a `measureWidth` callback so these fit it to the renderer's real width. See [Column Resizing](column-resizing.md#4-fit-content-trinaautosizemodefitcontent).

## Comparison with Cell Renderer

| Feature | Column Renderer | Cell Renderer |
|---------|----------------|---------------|
| **Scope** | Applied to all cells in a column | Applied to individual cells |
| **Definition** | Defined at the column level | Defined at the cell level |
| **Precedence** | Lower precedence | Higher precedence (overrides column renderer) |
| **Use Case** | Consistent formatting for a data type | Special cases and exceptions |
| **Performance** | More efficient for columns with similar formatting | More flexible but potentially less efficient |

## Related Features

- [Cell Renderers](cell-renderer.md) - For customizing individual cells
- [Column Types](column-types.md) - For type-specific behavior
- [Custom Styling](custom-styling.md) - For global styling options
- [Themes](themes.md) - For applying consistent themes across the grid
