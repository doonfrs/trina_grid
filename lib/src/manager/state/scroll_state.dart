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

    return Offset(
      (maxWidth! + gridGlobalOffset!.dx) - offset.dx,
      offset.dy,
    );
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

    final double rowSize = rowTotalHeight;

    final double screenOffset = scroll.verticalOffset +
        columnRowContainerHeight -
        columnGroupHeight -
        columnHeight -
        columnFilterHeight -
        columnFooterHeight -
        configuration.style.cellHorizontalBorderWidth;

    double offsetToMove =
        direction.isUp ? (rowIdx! - 1) * rowSize : (rowIdx! + 1) * rowSize;

    final bool inScrollStart = scroll.verticalOffset <= offsetToMove;

    final bool inScrollEnd = offsetToMove + rowSize <= screenOffset;

    if (inScrollStart && inScrollEnd) {
      return;
    } else if (inScrollEnd == false) {
      offsetToMove =
          scroll.verticalOffset + offsetToMove + rowSize - screenOffset;
    }

    scrollByDirection(direction, offsetToMove);
  }

  @override
  void moveScrollByColumn(TrinaMoveDirection direction, int? columnIdx) {
    if (!direction.horizontal) {
      return;
    }

    final columnIndexes = columnIndexesByShowFrozen;

    final TrinaColumn columnToMove =
        refColumns[columnIndexes[columnIdx! + direction.offset]];

    if (!canHorizontalCellScrollByDirection(
      direction,
      columnToMove,
    )) {
      return;
    }

    double offsetToMove = columnToMove.startPosition;

    final double? screenOffset = showFrozenColumn == true
        ? maxWidth! - leftFrozenColumnsWidth - rightFrozenColumnsWidth
        : maxWidth;

    if (direction.isRight) {
      if (offsetToMove > scroll.horizontal!.offset) {
        offsetToMove -= screenOffset!;
        offsetToMove += columnToMove.width;
        offsetToMove += scrollOffsetByFrozenColumn;

        if (offsetToMove < scroll.horizontal!.offset) {
          return;
        }
      }
    } else {
      final offsetToNeed = offsetToMove + columnToMove.width;

      final currentOffset = screenOffset! + scroll.horizontal!.offset;

      if (offsetToNeed > currentOffset) {
        offsetToMove = scroll.horizontal!.offset + offsetToNeed - currentOffset;
        offsetToMove += scrollOffsetByFrozenColumn;
      } else if (offsetToMove > scroll.horizontal!.offset) {
        return;
      }
    }

    scrollByDirection(direction, offsetToMove);
  }

  @override
  bool needMovingScroll(Offset? offset, TrinaMoveDirection move) {
    if (selectingMode.isDisabled) {
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
