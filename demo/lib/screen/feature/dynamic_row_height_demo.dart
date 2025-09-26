import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';
import '../../widget/trina_example_screen.dart';

class DynamicRowHeightDemo extends StatefulWidget {
  static const routeName = '/dynamic-row-height';

  const DynamicRowHeightDemo({super.key});

  @override
  State<DynamicRowHeightDemo> createState() => _DynamicRowHeightDemoState();
}

class _DynamicRowHeightDemoState extends State<DynamicRowHeightDemo> {
  TrinaGridStateManager? stateManager;

  // Sample data
  late List<TrinaColumn> columns;
  late List<TrinaRow> rows;

  // Controllers for input fields
  final TextEditingController _rowIndexController = TextEditingController();
  final TextEditingController _rowHeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _rowIndexController.dispose();
    _rowHeightController.dispose();
    super.dispose();
  }

  void _initializeData() {
    columns = [
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.text(),
        width: 80,
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        width: 150,
      ),
      TrinaColumn(
        title: 'Description',
        field: 'description',
        type: TrinaColumnType.text(),
        width: 200,
      ),
      TrinaColumn(
        title: 'Status',
        field: 'status',
        type: TrinaColumnType.select(['Active', 'Inactive', 'Pending']),
        width: 120,
      ),
    ];

    rows = List.generate(100, (index) {
      // Add some custom heights for demonstration
      double? customHeight;
      if (index == 2) {
        customHeight = 80.0; // Taller row
      } else if (index == 5) {
        customHeight = 60.0; // Medium height row
      } else if (index == 8) {
        customHeight = 100.0; // Very tall row
      } else if (index == 15) {
        customHeight = 70.0; // Another custom height
      } else if (index == 25) {
        customHeight = 90.0; // Another custom height
      } else if (index == 50) {
        customHeight = 75.0; // Another custom height
      } else if (index == 75) {
        customHeight = 85.0; // Another custom height
      }

      return TrinaRow(
        cells: {
          'id': TrinaCell(value: '${index + 1}'),
          'name': TrinaCell(value: 'Item ${index + 1}'),
          'description': TrinaCell(
            value: 'This is a description for item ${index + 1}.',
          ),
          'status': TrinaCell(
            value: ['Active', 'Inactive', 'Pending'][index % 3],
          ),
        },
        height: customHeight,
      );
    });
  }

  // Method to set row height using the stateManager
  void _setRowHeight() {
    final rowIndex = int.tryParse(_rowIndexController.text);
    final height = double.tryParse(_rowHeightController.text);

    if (rowIndex == null || height == null) {
      _showMessage('Please enter valid row index and height values');
      return;
    }

    if (rowIndex < 0 || rowIndex >= rows.length) {
      _showMessage('Row index must be between 0 and ${rows.length - 1}');
      return;
    }

    if (height <= 0) {
      _showMessage('Height must be greater than 0');
      return;
    }

    if (stateManager != null) {
      // Use the actual implemented method
      stateManager!.setRowHeight(rowIndex, height);
      _showMessage('Row $rowIndex height set to ${height.toStringAsFixed(1)}');
    }
    setState(() {});
  }

  // Method to get row height using the stateManager
  void _getRowHeight() {
    final rowIndex = int.tryParse(_rowIndexController.text);

    if (rowIndex == null) {
      _showMessage('Please enter a valid row index');
      return;
    }

    if (rowIndex < 0 || rowIndex >= rows.length) {
      _showMessage('Row index must be between 0 and ${rows.length - 1}');
      return;
    }

    if (stateManager != null) {
      // Use the actual implemented method
      final height = stateManager!.getRowHeight(rowIndex);

      // Update the height input to show the current effective height
      _rowHeightController.text = height.toString();

      _showMessage(
        'Row $rowIndex height retrieved: ${height.toStringAsFixed(1)}px',
      );
    }
  }

  // Method to reset a specific row height
  void _resetRowHeight() {
    final rowIndex = int.tryParse(_rowIndexController.text);

    if (rowIndex == null) {
      _showMessage('Please enter a valid row index');
      return;
    }

    if (rowIndex < 0 || rowIndex >= rows.length) {
      _showMessage('Row index must be between 0 and ${rows.length - 1}');
      return;
    }

    if (stateManager != null) {
      // Use the actual implemented method
      stateManager!.resetRowHeight(rowIndex);

      // Update the height input to show the default height
      final defaultHeight = stateManager!.configuration.style.rowHeight;
      _rowHeightController.text = defaultHeight.toString();

      _showMessage(
        'Row $rowIndex height reset to default (${defaultHeight.toStringAsFixed(1)}px)',
      );
      setState(() {});
    }
  }

  // Method to reset all row heights
  void _resetAllRowHeights() {
    if (stateManager != null) {
      // Use the actual implemented method
      stateManager!.resetAllRowHeights();

      // Update the height input to show the default height
      final defaultHeight = stateManager!.configuration.style.rowHeight;
      _rowHeightController.text = defaultHeight.toString();

      _showMessage(
        'All row heights reset to default (${defaultHeight.toStringAsFixed(1)}px)',
      );
      setState(() {});
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Dynamic Row Height',
      topTitle: 'Row Height Controls',
      body: Column(
        children: [
          // Control Panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Row Height Controls',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Inputs and Buttons in one row
                Row(
                  children: [
                    // Row Index Input
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _rowIndexController,
                        decoration: const InputDecoration(
                          labelText: 'Row Index',
                          border: OutlineInputBorder(),
                          hintText: '0-99',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Row Height Input
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _rowHeightController,
                        decoration: const InputDecoration(
                          labelText: 'Height (px)',
                          border: OutlineInputBorder(),
                          hintText: '60',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Set Button
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: _setRowHeight,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Set'),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Get Button
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: _getRowHeight,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Get'),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Reset Button
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: _resetRowHeight,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Reset All Button
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: _resetAllRowHeights,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Reset All'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
              rowColorCallback: (TrinaRowColorContext context) {
                // Show rows with custom heights in a different color
                if (context.row.height != null) {
                  return Colors.blue.withValues(alpha: 0.1);
                }
                // Use default alternating row colors
                return context.rowIdx % 2 == 0
                    ? Colors.white
                    : Colors.grey[50]!;
              },
              configuration: TrinaGridConfiguration(
                style: TrinaGridStyleConfig(
                  rowHeight: 45.0, // Default height
                  enableCellBorderHorizontal: true,
                  enableCellBorderVertical: true,
                  gridBackgroundColor: Colors.white,
                  borderColor: Colors.grey[300]!,
                  activatedBorderColor: Colors.blue,
                  activatedColor: Colors.blue.withValues(alpha: 0.1),
                ),
                scrollbar: const TrinaGridScrollbarConfig(
                  isAlwaysShown: true,
                  thumbVisible: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
