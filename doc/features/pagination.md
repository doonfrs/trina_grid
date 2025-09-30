# Pagination in Trina Grid

Trina Grid offers multiple pagination options to efficiently handle datasets of various sizes. This document provides an overview of the available pagination features and helps you choose the right approach for your application.

## Pagination Types

Trina Grid supports three main types of pagination:

1. **[Client-Side Pagination](pagination-client.md)** - For smaller datasets that can be loaded entirely into memory
2. **[Lazy Pagination (Server-Side)](lazy-pagination.md)** - For large datasets where data is fetched from the server page by page
3. **[Infinity Scroll](infinity-scroll.md)** - For continuous scrolling with on-demand data loading

## Choosing the Right Pagination Type

| Pagination Type | Best For | Key Benefits | Limitations |
|----------------|----------|-------------|------------|
| **Client-Side** | Small to medium datasets (<1000 rows) | Simple implementation, instant page changes, full client-side sorting and filtering | Requires loading all data upfront, higher memory usage |
| **Lazy (Server-Side)** | Large datasets, server APIs with pagination support | Minimal memory usage, handles millions of records, server-side sorting and filtering | Requires server-side implementation, page changes require network requests |
| **Infinity Scroll** | Continuous data streams, social media-like feeds | Seamless user experience, progressive loading | More complex to implement with sorting and filtering |

## Pagination Features

All pagination types in Trina Grid include these built-in features:

### Total Rows Display

Shows the total number of pages and records in the footer. Enabled by default.

**Format:** `/ TotalPages [TotalRecords]`

Example: `/ 50 [5000]` means 50 pages with 5000 total records.

### Go to Page

Allows users to jump directly to a specific page via a search icon button. Enabled by default.

**How to use:**
1. Click the search icon in the pagination footer
2. Enter the desired page number
3. Press Enter or click "Go"

### Configuration

Control these features globally via `TrinaGridConfiguration`:

```dart
TrinaGrid(
  configuration: TrinaGridConfiguration(
    paginationShowTotalRows: true,    // Show total rows (default: true)
    paginationEnableGotoPage: true,   // Enable goto page (default: true)
  ),
  // ...
)
```

Or override per pagination widget:

```dart
TrinaPagination(
  stateManager,
  showTotalRows: false,      // Override config setting
  enableGotoPage: false,     // Override config setting
)
```

## Implementation Overview

### Client-Side Pagination

```dart
TrinaGrid(
  // Grid configuration
  createFooter: (stateManager) {
    return TrinaPagination(stateManager);
  },
)
```

[Learn more about Client-Side Pagination](pagination-client.md)

### Lazy Pagination (Server-Side)

```dart
TrinaGrid(
  // Grid configuration
  createFooter: (stateManager) {
    return TrinaLazyPagination(
      fetch: fetch,  // Your data fetching function
      stateManager: stateManager,
    );
  },
)
```

[Learn more about Lazy Pagination](lazy-pagination.md)

### Infinity Scroll

```dart
TrinaGrid(
  // Grid configuration
  createFooter: (stateManager) {
    return TrinaInfinityScrollRows(
      fetch: fetch,  // Your data fetching function
      stateManager: stateManager,
    );
  },
)
```

[Learn more about Infinity Scroll](infinity-scroll.md)

## Best Practices

1. **Choose the right pagination type** based on your dataset size and requirements
2. **Set appropriate page sizes** - typically 10-50 rows per page depending on row complexity
3. **Consider user experience** - show loading indicators, total record counts, and clear navigation
4. **Test with realistic data volumes** to ensure performance meets expectations
5. **Combine with other features** like sorting and filtering for a complete data management solution

## Related Features

- [Column Sorting](column-sorting.md)
- [Column Filtering](column-filtering.md)
- [Export](export.md)
