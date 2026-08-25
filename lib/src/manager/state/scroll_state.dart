import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

abstract class IScrollState {
  /// Controller to control the scrolling of the grid.
  TrinaGridScrollController get scroll;

  bool get isHorizontalOverScrolled;

  double get correctHorizontalOffset;

  Offset get directionalScrollEdgeOffset;

  Offset toDirectionalOffset(Offset offset);

  /// [direction] Scroll direction
  /// [offset] Scroll position
  void scrollByDirection(TrinaMoveDirection direction, double offset);

  /// Whether the cell can be scrolled when moving.
  bool canHorizontalCellScrollByDirection(
    TrinaMoveDirection direction,
    TrinaColumn columnToMove,
  );

  /// Scroll to [rowIdx] position.
  void moveScrollByRow(TrinaMoveDirection direction, int? rowIdx);

  /// Scroll to [columnIdx] position.
  void moveScrollByColumn(TrinaMoveDirection direction, int? columnIdx);

  bool needMovingScroll(Offset offset, TrinaMoveDirection move);

  void updateCorrectScrollOffset();

  void updateScrollViewport();

  void resetScrollToZero();
}

mixin ScrollState implements ITrinaGridState {
  @override
  bool get isHorizontalOverScrolled =>
      scroll.bodyRowsHorizontal!.offset > scroll.maxScrollHorizontal ||
      scroll.bodyRowsHorizontal!.offset < 0;

  @override
  double get correctHorizontalOffset {
    if (isHorizontalOverScrolled) {
      return scroll.horizontalOffset < 0 ? 0 : scroll.maxScrollHorizontal;
    }

    return scroll.horizontalOffset;
  }

  @override
  Offset get directionalScrollEdgeOffset =>
      isLTR ? Offset.zero : Offset(gridGlobalOffset!.dx, 0);

  @override
  Offset toDirectionalOffset(Offset offset) {
    if (isLTR) {
      return offset;
    }

    return Offset((maxWidth! + gridGlobalOffset!.dx) - offset.dx, offset.dy);
  }

  /// The live [ScrollPosition] of [controller], or null when it has no client
  /// or has not been laid out yet.
  ///
  /// Returns null during the frames before the body lists are laid out, and in
  /// unit tests where the scroll controller is mocked. Callers must treat null
  /// as "fall back to geometry computed from the configuration".
  ScrollPosition? _laidOutPosition(ScrollController? controller) {
    if (controller == null || !controller.hasClients) {
      return null;
    }

    final position = controller.position;

    if (!position.hasViewportDimension || !position.hasContentDimensions) {
      return null;
    }

    return position;
  }

  /// Clamps [offset] to the scrollable range of [controller].
  ///
  /// When the position is not available this returns [offset] unchanged, so the
  /// behaviour matches the computed geometry fallback.
  double _clampToScrollExtent(ScrollController? controller, double offset) {
    final position = _laidOutPosition(controller);

    if (position == null) {
      return offset;
    }

    return offset.clamp(position.minScrollExtent, position.maxScrollExtent);
  }

  @override
  void scrollByDirection(TrinaMoveDirection direction, double offset) {
    if (direction.vertical) {
      scroll.vertical!.jumpTo(offset);
    } else {
      scroll.horizontal!.jumpTo(offset);
    }
  }

  @override
  bool canHorizontalCellScrollByDirection(
    TrinaMoveDirection direction,
    TrinaColumn columnToMove,
  ) {
    // When the frozen column is visible, the column to move is a frozen column, the scrolling is unnecessary.
    return !(showFrozenColumn == true && columnToMove.frozen.isFrozen);
  }

  @override
  void moveScrollByRow(TrinaMoveDirection direction, int? rowIdx) {
    if (!direction.vertical) {
      return;
    }

    // Calculate the actual offset based on row-specific heights
    double offsetToMove = 0.0;

    if (direction.isUp) {
      // Calculate offset to the row above
      for (int i = 0; i < rowIdx! - 1; i++) {
        final rowHeight = getRowHeight(i);
        offsetToMove +=
            rowHeight + configuration.style.cellHorizontalBorderWidth;
      }
    } else {
      // Calculate offset to the row below
      for (int i = 0; i < rowIdx! + 1; i++) {
        final rowHeight = getRowHeight(i);
        offsetToMove +=
            rowHeight + configuration.style.cellHorizontalBorderWidth;
      }
    }

    // Height of the region in which scrollable rows are actually visible.
    //
    // Prefer the live viewport of the body rows list: it already accounts for
    // the horizontal scrollbar strip below the list, the frozen top and bottom
    // row bands, and every divider, none of which the layout getters below know
    // about. The computed value is only a fallback for the frames before the
    // list is laid out.
    final double viewportHeight =
        _laidOutPosition(scroll.bodyRowsVertical)?.viewportDimension ??
        (columnRowContainerHeight -
            columnGroupHeight -
            columnHeight -
            columnFilterHeight -
            columnFooterHeight -
            configuration.style.cellHorizontalBorderWidth);

    final double screenOffset = scroll.verticalOffset + viewportHeight;

    // The row being moved to, and the space it occupies in the list. The border
    // has to be included: the list lays each row out as height + border, so
    // leaving it out stops one border short of the bottom of the last row.
    final double targetRowHeight =
        getRowHeight(rowIdx + direction.offset) +
        configuration.style.cellHorizontalBorderWidth;

    final bool inScrollStart = scroll.verticalOffset <= offsetToMove;

    final bool inScrollEnd = offsetToMove + targetRowHeight <= screenOffset;

    if (inScrollStart && inScrollEnd) {
      return;
    } else if (inScrollEnd == false) {
      offsetToMove =
          scroll.verticalOffset + offsetToMove + targetRowHeight - screenOffset;
    }

    scrollByDirection(
      direction,
      _clampToScrollExtent(scroll.bodyRowsVertical, offsetToMove),
    );
  }

  @override
  void moveScrollByColumn(TrinaMoveDirection direction, int? columnIdx) {
    if (!direction.horizontal) {
      return;
    }

    final columnIndexes = columnIndexesByShowFrozen;

    final TrinaColumn columnToMove =
        refColumns[columnIndexes[columnIdx! + direction.offset]];

    if (!canHorizontalCellScrollByDirection(direction, columnToMove)) {
      return;
    }

    double offsetToMove = columnToMove.startPosition;

    // The vertical scrollbar is an overlay inside the body's Stack, so it does
    // not shrink the horizontal viewport, it covers the trailing band of it.
    // The body pads its scroll content by the same amount so the last column
    // can be scrolled clear of the overlay. Exclude that band here, otherwise
    // scrolling to the last column stops exactly one scrollbar width short of
    // maxScrollExtent and leaves the column hidden under the scrollbar.
    final double screenOffset =
        (showFrozenColumn == true
            ? maxWidth! - leftFrozenColumnsWidth - rightFrozenColumnsWidth
            : maxWidth!) -
        configuration.scrollbar.verticalScrollBarReservedWidth;

    if (direction.isRight) {
      if (offsetToMove > scroll.horizontal!.offset) {
        offsetToMove -= screenOffset;
        offsetToMove += columnToMove.width;
        offsetToMove += scrollOffsetByFrozenColumn;

        if (offsetToMove < scroll.horizontal!.offset) {
          return;
        }
      }
    } else {
      final offsetToNeed = offsetToMove + columnToMove.width;

      final currentOffset = screenOffset + scroll.horizontal!.offset;

      if (offsetToNeed > currentOffset) {
        offsetToMove = scroll.horizontal!.offset + offsetToNeed - currentOffset;
        offsetToMove += scrollOffsetByFrozenColumn;
      } else if (offsetToMove > scroll.horizontal!.offset) {
        return;
      }
    }

    scrollByDirection(
      direction,
      _clampToScrollExtent(scroll.bodyRowsHorizontal, offsetToMove),
    );
  }

  @override
  bool needMovingScroll(Offset? offset, TrinaMoveDirection move) {
    if (selectingMode.isNone) {
      return false;
    }

    switch (move) {
      case TrinaMoveDirection.left:
        return offset!.dx < bodyLeftScrollOffset;
      case TrinaMoveDirection.right:
        return offset!.dx > bodyRightScrollOffset;
      case TrinaMoveDirection.up:
        return offset!.dy < bodyUpScrollOffset;
      case TrinaMoveDirection.down:
        return offset!.dy > bodyDownScrollOffset;
    }
  }

  @override
  void updateCorrectScrollOffset() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (scroll.bodyRowsHorizontal?.hasClients != true) {
        return;
      }

      if (isHorizontalOverScrolled) {
        scroll.horizontal!.animateTo(
          correctHorizontalOffset,
          curve: Curves.ease,
          duration: const Duration(milliseconds: 300),
        );
      }
    });
  }

  @override
  void updateScrollViewport() {
    if (maxWidth == null ||
        scroll.bodyRowsHorizontal?.position.hasViewportDimension != true) {
      return;
    }

    final double bodyWidth = maxWidth! - bodyLeftOffset - bodyRightOffset;

    scroll.horizontal!.applyViewportDimension(bodyWidth);

    updateCorrectScrollOffset();
  }

  /// Called to fix an error
  /// that the screen cannot be touched due to an incorrect scroll range
  /// when resizing the screen.
  @override
  void resetScrollToZero() {
    if ((scroll.bodyRowsVertical?.offset ?? 0) <= 0) {
      scroll.bodyRowsVertical?.jumpTo(0);
    }

    if ((scroll.bodyRowsHorizontal?.offset ?? 0) <= 0) {
      scroll.bodyRowsHorizontal?.jumpTo(0);
    }
  }
}
