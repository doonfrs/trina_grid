# Custom Renderers Examples

This page provides complete examples of using custom renderers in TrinaGrid.

## Task Management Grid Example

This example demonstrates a task management grid with various custom renderers:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

class TaskManagementGrid extends StatefulWidget {
  const TaskManagementGrid({Key? key}) : super(key: key);

  @override
  State<TaskManagementGrid> createState() => _TaskManagementGridState();
}

class _TaskManagementGridState extends State<TaskManagementGrid> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];
  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.text(),
        width: 80,
        enableRowDrag: true,
        enableRowChecked: true,
        // Column-level renderer for all ID cells
        renderer: (rendererContext) {
          return Text(
            rendererContext.cell.value.toString(),
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
      TrinaColumn(
        title: 'Task',
        field: 'task',
        type: TrinaColumnType.text(),
        width: 200,
      ),
      TrinaColumn(
        title: 'Status',
        field: 'status',
        type: TrinaColumnType.select(['Pending', 'In Progress', 'Completed', 'Cancelled']),
        width: 150,
      ),
      TrinaColumn(
        title: 'Priority',
        field: 'priority',
        type: TrinaColumnType.select(['Low', 'Medium', 'High', 'Critical']),
        width: 120,
      ),
      TrinaColumn(
        title: 'Due Date',
        field: 'due_date',
        type: TrinaColumnType.date(),
        width: 130,
      ),
      TrinaColumn(
        title: 'Progress',
        field: 'progress',
        type: TrinaColumnType.number(),
        width: 150,
        // Column-level renderer for progress cells
        renderer: (rendererContext) {
          final value = rendererContext.cell.value as int? ?? 0;
          
          return Stack(
            children: [
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                width: (value / 100) * (rendererContext.column.width - 20),
                height: 20,
                decoration: BoxDecoration(
                  color: value < 30 
                      ? Colors.red 
                      : (value < 70 ? Colors.orange : Colors.green),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Center(
                child: Text(
                  '$value%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      TrinaColumn(
        title: 'Assigned To',
        field: 'assigned_to',
        type: TrinaColumnType.text(),
        width: 150,
      ),
    ]);

    // Create rows with custom cell renderers
    for (var i = 1; i <= 10; i++) {
      final statusValue = i % 4 == 0 
          ? 'Completed' 
          : (i % 4 == 1 ? 'In Progress' : (i % 4 == 2 ? 'Pending' : 'Cancelled'));
      
      final priorityValue = i % 4 == 0 
          ? 'Low' 
          : (i % 4 == 1 ? 'Medium' : (i % 4 == 2 ? 'High' : 'Critical'));

      final dueDate = DateTime.now().add(Duration(days: i * 2));
      final progress = (i * 10) % 100;

      final cells = {
        'id': TrinaCell(value: 'TASK-$i'),
        'task': TrinaCell(value: 'Complete feature #$i'),
        'status': TrinaCell(
          value: statusValue,
          // Cell-level renderer for status cells
          renderer: (rendererContext) {
            Color backgroundColor;
            Color textColor = Colors.white;

            switch (rendererContext.cell.value) {
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
                rendererContext.cell.value.toString(),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
        'priority': TrinaCell(
          value: priorityValue,
          // Cell-level renderer for priority cells
          renderer: (rendererContext) {
            IconData iconData;
            Color iconColor;

            switch (rendererContext.cell.value) {
              case 'Low':
                iconData = Icons.arrow_downward;
                iconColor = Colors.green;
                break;
              case 'Medium':
                iconData = Icons.arrow_forward;
                iconColor = Colors.blue;
                break;
              case 'High':
                iconData = Icons.arrow_upward;
                iconColor = Colors.orange;
                break;
              case 'Critical':
                iconData = Icons.priority_high;
                iconColor = Colors.red;
                break;
              default:
                iconData = Icons.help_outline;
                iconColor = Colors.grey;
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  iconData,
                  color: iconColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  rendererContext.cell.value.toString(),
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
        'due_date': TrinaCell(
          value: dueDate.toString().substring(0, 10),
          // Cell-level renderer for due date cells
          renderer: (rendererContext) {
            final dueDate = DateTime.parse(rendererContext.cell.value);
            final today = DateTime.now();
            final difference = dueDate.difference(today).inDays;
            
            Color textColor = Colors.black;
            if (difference < 0) {
              textColor = Colors.red;
            } else if (difference <= 2) {
              textColor = Colors.orange;
            }
            
            return Row(
              children: [
                if (difference < 0)
                  const Icon(Icons.warning, color: Colors.red, size: 16),
                if (difference >= 0 && difference <= 2)
                  const Icon(Icons.access_time, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(
                  rendererContext.cell.value.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: difference <= 2 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            );
          },
        ),
        'progress': TrinaCell(value: progress),
        'assigned_to': TrinaCell(
          value: 'User ${i % 3 + 1}',
          // Cell-level renderer for assigned to cells
          renderer: (rendererContext) {
            final userName = rendererContext.cell.value.toString();
            final avatarColor = userName == 'User 1' 
                ? Colors.blue 
                : (userName == 'User 2' ? Colors.green : Colors.purple);
            
            return Row(
              children: [
                CircleAvatar(
                  backgroundColor: avatarColor,
                  radius: 12,
                  child: Text(
                    userName.substring(userName.length - 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(userName),
              ],
            );
          },
        ),
      };

      rows.add(TrinaRow(cells: cells));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management Grid'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: TrinaGrid(
          columns: columns,
          rows: rows,
          onLoaded: (TrinaGridOnLoadedEvent event) {
            stateManager = event.stateManager;
          },
          configuration: const TrinaGridConfiguration(),
        ),
      ),
    );
  }
}
```

## Reusable Cell Renderers

You can create reusable renderer functions to maintain consistency:

```dart
// Define reusable renderer functions
Widget statusRenderer(TrinaCellRendererContext context) {
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

// Use the reusable renderer
TrinaCell(
  value: 'Completed',
  renderer: statusRenderer,
)
```

## Interactive Cell Example

This example shows how to create cells with interactive elements:

```dart
TrinaColumn(
  title: 'Rating',
  field: 'rating',
  type: TrinaColumnType.number(),
  width: 200,
  renderer: (rendererContext) {
    final rating = rendererContext.cell.value as int? ?? 0;
    
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: index < rating ? Colors.amber : Colors.grey,
          ),
          onPressed: () {
            // Update the rating when a star is clicked
            rendererContext.stateManager.changeCellValue(
              rendererContext.cell,
              index + 1,
            );
          },
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }),
    );
  },
)
```

## Conditional Cell Renderer Example

This example demonstrates how to apply different renderers based on conditions:

```dart
// Create a function that returns different renderers based on conditions
TrinaCellRenderer getConditionalRenderer(String value) {
  if (value == 'Completed') {
    return (context) => Container(
          color: Colors.green[100],
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                context.cell.value.toString(),
                style: const TextStyle(color: Colors.green),
              ),
            ],
          ),
        );
  } else if (value == 'Cancelled') {
    return (context) => Container(
          color: Colors.red[100],
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Icon(Icons.cancel, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                context.cell.value.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        );
  }
  
  // Default renderer
  return (context) => Text(context.cell.value.toString());
}

// Use the conditional renderer
TrinaCell(
  value: 'Completed',
  renderer: getConditionalRenderer('Completed'),
)
```

## Best Practices

1. **Extract Reusable Renderers**: Create functions for common rendering patterns
2. **Keep Renderers Simple**: Avoid complex logic in renderer functions
3. **Consider Performance**: Use lightweight widgets for better scrolling performance
4. **Handle Null Values**: Always handle potential null values in your renderers
5. **Maintain Consistency**: Use similar styling patterns across your grid

## Related Documentation

- [Cell Renderer Feature](../features/cell-renderer.md)
- [Column Renderer Feature](../features/column-renderer.md)
- [Custom Styling](../features/custom-styling.md)
