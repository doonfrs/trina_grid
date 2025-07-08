import 'package:trina_grid/trina_grid.dart';

class ColumnHelper {
  static TrinaColumn selectColumn(
    String title, {
    List<String> items = const [],
    bool enableAutoEditing = false,
    bool selectWithSingleTap = false,
  }) {
    return TrinaColumn(
      title: title,
      field: title,
      enableAutoEditing: enableAutoEditing,
      type: TrinaColumnType.select(
        items,
        selectWithSingleTap: selectWithSingleTap,
      ),
    );
  }

  static TrinaColumn booleanColumn(
    String title, {
    bool selectWithSingleTap = false,
  }) {
    return TrinaColumn(
      title: title,
      field: title,
      type: TrinaColumnType.boolean(
        selectWithSingleTap: selectWithSingleTap,
      ),
    );
  }

  static List<TrinaColumn> textColumn(
    String title, {
    int count = 1,
    int start = 0,
    double width = TrinaGridSettings.columnWidth,
    TrinaColumnFrozen frozen = TrinaColumnFrozen.none,
    bool readOnly = false,
    bool hide = false,
    dynamic defaultValue = '',
    TrinaColumnFooterRenderer? footerRenderer,
  }) {
    return Iterable<int>.generate(count).map((e) {
      e += start;
      return TrinaColumn(
        title: '$title$e',
        field: '$title$e',
        width: width,
        frozen: frozen,
        readOnly: readOnly,
        hide: hide,
        type: TrinaColumnType.text(defaultValue: defaultValue),
        footerRenderer: footerRenderer,
      );
    }).toList();
  }

  static List<TrinaColumn> dateColumn(
    String title, {
    int count = 1,
    int start = 0,
    double width = TrinaGridSettings.columnWidth,
    TrinaColumnFrozen frozen = TrinaColumnFrozen.none,
    bool readOnly = false,
    bool hide = false,
    DateTime? startDate,
    DateTime? endDate,
    String format = 'yyyy-MM-dd',
    bool applyFormatOnInit = true,
    TrinaColumnFooterRenderer? footerRenderer,
    bool selectWithSingleTap = false,
  }) {
    return Iterable<int>.generate(count).map((e) {
      e += start;
      return TrinaColumn(
        title: '$title$e',
        field: '$title$e',
        width: width,
        frozen: frozen,
        readOnly: readOnly,
        hide: hide,
        type: TrinaColumnType.date(
          startDate: startDate,
          selectWithSingleTap: selectWithSingleTap,
          endDate: endDate,
          format: format,
          applyFormatOnInit: applyFormatOnInit,
        ),
        footerRenderer: footerRenderer,
      );
    }).toList();
  }

  static List<TrinaColumn> timeColumn(
    String title, {
    int count = 1,
    int start = 0,
    double width = TrinaGridSettings.columnWidth,
    TrinaColumnFrozen frozen = TrinaColumnFrozen.none,
    bool readOnly = false,
    bool hide = false,
    dynamic defaultValue = '00:00',
    TrinaColumnFooterRenderer? footerRenderer,
  }) {
    return Iterable<int>.generate(count).map((e) {
      e += start;
      return TrinaColumn(
        title: '$title$e',
        field: '$title$e',
        width: width,
        frozen: frozen,
        readOnly: readOnly,
        hide: hide,
        type: TrinaColumnType.time(
          defaultValue: defaultValue,
        ),
        footerRenderer: footerRenderer,
      );
    }).toList();
  }
}
