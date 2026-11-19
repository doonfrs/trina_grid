# Lazy Pagination Events in TrinaGrid

Trina Grid provides events to help you monitor and respond to lazy pagination operations. The most significant of these is the `onLazyFetchCompleted` event, which is triggered whenever a lazy pagination fetch operation completes.

## Overview

When using lazy pagination, you often need to know when data has been successfully loaded. The `onLazyFetchCompleted` event gives you this information, allowing you to:

- Update UI elements based on loaded data
- Track pagination statistics
- Implement custom loading indicators
- Perform additional operations after data is loaded
- Log pagination information for analytics

## Using onLazyFetchCompleted

The `onLazyFetchCompleted` callback is available directly on the `TrinaGrid` widget:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onLazyFetchCompleted: (event) {
    // Handle the lazy fetch completed event
    print('Fetch completed: page ${event.page} of ${event.totalPage}');
    print('Total records: ${event.totalRecords}');
  },
  createFooter: (stateManager) {
    return TrinaLazyPagination(
      fetch: fetch,
      stateManager: stateManager,
    );
  },
)
```

## The TrinaGridOnLazyFetchCompletedEvent Object

The `onLazyFetchCompleted` callback receives a `TrinaGridOnLazyFetchCompletedEvent` object containing information about the completed fetch operation:

| Property | Type | Description |
|----------|------|-------------|
| `stateManager` | `TrinaGridStateManager` | Reference to the grid's state manager |
| `page` | `int` | The current page number after fetch completed |
| `totalPage` | `int` | The total number of pages available |
| `totalRecords` | `int?` | The total number of records (if available) |

### Example: Using the Event Object

```dart
onLazyFetchCompleted: (event) {
  // Access pagination information
  print('Current page: ${event.page}');
  print('Total pages: ${event.totalPage}');
  print('Total records: ${event.totalRecords ?? "Not available"}');
  
  // Calculate progress
  final progress = (event.page / event.totalPage) * 100;
  print('Pagination progress: ${progress.toStringAsFixed(1)}%');
  
  // Access state manager for additional operations
  event.stateManager.setShowLoading(false);
}
```

## Common Use Cases

### Updating Loading Status

```dart
bool isLoading = false;

TrinaGrid(
  columns: columns,
  rows: rows,
  onLazyFetchCompleted: (event) {
    // Update loading status
    setState(() {
      isLoading = false;
    });
  },
  createFooter: (stateManager) {
    // Show your custom loading indicator while fetching
    if (isLoading) {
      return CustomLoadingIndicator();
    }
    
    return TrinaLazyPagination(
      fetch: (request) {
        setState(() {
          isLoading = true;
        });
        return fetchData(request);
      },
      stateManager: stateManager,
    );
  },
)
```

### Pagination Statistics

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onLazyFetchCompleted: (event) {
    // Update pagination statistics in UI
    setState(() {
      currentPage = event.page;
      totalPages = event.totalPage;
      totalRecords = event.totalRecords;
    });
  },
  createFooter: (stateManager) {
    return Column(
      children: [
        // Custom statistics display
        Text('Showing page $currentPage of $totalPages (Total: $totalRecords records)'),
        
        // Standard pagination controls
        TrinaLazyPagination(
          fetch: fetch,
          stateManager: stateManager,
        ),
      ],
    );
  },
)
```

### Analytics Tracking

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onLazyFetchCompleted: (event) {
    // Log pagination analytics
    analyticsService.logEvent(
      'data_page_viewed',
      parameters: {
        'page_number': event.page,
        'total_pages': event.totalPage,
        'records_count': event.totalRecords,
        'page_size': stateManager.pageSize,
      },
    );
  },
  createFooter: (stateManager) {
    return TrinaLazyPagination(
      fetch: fetch,
      stateManager: stateManager,
    );
  },
)
```

## Pagination Component Events

In addition to the grid-level event, the `TrinaLazyPagination` component itself provides a similar callback:

```dart
TrinaLazyPagination(
  fetch: fetch,
  stateManager: stateManager,
  onLazyFetchCompleted: (page, totalPage, totalRecords) {
    // This is called at the pagination component level
    print('Pagination component: page $page of $totalPage');
  },
)
```

This component-level callback is useful when you need to handle events specific to the pagination component itself, rather than at the grid level.

## Complete Example

Here's a complete example demonstrating the use of `onLazyFetchCompleted`:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

class LazyPaginationEventExample extends StatefulWidget {
  @override
  _LazyPaginationEventExampleState createState() => _LazyPaginationEventExampleState();
}

class _LazyPaginationEventExampleState extends State<LazyPaginationEventExample> {
  late List<TrinaColumn> columns;
  late List<TrinaRow> rows;
  late TrinaGridStateManager stateManager;
  
  // Pagination stats
  int currentPage = 0;
  int totalPages = 0;
  int? totalRecords;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    // Define columns
    columns = [
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.number(),
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Description',
        field: 'description',
        type: TrinaColumnType.text(),
      ),
    ];
    
    // Initial empty rows
    rows = [];
  }
  
  Future<TrinaLazyPaginationResponse> fetch(TrinaLazyPaginationRequest request) async {
    setState(() {
      isLoading = true;
    });
    
    // Simulate API call with delay
    await Future.delayed(Duration(milliseconds: 800));
    
    // Generate sample data
    final fetchedRows = List.generate(
      request.pageSize,
      (index) => TrinaRow(
        cells: {
          'id': TrinaCell(value: (request.page - 1) * request.pageSize + index + 1),
          'name': TrinaCell(value: 'Item ${(request.page - 1) * request.pageSize + index + 1}'),
          'description': TrinaCell(value: 'Description for item ${(request.page - 1) * request.pageSize + index + 1}'),
        },
      ),
    );
    
    return TrinaLazyPaginationResponse(
      totalPage: 10,
      rows: fetchedRows,
      totalRecords: 100,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lazy Pagination Events'),
      ),
      body: Column(
        children: [
          // Stats display
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Page: $currentPage / $totalPages'),
                Text('Total Records: ${totalRecords ?? "-"}'),
                if (isLoading) CircularProgressIndicator(strokeWidth: 2),
              ],
            ),
          ),
          
          // Grid with event handling
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (event) => stateManager = event.stateManager,
              onLazyFetchCompleted: (event) {
                // Update state with pagination information
                setState(() {
                  currentPage = event.page;
                  totalPages = event.totalPage;
                  totalRecords = event.totalRecords;
                  isLoading = false;
                });
                
                // Log pagination event
                print('Fetch complete: Page $currentPage of $totalPages');
                print('Total records: $totalRecords');
              },
              createFooter: (stateManager) {
                return TrinaLazyPagination(
                  initialPage: 1,
                  initialPageSize: 10,
                  showPageSizeSelector: true,
                  pageSizes: [10, 20, 50, 100],
                  fetch: fetch,
                  stateManager: stateManager,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## Programmatically Changing Pages with Events

In addition to the UI-based pagination controls, you can also programmatically change the current page using the `TrinaGridChangeLazyPageEvent`. This is useful when you need to:

- Jump to a specific page based on user actions outside the grid
- Refresh the current page without rebuilding the grid
- Implement custom pagination controls

### Using TrinaGridChangeLazyPageEvent

```dart
// Get a reference to the state manager (typically from onLoaded event)
late TrinaGridStateManager stateManager;

// To change to a specific page
stateManager.eventManager!.addEvent(TrinaGridChangeLazyPageEvent(page: 3));

// To refresh the current page without changing it
stateManager.eventManager!.addEvent(TrinaGridChangeLazyPageEvent(page: null));
```

### Example: Custom Pagination Controls

```dart
class CustomPaginationControls extends StatelessWidget {
  final TrinaGridStateManager stateManager;
  final int totalPages;

  const CustomPaginationControls({
    required this.stateManager,
    required this.totalPages,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            // Jump to first page
            stateManager.eventManager!.addEvent(TrinaGridChangeLazyPageEvent(page: 1));
          },
          child: Text('First'),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            // Jump to a specific page
            final currentPage = stateManager.page;
            if (currentPage > 1) {
              stateManager.eventManager!.addEvent(TrinaGridChangeLazyPageEvent(page: currentPage - 1));
            }
          },
          child: Text('Previous'),
        ),
        SizedBox(width: 8),
        Text('Page ${stateManager.page} of $totalPages'),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            // Jump to a specific page
            final currentPage = stateManager.page;
            if (currentPage < totalPages) {
              stateManager.eventManager!.addEvent(TrinaGridChangeLazyPageEvent(page: currentPage + 1));
            }
          },
          child: Text('Next'),
        ),
        SizedBox(width: 8),
        ElevatedButton( 
          onPressed: () {
            // Jump to last page
            stateManager.eventManager!.addEvent(TrinaGridChangeLazyPageEvent(page: totalPages));
          },
          child: Text('Last'),
        ),
        SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            // Refresh current page
            stateManager.eventManager!.addEvent(TrinaGridChangeLazyPageEvent(page: null));
          },
          child: Text('Refresh'),
        ),
      ],
    );
  }
}
```

## Related Features

- For basic Lazy Pagination implementation, see [Lazy Pagination](lazy-pagination.md)
- For client-side pagination, see [Client-Side Pagination](pagination-client.md)
- For infinite scrolling, see [Infinity Scroll](infinite-scrolling.md)
