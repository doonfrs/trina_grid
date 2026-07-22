import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:trina_grid/src/ui/widgets/ensure_shad_theme.dart';
import 'package:trina_grid/trina_grid.dart';

/// Chrome for the record sidebar panel.
///
/// Provides the panel background and a left border (from the shadcn theme)
/// around its [child] (the built-in record view or a custom builder result).
/// Wraps the subtree in [EnsureShadTheme] so shadcn widgets work even when the
/// host app is a plain `MaterialApp`.
class TrinaSidebarContainer extends StatelessWidget {
  const TrinaSidebarContainer({
    super.key,
    required this.stateManager,
    required this.child,
  });

  final TrinaGridStateManager stateManager;

  /// The sidebar content (built-in record view or a custom builder result).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return EnsureShadTheme(
      child: Builder(
        builder: (context) {
          final colors = ShadTheme.of(context).colorScheme;

          return FocusTraversalGroup(
            child: Container(
              decoration: BoxDecoration(
                color: colors.background,
                border: Border(left: BorderSide(color: colors.border)),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

/// The built-in record view for the sidebar.
///
/// Lists every field of the grid's currently selected/active row as a
/// `label -> value` list, with a search box to filter fields. Tapping a
/// (non read-only) field edits it using the grid's own per-type editor
/// (text, number, date, boolean, select, ...), so editing behaves exactly like
/// editing the cell in the grid - including any custom `editCellRenderer` or
/// custom column types.
///
/// The editor is shown for one field at a time, tracked by sidebar-local state.
/// The grid's editing state is deliberately NOT enabled for the cell: doing so
/// would make the grid body render a second editor for the same cell, and the
/// two editors would fight over focus.
class TrinaSidebar extends StatefulWidget {
  const TrinaSidebar({
    super.key,
    required this.stateManager,
    this.showCloseButton = false,
  });

  final TrinaGridStateManager stateManager;

  /// Whether to show a close button next to the search field (floating mode).
  final bool showCloseButton;

  @override
  State<TrinaSidebar> createState() => _TrinaSidebarState();
}

class _TrinaSidebarState extends State<TrinaSidebar> {
  TrinaGridStateManager get stateManager => widget.stateManager;

  /// Current field search query (lower-cased).
  String _query = '';

  /// The column field currently edited in the sidebar, or null when none.
  String? _editingField;

  // Mirrors of the grid state used to decide when to rebuild.
  Key? _rowKey;
  int? _rowVersion;

  @override
  void initState() {
    super.initState();
    _rowKey = stateManager.currentRow?.key;
    _rowVersion = stateManager.currentRow?.version;
    stateManager.addListener(_onGridChanged);
  }

  @override
  void dispose() {
    stateManager.removeListener(_onGridChanged);
    super.dispose();
  }

  /// Rebuild when the active row changes, a cell value in the row changes, or
  /// the grid takes over editing/moves its current cell away from the field
  /// being edited here (which exits the sidebar edit state).
  void _onGridChanged() {
    final row = stateManager.currentRow;
    final rowKey = row?.key;
    final rowVersion = row?.version;

    bool changed = false;

    if (rowKey != _rowKey) {
      _rowKey = rowKey;
      _editingField = null;
      changed = true;
    }

    if (rowVersion != _rowVersion) {
      _rowVersion = rowVersion;
      changed = true;
    }

    if (_editingField != null) {
      final editedCell = row?.cells[_editingField!];
      final gridTookOver =
          stateManager.isEditing ||
          editedCell == null ||
          stateManager.currentCell?.key != editedCell.key;
      if (gridTookOver) {
        _editingField = null;
        changed = true;
      }
    }

    if (changed) _safeRebuild();
  }

  /// Rebuilds now, or after the current frame when notified mid-frame (e.g.
  /// an unmounting editor committing its pending value from dispose notifies
  /// listeners synchronously while the framework is locked).
  void _safeRebuild() {
    if (!mounted) return;

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  /// Starts editing [cell] in the sidebar with the grid's per-type editor.
  ///
  /// Makes the cell the grid's current cell (so the grid highlights it and
  /// editor internals that reference `currentCell` target the right cell) and
  /// restores grid focus so the editor auto-focuses - but does NOT enable the
  /// grid's editing state, which would render a duplicate editor in the grid.
  void _editField(TrinaColumn column, TrinaCell cell) {
    final rowIdx = stateManager.currentRowIdx;
    if (rowIdx == null) return;

    if (!stateManager.hasFocus) {
      stateManager.setKeepFocus(true);
    }
    if (stateManager.isEditing) {
      stateManager.setEditing(false, notify: false);
    }
    stateManager.setCurrentCell(cell, rowIdx);

    setState(() => _editingField = column.field);
  }

  bool _isTextFamily(TrinaColumnType type) {
    return type.isText ||
        type.isNumber ||
        type.isCurrency ||
        type.isPercentage ||
        type.isCustom;
  }

  @override
  Widget build(BuildContext context) {
    final shad = ShadTheme.of(context);
    final colors = shad.colorScheme;
    final row = stateManager.currentRow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            children: [
              Expanded(child: _buildSearchField(colors)),
              if (widget.showCloseButton)
                ShadIconButton.ghost(
                  icon: const Icon(LucideIcons.x),
                  onPressed: stateManager.hideSidebar,
                ),
            ],
          ),
        ),
        Expanded(
          child: row == null
              ? _buildEmptyState(colors)
              : _buildFields(shad, colors, row),
        ),
      ],
    );
  }

  Widget _buildSearchField(ShadColorScheme colors) {
    // A plain Material [TextField] is used here (rather than shadcn's
    // ShadInput) because ShadInput does not receive keyboard text input on
    // Flutter web when accessibility semantics are enabled (see issue #394).
    // It is styled from the shad color scheme to stay visually consistent.
    return TextField(
      style: TextStyle(fontSize: 14, color: colors.foreground),
      decoration: InputDecoration(
        hintText: 'Search for field...',
        hintStyle: TextStyle(color: colors.mutedForeground),
        prefixIcon: Icon(
          LucideIcons.search,
          size: 16,
          color: colors.mutedForeground,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.ring),
        ),
      ),
      onChanged: (value) {
        setState(() => _query = value.trim().toLowerCase());
      },
    );
  }

  Widget _buildEmptyState(ShadColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Select a row to view its fields.',
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.mutedForeground),
        ),
      ),
    );
  }

  Widget _buildFields(
    ShadThemeData shad,
    ShadColorScheme colors,
    TrinaRow row,
  ) {
    final columns = stateManager.columns.where((column) {
      if (_query.isEmpty) return true;
      final value = row.cells[column.field]?.value?.toString() ?? '';
      return column.title.toLowerCase().contains(_query) ||
          column.field.toLowerCase().contains(_query) ||
          value.toLowerCase().contains(_query);
    }).toList();

    if (columns.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No fields match "$_query".',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.mutedForeground),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: columns.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _buildFieldRow(shad, colors, row, columns[index]),
    );
  }

  Widget _buildFieldRow(
    ShadThemeData shad,
    ShadColorScheme colors,
    TrinaRow row,
    TrinaColumn column,
  ) {
    final cell = row.cells[column.field];
    if (cell == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                column.title,
                style: TextStyle(fontSize: 12, color: colors.mutedForeground),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (column.readOnly)
              Icon(LucideIcons.lock, size: 12, color: colors.mutedForeground),
          ],
        ),
        const SizedBox(height: 4),
        _buildValue(shad, colors, row, column, cell),
      ],
    );
  }

  Widget _buildValue(
    ShadThemeData shad,
    ShadColorScheme colors,
    TrinaRow row,
    TrinaColumn column,
    TrinaCell cell,
  ) {
    // When this field is being edited, render the grid's own per-type editor.
    if (_editingField == column.field) {
      Widget editor = column.type.buildCell(stateManager, cell, column, row);

      if (_isTextFamily(column.type)) {
        // Exit the edit state when the text editor loses focus. Unmounting the
        // editor flushes its pending change (its dispose commits the value).
        // Popup editors (select/boolean/date/time) must NOT exit on blur:
        // their popup overlay takes focus while they are in use.
        editor = Focus(
          skipTraversal: true,
          onFocusChange: (hasFocus) {
            if (!hasFocus && _editingField == column.field && mounted) {
              setState(() => _editingField = null);
            }
          },
          child: editor,
        );
      }

      return Container(
        height: stateManager.rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: colors.ring),
          borderRadius: shad.radius,
        ),
        clipBehavior: Clip.hardEdge,
        child: editor,
      );
    }

    final displayValue = column.formattedValueForDisplay(cell.value);

    return GestureDetector(
      key: ValueKey('trina_sidebar_field_${column.field}'),
      behavior: HitTestBehavior.opaque,
      onTap: column.readOnly ? null : () => _editField(column, cell),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: stateManager.rowHeight),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: column.readOnly ? colors.muted : null,
          border: Border.all(color: colors.border),
          borderRadius: shad.radius,
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          displayValue,
          style: TextStyle(
            color: column.readOnly ? colors.mutedForeground : colors.foreground,
          ),
        ),
      ),
    );
  }
}
