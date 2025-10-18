# Cell Navigation Validation

TrinaGrid provides a powerful callback mechanism to validate and control cell navigation. This feature allows you to prevent users from navigating away from a cell or row until certain conditions are met, such as data validation.

## Overview

The `onBeforeActiveCellChange` callback fires **before** the active cell changes, allowing you to:

- Validate data in the current cell/row
- Prevent navigation if validation fails
- Implement custom navigation rules
- Show validation errors without visual flicker

This is particularly useful for building data entry forms where strict validation rules are required before proceeding.

## Basic Usage

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onBeforeActiveCellChange: (event) {
    // Return true to allow the change
    // Return false to cancel the change
    return true;
  },
)
```

## Event Object

The `TrinaGridOnBeforeActiveCellChangeEvent` provides complete context about the navigation:

```dart
class TrinaGridOnBeforeActiveCellChangeEvent {
  /// The current (old) cell that is active
  final TrinaCell? oldCell;

  /// The current (old) row index
  final int? oldRowIdx;

  /// The new cell that will become active
  final TrinaCell newCell;

  /// The new row index
  final int newRowIdx;
}
```

## Common Use Cases

### 1. Row-Level Validation

Prevent navigation to a different row until the current row is valid:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onBeforeActiveCellChange: (event) {
    // Check if user is trying to change rows
    if (event.oldRowIdx != null && event.oldRowIdx != event.newRowIdx) {
      // Validate the current row
      final currentRow = rows[event.oldRowIdx!];
      final isValid = validateRow(currentRow);

      if (!isValid) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fix errors in the current row before proceeding'),
            backgroundColor: Colors.red,
          ),
        );

        // Cancel navigation
        return false;
      }
    }

    // Allow navigation
    return true;
  },
)
```

### 2. Required Field Validation

Ensure required fields are filled before navigating away:

```dart
bool validateRow(TrinaRow row) {
  // Check if name field is not empty
  final name = row.cells['name']?.value;
  if (name == null || name.toString().trim().isEmpty) {
    return false;
  }

  // Check if email field is not empty
  final email = row.cells['email']?.value;
  if (email == null || email.toString().trim().isEmpty) {
    return false;
  }

  return true;
}

TrinaGrid(
  columns: columns,
  rows: rows,
  onBeforeActiveCellChange: (event) {
    if (event.oldRowIdx != null && event.oldRowIdx != event.newRowIdx) {
      final currentRow = rows[event.oldRowIdx!];
      if (!validateRow(currentRow)) {
        return false; // Cancel navigation
      }
    }
    return true;
  },
)
```

### 3. Async Validation

Perform asynchronous validation before allowing navigation:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onBeforeActiveCellChange: (event) {
    if (event.oldRowIdx != null && event.oldRowIdx != event.newRowIdx) {
      final currentRow = rows[event.oldRowIdx!];

      // Show loading indicator
      final loadingDialog = showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Perform async validation
      validateRowAsync(currentRow).then((isValid) {
        // Hide loading indicator
        Navigator.of(context).pop();

        if (!isValid) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Validation Error'),
              content: Text('Please fix errors before proceeding'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      });

      // Note: For async validation, you might need to store state
      // and prevent navigation in the sync callback
      return false; // Cancel for now
    }
    return true;
  },
)
```

**Note**: The callback is synchronous. For async validation, you may need to implement a two-step approach:
1. Cancel navigation in the callback
2. Perform async validation
3. If valid, programmatically trigger navigation using `stateManager.setCurrentCell()`

### 4. Conditional Navigation Rules

Allow or prevent navigation based on specific conditions:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onBeforeActiveCellChange: (event) {
    // Allow same-row navigation
    if (event.oldRowIdx == event.newRowIdx) {
      return true;
    }

    // Allow navigation from the last row
    if (event.oldRowIdx == rows.length - 1) {
      return true;
    }

    // For other cases, validate the current row
    if (event.oldRowIdx != null) {
      final currentRow = rows[event.oldRowIdx!];
      return validateRow(currentRow);
    }

    return true;
  },
)
```

### 5. Field-Specific Validation

Prevent navigation based on specific field validation:

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onBeforeActiveCellChange: (event) {
    if (event.oldRowIdx != null && event.oldRowIdx != event.newRowIdx) {
      final currentRow = rows[event.oldRowIdx!];

      // Validate specific fields
      final email = currentRow.cells['email']?.value?.toString() ?? '';
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

      if (email.isNotEmpty && !emailRegex.hasMatch(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid email address'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    return true;
  },
)
```

## Integration with Other Callbacks

The `onBeforeActiveCellChange` callback works seamlessly with other cell-related callbacks:

### Combining with onActiveCellChanged

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onBeforeActiveCellChange: (event) {
    // Validate before navigation
    if (event.oldRowIdx != null && event.oldRowIdx != event.newRowIdx) {
      final isValid = validateRow(rows[event.oldRowIdx!]);
      if (!isValid) {
        return false; // Cancel navigation
      }
    }
    return true;
  },
  onActiveCellChanged: (event) {
    // This only fires if navigation was allowed
    print('Active cell changed to row ${event.idx}');

    // You can perform actions after successful navigation
    loadAdditionalDataForRow(event.idx);
  },
)
```

### Combining with onValidationFailed

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onBeforeActiveCellChange: (event) {
    // Prevent row navigation until validation passes
    if (event.oldRowIdx != null && event.oldRowIdx != event.newRowIdx) {
      final currentRow = rows[event.oldRowIdx!];
      return validateAllFieldsInRow(currentRow);
    }
    return true;
  },
  onValidationFailed: (event) {
    // This fires when individual cell validation fails
    print('Field ${event.column.title} validation failed: ${event.errorMessage}');
  },
)
```

## Keyboard and Mouse Navigation

The `onBeforeActiveCellChange` callback works for **all** navigation methods:

- **Keyboard navigation**: Arrow keys, Tab, Enter
- **Mouse clicks**: Clicking on cells
- **Programmatic navigation**: `stateManager.setCurrentCell()`

This ensures consistent validation regardless of how the user navigates.

## Best Practices

1. **Provide Clear Feedback**: Always show clear error messages when preventing navigation
   ```dart
   if (!isValid) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Please complete all required fields')),
     );
     return false;
   }
   ```

2. **Allow Same-Row Navigation**: Let users move between cells in the same row
   ```dart
   if (event.oldRowIdx == event.newRowIdx) {
     return true; // Allow cell navigation within same row
   }
   ```

3. **Handle First Selection**: Check if `oldRowIdx` is null (first cell selection)
   ```dart
   if (event.oldRowIdx == null) {
     return true; // Always allow first cell selection
   }
   ```

4. **Keep Validation Logic Fast**: The callback is synchronous and blocks navigation
   ```dart
   // Good: Fast validation
   return row.cells['name']?.value != null;

   // Avoid: Slow operations that block UI
   // return await fetchValidationFromServer(row);
   ```

5. **Use with Cell Validation**: Combine with column-level validators for comprehensive validation
   ```dart
   TrinaColumn(
     field: 'email',
     validator: (value, context) {
       // Cell-level validation
       if (!isValidEmail(value)) {
         return 'Invalid email';
       }
       return null;
     },
   ),
   ```

6. **Visual Indicators**: Highlight invalid cells to guide users
   ```dart
   cellColorCallback: (cellContext) {
     if (!isValidCell(cellContext.cell)) {
       return Colors.red.shade50;
     }
     return Colors.white;
   },
   ```

## Differences from onActiveCellChanged

| Feature | onBeforeActiveCellChange | onActiveCellChanged |
|---------|-------------------------|---------------------|
| **Timing** | Before state changes | After state changes |
| **Can cancel** | Yes (return false) | No |
| **Return type** | bool | void |
| **Use case** | Validation, prevention | Tracking, logging |
| **Old cell info** | Yes (provided in event) | No |

## Example: Complete Validation Form

```dart
class ValidatedGrid extends StatelessWidget {
  final List<TrinaColumn> columns = [
    TrinaColumn(
      title: 'Name',
      field: 'name',
      type: TrinaColumnType.text(),
      validator: (value, context) {
        if (value == null || value.toString().trim().isEmpty) {
          return 'Name is required';
        }
        return null;
      },
    ),
    TrinaColumn(
      title: 'Email',
      field: 'email',
      type: TrinaColumnType.text(),
      validator: (value, context) {
        if (value == null || value.toString().trim().isEmpty) {
          return 'Email is required';
        }
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value.toString())) {
          return 'Invalid email format';
        }
        return null;
      },
    ),
  ];

  bool validateRow(TrinaRow row) {
    // Check all cells in the row
    for (final column in columns) {
      final cell = row.cells[column.field];
      if (column.validator != null) {
        final error = column.validator!(
          cell?.value,
          TrinaValidationContext(
            column: column,
            row: row,
            rowIdx: 0,
            oldValue: cell?.value,
          ),
        );
        if (error != null) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return TrinaGrid(
      columns: columns,
      rows: rows,
      onBeforeActiveCellChange: (event) {
        // Prevent row navigation if current row is invalid
        if (event.oldRowIdx != null && event.oldRowIdx != event.newRowIdx) {
          final currentRow = rows[event.oldRowIdx!];
          final isValid = validateRow(currentRow);

          if (!isValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please fix validation errors before proceeding'),
                backgroundColor: Colors.red,
              ),
            );
            return false;
          }
        }

        return true;
      },
      onValidationFailed: (event) {
        // Show specific field validation errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${event.column.title}: ${event.errorMessage}'),
            backgroundColor: Colors.orange,
          ),
        );
      },
      cellColorCallback: (cellContext) {
        // Highlight invalid cells
        if (cellContext.column.validator != null) {
          final error = cellContext.column.validator!(
            cellContext.cell.value,
            TrinaValidationContext(
              column: cellContext.column,
              row: cellContext.row,
              rowIdx: cellContext.rowIdx,
              oldValue: cellContext.cell.value,
            ),
          );
          if (error != null) {
            return Colors.red.shade50;
          }
        }
        return Colors.white;
      },
    );
  }
}
```

## Related Features

- [Cell Validation](cell-validation.md) - For column-level and cell-level validation
- [Cell Editing](cell-editing.md) - For controlling cell editing behavior
- [Cell Selection](cell-selection.md) - For understanding cell selection and navigation
- [Cell Value Change Handling](cell_value_change_handling.md) - For handling value changes
