import 'package:material_ui/material_ui.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class CurrencyTypeColumnScreen extends StatefulWidget {
  static const routeName = 'feature/currency-type-column';

  const CurrencyTypeColumnScreen({super.key});

  @override
  _CurrencyTypeColumnScreenState createState() =>
      _CurrencyTypeColumnScreenState();
}

class _CurrencyTypeColumnScreenState extends State<CurrencyTypeColumnScreen> {
  final List<TrinaColumn> columns = [];

  final List<TrinaRow> rows = [];

  late TrinaGridStateManager stateManager;

  Widget currencyRenderer(TrinaColumnRendererContext ctx) {
    assert(ctx.column.type.isCurrency);

    Color color = Colors.black;

    if (ctx.cell.value > 0) {
      color = Colors.blue;
    } else if (ctx.cell.value < 0) {
      color = Colors.red;
    }

    return Text(
      ctx.column.type.applyFormat(ctx.cell.value),
      style: TextStyle(color: color),
      textAlign: TextAlign.end,
    );
  }

  @override
  void initState() {
    super.initState();

    columns.addAll([
      TrinaColumn(
        title: 'column1',
        field: 'column1',
        renderer: currencyRenderer,
        textAlign: TrinaColumnTextAlign.end,
        type: TrinaColumnType.currency(),
      ),
      TrinaColumn(
        title: 'column2',
        field: 'column2',
        renderer: currencyRenderer,
        textAlign: TrinaColumnTextAlign.end,
        type: TrinaColumnType.currency(name: '(USD) '),
      ),
      TrinaColumn(
        title: 'column3',
        field: 'column3',
        renderer: currencyRenderer,
        textAlign: TrinaColumnTextAlign.end,
        type: TrinaColumnType.currency(
          locale: 'ko',
          name: '원',
          decimalDigits: 0,
          format: '#,###.## \u00A4',
          negative: false,
        ),
      ),
      TrinaColumn(
        title: 'column4',
        field: 'column4',
        renderer: currencyRenderer,
        textAlign: TrinaColumnTextAlign.end,
        type: TrinaColumnType.currency(
          locale: 'fr_FR',
          symbol: '€',
          format: '\u00A4 #,###.##',
        ),
      ),
      TrinaColumn(
        title: 'column5',
        field: 'column5',
        renderer: currencyRenderer,
        textAlign: TrinaColumnTextAlign.end,
        type: TrinaColumnType.currency(locale: 'da'),
      ),
    ]);

    rows.addAll(DummyData.rowsByColumns(length: 30, columns: columns));
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Currency type column',
      topTitle: 'Currency type column',
      topContents: const [
        Text('A column to enter a number as currency value.'),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/currency_type_column_screen.dart',
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
          stateManager.setShowColumnFilter(true);
        },
      ),
    );
  }
}
