import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/ui.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../mock/shared_mocks.mocks.dart';

/// Regression coverage for issue #367 (grid flickers when the column filter
/// row is enabled).
///
/// The per-column filter widgets ([TrinaColumnFilter]) and their host
/// ([TrinaBaseColumn]) used to be missing from the notifier-filter resolver,
/// so they fell through to an empty filter and reacted to *every* state event,
/// including cell navigation. These tests pin down that they now only react to
/// filter / column-structural events and ignore cell-navigation events.
void main() {
  late TrinaGridStateManager stateManager;

  setUp(() {
    final columns = [
      ...ColumnHelper.textColumn('column', count: 2, width: 150),
    ];
    final rows = RowHelper.count(10, columns);

    stateManager = TrinaGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: MockFocusNode(),
      scroll: MockTrinaGridScrollController(),
    );
  });

  TrinaNotifierEvent eventOf(int hash) => TrinaNotifierEvent({hash});

  group('TrinaColumnFilter notifier filter', () {
    test('ignores cell-navigation events', () {
      final filter = stateManager.resolveNotifierFilter<TrinaColumnFilter>();

      expect(
        filter.any(eventOf(stateManager.setCurrentCell.hashCode)),
        isFalse,
      );
      expect(
        filter.any(eventOf(stateManager.setCurrentCellPosition.hashCode)),
        isFalse,
      );
      expect(
        filter.any(eventOf(stateManager.updateCurrentCellPosition.hashCode)),
        isFalse,
      );
      expect(
        filter.any(eventOf(stateManager.clearCurrentCell.hashCode)),
        isFalse,
      );
    });

    test('reacts to filter and structural column changes', () {
      final filter = stateManager.resolveNotifierFilter<TrinaColumnFilter>();

      expect(filter.any(eventOf(stateManager.setFilter.hashCode)), isTrue);
      expect(
        filter.any(eventOf(stateManager.setShowColumnFilter.hashCode)),
        isTrue,
      );
      expect(filter.any(eventOf(stateManager.insertColumns.hashCode)), isTrue);
      expect(filter.any(eventOf(stateManager.removeColumns.hashCode)), isTrue);
      expect(filter.any(eventOf(stateManager.moveColumn.hashCode)), isTrue);
      expect(filter.any(eventOf(stateManager.hideColumn.hashCode)), isTrue);
    });
  });

  group('TrinaBaseColumn notifier filter', () {
    test('ignores cell-navigation events', () {
      final filter = stateManager.resolveNotifierFilter<TrinaBaseColumn>();

      expect(
        filter.any(eventOf(stateManager.setCurrentCell.hashCode)),
        isFalse,
      );
      expect(
        filter.any(eventOf(stateManager.setCurrentCellPosition.hashCode)),
        isFalse,
      );
    });

    test('reacts to show-column-filter toggling', () {
      final filter = stateManager.resolveNotifierFilter<TrinaBaseColumn>();

      expect(
        filter.any(eventOf(stateManager.setShowColumnFilter.hashCode)),
        isTrue,
      );
    });
  });
}
