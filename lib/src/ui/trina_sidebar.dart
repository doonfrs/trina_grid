import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

/// Chrome for the record sidebar panel.
///
/// Provides the panel background and a left border from the grid style around
/// its [child] (the built-in record view or a custom builder result).
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
    final style = stateManager.style;

    return FocusTraversalGroup(
      child: Container(
        decoration: BoxDecoration(
          color: style.gridBackgroundColor,
          border: Border(
            left: BorderSide(
              color: style.gridBorderColor,
              width: style.gridBorderWidth,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// The built-in record view for the sidebar.
///
/// Lists every field of the grid's currently selected/active row as a
/// `label -> value` list, with a search box to filter fields and inline editing
/// that writes changes back to the grid.
///
/// It subscribes to the [TrinaGridStateManager] and rebuilds its field editors
/// whenever the active row changes.
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

  /// Controllers/focus nodes keyed by column field, rebuilt on row change.
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  /// The key of the row currently shown, used to detect row changes.
  Key? _currentRowKey;

  /// Current field search query (lower-cased).
  String _query = '';

  @override
  void initState() {
    super.initState();
    _currentRowKey = stateManager.currentRow?.key;
    _rebuildControllers();
    stateManager.addListener(_onGridChanged);
  }

  @override
  void dispose() {
    stateManager.removeListener(_onGridChanged);
    _disposeControllers();
    super.dispose();
  }

  /// Fires on any grid state change. We only rebuild when the active row
  /// changes so that in-progress typing is never clobbered and edits that
  /// themselves trigger a notification do not cause a rebuild loop.
  void _onGridChanged() {
    final newKey = stateManager.currentRow?.key;
    if (newKey != _currentRowKey) {
      _currentRowKey = newKey;
      _rebuildControllers();
      if (mounted) setState(() {});
    }
  }

  void _disposeControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    _controllers.clear();
    _focusNodes.clear();
  }

  void _rebuildControllers() {
    _disposeControllers();

    final row = stateManager.currentRow;
    if (row == null) return;

    for (final column in stateManager.columns) {
      final value = row.cells[column.field]?.value;
      _controllers[column.field] = TextEditingController(
        text: value?.toString() ?? '',
      );

      final node = FocusNode();
      node.addListener(() {
        // Commit the value when the field loses focus.
        if (!node.hasFocus) _commit(column);
      });
      _focusNodes[column.field] = node;
    }
  }

  /// Writes the edited text back to the grid cell.
  void _commit(TrinaColumn column) {
    if (column.readOnly) return;

    final row = stateManager.currentRow;
    if (row == null) return;

    final cell = row.cells[column.field];
    final controller = _controllers[column.field];
    if (cell == null || controller == null) return;

    final text = controller.text;
    if ((cell.value?.toString() ?? '') == text) return;

    // changeCellValue casts the text according to the column type.
    stateManager.changeCellValue(cell, text);

    // Re-sync the field with the stored value (it may be reformatted, e.g.
    // number/currency columns).
    final storedText = cell.value?.toString() ?? '';
    if (controller.text != storedText) {
      controller.text = storedText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = stateManager.style;
    final row = stateManager.currentRow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            children: [
              Expanded(child: _buildSearchField(style)),
              if (widget.showCloseButton)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: style.iconColor,
                    size: style.iconSize,
                  ),
                  tooltip: 'Hide sidebar',
                  visualDensity: VisualDensity.compact,
                  onPressed: stateManager.hideSidebar,
                ),
            ],
          ),
        ),
        Expanded(
          child: row == null
              ? _buildEmptyState(style)
              : _buildFields(style, row),
        ),
      ],
    );
  }

  Widget _buildSearchField(TrinaGridStyleConfig style) {
    return TextField(
      style: style.cellTextStyle,
      decoration: InputDecoration(
        hintText: 'Search for field...',
        prefixIcon: Icon(Icons.search, color: style.iconColor),
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() => _query = value.trim().toLowerCase());
      },
    );
  }

  Widget _buildEmptyState(TrinaGridStyleConfig style) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Select a row to view its fields.',
          textAlign: TextAlign.center,
          style: style.cellTextStyle.copyWith(
            color: style.cellTextStyle.color?.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildFields(TrinaGridStyleConfig style, TrinaRow row) {
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
            style: style.cellTextStyle.copyWith(
              color: style.cellTextStyle.color?.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: columns.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildFieldRow(style, columns[index]),
    );
  }

  Widget _buildFieldRow(TrinaGridStyleConfig style, TrinaColumn column) {
    final controller = _controllers[column.field];
    final labelColor = style.cellTextStyle.color?.withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                column.title,
                style: style.cellTextStyle.copyWith(
                  fontSize: (style.cellTextStyle.fontSize ?? 14) - 2,
                  color: labelColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (column.readOnly)
              Icon(Icons.lock_outline, size: 14, color: labelColor),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          focusNode: _focusNodes[column.field],
          readOnly: column.readOnly,
          style: style.cellTextStyle,
          decoration: InputDecoration(
            isDense: true,
            filled: column.readOnly,
            fillColor: column.readOnly ? style.cellColorInReadOnlyState : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _commit(column),
        ),
      ],
    );
  }
}
