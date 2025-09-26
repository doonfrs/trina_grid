import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class EditCellRendererScreen extends StatefulWidget {
  static const routeName = 'feature/edit-cell-renderer';

  const EditCellRendererScreen({super.key});

  @override
  State<EditCellRendererScreen> createState() => _EditCellRendererScreenState();
}

class _EditCellRendererScreenState extends State<EditCellRendererScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'Text with Column Renderer',
        field: 'column1',
        type: TrinaColumnType.text(),
        enableEditingMode: true,
        width: 200,
        editCellRenderer:
            (
              defaultEditCellWidget,
              cell,
              controller,
              focusNode,
              handleSelected,
            ) {
              // Custom renderer for this specific column
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue.withAlpha((0.1 * 255).toInt()),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: defaultEditCellWidget,
              );
            },
      ),
      TrinaColumn(
        title: 'Text with Grid Renderer',
        field: 'column2',
        type: TrinaColumnType.text(),
        enableEditingMode: true,
        width: 200,
      ),
      TrinaColumn(
        title: 'Number with Column Renderer',
        field: 'column3',
        type: TrinaColumnType.number(),
        enableEditingMode: true,
        width: 200,
        editCellRenderer:
            (
              defaultEditCellWidget,
              cell,
              controller,
              focusNode,
              handleSelected,
            ) {
              // Custom renderer with prefix icon
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.purple.withAlpha((0.1 * 255).toInt()),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    const Icon(Icons.numbers, size: 16, color: Colors.purple),
                    const SizedBox(width: 4),
                    Expanded(child: defaultEditCellWidget),
                  ],
                ),
              );
            },
      ),
      TrinaColumn(
        title: 'Select with Column Renderer',
        field: 'column4',
        type: TrinaColumnType.select(['Red', 'Green', 'Blue']),
        enableEditingMode: true,
        width: 200,
        // For select columns, we need to use a fully custom renderer
        // that handles both display and edit modes
        editCellRenderer:
            (
              defaultEditCellWidget,
              cell,
              controller,
              focusNode,
              handleSelected,
            ) {
              String? value = cell.value;
              Color indicatorColor = Colors.grey;
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: indicatorColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: indicatorColor.withAlpha((0.1 * 255).toInt()),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: StatefulBuilder(
                  builder: (context, mSetState) {
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: value,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: indicatorColor,
                        ),
                        onChanged: (String? newValue) {
                          handleSelected?.call(newValue);
                          mSetState(() {
                            value = newValue;
                          });
                        },
                        items: (cell.column.type as TrinaColumnTypeSelect).items
                            .map<DropdownMenuItem<String>>((dynamic value) {
                              Color itemColor = Colors.grey;
                              if (value == 'Red') {
                                itemColor = Colors.red;
                              } else if (value == 'Green') {
                                itemColor = Colors.green;
                              } else if (value == 'Blue') {
                                itemColor = Colors.blue;
                              }

                              return DropdownMenuItem<String>(
                                value: value as String,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: itemColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      value,
                                      style: TextStyle(color: itemColor),
                                    ),
                                  ],
                                ),
                              );
                            })
                            .toList(),
                      ),
                    );
                  },
                ),
              );
            },
      ),
      TrinaColumn(
        title: 'Default Grid Date Field',
        field: 'column5',
        type: TrinaColumnType.date(),
        enableEditingMode: true,
        width: 200,
      ),
      TrinaColumn(
        title: 'Date with Custom renderer',
        field: 'column6',
        type: TrinaColumnType.date(),
        enableEditingMode: true,
        width: 200,
        // For date columns, we need to use a fully custom renderer
        // that handles both display and edit modes
        renderer: (rendererContext) {
          String displayText = rendererContext.cell.value != null
              ? '${(DateTime.parse(rendererContext.cell.value)).day}/${(DateTime.parse(rendererContext.cell.value)).month}/${(DateTime.parse(rendererContext.cell.value)).year}'
              : 'Select date';
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.orange.withAlpha((0.5 * 255).toInt()),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
              color: Colors.orange.withAlpha((0.1 * 255).toInt()),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(displayText, style: const TextStyle(color: Colors.orange)),
              ],
            ),
          );
        },
        editCellRenderer:
            (
              defaultEditCellWidget,
              cell,
              controller,
              focusNode,
              handleSelected,
            ) {
              // Format the date for display

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.orange.withAlpha((0.1 * 255).toInt()),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.calendar_today,
                        color: Colors.orange,
                      ),
                      onPressed: () async {
                        // Show date picker
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.tryParse(cell.value.toString()) ??
                              DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.orange,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        handleSelected?.call(picked);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                    ),
                  ],
                ),
              );
              // Otherwise show display mode
            },
      ),
      TrinaColumn(
        title: 'Number with Stepper',
        field: 'column7',
        type: TrinaColumnType.number(),
        enableEditingMode: true,
        width: 200,
        editCellRenderer:
            (
              defaultEditCellWidget,
              cell,
              controller,
              focusNode,
              handleSelected,
            ) {
              // Custom number input with increment/decrement buttons
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.indigo, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.indigo.withAlpha((0.1 * 255).toInt()),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.indigo,
                      ),
                      onPressed: () {
                        final currentValue = int.tryParse(controller.text) ?? 0;
                        controller.text = (currentValue - 1).toString();
                        focusNode.requestFocus();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.indigo,
                      ),
                      onPressed: () {
                        // Increment the value
                        final currentValue = int.parse(controller.text);
                        controller.text = (currentValue + 1).toString();
                        focusNode.requestFocus();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                    ),
                  ],
                ),
              );
            },
      ),
    ]);

    // Initialize rows with sample data
    rows.addAll(
      List.generate(10, (index) {
        return TrinaRow(
          cells: {
            'column1': TrinaCell(value: 'Text ${index + 1}'),
            'column2': TrinaCell(value: 'Grid Text ${index + 1}'),
            'column3': TrinaCell(value: (index + 1) * 10),
            'column4': TrinaCell(
              value: index % 3 == 0
                  ? 'Red'
                  : (index % 3 == 1 ? 'Green' : 'Blue'),
            ),
            'column5': TrinaCell(
              value: DateTime.now().add(Duration(days: index)),
            ),
            'column6': TrinaCell(
              value: DateTime.now().add(Duration(days: index * 2)),
            ),
            'column7': TrinaCell(value: (index + 1) * 5),
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Edit Cell Renderer',
      topTitle: 'Edit Cell Renderer',
      topContents: const [
        Text(
          'Customize the appearance of cells in edit mode using editCellRenderer.',
        ),
        SizedBox(height: 8),
        Text('You can apply renderers at the column level or grid level.'),
        SizedBox(height: 8),
        Text(
          'Column-level renderers take precedence over grid-level renderers.',
        ),
        SizedBox(height: 8),
        Text(
          'For select, date, and number columns, you may need to implement custom widgets.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/edit_cell_renderer_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
        },
        // Grid-level edit cell renderer (applied to columns without their own renderer)
        editCellRenderer:
            (
              defaultEditCellWidget,
              cell,
              controller,
              focusNode,
              handleSelected,
            ) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.green.withAlpha((0.1 * 255).toInt()),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: defaultEditCellWidget,
              );
            },
      ),
    );
  }
}
