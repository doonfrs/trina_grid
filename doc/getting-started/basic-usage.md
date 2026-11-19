# Basic Usage

This guide will walk you through creating a simple TrinaGrid implementation.

## Creating a Basic Grid

Here's a complete example of a basic TrinaGrid implementation:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrinaGrid Basic Example',
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
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];
  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    
    // Define columns
    columns.addAll([
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.text(),
        width: 100,
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        width: 200,
      ),
      TrinaColumn(
        title: 'Age',
        field: 'age',
        type: TrinaColumnType.number(),
        width: 100,
      ),
      TrinaColumn(
        title: 'Role',
        field: 'role',
        type: TrinaColumnType.select(['Developer', 'Designer', 'Manager']),
        width: 150,
      ),
    ]);
    
    // Create rows
    rows.addAll([
      TrinaRow(
        cells: {
          'id': TrinaCell(value: '1'),
          'name': TrinaCell(value: 'John Doe'),
          'age': TrinaCell(value: 28),
          'role': TrinaCell(value: 'Developer'),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: '2'),
          'name': TrinaCell(value: 'Jane Smith'),
          'age': TrinaCell(value: 32),
          'role': TrinaCell(value: 'Designer'),
        },
      ),
      TrinaRow(
        cells: {
          'id': TrinaCell(value: '3'),
          'name': TrinaCell(value: 'Mike Johnson'),
          'age': TrinaCell(value: 45),
          'role': TrinaCell(value: 'Manager'),
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrinaGrid Basic Example'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: TrinaGrid(
          columns: columns,
          rows: rows,
          onLoaded: (TrinaGridOnLoadedEvent event) {
            stateManager = event.stateManager;
          },
          onChanged: (TrinaGridOnChangedEvent event) {
            print('Cell changed: ${event.value}');
          },
        ),
      ),
    );
  }
}
```

## Key Components

### 1. Columns

Columns define the structure of your grid. Each column needs:

- `title`: The text displayed in the column header
- `field`: A unique identifier for the column
- `type`: The data type (text, number, select, date, time, etc.)
- `width`: The width of the column (optional, but recommended)

```dart
TrinaColumn(
  title: 'Name',
  field: 'name',
  type: TrinaColumnType.text(),
  width: 200,
)
```

### 2. Rows

Rows contain the data displayed in the grid. Each row consists of cells that correspond to the columns:

```dart
TrinaRow(
  cells: {
    'id': TrinaCell(value: '1'),
    'name': TrinaCell(value: 'John Doe'),
    'age': TrinaCell(value: 28),
    'role': TrinaCell(value: 'Developer'),
  },
)
```

### 3. StateManager

The `TrinaGridStateManager` provides methods to control the grid programmatically:

```dart
late TrinaGridStateManager stateManager;

// In your onLoaded callback:
onLoaded: (TrinaGridOnLoadedEvent event) {
  stateManager = event.stateManager;
},
```

## Column Types

TrinaGrid supports various column types:

### Text

```dart
TrinaColumn(
  title: 'Name',
  field: 'name',
  type: TrinaColumnType.text(),
)
```

### Number

```dart
TrinaColumn(
  title: 'Age',
  field: 'age',
  type: TrinaColumnType.number(),
)
```

### Select

```dart
TrinaColumn(
  title: 'Role',
  field: 'role',
  type: TrinaColumnType.select(['Developer', 'Designer', 'Manager']),
)
```

### Date

```dart
TrinaColumn(
  title: 'Birth Date',
  field: 'birth_date',
  type: TrinaColumnType.date(),
)
```

### Time

```dart
TrinaColumn(
  title: 'Start Time',
  field: 'start_time',
  type: TrinaColumnType.time(),
)
```

### Currency

```dart
TrinaColumn(
  title: 'Salary',
  field: 'salary',
  type: TrinaColumnType.currency(
    symbol: '\$',
    decimalDigits: 2,
  ),
)
```

## Event Handling

### onLoaded

Called when the grid is first loaded:

```dart
onLoaded: (TrinaGridOnLoadedEvent event) {
  stateManager = event.stateManager;
},
```

### onChanged

Called when a cell value is changed:

```dart
onChanged: (TrinaGridOnChangedEvent event) {
  print('Cell changed: ${event.value}');
},
```

### Other Events

TrinaGrid provides many other events for specific interactions:

- `onSelected`: Called when a cell or row is selected
- `onRowChecked`: Called when a row checkbox is toggled
- `onSorted`: Called when columns are sorted
- `onRowsMoved`: Called when rows are moved

## Next Steps

Now that you understand the basics, explore more advanced features:

- [Column Configuration](../features/column-types.md)
- [Row Operations](../features/row-selection.md)
- [Cell Customization](../features/cell-renderer.md)
- [Styling and Theming](../features/themes.md)
