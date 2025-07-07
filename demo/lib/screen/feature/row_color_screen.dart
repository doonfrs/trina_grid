import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class RowColorScreen extends StatefulWidget {
  static const routeName = 'feature/row-color';

  const RowColorScreen({super.key});

  @override
  _RowColorScreenState createState() => _RowColorScreenState();
}

class _RowColorScreenState extends State<RowColorScreen> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];
  TrinaGridStateManager? stateManager;

  // Define color options with names for identification - using more subtle material colors
  final List<Map<String, dynamic>> colorOptions = [
    {'name': 'Grey', 'color': Colors.grey[100]!},
    {'name': 'Purple', 'color': Colors.purple[100]!},
    {'name': 'Red', 'color': Colors.red[100]!},
    {'name': 'Indigo', 'color': Colors.indigo[100]!},
    {'name': 'Transparent', 'color': Colors.transparent},
  ];

  // Selection colors - different from row colors and more subtle
  final List<Map<String, dynamic>> selectionColorOptions = [
    {'name': 'Blue', 'color': Colors.blue[200]!},
    {'name': 'Teal', 'color': Colors.teal[200]!},
    {'name': 'Amber', 'color': Colors.amber[200]!},
    {'name': 'Green', 'color': Colors.green[200]!},
  ];

  // Color selections
  int oneValueColorIndex = 0;
  int twoValueColorIndex = 1;
  int defaultRowColorIndex = 0;
  int selectionColorIndex = 0;
  int activatedBorderColorIndex = 0;

  Color get oneValueColor => colorOptions[oneValueColorIndex]['color'] as Color;
  Color get twoValueColor => colorOptions[twoValueColorIndex]['color'] as Color;
  Color get defaultRowColor =>
      colorOptions[defaultRowColorIndex]['color'] as Color;
  Color get selectionColor =>
      selectionColorOptions[selectionColorIndex]['color'] as Color;
  Color get activatedBorderColor =>
      selectionColorOptions[activatedBorderColorIndex]['color'] as Color;

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 100);
    columns.addAll(dummyData.columns);
    rows.addAll(dummyData.rows);
  }

  // Helper method to create color selection dropdown
  Widget _buildColorDropdown(String label, int currentIndex,
      Function(int) onChanged, List<Map<String, dynamic>> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: '),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: options[currentIndex]['color'] as Color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey),
            ),
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: currentIndex,
            onChanged: (int? index) {
              if (index != null) {
                setState(() {
                  onChanged(index);

                  // Update grid if selection color changed and grid is initialized
                  if (label == 'Selection Color') {
                    final newStyle = stateManager!.configuration.style.copyWith(
                      activatedColor: selectionColor,
                    );
                    stateManager!
                        .setConfiguration(stateManager!.configuration.copyWith(
                      style: newStyle,
                    ));
                  }
                });
              }
            },
            items: List.generate(options.length, (index) {
              return DropdownMenuItem<int>(
                value: index,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: options[index]['color'] as Color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(options[index]['name'] as String),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Row color',
      topTitle: 'Row color',
      topContents: [
        Text(
            'You can dynamically adjust row colors by utilizing the rowColorCallback function.'),
        Text(
            'Changing the value in the "${columns.elementAt(4).title}" column will automatically update the row\'s background color based on that value.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/row_color_screen.dart',
        ),
      ],
      body: Column(
        children: [
          // Color controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Color Settings:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildColorDropdown(
                            'Value "One" Color',
                            oneValueColorIndex,
                            (index) => oneValueColorIndex = index,
                            colorOptions),
                        _buildColorDropdown(
                            'Value "Two" Color',
                            twoValueColorIndex,
                            (index) => twoValueColorIndex = index,
                            colorOptions),
                        _buildColorDropdown(
                            'Default Row Color',
                            defaultRowColorIndex,
                            (index) => defaultRowColorIndex = index,
                            colorOptions),
                        _buildColorDropdown(
                            'Selection Color',
                            selectionColorIndex,
                            (index) => selectionColorIndex = index,
                            selectionColorOptions),
                        _buildColorDropdown(
                            'Border Color', activatedBorderColorIndex, (index) {
                          setState(() {
                            activatedBorderColorIndex = index;
                            if (stateManager != null) {
                              final newStyle =
                                  stateManager!.configuration.style.copyWith(
                                activatedBorderColor: activatedBorderColor,
                              );
                              stateManager!.setConfiguration(
                                  stateManager!.configuration.copyWith(
                                style: newStyle,
                              ));
                            }
                          });
                        }, selectionColorOptions),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Grid
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              configuration: TrinaGridConfiguration(
                selectingMode: TrinaGridSelectingMode.rowWithSingleTap,
                style: TrinaGridStyleConfig(
                  activatedColor: selectionColor,
                  cellColorInReadOnlyState: Colors.black45,
                  cellReadonlyColor: Colors.transparent,
                  // Set initial border color
                  activatedBorderColor: activatedBorderColor,
                ),
              ),
              onChanged: (TrinaGridOnChangedEvent event) {
                print(event);
              },
              onLoaded: (TrinaGridOnLoadedEvent event) {
                setState(() {
                  stateManager = event.stateManager;
                });
              },
              rowColorCallback: (rowColorContext) {
                if (rowColorContext.row.cells.entries
                        .elementAt(4)
                        .value
                        .value ==
                    'One') {
                  return oneValueColor;
                } else if (rowColorContext.row.cells.entries
                        .elementAt(4)
                        .value
                        .value ==
                    'Two') {
                  return twoValueColor;
                }
                return defaultRowColor;
              },
              onSelected: (TrinaGridOnSelectedEvent event) {
                print(
                    'Row no. ${event.lastSelectedRow?.sortIdx} is selected. Total selected rows: ${event.selectedRows.length}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
