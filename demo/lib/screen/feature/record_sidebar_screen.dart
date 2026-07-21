import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class RecordSidebarScreen extends StatefulWidget {
  static const routeName = 'feature/record-sidebar';

  const RecordSidebarScreen({super.key});

  @override
  State<RecordSidebarScreen> createState() => _RecordSidebarScreenState();
}

class _RecordSidebarScreenState extends State<RecordSidebarScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  TrinaGridStateManager? stateManager;

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 100);
    columns.addAll(dummyData.columns);
    rows.addAll(dummyData.rows);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Record Sidebar',
      topTitle: 'Record Sidebar',
      topContents: const [
        Text(
          'A sidebar that shows every field of the selected row, with a search '
          'box and inline editing. It is a built-in grid feature toggled '
          'through the state manager.',
        ),
        Text(
          'Use the buttons above the grid to show/hide it, switch between '
          'docked (pushes the grid) and floating (slides over the grid) modes, '
          'and change its width.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/record_sidebar_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        configuration: const TrinaGridConfiguration(
          sidebar: TrinaGridSidebarConfig(width: 340),
        ),
        createHeader: (stateManager) => _Header(stateManager: stateManager),
        onLoaded: (TrinaGridOnLoadedEvent event) {
          event.stateManager.setSelectingMode(TrinaGridSelectingMode.row);
          event.stateManager.showSidebar();
          stateManager = event.stateManager;
        },
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({required this.stateManager});

  final TrinaGridStateManager stateManager;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();
    stateManager.addListener(_update);
  }

  @override
  void dispose() {
    stateManager.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            ElevatedButton.icon(
              icon: Icon(
                stateManager.isSidebarVisible
                    ? Icons.view_sidebar
                    : Icons.view_sidebar_outlined,
              ),
              label: Text(
                stateManager.isSidebarVisible ? 'Hide sidebar' : 'Show sidebar',
              ),
              onPressed: () => stateManager.toggleSidebar(),
            ),
            const SizedBox(width: 16),
            const Text('Mode:'),
            const SizedBox(width: 8),
            SegmentedButton<TrinaGridSidebarMode>(
              segments: const [
                ButtonSegment(
                  value: TrinaGridSidebarMode.docked,
                  label: Text('Docked'),
                  icon: Icon(Icons.vertical_split),
                ),
                ButtonSegment(
                  value: TrinaGridSidebarMode.floating,
                  label: Text('Floating'),
                  icon: Icon(Icons.flip_to_front),
                ),
              ],
              selected: {stateManager.sidebarMode},
              onSelectionChanged: (selection) {
                stateManager.setSidebarMode(selection.first);
              },
            ),
            const SizedBox(width: 16),
            const Text('Width:'),
            const SizedBox(width: 8),
            for (final width in const [280.0, 340.0, 420.0])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('${width.toInt()}'),
                  selected: stateManager.sidebarWidth == width,
                  onSelected: (_) => stateManager.setSidebarWidth(width),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
