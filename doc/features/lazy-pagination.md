# Lazy Pagination in Trina Grid

Lazy pagination (or server-side pagination) is designed for handling large datasets where loading all data at once would be inefficient. Instead of loading the entire dataset, it fetches only the data needed for the current page from the server.

## Key Benefits

- Reduces memory usage by loading only necessary data
- Improves initial load time and performance
- Efficiently handles very large datasets
- Allows server-side processing of sorting and filtering

## Implementation

To implement lazy pagination, you need to:

1. Create a fetch function that handles data retrieval from the server
2. Add the `TrinaLazyPagination` widget to your grid's footer

```dart
createFooter: (stateManager) {
  return TrinaLazyPagination(
    fetch: fetch,
    stateManager: stateManager,
  );
},
```

The fetch function should implement the `TrinaLazyPaginationFetch` type:

```dart
Future<TrinaLazyPaginationResponse> fetch(
  TrinaLazyPaginationRequest request,
) async {
  // Fetch data from server based on request parameters
  // ...

  return TrinaLazyPaginationResponse(
    totalPage: totalPages,
    rows: fetchedRows,
    totalRecords: totalRecordCount,
  );
}
```

## Configuration Options

`TrinaLazyPagination` provides several configuration options:

```dart
TrinaLazyPagination(
  // Set the initial page (default: 1)
  initialPage: 1,
  
  // Set the initial page size (default: 10)
  initialPageSize: 10,
  
  // Whether to fetch data on initialization (default: true)
  initialFetch: true,
  
  // Whether sorting should trigger server-side fetching (default: true)
  fetchWithSorting: true,
  
  // Whether filtering should trigger server-side fetching (default: true)
  fetchWithFiltering: true,
  
  // Number of pages to move with prev/next buttons (default: null - moves by visible page count)
  pageSizeToMove: null,
  
  // Required fetch function
  fetch: fetch,
  
  // Required state manager
  stateManager: stateManager,
);
```

## Handling Sorting and Filtering

The `TrinaLazyPaginationRequest` provides information about the current sorting and filtering state:

```dart
// Sorting
if (request.sortColumn != null && !request.sortColumn!.sort.isNone) {
  // Apply server-side sorting based on sortColumn
}

// Filtering
if (request.filterRows.isNotEmpty) {
  // Apply server-side filtering based on filterRows
  // You can convert filterRows to a more usable format:
  final filterMap = FilterHelper.convertRowsToMap(request.filterRows);
  // or
  final filter = FilterHelper.convertRowsToFilter(
    request.filterRows,
    stateManager.refColumns,
  );
}
```

When sorting or filtering changes, the pagination automatically resets to page 1 to ensure data consistency.

## Page Size Selection

Lazy pagination supports a page size selector dropdown:

```dart
TrinaLazyPagination(
  // Enable page size selector dropdown
  showPageSizeSelector: true,
  
  // Available page size options
  pageSizes: [10, 20, 30, 50, 100],
  
  // Callback when page size changes
  onPageSizeChanged: (pageSize) {
    print('Page size changed to: $pageSize');
  },
  
  // Optional styling for dropdown
  dropdownDecoration: BoxDecoration(...),
  dropdownItemDecoration: BoxDecoration(...),
  pageSizeDropdownIcon: Icon(...),
  
  // Other required parameters
  fetch: fetch,
  stateManager: stateManager,
);
```

## Custom Pagination UI

You can provide a custom UI for the pagination footer by using the `builder` property. This allows you to create a completely custom layout and set of controls for pagination.

The `builder` function provides the `TrinaLazyPaginationState`, which gives you access to the current pagination status and methods to control it.

### `TrinaLazyPaginationState` Properties and Methods

- `page`: The current page number.
- `pageSize`: The number of items per page.
- `totalPage`: The total number of pages.
- `totalRecords`: The total number of records in the dataset.
- `isFirstPage`: Whether the current page is the first page.
- `isLastPage`: Whether the current page is the last page.
- `setPage(int page)`: Navigates to a specific page.
- `nextPage()`: Navigates to the next page.
- `previousPage()`: Navigates to the previous page.
- `firstPage()`: Navigates to the first page.
- `lastPage()`: Navigates to the last page.
- `setPageSize(int size)`: Changes the page size and re-fetches data.
- `refresh()`: Re-fetches the data for the current page.

### Example

```dart
createFooter: (stateManager) {
  return TrinaLazyPagination(
    fetch: fetch,
    stateManager: stateManager,
    builder: (context, state) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: state.isFirstPage ? null : state.firstPage,
            ),
            IconButton(
              icon: const Icon(Icons.navigate_before),
              onPressed: state.isFirstPage ? null : state.previousPage,
            ),
            Text('Page ${state.page} of ${state.totalPage}'),
            IconButton(
              icon: const Icon(Icons.navigate_next),
              onPressed: state.isLastPage ? null : state.nextPage,
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: state.isLastPage ? null : state.lastPage,
            ),
            const Spacer(),
            if (state.totalRecords != null)
              Text('Total records: ${state.totalRecords}'),
          ],
        ),
      );
    },
  );
},
```

## Complete Example

Here's a complete example demonstrating lazy pagination:

```dart
class MyDataGrid extends StatefulWidget {
  @override
  _MyDataGridState createState() => _MyDataGridState();
}

class _MyDataGridState extends State<MyDataGrid> {
  late TrinaGridStateManager stateManager;
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];

  Future<TrinaLazyPaginationResponse> fetch(TrinaLazyPaginationRequest request) async {
    // Simulate API call
    final response = await myApi.fetchData(
      page: request.page,
      pageSize: request.pageSize,
      sortColumn: request.sortColumn,
      filterRows: request.filterRows,
    );

    return TrinaLazyPaginationResponse(
      totalPage: response.totalPages,
      rows: response.rows,
      totalRecords: response.totalCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TrinaGrid(
      columns: columns,
      rows: rows,
      onLoaded: (event) => stateManager = event.stateManager,
      createFooter: (stateManager) => TrinaLazyPagination(
        initialPage: 1,
        initialPageSize: 20,
        showPageSizeSelector: true,
        pageSizes: [10, 20, 50, 100],
        fetch: fetch,
        stateManager: stateManager,
      ),
    );
  }
}
```

## Related Features

- For tracking lazy pagination events, see [Lazy Pagination Events](lazy-pagination-events.md)
- For programmatically changing pages with events, see [Lazy Pagination Events - Programmatically Changing Pages](lazy-pagination-events.md#programmatically-changing-pages-with-events)
- For client-side pagination, see [Client-Side Pagination](pagination-client.md)
- For infinite scrolling, see [Infinity Scroll](infinity-scroll.md)