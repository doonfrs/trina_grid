// This file is a modified version of "flutter_popup" popup.dart
// credits to the original author: https://github.com/herowws/flutter_popup

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Direction of the popup arrow.
enum _ArrowDirection { top, bottom }

/// Determines where the popup appears in relation to the anchor widget.
enum TrinaPopupPosition {
  /// Automatically determine the best position based on available space.
  auto,

  /// Always position the popup above the anchor.
  top,

  /// Always position the popup below the anchor.
  bottom,
}

/// A widget that displays a popup anchored to another widget.
///
/// The popup can be triggered by tap or long press, and displays [content] in an overlay.
class TrinaPopup<T> extends StatefulWidget {
  /// The key of the widget to anchor the popup to.
  final GlobalKey? anchorKey;

  /// The content to display inside the popup.
  final Widget content;

  /// The widget that triggers the popup.
  final Widget child;

  /// Whether to trigger the popup on long press (otherwise on tap).
  final bool isLongPress;

  /// The background color of the popup.
  final Color? backgroundColor;

  /// The color of the popup arrow.
  final Color? arrowColor;

  /// The color of the modal barrier.
  final Color? barrierColor;

  /// Whether to show the arrow.
  final bool showArrow;

  /// Padding for the popup content.
  final EdgeInsets contentPadding;

  /// Border radius for the popup content.
  final double? contentRadius;

  /// Custom decoration for the popup content.
  final BoxDecoration? contentDecoration;

  /// Called before the popup is shown.
  final VoidCallback? onBeforePopup;

  /// Called after the popup is closed, with the result value.
  final void Function(T? value)? onAfterPopup;

  /// Whether to use the root navigator for the popup.
  final bool rootNavigator;

  /// Positioning of the popup relative to the anchor.
  final TrinaPopupPosition position;

  /// Duration of the popup animation.
  final Duration animationDuration;

  /// Animation curve for the popup.
  final Curve animationCurve;

  /// Creates a [TrinaPopup].
  const TrinaPopup({
    required this.content,
    required this.child,
    this.anchorKey,
    this.isLongPress = false,
    this.backgroundColor,
    this.arrowColor,
    this.showArrow = true,
    this.barrierColor,
    this.contentPadding = const EdgeInsets.all(8),
    this.contentRadius,
    this.contentDecoration,
    this.onBeforePopup,
    this.onAfterPopup,
    this.rootNavigator = false,
    this.position = TrinaPopupPosition.auto,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationCurve = Curves.easeInOut,
  }) : super(key: anchorKey);

  @override
  State<TrinaPopup<T>> createState() => TrinaPopupState<T>();
}

/// State for [TrinaPopup].
class TrinaPopupState<T> extends State<TrinaPopup<T>> {
  /// Shows the popup overlay.
  void show() {
    final anchor = widget.anchorKey?.currentContext ?? context;
    final renderBox = anchor.findRenderObject();
    if (renderBox is! RenderBox) return;

    final offset = renderBox.localToGlobal(renderBox.paintBounds.topLeft);

    widget.onBeforePopup?.call();

    Navigator.of(context, rootNavigator: widget.rootNavigator)
        .push(
          _PopupRoute<T>(
            context: context,
            targetRect: offset & renderBox.paintBounds.size,
            backgroundColor: widget.backgroundColor,
            arrowColor: widget.arrowColor,
            showArrow: widget.showArrow,
            barriersColor: widget.barrierColor,
            contentPadding: widget.contentPadding,
            contentRadius: widget.contentRadius,
            contentDecoration: widget.contentDecoration,
            position: widget.position,
            animationDuration: widget.animationDuration,
            animationCurve: widget.animationCurve,
            child: widget.content,
          ),
        )
        .then((value) => widget.onAfterPopup?.call(value));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: widget.isLongPress ? () => show() : null,
      onTapUp: !widget.isLongPress ? (_) => show() : null,
      child: widget.child,
    );
  }
}

/// Internal widget for rendering the popup content and arrow.
class _PopupContent extends StatelessWidget {
  final Widget child;
  final GlobalKey childKey;
  final GlobalKey arrowKey;
  final _ArrowDirection arrowDirection;
  final double arrowHorizontal;
  final Color? backgroundColor;
  final Color? arrowColor;
  final bool showArrow;
  final EdgeInsets? padding;
  final double? contentRadius;

  const _PopupContent({
    required this.child,
    required this.childKey,
    required this.arrowKey,
    required this.arrowHorizontal,
    required this.showArrow,
    this.arrowDirection = _ArrowDirection.top,
    this.arrowColor,
    this.contentRadius,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          key: childKey,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(contentRadius ?? 10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 11,
                offset: Offset(0, 5),
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(vertical: 10).copyWith(
            top: arrowDirection == _ArrowDirection.bottom ? 0 : null,
            bottom: arrowDirection == _ArrowDirection.top ? 0 : null,
          ),
          child: child,
        ),
        Positioned(
          top: arrowDirection == _ArrowDirection.top ? 2 : null,
          bottom: arrowDirection == _ArrowDirection.bottom ? 2 : null,
          left: arrowHorizontal,
          child: RotatedBox(
            key: arrowKey,
            quarterTurns: arrowDirection == _ArrowDirection.top ? 2 : 4,
            child: CustomPaint(
              size: showArrow ? const Size(16, 8) : Size.zero,
              painter: _TrianglePainter(color: arrowColor ?? Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the popup arrow.
class _TrianglePainter extends CustomPainter {
  final Color color;

  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();
    paint.isAntiAlias = true;
    paint.color = color;

    path.lineTo(size.width * 0.66, size.height * 0.86);
    path.cubicTo(
      size.width * 0.58,
      size.height * 1.05,
      size.width * 0.42,
      size.height * 1.05,
      size.width * 0.34,
      size.height * 0.86,
    );
    path.cubicTo(size.width * 0.34, size.height * 0.86, 0, 0, 0, 0);
    path.cubicTo(0, 0, size.width, 0, size.width, 0);
    path.cubicTo(
      size.width,
      0,
      size.width * 0.66,
      size.height * 0.86,
      size.width * 0.66,
      size.height * 0.86,
    );
    path.cubicTo(
      size.width * 0.66,
      size.height * 0.86,
      size.width * 0.66,
      size.height * 0.86,
      size.width * 0.66,
      size.height * 0.86,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is! _TrianglePainter || oldDelegate.color != color;
  }
}

/// Popup route for displaying the popup overlay.
class _PopupRoute<T> extends PopupRoute<T> {
  final Rect targetRect;
  final TrinaPopupPosition position;
  final Widget child;
  final Duration animationDuration;
  final Curve animationCurve;

  static const double _margin = 10;
  static const double _mobileWidthThreshold = 600;

  late final ScreenUtil screenUtil = ScreenUtil(
    mediaQuery: MediaQuery.of(context),
  );

  late final Rect _viewportRect = Rect.fromLTWH(
    _margin,
    screenUtil.statusBar + _margin,
    screenUtil.width - _margin * 2,
    screenUtil.height -
        screenUtil.statusBar -
        screenUtil.bottomBar -
        _margin * 2,
  );

  final GlobalKey _childKey = GlobalKey();
  final GlobalKey _arrowKey = GlobalKey();
  final Color? backgroundColor;
  final Color? arrowColor;
  final bool showArrow;
  final Color? barriersColor;
  final EdgeInsets contentPadding;
  final double? contentRadius;
  final BoxDecoration? contentDecoration;
  final BuildContext context;

  late double _maxHeight = _viewportRect.height;
  _ArrowDirection _arrowDirection = _ArrowDirection.top;
  double _arrowHorizontal = 0;
  double _scaleAlignDx = 0.5;
  double _scaleAlignDy = 0.5;
  double? _bottom;
  double? _top;
  double? _left;
  double? _right;
  bool _isCentered = false;

  _PopupRoute({
    required this.child,
    required this.targetRect,
    this.backgroundColor,
    this.arrowColor,
    required this.showArrow,
    this.barriersColor,
    required this.contentPadding,
    this.contentRadius,
    this.contentDecoration,
    this.position = TrinaPopupPosition.auto,
    required this.animationDuration,
    required this.context,
    this.animationCurve = Curves.easeInOut,
  });

  @override
  Color? get barrierColor =>
      barriersColor ?? Colors.black.withAlpha((0.1 * 255).round());

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Popup';

  @override
  TickerFuture didPush() {
    super.offstage = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (screenUtil.width < _mobileWidthThreshold) {
        _isCentered = true;
      }

      final childRect = _getRect(_childKey);
      final arrowRect = _getRect(_arrowKey);

      if (_isCentered) {
        _calculateCenteredOffset(childRect);
      } else {
        _calculateArrowOffset(arrowRect, childRect);
        _calculateChildOffset(childRect);
      }
      super.offstage = false;
    });
    return super.didPush();
  }

  /// Gets the rectangle for a widget by key.
  Rect? _getRect(GlobalKey key) {
    final currentContext = key.currentContext;
    final renderBox = currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || currentContext == null) return null;
    final offset = renderBox.localToGlobal(renderBox.paintBounds.topLeft);
    var rect = offset & renderBox.paintBounds.size;

    if (Directionality.of(currentContext) == TextDirection.rtl) {
      rect = Rect.fromLTRB(0, rect.top, rect.right - rect.left, rect.bottom);
    }

    return rect;
  }

  void _calculateCenteredOffset(Rect? childRect) {
    if (childRect == null) return;

    _maxHeight = _viewportRect.height;
    _top = _viewportRect.top + (_viewportRect.height - childRect.height) / 2;
    _left = _viewportRect.left + (_viewportRect.width - childRect.width) / 2;

    _scaleAlignDx = 0.5;
    _scaleAlignDy = 0.5;
  }

  /// Calculate the horizontal position of the arrow.
  void _calculateArrowOffset(Rect? arrowRect, Rect? childRect) {
    if (childRect == null || arrowRect == null) return;
    // Calculate the distance from the left side of the screen based on the middle position of the target and the popover layer
    var leftEdge = targetRect.center.dx - childRect.center.dx;
    final rightEdge = leftEdge + childRect.width;
    leftEdge = leftEdge < _viewportRect.left ? _viewportRect.left : leftEdge;
    // If it exceeds the screen, subtract the excess part
    if (rightEdge > _viewportRect.right) {
      leftEdge -= rightEdge - _viewportRect.right;
    }
    final center = targetRect.center.dx - leftEdge - arrowRect.center.dx;
    // Prevent the arrow from extending beyond the padding of the popover
    if (center + arrowRect.center.dx > childRect.width - 15) {
      _arrowHorizontal = center - 15;
    } else if (center < 15) {
      _arrowHorizontal = 15;
    } else {
      _arrowHorizontal = center;
    }

    _scaleAlignDx = (_arrowHorizontal + arrowRect.center.dx) / childRect.width;
  }

  /// Calculate the position of the popover.
  void _calculateChildOffset(Rect? childRect) {
    if (childRect == null) return;

    final topHeight = targetRect.top - _viewportRect.top;
    final bottomHeight = _viewportRect.bottom - targetRect.bottom;
    final maximum = math.max(topHeight, bottomHeight);
    _maxHeight = childRect.height > maximum ? maximum : childRect.height;
    _maxHeight = _maxHeight.clamp(
      0.0,
      double.infinity,
    ); // Prevent negative height

    if (position == TrinaPopupPosition.top ||
        (position == TrinaPopupPosition.auto && _maxHeight > bottomHeight)) {
      _bottom = screenUtil.height - targetRect.top;
      _arrowDirection = _ArrowDirection.bottom;
      _scaleAlignDy = 1;
    } else {
      _top = targetRect.bottom;
      _arrowDirection = _ArrowDirection.top;
      _scaleAlignDy = 0;
    }

    final left = targetRect.center.dx - childRect.center.dx;
    final right = left + childRect.width;
    if (right > _viewportRect.right) {
      _right = _margin;
    } else {
      _left = left < _margin ? _margin : left;
    }
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    child = _PopupContent(
      childKey: _childKey,
      arrowKey: _arrowKey,
      arrowHorizontal: _arrowHorizontal,
      arrowDirection: _arrowDirection,
      backgroundColor: backgroundColor,
      arrowColor: arrowColor,
      showArrow: showArrow && !_isCentered,
      contentRadius: contentRadius,
      padding: contentPadding,
      child: child,
    );
    if (!animation.isCompleted) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: animationCurve,
      );
      child = FadeTransition(
        opacity: curvedAnimation,
        child: ScaleTransition(
          alignment: FractionalOffset(_scaleAlignDx, _scaleAlignDy),
          scale: curvedAnimation,
          child: child,
        ),
      );
    }
    return Stack(
      children: [
        Positioned(
          left: _left,
          right: _right,
          top: _top,
          bottom: _bottom,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: _viewportRect.width,
              maxHeight: _maxHeight,
            ),
            child: Material(
              color: Colors.transparent,
              type: MaterialType.transparency,
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Duration get transitionDuration => animationDuration;
}

/// Utility class for screen metrics.
class ScreenUtil {
  final MediaQueryData mediaQuery;

  const ScreenUtil({required this.mediaQuery});

  /// Screen width in logical pixels.
  double get width => mediaQuery.size.width;

  /// Screen height in logical pixels.
  double get height => mediaQuery.size.height;

  /// Device pixel ratio.
  double get scale => mediaQuery.devicePixelRatio;

  /// Top padding (status bar height).
  double get statusBar => mediaQuery.padding.top;

  /// Bottom padding (system navigation bar height).
  double get bottomBar => mediaQuery.padding.bottom;
}
