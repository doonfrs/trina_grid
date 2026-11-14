import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class ColumnTitleRendererScreen extends StatefulWidget {
  static const routeName = 'feature/column-title-renderer';

  const ColumnTitleRendererScreen({super.key});

  @override
  _ColumnTitleRendererScreenState createState() =>
      _ColumnTitleRendererScreenState();
}

class _ColumnTitleRendererScreenState extends State<ColumnTitleRendererScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  late TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'Standard Column',
        field: 'column1',
        type: TrinaColumnType.text(),
        width: 180,
      ),
      TrinaColumn(
        title: 'Custom Title',
        field: 'column2',
        type: TrinaColumnType.text(),
        width: 200,
        backgroundColor: Colors.blue.shade50,
        titleRenderer: (rendererContext) {
          return Container(
            width: rendererContext.column.width,
            height: rendererContext.height,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                right: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Custom Title',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (rendererContext.showContextIcon)
                  rendererContext.contextMenuIcon,
              ],
            ),
          );
        },
      ),
      TrinaColumn(
        title: 'With Icon',
        field: 'column3',
        type: TrinaColumnType.text(),
        width: 150,
        titleRenderer: (rendererContext) {
          return Container(
            width: rendererContext.column.width,
            height: rendererContext.height,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                right: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rendererContext.column.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (rendererContext.showContextIcon)
                  rendererContext.contextMenuIcon,
              ],
            ),
          );
        },
      ),
      TrinaColumn(
        title: 'Multi-line Title',
        field: 'column4',
        type: TrinaColumnType.text(),
        width: 180,
        titleRenderer: (rendererContext) {
          return Container(
            width: rendererContext.column.width,
            height: rendererContext.height,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border(
                right: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Multi-line',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  'Title',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ],
            ),
          );
        },
      ),
      TrinaColumn(
        title: 'With Badge',
        field: 'column5',
        type: TrinaColumnType.text(),
        width: 160,
        titleRenderer: (rendererContext) {
          return Container(
            width: rendererContext.column.width,
            height: rendererContext.height,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                right: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    rendererContext.column.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (rendererContext.showContextIcon) SizedBox(width: 8),
                if (rendererContext.showContextIcon)
                  rendererContext.contextMenuIcon,
              ],
            ),
          );
        },
      ),
    ]);

    rows.addAll(DummyData.rowsByColumns(length: 15, columns: columns));
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Column Title Renderer',
      topTitle: 'Column Title Renderer',
      topContents: const [
        Text('You can fully customize column titles using titleRenderer.'),
        SizedBox(height: 8),
        Text(
          'The titleRenderer property allows you to create custom title widgets for each column, while still supporting core functionality like sorting, context menus, and column dragging.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/column_title_renderer_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onChanged: (TrinaGridOnChangedEvent event) {
          print(event);
        },
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
        },
      ),
    );
  }
}
