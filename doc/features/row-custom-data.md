# Row Custom Data

TrinaGrid allows you to associate custom data with each row using the `TrinaRow.data<T>` property. This feature is useful for storing metadata, original values for change detection, or any application-specific data alongside your grid rows.

## Overview

Every `TrinaRow<T>` has a generic `data` property that can hold any object type. This property is separate from the cell values displayed in the grid and is not rendered.

```dart
class TrinaRow<T> {
  T? data;  // Your custom data
  // ...
}
```

## Use Case: Storing Original Data for Change Detection

A common use case is storing the original row data to detect whether users have modified values:

```dart
// Define your data model
class Person {
  final String name;
  final int age;
  final String email;

  Person({required this.name, required this.age, required this.email});

  Map<String, dynamic> toMap() => {
    'name': name,
    'age': age,
    'email': email,
  };
}

// Create rows with original data stored
List<TrinaRow<Person>> createRows(List<Person> people) {
  return people.map((person) => TrinaRow<Person>(
    cells: {
      'name': TrinaCell(value: person.name),
      'age': TrinaCell(value: person.age),
      'email': TrinaCell(value: person.email),
    },
    data: person,  // Store the original data
  )).toList();
}
```

### Detecting Changes

You can compare current cell values with the stored original data:

```dart
bool hasRowChanged(TrinaRow<Person> row) {
  final original = row.data;
  if (original == null) return false;

  return row.cells['name']?.value != original.name ||
         row.cells['age']?.value != original.age ||
         row.cells['email']?.value != original.email;
}

// Check all rows for changes
List<TrinaRow<Person>> getModifiedRows(List<TrinaRow<Person>> rows) {
  return rows.where((row) => hasRowChanged(row)).toList();
}
```

### Updating Stored Data

After saving changes, update the stored data to reflect the new "original" state:

```dart
void commitRowChanges(TrinaRow<Person> row) {
  // Create new Person from current cell values
  final updatedPerson = Person(
    name: row.cells['name']?.value ?? '',
    age: row.cells['age']?.value ?? 0,
    email: row.cells['email']?.value ?? '',
  );

  // Update the stored data
  row.setData(updatedPerson);
}
```

## Using Map for Flexible Storage

For simpler cases, you can use a `Map` instead of a custom class:

```dart
final row = TrinaRow<Map<String, dynamic>>(
  cells: {
    'name': TrinaCell(value: 'John'),
    'age': TrinaCell(value: 30),
  },
  data: {'name': 'John', 'age': 30},  // Original values as Map
);

// Check if a specific field changed
bool fieldChanged(TrinaRow<Map<String, dynamic>> row, String field) {
  return row.cells[field]?.value != row.data?[field];
}
```

## Alternative: Hidden Columns

Another approach is using hidden columns with the `hide` property:

```dart
TrinaColumn(
  title: 'Original Name',
  field: 'original_name',
  type: TrinaColumnType.text(),
  hide: true,  // Column won't be rendered
)
```

Hidden columns:
- Are not displayed in the grid
- Still store data in cells
- Are accessible via `row.cells['original_name']`

However, `TrinaRow.data<T>` is generally cleaner for storing complex objects or metadata that doesn't fit the column/cell model.

## Best Practices

1. **Type Safety**: Use a specific type parameter (`TrinaRow<Person>`) rather than `dynamic` for compile-time safety.

2. **Immutable Original Data**: Consider making your stored data immutable to prevent accidental modifications.

3. **Memory Considerations**: The `data` property stores a reference, so large objects increase memory usage per row.

4. **Serialization**: When exporting/importing grid data, remember to handle the `data` property separately since `toJson()` only exports cell values.

## Related Features

- [Change Tracking](change-tracking.md) - Built-in cell-level dirty tracking with commit/revert
- [Column Hiding](column-hiding.md) - Hide columns from rendering
- [Row Selection](row-selection.md) - Select and work with rows
