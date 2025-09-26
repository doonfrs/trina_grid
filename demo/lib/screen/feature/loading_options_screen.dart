import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class LoadingOptionsScreen extends StatefulWidget {
  static const routeName = 'feature/loading-options';

  const LoadingOptionsScreen({super.key});

  @override
  _LoadingOptionsScreenState createState() => _LoadingOptionsScreenState();
}

class _LoadingOptionsScreenState extends State<LoadingOptionsScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  late TrinaGridStateManager stateManager;

  // Loading options
  int _selectedLoadingWidget = 0;
  TrinaGridLoadingLevel _loadingLevel = TrinaGridLoadingLevel.grid;
  bool _useCustomWidget = false;

  // Custom loading widget examples
  final List<Widget> customLoadingWidgets = [
    // Example 1: Custom progress indicator with branding
    Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue,
            child: Icon(Icons.grid_on, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading data...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ],
      ),
    ),

    // Example 2: Shimmer loading effect
    Container(
      color: Colors.white.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShimmerLoading(
              width: 300,
              height: 30,
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
            ShimmerLoading(
              width: 300,
              height: 30,
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
            ShimmerLoading(
              width: 300,
              height: 30,
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
            ShimmerLoading(
              width: 300,
              height: 30,
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
            ShimmerLoading(
              width: 300,
              height: 30,
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
          ],
        ),
      ),
    ),

    // Example 3: Animated loading spinner
    Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade400),
          ),
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        width: 150,
      ),
      TrinaColumn(
        title: 'Age',
        field: 'age',
        type: TrinaColumnType.number(),
        width: 80,
      ),
      TrinaColumn(
        title: 'Role',
        field: 'role',
        type: TrinaColumnType.text(),
        width: 150,
      ),
      TrinaColumn(
        title: 'Joined',
        field: 'joined',
        type: TrinaColumnType.date(),
        width: 150,
      ),
      TrinaColumn(
        title: 'Status',
        field: 'status',
        type: TrinaColumnType.select(<String>['Active', 'Inactive', 'Pending']),
        width: 130,
      ),
    ]);

    rows.addAll(DummyData.rowsByColumns(length: 10, columns: columns));
  }

  void _showLoading() {
    // Determine the effective loading level
    final effectiveLevel = _useCustomWidget
        ? TrinaGridLoadingLevel.grid
        : _loadingLevel;

    // Display what's actually being used
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _useCustomWidget
              ? 'Showing custom loading widget with grid level'
              : 'Showing default loading with ${effectiveLevel.toString().split('.').last} level',
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    stateManager.setShowLoading(
      true,
      level:
          _loadingLevel, // The state manager will enforce grid level if custom widget is used
      customLoadingWidget: _useCustomWidget
          ? customLoadingWidgets[_selectedLoadingWidget]
          : null,
    );

    // Simulate an operation that takes 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        stateManager.setShowLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Loading Options',
      topTitle: 'Loading Options',
      topContents: const [
        Text('The TrinaGrid provides flexible loading display options:'),
        SizedBox(height: 8),
        Text('• Choose from different loading levels to control coverage'),
        Text('• Provide a custom loading widget for complete UI control'),
        SizedBox(height: 8),
        Text(
          'Note: When using a custom loading widget, the level is always treated as grid level.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/loading_options_screen.dart',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: _showLoading,
              child: const Text('Show Loading'),
            ),
            const SizedBox(width: 16),
            const Text('Loading Level:'),
            const SizedBox(width: 8),
            DropdownButton<TrinaGridLoadingLevel>(
              value: _loadingLevel,
              items: TrinaGridLoadingLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level.toString().split('.').last),
                );
              }).toList(),
              onChanged: _useCustomWidget
                  ? null // Disable dropdown when custom widget is used
                  : (value) {
                      setState(() {
                        _loadingLevel = value!;
                      });
                    },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _useCustomWidget,
              onChanged: (value) {
                setState(() {
                  _useCustomWidget = value!;
                  // If custom widget is enabled, show a message to the user
                  if (_useCustomWidget &&
                      _loadingLevel != TrinaGridLoadingLevel.grid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'When using a custom widget, level is always set to grid',
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                });
              },
            ),
            const Text('Use Custom Widget'),
            const SizedBox(width: 16),
            if (_useCustomWidget) ...[
              const Text('Widget Style:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _selectedLoadingWidget,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Branded Loading')),
                  DropdownMenuItem(value: 1, child: Text('Shimmer Effect')),
                  DropdownMenuItem(value: 2, child: Text('Simple Spinner')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLoadingWidget = value!;
                  });
                },
              ),
            ],
          ],
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
        },
      ),
    );
  }
}

/// A simple shimmer loading effect widget
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final EdgeInsets margin;

  const ShimmerLoading({
    required this.width,
    required this.height,
    this.margin = EdgeInsets.zero,
    super.key,
  });

  @override
  _ShimmerLoadingState createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.shade200,
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  Colors.grey.shade200,
                  Colors.grey.shade100,
                  Colors.grey.shade200,
                ],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment(_animation.value, 0),
                end: Alignment(_animation.value + 1, 0),
                tileMode: TileMode.clamp,
              ).createShader(bounds);
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
