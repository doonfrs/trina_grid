import 'package:demo/dummy_data/development.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ColumnMenuScreen extends StatefulWidget {
  static const routeName = 'feature/column-menu';

  const ColumnMenuScreen({super.key});

  @override
  _ColumnMenuScreenState createState() => _ColumnMenuScreenState();
}

class _ColumnMenuScreenState extends State<ColumnMenuScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 100);

    columns.addAll(dummyData.columns);

    rows.addAll(dummyData.rows);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Column menu',
      topTitle: 'Column menu',
      topContents: const [
        Text('You can customize the menu on the right side of the column.'),
        Text('A different menu can be displayed for each column.'),
        Text(
          'You can also customize the menu items. For example, you can remove the from the default menu.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/column_menu_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        columnMenuDelegate: UserColumnMenuDelegate(),
      ),
    );
  }
}

/// A delegate that combines default column menu with custom items
class UserColumnMenuDelegate implements TrinaColumnMenuDelegate<dynamic> {
  // Custom menu item keys
  static const String moveNextKey = 'moveNext';
  static const String movePreviousKey = 'movePrevious';

  // Default delegate to handle standard menu items
  final TrinaColumnMenuDelegateDefault _defaultDelegate =
      const TrinaColumnMenuDelegateDefault();

  @override
  List<PopupMenuEntry<dynamic>> buildMenuItems({
    required TrinaGridStateManager stateManager,
    required TrinaColumn column,
  }) {
    // Get default menu items
    final defaultItems = _defaultDelegate.buildMenuItems(
      stateManager: stateManager,
      column: column,
    );

    //remove the unfreeze item
    defaultItems.removeWhere((element) {
      if (element is PopupMenuItem<String>) {
        return element.value ==
            TrinaColumnMenuDelegateDefault.defaultMenuFreezeToStart;
      }
      return false;
    });

    // Add custom menu items (with a divider if there are default items)
    return [
      ...defaultItems,
      if (defaultItems.isNotEmpty) const PopupMenuDivider(),

      if (column.field == '0')
        PopupMenuItem<String>(
          value: 'Only show in first column',
          height: 36,
          enabled: true,
          child: Container(
            color: Colors.amber,
            child: Text(
              'Only show in first column',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ),

      // Custom menu items
      if (column.key != stateManager.columns.last.key)
        const PopupMenuItem<String>(
          value: moveNextKey,
          height: 36,
          enabled: true,
          child: Text('Move next', style: TextStyle(fontSize: 13)),
        ),
      if (column.key != stateManager.columns.first.key)
        const PopupMenuItem<String>(
          value: movePreviousKey,
          height: 36,
          enabled: true,
          child: Text('Move previous', style: TextStyle(fontSize: 13)),
        ),
    ];
  }

  @override
  void onSelected({
    required BuildContext context,
    required TrinaGridStateManager stateManager,
    required TrinaColumn column,
    required bool mounted,
    required dynamic selected,
  }) {
    // Handle custom menu items first
    switch (selected) {
      case moveNextKey:
        final targetColumn = stateManager.columns
            .skipWhile((value) => value.key != column.key)
            .skip(1)
            .first;

        stateManager.moveColumn(column: column, targetColumn: targetColumn);
        break;
      case movePreviousKey:
        final targetColumn = stateManager.columns.reversed
            .skipWhile((value) => value.key != column.key)
            .skip(1)
            .first;

        stateManager.moveColumn(column: column, targetColumn: targetColumn);
        break;
      default:
        _defaultDelegate.onSelected(
          context: context,
          stateManager: stateManager,
          column: column,
          mounted: mounted,
          selected: selected,
        );
    }
  }
}
