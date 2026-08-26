import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A [ScrollPhysics] that applies different physics to each scroll axis.
///
/// [ScrollBehavior.getScrollPhysics] resolves a single [ScrollPhysics] for
/// every [Scrollable] beneath a [ScrollConfiguration], with no way to tell the
/// axes apart. Every [ScrollPhysics] method that makes a decision does receive
/// [ScrollMetrics] though, and those metrics know their own
/// [ScrollMetrics.axis], so one physics object can dispatch per axis.
///
/// TrinaGrid uses this internally when `TrinaGrid.horizontalScrollPhysics` or
/// `TrinaGrid.verticalScrollPhysics` is set. The common case is a grid placed
/// inside a scrolling page, where the page should own vertical scrolling while
/// the grid keeps its horizontal scrolling:
///
/// ```dart
/// TrinaGrid(
///   columns: columns,
///   rows: rows,
///   fitContent: true,
///   verticalScrollPhysics: const NeverScrollableScrollPhysics(),
/// )
/// ```
///
/// It can also be used directly wherever a [ScrollPhysics] is accepted:
///
/// ```dart
/// TrinaAxisScrollPhysics(
///   horizontal: const BouncingScrollPhysics(),
///   vertical: const NeverScrollableScrollPhysics(),
/// )
/// ```
///
/// Only the members that receive [ScrollMetrics] can be dispatched per axis.
/// The axis-agnostic ones ([spring], [minFlingDistance], [minFlingVelocity],
/// [maxFlingVelocity], [carriedMomentum], [dragStartDistanceMotionThreshold])
/// keep the inherited behavior and defer to [parent], so fling and spring
/// tuning follows the ambient physics rather than [horizontal] or [vertical].
/// In practice none of Flutter's built-in physics differ through those members.
class TrinaAxisScrollPhysics extends ScrollPhysics {
  const TrinaAxisScrollPhysics({
    required this.horizontal,
    required this.vertical,
    super.parent,
  });

  /// Physics applied to scroll positions on [Axis.horizontal].
  final ScrollPhysics horizontal;

  /// Physics applied to scroll positions on [Axis.vertical].
  final ScrollPhysics vertical;

  ScrollPhysics _forAxis(Axis axis) =>
      axis == Axis.horizontal ? horizontal : vertical;

  @override
  TrinaAxisScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return TrinaAxisScrollPhysics(
      horizontal: horizontal.applyTo(ancestor),
      vertical: vertical.applyTo(ancestor),
      parent: buildParent(ancestor),
    );
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return _forAxis(position.axis).shouldAcceptUserOffset(position);
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return _forAxis(position.axis).applyPhysicsToUserOffset(position, offset);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    return _forAxis(position.axis).applyBoundaryConditions(position, value);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    return _forAxis(
      position.axis,
    ).createBallisticSimulation(position, velocity);
  }

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    return _forAxis(newPosition.axis).adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );
  }

  @override
  bool recommendDeferredLoading(
    double velocity,
    ScrollMetrics metrics,
    BuildContext context,
  ) {
    return _forAxis(
      metrics.axis,
    ).recommendDeferredLoading(velocity, metrics, context);
  }

  @override
  Tolerance toleranceFor(ScrollMetrics metrics) {
    return _forAxis(metrics.axis).toleranceFor(metrics);
  }

  /// The base implementation returns a bare `true` without deferring to
  /// [parent], so it has to be combined here. Otherwise a grid whose axes are
  /// both blocked would still advertise implicit scrolling to accessibility.
  @override
  bool get allowImplicitScrolling =>
      horizontal.allowImplicitScrolling || vertical.allowImplicitScrolling;

  @override
  String toString() {
    return '${objectRuntimeType(this, 'TrinaAxisScrollPhysics')}'
        '(horizontal: $horizontal, vertical: $vertical)';
  }
}
