import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

abstract class TrinaStatefulWidget extends StatefulWidget {
  const TrinaStatefulWidget({super.key});
}

abstract class TrinaStateWithChange<T extends TrinaStatefulWidget>
    extends State<T> {
  /// Subscribe to the event
  /// that is issued when a state change occurs in [TrinaGridStateManager].
  late final StreamSubscription _subscription;

  /// Contains filtering information
  /// so that only events related to widget change can be received.
  late final TrinaChangeNotifierFilter _filter;

  bool _initialized = false;

  bool _changed = false;

  bool get changed => _changed;

  StatefulElement? get _statefulElement =>
      mounted ? context as StatefulElement? : null;

  TrinaGridStateManager get stateManager;

  /// Called when a state change of [TrinaGridStateManager] occurs.
  ///
  /// Widgets in [TrinaGrid] that inherit this widget implement this method
  /// to decide whether to rebuild the widget according to the state change.
  ///
  /// By calling oldValue and newValue with the [update] method,
  /// rebuild the widget according to the value change.
  ///
  /// ```dart
  /// void updateState(TrinaNotifierEvent event) {
  ///   _showColumnFilter = update<bool>(
  ///     _showColumnFilter,
  ///     stateManager.showColumnFilter,
  ///   );
  /// }
  /// ```
  void updateState(TrinaNotifierEvent event) {}

  @override
  void initState() {
    super.initState();

    if (TrinaChangeNotifierFilter.enabled) {
      _filter = stateManager.resolveNotifierFilter<T>();
      _subscription = stateManager.streamNotifier.stream
          .where(_filter.any)
          .listen(_onChange);
    } else {
      _subscription = stateManager.streamNotifier.stream.listen(_onChange);
    }

    _initialized = true;
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void dispose() {
    _subscription.cancel();

    super.dispose();
  }

  /// Call within the [updateState] method to determine the rebuild
  /// of the widget according to the state change.
  U update<U>(
    U oldValue,
    U newValue, {
    bool Function(U a, U b)? compare,
    bool? ignoreChange = false,
  }) {
    if (oldValue == null) {
      _changed = true;
    } else if (ignoreChange == false && _changed == false) {
      _changed = compare == null
          ? oldValue != newValue
          : compare(oldValue, newValue) == false;
    }

    return newValue;
  }

  /// Process to be rebuilt with steel regardless of state change.
  void forceUpdate() {
    _changed = true;
  }

  /// Called when a state change event occurs.
  ///
  /// Call [update] in [updateState] to handle rebuilding
  /// depending on whether the value has changed.
  void _onChange(TrinaNotifierEvent event) {
    bool rebuild = false;

    updateState(event);

    if (mounted && _initialized && _changed && stateManager.maxWidth != null) {
      rebuild = true;
      _changed = false;
      _statefulElement?.markNeedsBuild();
    }

    if (TrinaChangeNotifierFilter.printDebug) {
      _filter.printNotifierOnChange(event, rebuild);
    }
  }
}

mixin TrinaStateWithKeepAlive<T extends StatefulWidget>
    on AutomaticKeepAliveClientMixin<T> {
  bool _keepAlive = false;

  KeepAliveHandle? _keepAliveHandle;

  @override
  bool get wantKeepAlive => _keepAlive;

  void setKeepAlive(bool flag) {
    if (_keepAlive != flag) {
      _keepAlive = flag;

      updateKeepAlive();
    }
  }

  @override
  @protected
  void updateKeepAlive() {
    if (wantKeepAlive) {
      if (_keepAliveHandle == null) _ensureKeepAlive();
    } else {
      if (_keepAliveHandle != null) _releaseKeepAlive();
    }
  }

  void _ensureKeepAlive() {
    assert(_keepAliveHandle == null);
    _keepAliveHandle = KeepAliveHandle();
    KeepAliveNotification(_keepAliveHandle!).dispatch(context);
  }

  void _releaseKeepAlive() {
    _keepAliveHandle!.dispose();
    _keepAliveHandle = null;
  }
}
