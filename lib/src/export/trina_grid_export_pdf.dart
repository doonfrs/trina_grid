import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:trina_grid/src/export/trina_grid_export.dart';
import 'package:trina_grid/src/manager/trina_grid_state_manager.dart';
import 'package:trina_grid/src/model/trina_column.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:trina_grid/src/model/trina_row.dart';

/// Implementation of PDF export for Trina Grid
class TrinaGridExportPdf implements TrinaGridExport {
  @override
  Future<Uint8List> export({
    required TrinaGridStateManager stateManager,
    List<String>? columns,
    bool includeHeaders = true,
    bool ignoreFixedRows = false,
    bool Function(TrinaRow row)? rowIgnoreCondition,
    String? title,
    String? creator,
    pw.PageTheme? pageTheme,
    TrinaGridExportPdfSettings? pdfSettings,
  }) async {
    // Create document with theme and metadata
    final doc = pw.Document(
      creator: pdfSettings?.creator,
      title: pdfSettings?.title,
      theme: pdfSettings?.theme,
    );

    doc.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisAlignment: pw.MainAxisAlignment.start,
        header: title != null ? (context) => _getHeader(title: title) : null,
        footer: (context) => _getFooter(context),
        build: (pw.Context context) => _exportInternal(
          context,
          stateManager,
          columns,
          ignoreFixedRows,
          pdfSettings,
          rowIgnoreCondition,
        ),
      ),
    );
    return await doc.save();
  }

  List<pw.Widget> _exportInternal(
    pw.Context context,
    TrinaGridStateManager stateManager,
    List<String>? columns,
    bool ignoreFixedRows,
    TrinaGridExportPdfSettings? pdfSettings,
    bool Function(TrinaRow row)? rowIgnoreCondition,
  ) {
    final columnsToExport = _getColumnsToExport(
      stateManager: stateManager,
      columnNames: columns,
    );
    final rows = stateManager.refRows;

    return [
      _table(
        columnsToExport,
        rows,
        ignoreFixedRows,
        pdfSettings,
        rowIgnoreCondition,
      ),
    ];
  }

  /// Helper method to get the columns to export based on provided column names
  /// or visible columns if no column names are provided
  List<TrinaColumn> _getColumnsToExport({
    required TrinaGridStateManager stateManager,
    List<String>? columnNames,
  }) {
    if (columnNames == null || columnNames.isEmpty) {
      // If no columns specified, use all visible columns
      return stateManager.columns;
    } else {
      // Filter columns by the provided column names
      return stateManager.refColumns
          .where((column) => columnNames.contains(column.title))
          .toList();
    }
  }

  pw.Widget _getHeader({required String title}) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 1),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: pw.Text(title, textAlign: pw.TextAlign.center)),
        ],
      ),
    );
  }

  pw.Widget _table(
    List<TrinaColumn> columns,
    List<TrinaRow> rows,
    bool ignoreFixedRows,
    TrinaGridExportPdfSettings? pdfSettings,
    bool Function(TrinaRow row)? rowIgnoreCondition,
  ) {
    return pw.TableHelper.fromTextArray(
      border: pdfSettings?.border,
      cellAlignment: pdfSettings?.cellAlignment ?? pw.Alignment.center,
      headerHeight: pdfSettings?.headerHeight ?? 25,
      cellHeight: pdfSettings?.cellHeight ?? 20,
      headerAlignment: pdfSettings?.headerAlignment ?? pw.Alignment.center,
      cellPadding: pdfSettings?.cellPadding ?? const pw.EdgeInsets.all(1),
      cellDecoration:
          pdfSettings?.cellDecoration ??
          (index, data, rowNum) => pw.BoxDecoration(
            border: pw.Border.all(color: PdfColor.fromInt(0x000000), width: .5),
          ),
      cellAlignments: pdfSettings?.cellAlignments,
      cellStyle: pdfSettings?.cellStyle,
      oddCellStyle: pdfSettings?.oddCellStyle,
      cellFormat: pdfSettings?.cellFormat,
      headerPadding: pdfSettings?.headerPadding,
      headerAlignments: pdfSettings?.headerAlignments,
      headerStyle: pdfSettings?.headerStyle,
      headerFormat: pdfSettings?.headerFormat,
      headerCount: pdfSettings?.headerCount ?? 1,
      headerDecoration:
          pdfSettings?.headerDecoration ??
          pw.BoxDecoration(
            border: pw.Border.all(
              color: PdfColor.fromInt(0x000000),
              width: 0.5,
            ),
          ),
      columnWidths: pdfSettings?.columnWidths,
      defaultColumnWidth:
          pdfSettings?.defaultColumnWidth ?? pw.IntrinsicColumnWidth(),
      tableWidth: pdfSettings?.tableWidth ?? pw.TableWidth.max,
      headerCellDecoration: pdfSettings?.headerCellDecoration,
      rowDecoration: pdfSettings?.rowDecoration,
      oddRowDecoration: pdfSettings?.oddRowDecoration,
      headerDirection: pdfSettings?.headerDirection,
      tableDirection: pdfSettings?.tableDirection,
      cellBuilder: pdfSettings?.cellBuilder,
      textStyleBuilder: pdfSettings?.textStyleBuilder,
      headers: columns.map((column) => column.title).toList(),
      data: rows
          .where(
            (row) =>
                (!ignoreFixedRows || row.frozen == TrinaRowFrozen.none) &&
                (rowIgnoreCondition == null || !rowIgnoreCondition(row)),
          )
          .map(
            (row) => columns.map((column) {
              final cell = row.cells[column.field];
              return cell?.value?.toString() ?? '';
            }).toList(),
          )
          .toList(),
    );
  }

  pw.Widget _getFooter(pw.Context context) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.max,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text('# ${context.pageNumber}/${context.pagesCount}'),
          pw.Text(DateTime.now().toString()),
        ],
      ),
    );
  }
}

class TrinaGridExportPdfSettings {
  TrinaGridExportPdfSettings({
    this.title,
    this.creator,
    this.pageTheme,
    this.theme,
    this.cellDecoration,
    this.headerAlignment,
    this.cellPadding,
    this.cellHeight,
    this.cellAlignment,
    this.cellAlignments,
    this.cellStyle,
    this.oddCellStyle,
    this.cellFormat,
    this.headerPadding,
    this.headerHeight,
    this.headerAlignments,
    this.headerStyle,
    this.headerFormat,
    this.border,
    this.columnWidths,
    this.defaultColumnWidth,
    this.tableWidth,
    this.headerDecoration,
    this.headerDirection,
    this.tableDirection,
    this.cellBuilder,
    this.textStyleBuilder,
    this.headerCount,
    this.headers,
    this.headerCellDecoration,
    this.rowDecoration,
    this.oddRowDecoration,
  });

  final String? title;
  final String? creator;
  final pw.PageTheme? pageTheme;
  final pw.ThemeData? theme;
  final pw.AlignmentGeometry? headerAlignment;
  final pw.EdgeInsetsGeometry? cellPadding;
  final double? cellHeight;
  final pw.AlignmentGeometry? cellAlignment;
  final Map<int, pw.AlignmentGeometry>? cellAlignments;
  final pw.TextStyle? cellStyle;
  final pw.TextStyle? oddCellStyle;
  final pw.OnCellFormat? cellFormat;
  final pw.OnCellDecoration? cellDecoration;
  final int? headerCount;
  final List<dynamic>? headers;
  final pw.EdgeInsetsGeometry? headerPadding;
  final double? headerHeight;
  final Map<int, pw.AlignmentGeometry>? headerAlignments;
  final pw.TextStyle? headerStyle;
  final pw.OnCellFormat? headerFormat;
  final pw.TableBorder? border;
  final Map<int, pw.TableColumnWidth>? columnWidths;
  final pw.TableColumnWidth? defaultColumnWidth;
  final pw.TableWidth? tableWidth;
  final pw.BoxDecoration? headerDecoration;
  final pw.TextDirection? headerDirection;
  final pw.TextDirection? tableDirection;
  final pw.OnCell? cellBuilder;
  final pw.OnCellTextStyle? textStyleBuilder;
  final pw.BoxDecoration? headerCellDecoration;
  final pw.BoxDecoration? rowDecoration;
  final pw.BoxDecoration? oddRowDecoration;
}
