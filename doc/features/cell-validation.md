# Cell Validation

TrinaGrid provides multiple approaches to validation:

1. **Built-in Column Type Validation**: Each column type has built-in validation rules
2. **Custom Column Validation**: Define custom validation rules at the column level
3. **Cell Change Handlers**: Implement validation in cell change event handlers

## Column Type Validation

Each column type in TrinaGrid comes with built-in validation rules that are automatically applied:

### Text Column

```dart
TrinaColumn(
  title: 'Name',
  field: 'name',
  type: TrinaColumnType.text(),
)
```

The text column type validates that values are either strings or numbers. Null values are considered invalid.

### Number Column

```dart
TrinaColumn(
  title: 'Age',
  field: 'age',
  type: TrinaColumnType.number(
    negative: false, // Disallow negative numbers
    format: '#,##0', // Format pattern
  ),
)
```

The number column type validates:

- Values are numeric
- Negative numbers (can be disabled)
- Format pattern compliance

### Select Column

```dart
TrinaColumn(
  title: 'Status',
  field: 'status',
  type: TrinaColumnType.select(
    items: [
      'Pending',
      'In Progress',
      'Completed',
      'Cancelled',
    ],
    onItemSelected: (event) {
      // Handle selection
    },
    enableColumnFilter: true,
  ),
)
```

The select column type validates that values are present in the predefined items list.

### Date Column

```dart
TrinaColumn(
  title: 'Birth Date',
  field: 'birthDate',
  type: TrinaColumnType.date(
    format: 'yyyy-MM-dd',
    startDate: DateTime(1900),
    endDate: DateTime.now(),
  ),
)
```

The date column type validates:

- Date format compliance
- Date range (if startDate/endDate specified)
- Valid date values

### Time Column

```dart
TrinaColumn(
  title: 'Start Time',
  field: 'startTime',
  type: TrinaColumnType.time(),
)
```

The time column type validates that values match the format `HH:mm` (24-hour format).

## Custom Column Validation

You can define custom validation rules at the column level using the `validator` property:

```dart
TrinaColumn(
  title: 'Email',
  field: 'email',
  type: TrinaColumnType.text(),
  validator: (value, context) {
    if (value == null || value.toString().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.toString())) {
      return 'Please enter a valid email address';
    }

    return null; // Return null if validation passes
  },
)
```

### The Validation Context

The validator function receives a `TrinaValidationContext` object that provides access to:

- `column`: The column definition
- `row`: The row containing the cell being validated
- `rowIdx`: The row index
- `oldValue`: The previous value before the change
- `stateManager`: The grid's state manager

This context allows you to create dynamic validators that can access other cells or grid state.

### Cross-Field Validation

Validate a value based on other fields in the same row:

```dart
TrinaColumn(
  title: 'Confirm Password',
  field: 'confirmPassword',
  type: TrinaColumnType.text(),
  validator: (value, context) {
    final password = context.row.cells['password']?.value;
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  },
)
```

### Complex Validation Rules

Combine multiple validation rules:

```dart
TrinaColumn(
  title: 'Password',
  field: 'password',
  type: TrinaColumnType.text(),
  validator: (value, context) {
    if (value == null || value.toString().isEmpty) {
      return 'Password is required';
    }

    final password = value.toString();
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    return null;
  },
)
```

## Handling Validation Failures

You can handle validation failures at the grid level by providing an `onValidationFailed` callback:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onValidationFailed: (event) {
    // Show error message
    showErrorDialog(
      context,
      'Validation Error',
      event.errorMessage,
    );
    
    // Log validation failure
    logger.warning(
      'Validation failed for ${event.column.title}: ${event.errorMessage}',
    );
    
    // You can also access:
    // event.value - The invalid value
    // event.oldValue - The previous value
    // event.row - The row containing the invalid value
    // event.rowIdx - The row index
  },
)
```

## Cell Change Handlers

For more complex validation scenarios, you can still use cell change handlers:

```dart
TrinaCell(
  value: 'username',
  onChanged: (event) async {
    // Show loading indicator
    event.stateManager.showLoading();
    
    try {
      // Perform async validation
      final isAvailable = await checkUsernameAvailability(event.value);
      
      if (!isAvailable) {
        event.stateManager.showSnackBar(
          'Username already taken',
          backgroundColor: Colors.red,
        );
        
        // Revert to previous value
        event.stateManager.changeCellValue(
          event.cell,
          event.oldValue,
        );
      }
    } finally {
      // Hide loading indicator
      event.stateManager.hideLoading();
    }
  },
)
```

## Validation UI

### Error Feedback

When validation fails, you can provide feedback to users through:

#### Method 1: Using the onValidationFailed callback

```dart
onValidationFailed: (event) {
  showSnackBar(
    context,
    event.errorMessage,
    backgroundColor: Colors.red,
  );
}
```

#### Method 2: Using custom cell rendering

```dart
TrinaColumn(
  title: 'Email',
  field: 'email',
  renderer: (context) {
    final isValid = isValidEmail(context.cell.value);
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isValid ? Colors.transparent : Colors.red,
        ),
      ),
      child: Text(
        context.cell.value.toString(),
        style: TextStyle(
          color: isValid ? Colors.black : Colors.red,
        ),
      ),
    );
  },
)
```

## Best Practices

1. **Use Built-in Validation**: Leverage the built-in validation provided by column types whenever possible
2. **Column-Level Validation**: Use the `validator` property for validation rules that apply to all cells in a column
3. **Cell-Level Validation**: Use `onChanged` handlers for complex validation scenarios or async validation
4. **Clear Feedback**: Provide clear error messages when validation fails
5. **Prevent Invalid States**: Invalid values are automatically prevented from being committed
6. **Performance**: Keep validation logic efficient, especially for large datasets
7. **User Experience**: Show loading indicators during asynchronous validation
8. **Error Recovery**: Provide clear paths for users to correct invalid data
9. **Consistent Validation**: Apply consistent validation rules across similar data types

## Related Features

- [Cell Navigation Validation](cell-navigation-validation.md) - For preventing navigation away from invalid cells/rows
- [Column Types](column-types.md) - For details on built-in column types and their validation
- [Cell Editing](cell-editing.md) - For more details on cell editing behavior
- [Cell Value Change Handling](cell_value_change_handling.md) - For handling cell value changes
- [Column Renderers](column-renderer.md) - For customizing cell appearance based on validation state
