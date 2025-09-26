import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import 'ui.dart';

class TrinaBodyColumns extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  const TrinaBodyColumns(this.stateManager, {super.key});

  @override
  TrinaBodyColumnsState createState() => TrinaBodyColumnsState();
}

class TrinaBodyColumnsState extends TrinaStateWithChange<TrinaBodyColumns> {
  List<TrinaColumn> _columns = [];

  List<TrinaColumnGroupPair> _columnGroups = [];

  bool _showColumnGroups = false;

  int _itemCount = 0;

  late final ScrollController _scroll;

  // Track the end padding needed to account for vertical scrollbar
  double _verticalScrollbarWidth = 0;

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    _scroll = stateManager.scroll.horizontal!.addAndGet();

    // Calculate vertical scrollbar width when needed
    _updateVerticalScrollbarWidth();

    // Listen for configuration changes that might affect scrollbar visibility
    stateManager.addListener(_handleConfigChange);

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  void _handleConfigChange() {
    _updateVerticalScrollbarWidth();
  }

  void _updateVerticalScrollbarWidth() {
    final scrollConfig = stateManager.configuration.scrollbar;
    // Only account for vertical scrollbar width if it's shown
    if (scrollConfig.showVertical && scrollConfig.columnShowScrollWidth) {
      _verticalScrollbarWidth =
          scrollConfig.thickness +
          4; // Add padding as in TrinaVerticalScrollBar
    } else {
      _verticalScrollbarWidth = 0;
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    stateManager.removeListener(_handleConfigChange);

    super.dispose();
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _showColumnGroups = update<bool>(
      _showColumnGroups,
      stateManager.showColumnGroups,
    );

    _columns = update<List<TrinaColumn>>(
      _columns,
      _getColumns(),
      compare: listEquals,
    );

    _columnGroups = update<List<TrinaColumnGroupPair>>(
      _columnGroups,
      stateManager.separateLinkedGroup(
        columnGroupList: stateManager.refColumnGroups,
        columns: _columns,
      ),
    );

    _itemCount = update<int>(_itemCount, _getItemCount());

    // Update scrollbar width on state changes
    _updateVerticalScrollbarWidth();
  }

  List<TrinaColumn> _getColumns() {
    return stateManager.showFrozenColumn
        ? stateManager.bodyColumns
        : stateManager.columns;
  }

  int _getItemCount() {
    return _showColumnGroups == true ? _columnGroups.length : _columns.length;
  }

  TrinaVisibilityLayoutId _makeColumnGroup(TrinaColumnGroupPair e) {
    return TrinaVisibilityLayoutId(
      id: e.key,
      child: TrinaBaseColumnGroup(
        stateManager: stateManager,
        columnGroup: e,
        depth: stateManager.columnGroupDepth(stateManager.refColumnGroups),
      ),
    );
  }

  TrinaVisibilityLayoutId _makeColumn(TrinaColumn e) {
    return TrinaVisibilityLayoutId(
      id: e.field,
      child: TrinaBaseColumn(stateManager: stateManager, column: e),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: Row(
        children: [
          TrinaVisibilityLayout(
            delegate: MainColumnLayoutDelegate(
              stateManager: stateManager,
              columns: _columns,
              columnGroups: _columnGroups,
              frozen: TrinaColumnFrozen.none,
              textDirection: stateManager.textDirection,
            ),
            scrollController: _scroll,
            initialViewportDimension:
                MediaQuery.of(context).size.width - _verticalScrollbarWidth,
            children: _showColumnGroups == true
                ? _columnGroups.map(_makeColumnGroup).toList(growable: false)
                : _columns.map(_makeColumn).toList(growable: false),
          ),
          // Add a spacer with the same width as the vertical scrollbar
          SizedBox(width: _verticalScrollbarWidth),
        ],
      ),
    );
  }
}

class MainColumnLayoutDelegate extends MultiChildLayoutDelegate {
  final TrinaGridStateManager stateManager;

  final List<TrinaColumn> columns;

  final List<TrinaColumnGroupPair> columnGroups;

  final TrinaColumnFrozen frozen;

  final TextDirection textDirection;

  MainColumnLayoutDelegate({
    required this.stateManager,
    required this.columns,
    required this.columnGroups,
    required this.frozen,
    required this.textDirection,
  }) : super(relayout: stateManager.resizingChangeNotifier);

  double totalColumnsHeight = 0;

  @override
  Size getSize(BoxConstraints constraints) {
    totalColumnsHeight = 0;

    if (stateManager.showColumnGroups) {
      totalColumnsHeight =
          stateManager.columnGroupHeight + stateManager.columnHeight;
    } else {
      totalColumnsHeight = stateManager.columnHeight;
    }

    totalColumnsHeight += stateManager.columnFilterHeight;

    return Size(
      columns.fold(
        0,
        (previousValue, element) => previousValue += element.width,
      ),
      totalColumnsHeight,
    );
  }

  @override
  void performLayout(Size size) {
    final isLTR = textDirection == TextDirection.ltr;

    if (stateManager.showColumnGroups) {
      final items = isLTR ? columnGroups : columnGroups.reversed;
      double dx = 0;

      for (TrinaColumnGroupPair pair in items) {
        final double width = pair.columns.fold<double>(
          0,
          (previousValue, element) => previousValue + element.width,
        );

        if (hasChild(pair.key)) {
          var boxConstraints = BoxConstraints.tight(
            Size(width, totalColumnsHeight),
          );

          layoutChild(pair.key, boxConstraints);

          positionChild(pair.key, Offset(dx, 0));
        }

        dx += width;
      }
    } else {
      final items = isLTR ? columns : columns.reversed;
      double dx = 0;

      for (TrinaColumn col in items) {
        var width = col.width;

        if (hasChild(col.field)) {
          var boxConstraints = BoxConstraints.tight(
            Size(width, totalColumnsHeight),
          );

          layoutChild(col.field, boxConstraints);

          positionChild(col.field, Offset(dx, 0));
        }

        dx += width;
      }
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}
