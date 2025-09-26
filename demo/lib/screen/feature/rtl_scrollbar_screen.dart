import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class RTLScrollbarScreen extends StatefulWidget {
  static const routeName = 'feature/rtl-scrollbar';

  const RTLScrollbarScreen({super.key});

  @override
  _RTLScrollbarScreenState createState() => _RTLScrollbarScreenState();
}

class _RTLScrollbarScreenState extends State<RTLScrollbarScreen> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();

    // Create a lot of columns and rows to ensure both scrollbars are visible
    final dummyData = DummyData(25, 100);
    columns.addAll(dummyData.columns);
    rows.addAll(dummyData.rows);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'RTL Scrollbar Demo',
      topTitle: 'RTL with Scrollbars',
      topContents: const [
        Text(
          'This demo shows proper scrollbar positioning in RTL mode. '
          'In RTL languages like Arabic, the vertical scrollbar should appear on the left side of the screen '
          'and horizontal scrollbar thumb movements should be reversed.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/rtl_scrollbar_screen.dart',
        ),
      ],
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tab for switching between LTR and RTL
            _buildDirectionalitySelector(),
            const SizedBox(height: 16),
            // Main grid that takes the rest of the space
            Expanded(child: _buildGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionalitySelector() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select text direction:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDirectionButton(
                  'LTR (Left to Right)',
                  TextDirection.ltr,
                  setState,
                ),
                const SizedBox(width: 16),
                _buildDirectionButton(
                  'RTL (Right to Left)',
                  TextDirection.rtl,
                  setState,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // State variable to track current text direction
  TextDirection _currentDirection = TextDirection.rtl;

  Widget _buildDirectionButton(
    String label,
    TextDirection direction,
    Function(void Function()) setState,
  ) {
    final isSelected = _currentDirection == direction;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        setState(() {
          _currentDirection = direction;
        });
        // Force full rebuild of parent widget
        this.setState(() {});
      },
      child: Text(label),
    );
  }

  Widget _buildGrid() {
    return Directionality(
      textDirection: _currentDirection,
      child: TrinaGrid(
        columns: columns,
        rows: rows,
        configuration: TrinaGridConfiguration(
          scrollbar: const TrinaGridScrollbarConfig(
            isAlwaysShown: true,
            thickness: 12.0,
            showTrack: true,
            thumbColor: Colors.blue,
            thumbHoverColor: Colors.blueAccent,
            trackColor: Color.fromRGBO(200, 200, 200, 0.2),
          ),
        ),
        onLoaded: (event) {
          // Show column filter to add more UI elements
          event.stateManager.setShowColumnFilter(true);
        },
        // Add footer with pagination to show more UI elements
        createFooter: (stateManager) {
          stateManager.setPageSize(20);
          return TrinaPagination(stateManager);
        },
      ),
    );
  }
}
