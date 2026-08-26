# Column Title Renderer

> Looking for a `headerRenderer` or `headerBuilder`? This is it. TrinaGrid calls the column header the column *title*, so `TrinaColumn.titleRenderer` is the header customization API, and it is the direct counterpart of `footerRenderer`.

The column title renderer feature allows you to fully customize the appearance and behavior of column titles (also known as column headers) in TrinaGrid. This is useful when you want to:

- Create visually distinctive column headers
- Add custom icons or badges to column titles
- Use multi-line text or rich formatting in titles
- Implement interactive elements in column headers
- Maintain full control over title styling while preserving functionality

![Column Title Renderer Demo](https://raw.githubusercontent.com/doonfrs/trina_grid/master/doc/assets/column-title-renderer.gif)

## Overview

Column title renderers provide a way to define how the title of a column should be displayed. Unlike the standard title or titleSpan properties, the titleRenderer gives you complete control over the appearance while still integrating with core grid functionality like:

- Column sorting
- Context menus
- Column dragging/moving
- Column resizing

## Basic Usage

To apply a custom title renderer to a column, provide a `titleRenderer` function when creating the `TrinaColumn`:

```dart
TrinaColumn(
  title: 'Status',
  field: 'status',
  type: TrinaColumnType.text(),
  titleRenderer: (rendererContext) {
    return Container(
      width: rendererContext.column.width,
      height: rendererContext.height,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              rendererContext.column.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (rendererContext.showContextIcon) 
            rendererContext.contextMenuIcon,
        ],
      ),
    );
  },
)
```

## The TrinaColumnTitleRendererContext

The titleRenderer function receives a `TrinaColumnTitleRendererContext` object that provides access to:

- `column`: The column definition
- `stateManager`: The grid's state manager
- `height`: The height of the column title
- `showContextIcon`: Whether the context menu icon should be shown
- `contextMenuIcon`: The default context menu icon widget
- `isFiltered`: Whether the column is filtered
- `showContextMenu`: Function to show the context menu

This context provides all the information and functions needed to create fully custom title widgets while preserving built-in functionality.

## Working with Context Menu

When customizing column titles, it's important to maintain the context menu functionality if your users depend on it. The renderer context includes both information about whether to show the icon and the icon widget itself:

```dart
titleRenderer: (rendererContext) {
  return Container(
    // ... container properties ...
    child: Row(
      children: [
        // ... your custom title content ...
        
        // Add the context menu icon if needed
        if (rendererContext.showContextIcon) 
          rendererContext.contextMenuIcon,
      ],
    ),
  );
}
```

## Examples

### Gradient Background Title

Create a column title with a gradient background:

```dart
TrinaColumn(
  title: 'Custom Title',
  field: 'customField',
  titleRenderer: (rendererContext) {
    return Container(
      width: rendererContext.column.width,
      height: rendererContext.height,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade200, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.amber),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              rendererContext.column.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (rendererContext.showContextIcon) 
            rendererContext.contextMenuIcon,
        ],
      ),
    );
  },
)
```

### Multi-line Title

Create a title with multiple lines of text:

```dart
TrinaColumn(
  title: 'Multi-line Title',
  field: 'multilineField',
  titleRenderer: (rendererContext) {
    return Container(
      width: rendererContext.column.width,
      height: rendererContext.height,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Multi-line',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            'Title',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  },
)
```

### Badge Title

Create a title with a badge indicator:

```dart
TrinaColumn(
  title: 'With Badge',
  field: 'badgeField',
  titleRenderer: (rendererContext) {
    return Container(
      width: rendererContext.column.width,
      height: rendererContext.height,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              rendererContext.column.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'NEW',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (rendererContext.showContextIcon) SizedBox(width: 8),
          if (rendererContext.showContextIcon) rendererContext.contextMenuIcon,
        ],
      ),
    );
  },
)
```

### Interactive Filter Title

Create a title with a filter icon that opens the filter menu:

```dart
TrinaColumn(
  title: 'Interactive Filter',
  field: 'filterField',
  titleRenderer: (rendererContext) {
    return Container(
      width: rendererContext.column.width,
      height: rendererContext.height,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              rendererContext.column.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (rendererContext.isFiltered)
            IconButton(
              icon: Icon(Icons.filter_alt, color: Colors.blue),
              onPressed: () {
                rendererContext.stateManager.showFilterPopup(
                  context, 
                  calledColumn: rendererContext.column,
                );
              },
              constraints: BoxConstraints(
                minHeight: 36,
                minWidth: 36,
              ),
              padding: EdgeInsets.zero,
              iconSize: 20,
            ),
          if (rendererContext.showContextIcon) rendererContext.contextMenuIcon,
        ],
      ),
    );
  },
)
```

## Considerations

When using column title renderers, keep these points in mind:

1. **Width and Height**: Always use the width and height provided in the context to ensure proper sizing.
2. **Border Styling**: Include border styling in your container to maintain visual consistency.
3. **Context Menu Icon**: If your users rely on the context menu, make sure to include the icon in your custom renderer.
4. **Overflow Handling**: Implement proper overflow handling for text to prevent layout issues.
5. **Preserving Functionality**: The feature preserves column dragging and other functionality automatically.

## Complete Example

Here's a comprehensive example showing multiple custom title renderers:

```dart
TrinaGrid(
  columns: [
    TrinaColumn(
      title: 'Standard Column',
      field: 'column1',
      type: TrinaColumnType.text(),
    ),
    TrinaColumn(
      title: 'Custom Title',
      field: 'column2',
      type: TrinaColumnType.text(),
      backgroundColor: Colors.blue.shade50,
      titleRenderer: (rendererContext) {
        return Container(
          width: rendererContext.column.width,
          height: rendererContext.height,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade200, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              right: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Custom Title',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (rendererContext.showContextIcon) rendererContext.contextMenuIcon,
            ],
          ),
        );
      },
    ),
    TrinaColumn(
      title: 'With Icon',
      field: 'column3',
      type: TrinaColumnType.text(),
      titleRenderer: (rendererContext) {
        return Container(
          width: rendererContext.column.width,
          height: rendererContext.height,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(
              right: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rendererContext.column.title,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (rendererContext.showContextIcon) rendererContext.contextMenuIcon,
            ],
          ),
        );
      },
    ),
  ],
  rows: rows,
  // ... other grid properties
)
```
