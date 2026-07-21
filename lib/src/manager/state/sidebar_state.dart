import 'package:trina_grid/trina_grid.dart';

/// State for the record sidebar - a panel showing all fields of the currently
/// selected row, with a search box and inline editing.
///
/// Defaults (mode/width) come from [TrinaGridConfiguration.sidebar] until they
/// are overridden through the setters below.
abstract class ISidebarState {
  /// Whether the sidebar is currently visible.
  bool get isSidebarVisible;

  /// The current display mode (docked or floating).
  TrinaGridSidebarMode get sidebarMode;

  /// The current sidebar width in logical pixels.
  double get sidebarWidth;

  /// Show or hide the sidebar.
  ///
  /// Optionally set the [mode] at the same time. Does nothing when the sidebar
  /// feature is disabled via [TrinaGridConfiguration.sidebar].
  void setSidebarVisible(
    bool flag, {
    TrinaGridSidebarMode? mode,
    bool notify = true,
  });

  /// Set the sidebar display mode.
  void setSidebarMode(TrinaGridSidebarMode mode, {bool notify = true});

  /// Set the sidebar width.
  void setSidebarWidth(double width, {bool notify = true});

  /// Show the sidebar, optionally in the given [mode].
  void showSidebar({TrinaGridSidebarMode? mode});

  /// Hide the sidebar.
  void hideSidebar();

  /// Toggle the sidebar visibility, optionally setting the [mode] when showing.
  void toggleSidebar({TrinaGridSidebarMode? mode});
}

class _State {
  bool? _visible;

  TrinaGridSidebarMode? _mode;

  double? _width;
}

mixin SidebarState implements ITrinaGridState {
  final _State _state = _State();

  @override
  bool get isSidebarVisible => _state._visible ?? false;

  @override
  TrinaGridSidebarMode get sidebarMode =>
      _state._mode ?? configuration.sidebar.mode;

  @override
  double get sidebarWidth => _state._width ?? configuration.sidebar.width;

  @override
  void setSidebarVisible(
    bool flag, {
    TrinaGridSidebarMode? mode,
    bool notify = true,
  }) {
    if (!configuration.sidebar.enabled) {
      return;
    }

    final newMode = mode ?? sidebarMode;

    if (isSidebarVisible == flag && sidebarMode == newMode) {
      return;
    }

    _state._visible = flag;
    _state._mode = newMode;

    notifyListeners(notify, setSidebarVisible.hashCode);
  }

  @override
  void setSidebarMode(TrinaGridSidebarMode mode, {bool notify = true}) {
    if (sidebarMode == mode) {
      return;
    }

    _state._mode = mode;

    notifyListeners(notify, setSidebarMode.hashCode);
  }

  @override
  void setSidebarWidth(double width, {bool notify = true}) {
    if (sidebarWidth == width) {
      return;
    }

    _state._width = width;

    notifyListeners(notify, setSidebarWidth.hashCode);
  }

  @override
  void showSidebar({TrinaGridSidebarMode? mode}) {
    setSidebarVisible(true, mode: mode);
  }

  @override
  void hideSidebar() {
    setSidebarVisible(false);
  }

  @override
  void toggleSidebar({TrinaGridSidebarMode? mode}) {
    setSidebarVisible(!isSidebarVisible, mode: mode);
  }
}
