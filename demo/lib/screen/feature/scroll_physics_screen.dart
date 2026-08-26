import 'package:demo/dummy_data/development.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

/// Options offered for each axis in the controls below.
enum _PhysicsOption {
  platformDefault('Platform default', null),
  never('Never scrollable', NeverScrollableScrollPhysics()),
  bouncing('Bouncing', BouncingScrollPhysics()),
  clamping('Clamping', ClampingScrollPhysics());

  const _PhysicsOption(this.label, this.physics);

  final String label;
  final ScrollPhysics? physics;
}

class ScrollPhysicsScreen extends StatefulWidget {
  static const routeName = 'feature/scroll-physics';

  const ScrollPhysicsScreen({super.key});

  @override
  State<ScrollPhysicsScreen> createState() => _ScrollPhysicsScreenState();
}

/// Height used for the grid when it is not sizing itself to its content.
const double _fixedGridHeight = 400;

class _ScrollPhysicsScreenState extends State<ScrollPhysicsScreen> {
  final List<TrinaColumn> columns = [];
  final List<TrinaRow> rows = [];

  final ScrollController _pageScroll = ScrollController();

  _PhysicsOption _vertical = _PhysicsOption.never;
  _PhysicsOption _horizontal = _PhysicsOption.platformDefault;
  bool _fitContent = true;

  @override
  void initState() {
    super.initState();

    // Enough columns to overflow the width, few enough rows that the grid
    // stays a readable section of the page when `fitContent` is on.
    final dummyData = DummyData(15, 20);
    columns.addAll(dummyData.columns);
    rows.addAll(dummyData.rows);
  }

  @override
  void dispose() {
    _pageScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Scroll Physics',
      topTitle: 'Scroll Physics',
      topContents: const [
        Text(
          'scrollPhysics applies to both axes at once, so blocking vertical scrolling used to block horizontal scrolling with it. '
          'horizontalScrollPhysics and verticalScrollPhysics control each axis on its own.',
        ),
        SizedBox(height: 8),
        Text(
          'The grid below sits inside a scrolling page. With Vertical set to "Never scrollable" and Fit content on, '
          'dragging up and down over the grid scrolls the page, while dragging left and right still scrolls the grid. '
          'Switch Vertical back to "Platform default" to feel the scroll conflict that the per axis physics avoids.',
        ),
        SizedBox(height: 8),
        Text(
          'Turning Fit content off gives the grid a fixed height instead, so it keeps its own vertical scrolling. '
          'A grid inside a page needs one of the two: without a bounded height and without fitContent, it has no '
          'height to lay out with.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/scroll_physics_screen.dart',
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildControls(),
          const SizedBox(height: 10),
          Expanded(child: _buildScrollingPage()),
        ],
      ),
    );
  }

  /// The "page" the grid is embedded in. Everything inside scrolls together.
  Widget _buildScrollingPage() {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        controller: _pageScroll,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPageSection(
              'Page content above the grid',
              'This block and the one below the grid belong to the page, not to the grid. '
                  'They are here so the page is taller than the viewport and has something to scroll.',
              Colors.indigo,
            ),
            const SizedBox(height: 16),
            _buildGrid(),
            const SizedBox(height: 16),
            _buildPageSection(
              'Page content below the grid',
              'Scroll down to here by dragging over the grid itself. That only works while the '
                  'grid hands vertical drags back to the page.',
              Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final grid = TrinaGrid(
      // The grid is rebuilt when the sizing mode changes so it takes effect.
      key: ValueKey('grid_$_fitContent'),
      columns: columns,
      rows: rows,
      fitContent: _fitContent,
      horizontalScrollPhysics: _horizontal.physics,
      verticalScrollPhysics: _vertical.physics,
      configuration: const TrinaGridConfiguration(
        columnSize: TrinaGridColumnSizeConfig(
          autoSizeMode: TrinaAutoSizeMode.none,
        ),
      ),
    );

    // The page gives its children unbounded height, so a grid that does not
    // size itself to its content needs an explicit height.
    return _fitContent ? grid : SizedBox(height: _fixedGridHeight, child: grid);
  }

  Widget _buildPageSection(String title, String body, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(body),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildPhysicsDropdown(
            label: 'Vertical',
            value: _vertical,
            onChanged: (value) => setState(() => _vertical = value),
          ),
          _buildPhysicsDropdown(
            label: 'Horizontal',
            value: _horizontal,
            onChanged: (value) => setState(() => _horizontal = value),
          ),
          Tooltip(
            message: _fitContent
                ? 'The grid sizes itself to all of its rows, so the page scrolls through them.'
                : 'The grid is ${_fixedGridHeight.toInt()}px tall, so rows past that need the grid to scroll vertically.',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _fitContent
                      ? 'Fit content'
                      : 'Fixed height (${_fixedGridHeight.toInt()}px)',
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _fitContent,
                  onChanged: (value) => setState(() => _fitContent = value),
                ),
              ],
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.vertical_align_top),
            label: const Text('Scroll page to top'),
            onPressed: _pageScroll.hasClients
                ? () => _pageScroll.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicsDropdown({
    required String label,
    required _PhysicsOption value,
    required ValueChanged<_PhysicsOption> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: '),
        const SizedBox(width: 4),
        DropdownButton<_PhysicsOption>(
          value: value,
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
          items: _PhysicsOption.values
              .map(
                (option) => DropdownMenuItem<_PhysicsOption>(
                  value: option,
                  child: Text(option.label),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
