import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../ui.dart';

class TrinaColumnTitle extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  final TrinaColumn column;

  /// Height of the column title, defaulting to the state manager's column height
  late final double height;

  TrinaColumnTitle({
    required this.stateManager,
    required this.column,
    double? height,
  })  : height = height ?? stateManager.columnHeight,
        super(key: ValueKey('column_title_${column.key}'));

  @override
  TrinaColumnTitleState createState() => TrinaColumnTitleState();
}

class TrinaColumnTitleState extends TrinaStateWithChange<TrinaColumnTitle> {
  /// Tracks the right position of the column during resize
  late Offset _columnRightPosition;

  bool _isPointMoving = false;

  TrinaColumnSort _sort = TrinaColumnSort.none;

  bool get showContextIcon {
    return widget.column.enableContextMenu ||
        widget.column.enableDropToResize ||
        !_sort.isNone;
  }

  bool get enableGesture {
    return widget.column.enableContextMenu || widget.column.enableDropToResize;
  }

  MouseCursor get contextMenuCursor {
    if (enableGesture) {
      return widget.column.enableDropToResize
          ? SystemMouseCursors.resizeLeftRight
          : SystemMouseCursors.click;
    }

    return SystemMouseCursors.basic;
  }

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _sort = update<TrinaColumnSort>(_sort, widget.column.sort);
  }

  void _showContextMenu(BuildContext context, Offset position) async {
    final selected = await showColumnMenu(
      context: context,
      position: position,
      backgroundColor: stateManager.style.menuBackgroundColor,
      items: stateManager.columnMenuDelegate.buildMenuItems(
        stateManager: stateManager,
        column: widget.column,
      ),
    );

    if (context.mounted) {
      stateManager.columnMenuDelegate.onSelected(
        context: context,
        stateManager: stateManager,
        column: widget.column,
        mounted: mounted,
        selected: selected,
      );
    }
  }

  void _handleOnPointDown(PointerDownEvent event) {
    _isPointMoving = false;

    _columnRightPosition = event.position;
  }

  /// Handles pointer movement events for column resizing
  ///
  /// This method tracks pointer movement and enables column resizing when
  /// the pointer moves beyond a small threshold.
  void _handleOnPointMove(PointerMoveEvent event) {
    // Mark point as moving if distance moved is above a threshold
    _isPointMoving |=
        (_columnRightPosition - event.position).distanceSquared > 0.5;

    if (!_isPointMoving) return;

    // Calculate the horizontal movement offset
    final moveOffset = event.position.dx - _columnRightPosition.dx;

    final bool isLTR = stateManager.isLTR;

    // Resize the column, inverting offset for RTL layouts
    stateManager.resizeColumn(widget.column, isLTR ? moveOffset : -moveOffset);

    // Update the column's right position for next movement tracking
    _columnRightPosition = event.position;
  }

  void _handleOnPointUp(PointerUpEvent event) {
    if (_isPointMoving) {
      stateManager.updateCorrectScrollOffset();
    } else if (mounted && widget.column.enableContextMenu) {
      _showContextMenu(context, event.position);
    }

    _isPointMoving = false;
  }

  @override
  Widget build(BuildContext context) {
    final style = stateManager.configuration.style;
    final bool isCustom = widget.column.hasTitleRenderer;

    var contextMenuIcon = _buildContextMenuIcon(style);
    contextMenuIcon = _buildContextMenuWidget(
      contextMenuIcon,
      hasTitleRenderer: isCustom,
    );
    Widget title;

    if (isCustom) {
      final rendererContext = _createTitleRendererContext(contextMenuIcon);
      // use user-defined title renderer
      title = widget.column.titleRenderer!(rendererContext);
    } else {
      title = _DefaultColumnTitleContent(
        stateManager: stateManager,
        column: widget.column,
        height: widget.height,
      );
    }
    if (widget.column.enableSorting) {
      title = _SortableWidget(
        stateManager: stateManager,
        column: widget.column,
        child: title,
      );
    }

    if (widget.column.enableColumnDrag) {
      // NOTE: The order is important; `Draggable` wraps `DragTarget`
      title = _ColumnDragTarget(
        column: widget.column,
        stateManager: stateManager,
        height: widget.height,
        child: title,
      );
      title = _DraggableWidget(
        stateManager: stateManager,
        column: widget.column,
        child: title,
      );
    }

    if (isCustom) {
      return title;
    }

    return Stack(
      children: [
        Positioned(left: 0, right: 0, child: title),
        if (showContextIcon)
          Positioned.directional(
            textDirection: stateManager.textDirection,
            end: -3,
            child: contextMenuIcon,
          ),
      ],
    );
  }

  Widget _buildContextMenuIcon(TrinaGridStyleConfig style) {
    return SizedBox(
      height: widget.height,
      child: Align(
        alignment: Alignment.center,
        child: IconButton(
          icon: TrinaGridColumnIcon(
            sort: _sort,
            color: style.iconColor,
            widget: widget.column.enableContextMenu
                ? null
                : style.columnResizeWidget,
            icon: widget.column.enableContextMenu
                ? style.columnContextIcon
                : style.columnResizeIcon,
            ascendingIcon: style.columnAscendingIcon,
            descendingIcon: style.columnDescendingIcon,
          ),
          iconSize: style.iconSize,
          mouseCursor: contextMenuCursor,
          onPressed: null,
        ),
      ),
    );
  }

  TrinaColumnTitleRendererContext _createTitleRendererContext(
    Widget contextMenuIcon,
  ) {
    final isFiltered = stateManager.isFilteredColumn(widget.column);

    return TrinaColumnTitleRendererContext(
      column: widget.column,
      stateManager: stateManager,
      height: widget.height,
      showContextIcon: showContextIcon,
      contextMenuIcon: contextMenuIcon,
      isFiltered: isFiltered,
      showContextMenu:
          mounted && widget.column.enableContextMenu ? _showContextMenu : null,
    );
  }

  /// Builds the context menu widget, wrapping it with gesture detectors.
  ///
  /// If [hasTitleRenderer] is true, the widget is also wrapped in a
  /// [GestureDetector] to absorb tap events. This prevents the tap from
  /// propagating to the parent `_SortableWidget`, which would otherwise
  /// trigger a column sort when the context menu icon is clicked.
  Widget _buildContextMenuWidget(
    Widget contextMenuIcon, {
    bool hasTitleRenderer = false,
  }) {
    if (!enableGesture) {
      return contextMenuIcon;
    }

    final listener = Listener(
      onPointerDown: _handleOnPointDown,
      onPointerMove: _handleOnPointMove,
      onPointerUp: _handleOnPointUp,
      child: contextMenuIcon,
    );

    if (hasTitleRenderer) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {}, // Absorb the tap to prevent sorting.
        child: listener,
      );
    }

    return listener;
  }
}

class TrinaGridColumnIcon extends StatelessWidget {
  final TrinaColumnSort? sort;

  final Color color;

  final IconData icon;
  final Widget? widget;

  final Widget? ascendingIcon;

  final Widget? descendingIcon;

  const TrinaGridColumnIcon({
    this.sort,
    this.widget,
    this.color = Colors.black26,
    this.icon = Icons.dehaze,
    this.ascendingIcon,
    this.descendingIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    switch (sort) {
      case TrinaColumnSort.ascending:
        return ascendingIcon == null
            ? Transform.rotate(
                angle: 90 * pi / 90,
                child: const Icon(Icons.sort, color: Colors.green),
              )
            : ascendingIcon!;
      case TrinaColumnSort.descending:
        return descendingIcon == null
            ? const Icon(Icons.sort, color: Colors.red)
            : descendingIcon!;
      default:
        return widget ?? Icon(icon, color: color);
    }
  }
}

class _DraggableWidget extends StatelessWidget {
  final TrinaGridStateManager stateManager;

  final TrinaColumn column;

  final Widget child;

  const _DraggableWidget({
    required this.stateManager,
    required this.column,
    required this.child,
  });

  void _handleOnPointerMove(PointerMoveEvent event) {
    stateManager.eventManager!.addEvent(
      TrinaGridScrollUpdateEvent(
        offset: event.position,
        scrollDirection: TrinaGridScrollUpdateDirection.horizontal,
      ),
    );
  }

  void _handleOnPointerUp(PointerUpEvent event) {
    TrinaGridScrollUpdateEvent.stopScroll(
      stateManager,
      TrinaGridScrollUpdateDirection.horizontal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _handleOnPointerMove,
      onPointerUp: _handleOnPointerUp,
      child: Draggable<TrinaColumn>(
        data: column,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: TrinaShadowContainer(
            alignment: column.titleTextAlign.alignmentValue,
            width: TrinaGridSettings.minColumnWidth,
            height: stateManager.columnHeight,
            backgroundColor:
                stateManager.configuration.style.gridBackgroundColor,
            borderColor: stateManager.configuration.style.gridBorderColor,
            child: Text(
              column.title,
              style: stateManager.configuration.style.columnTextStyle.copyWith(
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}

class _SortableWidget extends StatelessWidget {
  final TrinaGridStateManager stateManager;

  final TrinaColumn column;

  final Widget child;

  const _SortableWidget({
    required this.stateManager,
    required this.column,
    required this.child,
  });

  void _onTap() {
    stateManager.toggleSortColumn(column);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: const ValueKey('ColumnTitleSortableGesture'),
        onTap: _onTap,
        child: child,
      ),
    );
  }
}

class _DefaultColumnTitleContent extends StatelessWidget {
  final TrinaGridStateManager stateManager;

  final TrinaColumn column;

  final double height;

  const _DefaultColumnTitleContent({
    required this.stateManager,
    required this.column,
    required this.height,
  });

  EdgeInsets get padding =>
      column.titlePadding ??
      stateManager.configuration.style.defaultColumnTitlePadding;

  bool get showSizedBoxForIcon =>
      column.isShowRightIcon &&
      (column.titleTextAlign.isRight || stateManager.isRTL);

  TrinaGridStyleConfig get style => stateManager.style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      height: height,
      width: column.width,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: column.backgroundColor,
        border: BorderDirectional(
          end: style.enableColumnBorderVertical
              ? BorderSide(color: style.borderColor, width: 1.0)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          if (column.enableRowChecked &&
              column.rowCheckBoxGroupDepth == 0 &&
              column.enableTitleChecked)
            Flexible(
              child: CheckboxAllSelectionWidget(stateManager: stateManager),
            ),
          Expanded(
            child: _ColumnTextWidget(
              column: column,
              stateManager: stateManager,
              height: height,
            ),
          ),
          if (showSizedBoxForIcon) SizedBox(width: style.iconSize),
        ],
      ),
    );
  }
}

class CheckboxAllSelectionWidget extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  const CheckboxAllSelectionWidget({required this.stateManager, super.key});

  @override
  CheckboxAllSelectionWidgetState createState() =>
      CheckboxAllSelectionWidgetState();
}

class CheckboxAllSelectionWidgetState
    extends TrinaStateWithChange<CheckboxAllSelectionWidget> {
  bool? _checked;

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _checked = update<bool?>(_checked, stateManager.tristateCheckedRow);
  }

  void _handleOnChanged(bool? changed) {
    if (changed == _checked) {
      return;
    }

    changed ??= false;

    if (_checked == null) changed = true;

    stateManager.toggleAllRowChecked(changed);

    if (stateManager.onRowChecked != null) {
      stateManager.onRowChecked!(
        TrinaGridOnRowCheckedAllEvent(isChecked: changed),
      );
    }

    setState(() {
      _checked = changed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TrinaScaledCheckbox(
      value: _checked,
      handleOnChanged: _handleOnChanged,
      tristate: true,
      scale: 0.86,
      unselectedColor: stateManager.configuration.style.columnUnselectedColor,
      activeColor: stateManager.configuration.style.columnActiveColor,
      checkColor: stateManager.configuration.style.columnCheckedColor,
      side: stateManager.configuration.style.columnCheckedSide,
    );
  }
}

class _ColumnTextWidget extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  final TrinaColumn column;

  final double height;

  const _ColumnTextWidget({
    required this.stateManager,
    required this.column,
    required this.height,
  });

  @override
  _ColumnTextWidgetState createState() => _ColumnTextWidgetState();
}

class _ColumnTextWidgetState extends TrinaStateWithChange<_ColumnTextWidget> {
  bool _isFilteredList = false;

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _isFilteredList = update<bool>(
      _isFilteredList,
      stateManager.isFilteredColumn(widget.column),
    );
  }

  void _handleOnPressedFilter() {
    stateManager.showFilterPopup(context, calledColumn: widget.column);
  }

  String? get _title =>
      widget.column.titleSpan == null ? widget.column.title : null;

  List<InlineSpan> get _children => [
        if (widget.column.titleSpan != null) widget.column.titleSpan!,
        if (_isFilteredList &&
            stateManager.configuration.style.filterIcon != null)
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: IconButton(
              icon: Icon(
                stateManager.configuration.style.filterIcon!.icon,
                color: stateManager.configuration.style.filterHeaderIconColor ??
                    stateManager.configuration.style.iconColor,
                size: stateManager.configuration.style.iconSize,
              ),
              onPressed: _handleOnPressedFilter,
              constraints: BoxConstraints(
                maxHeight: widget.height +
                    (widget.stateManager.style.cellHorizontalBorderWidth * 2),
              ),
            ),
          ),
      ];

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(text: _title, children: _children),
      style: stateManager.configuration.style.columnTextStyle,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      maxLines: 1,
      textAlign: widget.column.titleTextAlign.value,
    );
  }
}

class _ColumnDragTarget extends StatelessWidget {
  final TrinaGridStateManager stateManager;

  final TrinaColumn column;

  final Widget child;

  final double height;

  const _ColumnDragTarget({
    required this.stateManager,
    required this.column,
    required this.child,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<TrinaColumn>(
      onWillAcceptWithDetails: (columnToDrag) {
        return columnToDrag.data.key != column.key &&
            !stateManager.limitMoveColumn(
              column: columnToDrag.data,
              targetColumn: column,
            );
      },
      onAcceptWithDetails: (columnToMove) {
        if (columnToMove.data.key != column.key) {
          stateManager.moveColumn(
            column: columnToMove.data,
            targetColumn: column,
          );
        }
      },
      builder: (context, candidate, rejectedData) {
        final bool hasDragTarget = candidate.isNotEmpty;

        final style = stateManager.style;

        return SizedBox(
          width: column.width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              child,
              if (hasDragTarget)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: style.dragTargetColumnColor,
                    border: Border.all(color: Colors.blue, width: 1.5),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
