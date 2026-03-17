<!-- WOW README for TrinaGrid: visually enhanced, content unchanged -->

<p align="center">
  <img src="https://raw.githubusercontent.com/doonfrs/trina_grid/master/screenshots/demo.gif" alt="TrinaGrid Demo" width="600"/>
</p>

<h1 align="center">✨ TrinaGrid ✨</h1>

<p align="center">
  <a href="https://pub.dev/packages/trina_grid"><img src="https://img.shields.io/pub/v/trina_grid.svg" alt="Pub Version"></a>
    <a href="https://buymeacoffee.com/doonfrs"><img src="https://img.shields.io/badge/Buy%20Me%20A%20Coffee-%23FFDD00.svg?&style=flat&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me A Coffee"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="MIT License"></a>
</p>

<h2 align="center">🚀 <a href="https://doonfrs.github.io/trina_grid/">Try the Live Demo</a> 🚀</h2>


<p align="center">⭐ Please star this repository to support the project! ⭐</p>

---

<p align="center">
  <b>TrinaGrid is a powerful <span style="color:#1976d2">data grid</span> for Flutter that provides a wide range of features for displaying, editing, and managing tabular data. It works seamlessly on <span style="color:#43a047">all platforms</span> including web, desktop, and mobile.</b>
</p>

---

## 📑 Table of Contents

- [✨ TrinaGrid](#-trinagrid)
- [💖 Support This Project](#-support-this-project)
- [🚀 Migration from PlutoGrid](#-migration-from-plutogrid)
- [📦 Installation](#-installation)
- [🏁 Basic Usage](#-basic-usage)
- [🦄 Features](#-features)
  - [🏷️ Column Features](#-column-features)
    - [Column Types](#column-types)
    - [Column Freezing](#column-freezing)
    - [Column Resizing](#column-resizing)
    - [Column Moving](#column-moving)
    - [Column Hiding](#column-hiding)
    - [Column Sorting](#column-sorting)
    - [Column Filtering](#column-filtering)
    - [Column Groups](#column-groups)
    - [Column Renderers](#column-renderers)
    - [Column Title Renderer](#column-title-renderer)
    - [Column Footer](#column-footer)
    - [Column Viewport Visibility](#column-viewport-visibility)
    - [Column Menu](#column-menu)
    - [Filter Icon Customization](#filter-icon-customization)
  - [🧑‍🤝‍🧑 Row Features](#-row-features)
    - [Row Selection](#row-selection)
    - [Row Moving](#row-moving)
    - [Row Coloring](#row-coloring)
    - [Row Wrapper](#row-wrapper)
    - [Row Checking](#row-checking)
    - [Row Groups](#row-groups)
    - [Frozen Rows](#frozen-rows)
    - [Row Pagination](#row-pagination)
    - [Row Lazy Pagination](#row-lazy-pagination)
    - [Row Infinity Scroll](#row-infinity-scroll)
    - [Add/Remove Rows](#addremove-rows)
    - [Add Rows Asynchronously](#add-rows-asynchronously)
  - [🔲 Cell Features](#-cell-features)
    - [Cell Selection](#cell-selection)
    - [Cell Editing](#cell-editing)
    - [Cell Renderers](#cell-renderers)
    - [Cell Validation](#cell-validation)
    - [Cell Value Change Handling](#cell-value-change-handling)
    - [Edit Cell Renderer](#edit-cell-renderer)
  - [📊 Data Management](#-data-management)
    - [Pagination Overview](#pagination-overview)
    - [Client-Side Pagination](#client-side-pagination)
    - [Lazy Pagination (Server-Side)](#lazy-pagination-server-side)
    - [Infinite Scrolling](#infinite-scrolling)
    - [Lazy Loading](#lazy-loading)
    - [Copy & Paste](#copy--paste)
    - [Export](#export)
    - [Custom Pagination UI](#custom-pagination-ui)
    - [Custom Footer](#custom-footer)
  - [🎨 UI Customization](#-ui-customization)
    - [Themes](#themes)
    - [Custom Styling](#custom-styling)
    - [Loading Options](#loading-options)
    - [Enhanced Scrollbars](#enhanced-scrollbars)
    - [RTL Support](#rtl-support)
    - [Dark Mode](#dark-mode)
    - [Value Formatter](#value-formatter)
  - [⚡ Other Features](#-other-features)
    - [Keyboard Navigation](#keyboard-navigation)
    - [Context Menus](#context-menus)
    - [Dual Grid Mode](#dual-grid-mode)
    - [Popup Mode](#popup-mode)
    - [Change Tracking](#change-tracking)
    - [Moving](#moving)
    - [Editing State](#editing-state)
    - [Listing Mode](#listing-mode)
    - [Grid as Popup](#grid-as-popup)
    - [Multi-Items Filter Delegate](#multi-items-filter-delegate)
- [Cell-Level Renderers](#cell-level-renderers)
- [Enhanced Scrollbars](#enhanced-scrollbars)
- [📚 Documentation](#-documentation)
- [🧑‍💻 Examples](#-examples)
- [📖 API Reference](#-api-reference)
- [🤝 Contributing](#-contributing)
- [📝 License](#license)

---

## 💖 Support This Project

> TrinaGrid is a maintained and enhanced version of the original PlutoGrid package.<br>
> I'm <a href="https://github.com/doonfrs">Feras</a>, the current maintainer, and I'm actively working on adding new features and keeping this great package rich and up-to-date.<br>
> I continued the development after the original package <a href="https://github.com/bosskmk/pluto_grid">PlutoGrid</a> was no longer being maintained.

If you find TrinaGrid useful, please consider supporting its development:

<p align="center">
  <a href="https://buymeacoffee.com/doonfrs"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" width="200" alt="Buy Me A Coffee"></a>
</p>

- Become a GitHub sponsor: [Sponsor @doonfrs](https://github.com/sponsors/doonfrs)
- Your support will encourage me to dedicate more time to keeping this useful package updated and well-documented.

---

## 🚀 Migration from PlutoGrid

> **Automatic migration tool included!**

If you're migrating from PlutoGrid, we've included a migration tool to help you automatically update your codebase:

```bash
# First, add trina_grid to your pubspec.yaml and run flutter pub get

# Run the migration tool (dry run first to see changes)
flutter pub run trina_grid --migrate-from-pluto-grid --dry-run

# Apply the changes
flutter pub run trina_grid --migrate-from-pluto-grid

# To scan all directories (including build and platform-specific directories)
flutter pub run trina_grid --migrate-from-pluto-grid --scan-all
```

The migration tool will automatically replace all PlutoGrid references with their TrinaGrid equivalents, including:

- Class names (PlutoGrid → TrinaGrid)
- Package imports:
  - `package:pluto_grid/pluto_grid.dart` → `package:trina_grid/trina_grid.dart`
  - `package:pluto_grid_plus/pluto_grid_plus.dart` → `package:trina_grid/trina_grid.dart`
- All related components, widgets, and enums

See [Migration Tool Documentation](tool/README.md) for more details.

---

## 📦 Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  trina_grid: <latest version>
```

Then run:

```bash
flutter pub get
```

---

## 🏁 Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrinaGrid Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<TrinaColumn> columns = [
    TrinaColumn(
      title: 'ID',
      field: 'id',
      type: TrinaColumnType.text(),
    ),
    TrinaColumn(
      title: 'Name',
      field: 'name',
      type: TrinaColumnType.text(),
    ),
    TrinaColumn(
      title: 'Age',
      field: 'age',
      type: TrinaColumnType.number(),
    ),
    TrinaColumn(
      title: 'Role',
      field: 'role',
      type: TrinaColumnType.select(['Developer', 'Designer', 'Manager']),
    ),
    TrinaColumn(
      title: 'Completion',
      field: 'completion',
      type: TrinaColumnType.percentage(
        decimalDigits: 1,
        showSymbol: true,
      ),
    ),
  ];

  final List<TrinaRow> rows = [
    TrinaRow(
      cells: {
        'id': TrinaCell(value: '1'),
        'name': TrinaCell(value: 'John Doe'),
        'age': TrinaCell(value: 28),
        'role': TrinaCell(value: 'Developer'),
        'completion': TrinaCell(value: 0.75),
      },
    ),
    TrinaRow(
      cells: {
        'id': TrinaCell(value: '2'),
        'name': TrinaCell(value: 'Jane Smith'),
        'age': TrinaCell(value: 32),
        'role': TrinaCell(value: 'Designer'),
        'completion': TrinaCell(value: 0.5),
      },
    ),
    TrinaRow(
      cells: {
        'id': TrinaCell(value: '3'),
        'name': TrinaCell(value: 'Mike Johnson'),
        'age': TrinaCell(value: 45),
        'role': TrinaCell(value: 'Manager'),
        'completion': TrinaCell(value: 0.9),
      },
    ),
  ];

  late TrinaGridStateManager stateManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrinaGrid Example'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: TrinaGrid(
          columns: columns,
          rows: rows,
          onLoaded: (TrinaGridOnLoadedEvent event) {
            stateManager = event.stateManager;
          },
        ),
      ),
    );
  }
}
```

---

## 🦄 Features

TrinaGrid offers a comprehensive set of features for handling tabular data:

### 🏷️ Column Features

#### Column Types
Support for various data types including:
- **Text Type**: Character value input
- **Number Type**: Numeric value input
- **Boolean Type**: True/false selection with custom options
- **Selection Type**: Dropdown selection from predefined options
- **Date Type**: Date picker input
- **Time Type**: Time picker input
- **DateTime Type**: Combined date and time input
- **Currency Type**: Currency value input with formatting
- **Percentage Type**: Percentage value input with decimal precision

#### Column Freezing
Freeze columns to the left or right

#### Column Resizing
Adjust column width by dragging

#### Column Moving
Change column order by drag and drop

#### Column Hiding
Hide and show columns as needed

#### Column Sorting
Sort data by clicking on column headers

#### Column Filtering
Filter data with built-in filter widgets

#### Column Groups
Group related columns together

#### Column Renderers
Customize column appearance with custom widgets

#### Column Title Renderer
Customize column header appearance

#### Column Footer
Display aggregate values at the bottom of columns

#### Column Viewport Visibility
Control column visibility based on viewport

#### Column Menu
Customize the menu on the right side of columns

#### Filter Icon Customization
Customize or hide the filter icon that appears in column titles after filtering

### 🧑‍🤝‍🧑 Row Features

#### Row Selection
Select single or multiple rows

#### Row Moving
Reorder rows by drag and drop

#### Row Coloring
Apply custom colors to rows

#### Row Wrapper
Customize row appearance and behavior

#### Row Checking
Built-in checkbox selection for rows

#### Row Groups
Group related rows together

#### Frozen Rows
Keep specific rows visible while scrolling

#### Row Pagination
Paginate rows with built-in pagination support

#### Row Lazy Pagination
Implement server-side pagination for large datasets

#### Row Infinity Scroll
Add new rows when scrolling reaches the bottom end

#### Add/Remove Rows
Dynamically add or delete rows from the grid

#### Add Rows Asynchronously
Add or set rows asynchronously for better performance

### 🔲 Cell Features

#### Cell Selection
Select individual cells or ranges

#### Cell Editing
Edit cell values with appropriate editors

#### Cell Renderers
Customize individual cell appearance

#### Cell Validation
Validate cell values during editing

#### Cell Value Change Handling
Handle and track cell value changes

#### Edit Cell Renderer
Customize the appearance of cells in edit mode

### 📊 Data Management

#### Pagination Overview
Built-in pagination support with comprehensive options

#### Client-Side Pagination
Handle pagination on the client side

#### Lazy Pagination (Server-Side)
Implement server-side pagination for large datasets

#### Infinite Scrolling
Load data as the user scrolls

#### Lazy Loading
Load data on demand

#### Copy & Paste
Copy and paste data between cells

#### Export
Export data to various formats (CSV, JSON, PDF)

#### Custom Pagination UI
Customize rows pagination UI with your own design

#### Custom Footer
Create custom pagination footer widgets at the bottom of the grid

### 🎨 UI Customization

#### Themes
Light and dark mode support

#### Custom Styling
Customize colors, borders, and text styles

#### Loading Options
Customize loading states and indicators

#### Enhanced Scrollbars
Draggable scrollbars with hover effects, custom colors, and improved desktop experience

#### RTL Support
Right-to-left language support

#### Dark Mode
Change the entire theme of the grid to dark mode

#### Value Formatter
Format cell values for display with custom formatters

### ⚡ Other Features

#### Keyboard Navigation
Navigate and edit using keyboard shortcuts

#### Context Menus
Right-click menus for columns and cells

#### Dual Grid Mode
Display two linked grids side by side

#### Popup Mode
Use the grid as a popup selector

#### Change Tracking
Track and manage data changes

#### Moving
Change the current cell position with arrow keys, enter key, and tab key

#### Editing State
Control the editing state of cells

#### Listing Mode
Navigate to detail pages with listing mode

#### Grid as Popup
Use the grid as a popup selector with TextField integration

#### Multi-Items Filter Delegate
Advanced filtering with multi-line or multi-item column filtering

---

## Cell-Level Renderers

TrinaGrid now supports cell-level renderers, allowing you to customize the appearance of individual cells:

```dart
TrinaCell(
  value: 'Completed',
  renderer: (rendererContext) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        rendererContext.cell.value.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  },
)
```

This powerful feature enables:

- Custom formatting for specific cells
- Visual indicators based on cell values
- Interactive elements within cells
- Conditional styling for individual cells

> Cell renderers take precedence over column renderers, giving you fine-grained control over your grid's appearance.

---

## Enhanced Scrollbars

TrinaGrid now includes enhanced scrollbar functionality, particularly useful for desktop applications:

- **Draggable Scrollbars**: Quickly navigate large datasets by dragging the scrollbar thumb
- **Hover Effects**: Visual feedback when hovering over scrollbars for better user experience
- **Customizable Appearance**: Control the colors, thickness, and behavior of scrollbars
- **Desktop Optimized**: Enhanced interaction model ideal for desktop applications

---

## 📚 Documentation

TrinaGrid comes with comprehensive documentation covering all features and use cases:

- **📖 [Getting Started Guide](https://github.com/doonfrs/trina_grid/blob/main/doc/getting-started/installation.md)** - Installation, basic usage, and configuration
- **🚀 [Migration Guide](https://github.com/doonfrs/trina_grid/blob/main/doc/migration/pluto-to-trina.md)** - Migrate from PlutoGrid with our automated tool
- **✨ [Feature Documentation](https://github.com/doonfrs/trina_grid/blob/main/doc/features/)** - Detailed guides for all features
- **🧑‍💻 [Examples & Tutorials](https://github.com/doonfrs/trina_grid/blob/main/doc/examples/)** - Practical examples and use cases
- **📚 [API Reference](https://github.com/doonfrs/trina_grid/blob/main/doc/api/)** - Complete API documentation

Visit our [Documentation Index](https://github.com/doonfrs/trina_grid/blob/main/doc/index.md) for a complete overview.

- **[LLM Documentation](llm.txt)** - Machine-readable project summary for AI agents ([full version](llms-full.txt))

---

## 🧑‍💻 Examples

Check out the [example project](https://github.com/doonfrs/trina_grid/tree/master/example) for more usage examples.

---

## 📖 API Reference

For detailed API documentation, refer to the following resources:

- **Core Classes**: [TrinaGrid](https://github.com/doonfrs/trina_grid/blob/main/doc/api/trina-grid.md), [TrinaColumn](https://github.com/doonfrs/trina_grid/blob/main/doc/api/trina-column.md), [TrinaRow](https://github.com/doonfrs/trina_grid/blob/main/doc/api/trina-row.md), [TrinaCell](https://github.com/doonfrs/trina_grid/blob/main/doc/api/trina-cell.md)
- **State Management**: [TrinaGridStateManager](https://github.com/doonfrs/trina_grid/blob/main/doc/api/trina-grid-state-manager.md)
- **Advanced Features**: [Custom Renderers](https://github.com/doonfrs/trina_grid/blob/main/doc/examples/custom-renderers.md), [Filtering & Sorting](https://github.com/doonfrs/trina_grid/blob/main/doc/examples/filtering-sorting.md)

---

## 🤝 Contributing

Contributions are welcome! If you'd like to help improve TrinaGrid, here's how you can contribute:

- **Star the repository** ⭐ to show your support
- **Report bugs** by opening issues
- **Suggest new features** or improvements
- **Submit pull requests** to fix issues or add functionality
- **Improve documentation** to help other users
- **Share the package** with others who might find it useful
- **Sponsor the project** to support its development Buy me a coffee [Buy Me A Coffee](https://buymeacoffee.com/doonfrs)

I'm committed to maintaining and improving this package, and your contributions help make it better for everyone. Feel free to reach out if you have any questions or ideas!

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
