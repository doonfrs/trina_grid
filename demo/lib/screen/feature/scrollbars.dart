import 'package:demo/dummy_data/development.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ScrollbarsScreen extends StatefulWidget {
  static const routeName = 'feature/scrollbars';

  const ScrollbarsScreen({super.key});

  @override
  State<ScrollbarsScreen> createState() => _ScrollbarsScreenState();
}

class _ScrollbarsScreenState extends State<ScrollbarsScreen> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];
  late final TrinaGridStateManager stateManager;

  // Scrollbar configuration
  bool isAlwaysShown = true;
  bool thumbVisible = true;
  bool showTrack = true;
  bool showHorizontal = true;
  bool showVertical = true;
  bool isDraggable = true;
  double thickness = 12;
  double minThumbLength = 40.0;
  double radius = 6.0; // Default radius (half of thickness)
  Color? thumbColor;
  Color? trackColor;
  Color? thumbHoverColor;
  Color? trackHoverColor;

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(20, 500);
    columns.addAll(dummyData.columns);
    rows.addAll(dummyData.rows);
  }

  void _updateScrollbarConfig() {
    final config = TrinaGridConfiguration(
      columnSize: const TrinaGridColumnSizeConfig(
        autoSizeMode: TrinaAutoSizeMode.none,
      ),
      scrollbar: TrinaGridScrollbarConfig(
        isAlwaysShown: isAlwaysShown,
        thumbVisible: thumbVisible,
        showTrack: showTrack,
        showHorizontal: showHorizontal,
        showVertical: showVertical,
        thickness: thickness,
        minThumbLength: minThumbLength,
        thumbColor: thumbColor,
        trackColor: trackColor,
        thumbHoverColor: thumbHoverColor,
        trackHoverColor: trackHoverColor,
        radius: radius,
        isDraggable: isDraggable,
      ),
    );

    stateManager.setConfiguration(config);
    stateManager.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Scrollbar Customization',
      topTitle: 'Scrollbar Customization',
      topContents: const [
        Text(
          'TrinaGrid provides extensive customization options for scrollbars. Control visibility, appearance, and behavior of scrollbars.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/scrollbars.dart',
        ),
      ],
      body: Column(
        children: [
          _buildControls(),
          Expanded(
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
              configuration: TrinaGridConfiguration(
                columnSize: const TrinaGridColumnSizeConfig(
                  autoSizeMode: TrinaAutoSizeMode.none,
                ),
                scrollbar: TrinaGridScrollbarConfig(
                  isAlwaysShown: isAlwaysShown,
                  thumbVisible: thumbVisible,
                  showTrack: showTrack,
                  showHorizontal: showHorizontal,
                  showVertical: showVertical,
                  thickness: thickness,
                  minThumbLength: minThumbLength,
                  radius: radius,
                  thumbColor: thumbColor,
                  trackColor: trackColor,
                  isDraggable: isDraggable,
                  thumbHoverColor: thumbHoverColor,
                  trackHoverColor: trackHoverColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scrollbar Settings',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                // Visibility controls
                Row(
                  children: [
                    _buildSwitchControl('Always Show', isAlwaysShown, (value) {
                      setState(() {
                        isAlwaysShown = value;

                        _updateScrollbarConfig();
                      });
                    }),
                    const SizedBox(width: 16),
                    _buildSwitchControl('Thumb Visible', thumbVisible, (value) {
                      setState(() {
                        thumbVisible = value;

                        _updateScrollbarConfig();
                      });
                    }),
                    const SizedBox(width: 16),
                    _buildSwitchControl('Show Track', showTrack, (value) {
                      setState(() {
                        showTrack = value;

                        _updateScrollbarConfig();
                      });
                    }),
                  ],
                ),
                const SizedBox(height: 8),

                // Scrollbar direction controls
                Row(
                  children: [
                    _buildSwitchControl('Show Horizontal', showHorizontal, (
                      value,
                    ) {
                      setState(() {
                        showHorizontal = value;

                        _updateScrollbarConfig();
                      });
                    }),
                    const SizedBox(width: 16),
                    _buildSwitchControl('Show Vertical', showVertical, (value) {
                      setState(() {
                        showVertical = value;

                        _updateScrollbarConfig();
                      });
                    }),
                    const SizedBox(width: 16),
                    _buildSwitchControl('Is Draggable', isDraggable, (value) {
                      setState(() {
                        isDraggable = value;

                        _updateScrollbarConfig();
                      });
                    }),
                  ],
                ),
                const SizedBox(height: 12),

                // Size controls
                Row(
                  children: [
                    Row(
                      children: [
                        const Text('Thickness:'),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 200,
                          child: Slider(
                            value: thickness,
                            min: 1,
                            max: 20,
                            divisions: 19,
                            label: thickness.round().toString(),
                            onChanged: (value) {
                              setState(() {
                                thickness = value;

                                _updateScrollbarConfig();
                              });
                            },
                          ),
                        ),
                        Text('${thickness.round()} px'),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Min Thumb Length:'),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 200,
                          child: Slider(
                            value: minThumbLength,
                            min: 20,
                            max: 100,
                            divisions: 16,
                            label: minThumbLength.round().toString(),
                            onChanged: (value) {
                              setState(() {
                                minThumbLength = value;

                                _updateScrollbarConfig();
                              });
                            },
                          ),
                        ),
                        Text('${minThumbLength.round()} px'),
                      ],
                    ),
                  ],
                ),

                Row(
                  children: [
                    const Text('Radius:'),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 200,
                      child: Slider(
                        value: radius,
                        min: 0,
                        max: 20,
                        divisions: 20,
                        label: radius.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            radius = value;

                            _updateScrollbarConfig();
                          });
                        },
                      ),
                    ),
                    Text('${radius.round()} px'),
                  ],
                ),
                const SizedBox(height: 12),

                // Color controls
                Row(
                  children: [
                    // Thumb color
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Thumb Color:'),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildColorButton(
                              null,
                              'Default',
                              thumbColor == null,
                              () => _setThumbColor(null),
                            ),
                            _buildColorButton(
                              Colors.blue,
                              'Blue',
                              thumbColor == Colors.blue,
                              () => _setThumbColor(Colors.blue),
                            ),
                            _buildColorButton(
                              Colors.red,
                              'Red',
                              thumbColor == Colors.red,
                              () => _setThumbColor(Colors.red),
                            ),
                            _buildColorButton(
                              Colors.green,
                              'Green',
                              thumbColor == Colors.green,
                              () => _setThumbColor(Colors.green),
                            ),
                            _buildColorButton(
                              Colors.purple,
                              'Purple',
                              thumbColor == Colors.purple,
                              () => _setThumbColor(Colors.purple),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),
                    // Track color
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Track Color:'),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildColorButton(
                              null,
                              'Default',
                              trackColor == null,
                              () => _setTrackColor(null),
                            ),
                            _buildColorButton(
                              Colors.grey.withAlpha(50),
                              'Light Grey',
                              trackColor == Colors.grey.withAlpha(50),
                              () => _setTrackColor(Colors.grey.withAlpha(50)),
                            ),
                            _buildColorButton(
                              Colors.lightBlue.withAlpha(50),
                              'Light Blue',
                              trackColor == Colors.lightBlue.withAlpha(50),
                              () => _setTrackColor(
                                Colors.lightBlue.withAlpha(50),
                              ),
                            ),
                            _buildColorButton(
                              Colors.pink.withAlpha(50),
                              'Pink',
                              trackColor == Colors.pink.withAlpha(50),
                              () => _setTrackColor(Colors.pink.withAlpha(50)),
                            ),
                            _buildColorButton(
                              Colors.amber.withAlpha(50),
                              'Amber',
                              trackColor == Colors.amber.withAlpha(50),
                              () => _setTrackColor(Colors.amber.withAlpha(50)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Hover Colors
                Row(
                  children: [
                    // Thumb hover color
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Thumb Hover Color:'),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildColorButton(
                              null,
                              'Default',
                              thumbHoverColor == null,
                              () => _setThumbHoverColor(null),
                            ),
                            _buildColorButton(
                              Colors.blue.shade700,
                              'Dark Blue',
                              thumbHoverColor == Colors.blue.shade700,
                              () => _setThumbHoverColor(Colors.blue.shade700),
                            ),
                            _buildColorButton(
                              Colors.red.shade700,
                              'Dark Red',
                              thumbHoverColor == Colors.red.shade700,
                              () => _setThumbHoverColor(Colors.red.shade700),
                            ),
                            _buildColorButton(
                              Colors.orange.shade700,
                              'Dark Orange',
                              thumbHoverColor == Colors.orange.shade700,
                              () => _setThumbHoverColor(Colors.orange.shade700),
                            ),
                            _buildColorButton(
                              Colors.deepPurple.shade700,
                              'Deep Purple',
                              thumbHoverColor == Colors.deepPurple.shade700,
                              () => _setThumbHoverColor(
                                Colors.deepPurple.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),
                    // Track hover color
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Track Hover Color:'),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildColorButton(
                              null,
                              'Default',
                              trackHoverColor == null,
                              () => _setTrackHoverColor(null),
                            ),
                            _buildColorButton(
                              Colors.grey.withAlpha(100),
                              'Grey',
                              trackHoverColor == Colors.grey.withAlpha(100),
                              () => _setTrackHoverColor(
                                Colors.grey.withAlpha(100),
                              ),
                            ),
                            _buildColorButton(
                              Colors.lightBlue.withAlpha(100),
                              'Light Blue',
                              trackHoverColor ==
                                  Colors.lightBlue.withAlpha(100),
                              () => _setTrackHoverColor(
                                Colors.lightBlue.withAlpha(100),
                              ),
                            ),
                            _buildColorButton(
                              Colors.pink.withAlpha(100),
                              'Pink',
                              trackHoverColor == Colors.pink.withAlpha(100),
                              () => _setTrackHoverColor(
                                Colors.pink.withAlpha(100),
                              ),
                            ),
                            _buildColorButton(
                              Colors.amber.withAlpha(100),
                              'Amber',
                              trackHoverColor == Colors.amber.withAlpha(100),
                              () => _setTrackHoverColor(
                                Colors.amber.withAlpha(100),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchControl(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 8),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildColorButton(
    Color? color,
    String label,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    color = color ?? Colors.grey.shade300;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: (color.computeLuminance() > 0.5 || color.a < 0.4)
            ? Colors.black
            : Colors.white,
        elevation: isSelected ? 4 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        side: isSelected ? BorderSide(color: Colors.black45, width: 1) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _setThumbColor(Color? color) {
    setState(() {
      thumbColor = color;
      _updateScrollbarConfig();
    });
  }

  void _setTrackColor(Color? color) {
    setState(() {
      trackColor = color;
      _updateScrollbarConfig();
    });
  }

  void _setThumbHoverColor(Color? color) {
    setState(() {
      thumbHoverColor = color;
      _updateScrollbarConfig();
    });
  }

  void _setTrackHoverColor(Color? color) {
    setState(() {
      trackHoverColor = color;
      _updateScrollbarConfig();
    });
  }
}
