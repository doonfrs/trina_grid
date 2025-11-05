import 'package:trina_grid/trina_grid.dart';

abstract class IVisibilityLayoutState {
  /// Set [TrinaColumn.startPosition] to [TrinaColumn.width].
  ///
  /// Set the horizontal position of the columns in the left area, center area, and right area
  /// according to the [TrinaColumn.frozen] value in [TrinaColumn.startPosition].
  ///
  /// This method should be called in an operation that dynamically changes the position of a column.
  /// Example) resizeColumn, frozenColumn, hideColumn...
  ///
  /// [notify] is called false in the normal case.
  /// When [notify] is called true,
  /// the notifyListeners of scrollController is forcibly called when build is not triggered.
  void updateVisibilityLayout({bool notify = false});
}

mixin VisibilityLayoutState implements ITrinaGridState {
  @override
  void updateVisibilityLayout({bool notify = false}) {
    if (refColumns.isEmpty) return;

    _updateColumnSize();

    _updateColumnPosition();

    updateScrollViewport();

    if (notify) scroll.horizontal?.notifyListeners();
  }

  void _updateColumnSize() {
    if (!activatedColumnsAutoSize) return;

    double offset = 0;

    if (showFrozenColumn) {
      if (hasLeftFrozenColumns) {
        offset += gridBorderWidth;
      }

      if (hasRightFrozenColumns) {
        offset += gridBorderWidth;
      }
    }

    // Subtract vertical scrollbar width from available column space.
    //
    // The scrollbar overlays content but still occupies visual space on the
    // right edge, so columns must be sized to (viewport width - scrollbar width).
    // Scrollbar uses thickness + 4px padding (see trina_vertical_scroll_bar.dart:273)
    // Only subtract when columnShowScrollWidth is enabled (matching behavior in
    // trina_body_columns.dart and trina_body_columns_footer.dart)
    if (configuration.scrollbar.showVertical &&
        configuration.scrollbar.columnShowScrollWidth) {
      offset += configuration.scrollbar.thickness + 4;
    }

    getColumnsAutoSizeHelper(
      columns: refColumns,
      maxWidth: maxWidth! - offset,
    ).update();
  }

  void _updateColumnPosition() {
    double leftX = 0;
    double bodyX = 0;
    double rightX = 0;

    for (final column in refColumns) {
      if (showFrozenColumn) {
        switch (column.frozen) {
          case TrinaColumnFrozen.none:
            column.startPosition = bodyX;
            bodyX += column.width;
            break;
          case TrinaColumnFrozen.start:
            column.startPosition = leftX;
            leftX += column.width;
            break;
          case TrinaColumnFrozen.end:
            column.startPosition = rightX;
            rightX += column.width;
            break;
        }
      } else {
        column.startPosition = bodyX;
        bodyX += column.width;
      }
    }
  }
}
