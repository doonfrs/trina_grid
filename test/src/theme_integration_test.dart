import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  group('TrinaGridStyleConfig.fromColorScheme', () {
    test('maps ColorScheme roles onto the grid style', () {
      final scheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);
      final style = TrinaGridStyleConfig.fromColorScheme(scheme);

      // Surfaces
      expect(style.gridBackgroundColor, scheme.surface);
      expect(style.rowColor, scheme.surface);
      expect(style.cellColorInEditState, scheme.surface);
      expect(style.frozenRowColor, scheme.surfaceContainerLow);
      expect(style.menuBackgroundColor, scheme.surfaceContainer);
      expect(style.cellColorInReadOnlyState, scheme.surfaceContainerHighest);
      expect(style.unfocusedSelectionColor, scheme.surfaceContainerHighest);

      // Selection / activation
      expect(style.activatedColor, scheme.primaryContainer);
      expect(style.columnCheckedColor, scheme.primaryContainer);
      expect(style.cellCheckedColor, scheme.primaryContainer);
      expect(style.activatedBorderColor, scheme.primary);
      expect(style.columnActiveColor, scheme.primary);
      expect(style.cellActiveColor, scheme.primary);

      // Borders
      expect(style.borderColor, scheme.outlineVariant);
      expect(style.inactivatedBorderColor, scheme.outlineVariant);
      expect(style.frozenRowBorderColor, scheme.outlineVariant);
      expect(style.gridBorderColor, scheme.outline);

      // Icons
      expect(style.iconColor, scheme.onSurfaceVariant);
      expect(style.columnUnselectedColor, scheme.onSurfaceVariant);
      expect(style.cellUnselectedColor, scheme.onSurfaceVariant);

      // Misc
      expect(style.cellDirtyColor, scheme.tertiaryContainer);
      expect(style.columnTextStyle.color, scheme.onSurface);
      expect(style.cellTextStyle.color, scheme.onSurface);
    });

    test('derives isDarkStyle from the scheme brightness', () {
      final light = TrinaGridStyleConfig.fromColorScheme(
        ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      );
      final dark = TrinaGridStyleConfig.fromColorScheme(
        ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      );

      expect(light.isDarkStyle, false);
      expect(dark.isDarkStyle, true);
    });

    test('leaves opt-in nullable colors unset so fallbacks still apply', () {
      final style = TrinaGridStyleConfig.fromColorScheme(
        ColorScheme.fromSeed(seedColor: Colors.teal),
      );

      expect(style.oddRowColor, isNull);
      expect(style.evenRowColor, isNull);
      expect(style.filterHeaderColor, isNull);
      expect(style.filterPopupHeaderColor, isNull);
      expect(style.filterHeaderIconColor, isNull);
      expect(style.cellReadonlyColor, isNull);
      expect(style.cellDefaultColor, isNull);
      expect(style.cellColorGroupedRow, isNull);
    });

    test('keeps the non-color defaults of the default constructor', () {
      const defaults = TrinaGridStyleConfig();
      final style = TrinaGridStyleConfig.fromColorScheme(
        ColorScheme.fromSeed(seedColor: Colors.teal),
      );

      expect(style.rowHeight, defaults.rowHeight);
      expect(style.columnHeight, defaults.columnHeight);
      expect(style.columnFilterHeight, defaults.columnFilterHeight);
      expect(style.iconSize, defaults.iconSize);
      expect(style.defaultCellPadding, defaults.defaultCellPadding);
      expect(
        style.defaultColumnTitlePadding,
        defaults.defaultColumnTitlePadding,
      );
      expect(style.gridBorderWidth, defaults.gridBorderWidth);
      expect(style.cellVerticalBorderWidth, defaults.cellVerticalBorderWidth);
      expect(
        style.cellHorizontalBorderWidth,
        defaults.cellHorizontalBorderWidth,
      );
      expect(style.columnContextIcon, defaults.columnContextIcon);
      expect(style.rowGroupExpandedIcon, defaults.rowGroupExpandedIcon);
    });

    test('fromTheme matches fromColorScheme for the same scheme', () {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      );
      final viaTheme = TrinaGridStyleConfig.fromTheme(theme);
      final viaScheme = TrinaGridStyleConfig.fromColorScheme(theme.colorScheme);

      expect(viaTheme.gridBackgroundColor, viaScheme.gridBackgroundColor);
      expect(viaTheme.activatedColor, viaScheme.activatedColor);
      expect(viaTheme.borderColor, viaScheme.borderColor);
      expect(viaTheme.isDarkStyle, viaScheme.isDarkStyle);
    });
  });

  group('additive guarantee', () {
    test('the const light defaults are unchanged', () {
      const style = TrinaGridStyleConfig();

      expect(style.gridBackgroundColor, Colors.white);
      expect(style.rowColor, Colors.white);
      expect(style.activatedColor, const Color(0xFFDCF5FF));
      expect(style.columnCheckedColor, const Color(0xFFDCF5FF));
      expect(style.cellCheckedColor, const Color(0xFFDCF5FF));
      expect(style.rowCheckedColor, const Color(0x11757575));
      expect(style.rowHoveredColor, const Color(0xFFB1B3B7));
      expect(style.cellColorInEditState, Colors.white);
      expect(style.cellColorInReadOnlyState, const Color(0xFFDBDBDC));
      expect(style.cellDirtyColor, const Color(0xFFFFF9C4));
      expect(style.frozenRowColor, const Color(0xFFF8F8F8));
      expect(style.frozenRowBorderColor, const Color(0xFFE0E0E0));
      expect(
        style.dragTargetColumnColor,
        const Color.fromARGB(129, 220, 245, 255),
      );
      expect(style.iconColor, Colors.black38);
      expect(style.disabledIconColor, Colors.black12);
      expect(style.menuBackgroundColor, Colors.white);
      expect(style.gridBorderColor, const Color(0xFFA1A5AE));
      expect(style.borderColor, const Color(0xFFDDE2EB));
      expect(style.activatedBorderColor, Colors.lightBlue);
      expect(style.inactivatedBorderColor, const Color(0xFFC4C7CC));
      expect(style.columnUnselectedColor, Colors.black38);
      expect(style.columnActiveColor, Colors.lightBlue);
      expect(style.cellUnselectedColor, Colors.black38);
      expect(style.cellActiveColor, Colors.lightBlue);
      expect(style.isDarkStyle, false);
    });

    test('the const dark defaults are unchanged', () {
      const style = TrinaGridStyleConfig.dark();

      expect(style.gridBackgroundColor, const Color(0xFF111111));
      expect(style.rowColor, const Color(0xFF111111));
      expect(style.unfocusedSelectionColor, const Color(0xFF4A4A4A));
      expect(style.activatedColor, const Color(0xFF313131));
      expect(style.columnCheckedColor, const Color(0xFF313131));
      expect(style.cellCheckedColor, const Color(0xFF313131));
      expect(style.rowCheckedColor, const Color(0x11202020));
      expect(style.rowHoveredColor, const Color(0xFF3D3D3D));
      expect(style.cellColorInEditState, const Color(0xFF666666));
      expect(style.cellColorInReadOnlyState, const Color(0xFF222222));
      expect(style.cellDirtyColor, const Color(0xFF5D4037));
      expect(style.frozenRowColor, const Color(0xFF222222));
      expect(style.frozenRowBorderColor, const Color(0xFF666666));
      expect(style.dragTargetColumnColor, const Color(0xFF313131));
      expect(style.iconColor, Colors.white38);
      expect(style.disabledIconColor, Colors.white12);
      expect(style.menuBackgroundColor, const Color(0xFF414141));
      expect(style.gridBorderColor, const Color(0xFF666666));
      expect(style.borderColor, const Color(0xFF222222));
      expect(style.activatedBorderColor, const Color(0xFFFFFFFF));
      expect(style.inactivatedBorderColor, const Color(0xFF666666));
      expect(style.isDarkStyle, true);
    });

    test('default configurations still compare equal', () {
      expect(const TrinaGridStyleConfig(), const TrinaGridStyleConfig());
      expect(
        const TrinaGridStyleConfig.dark(),
        const TrinaGridStyleConfig.dark(),
      );
      expect(
        const TrinaGridConfiguration(),
        isNot(const TrinaGridConfiguration.dark()),
      );
    });
  });

  group('copyWith', () {
    test('preserves theme-derived values when overriding one field', () {
      final scheme = ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      );
      final themed = TrinaGridStyleConfig.fromColorScheme(scheme);
      final copied = themed.copyWith(gridBackgroundColor: Colors.black);

      expect(copied.gridBackgroundColor, Colors.black);
      // Everything else must survive rather than fall back to the fixed
      // dark palette.
      expect(copied.isDarkStyle, true);
      expect(copied.rowColor, scheme.surface);
      expect(copied.activatedColor, scheme.primaryContainer);
      expect(copied.borderColor, scheme.outlineVariant);
      expect(copied.gridBorderColor, scheme.outline);
      expect(copied.iconColor, scheme.onSurfaceVariant);
      expect(copied.cellDirtyColor, scheme.tertiaryContainer);
      expect(copied.menuBackgroundColor, scheme.surfaceContainer);
      expect(copied.cellTextStyle.color, scheme.onSurface);
    });

    test('carries over fields the old implementation dropped', () {
      const style = TrinaGridStyleConfig(
        enableRowHoverColor: true,
        rowCheckedColor: Color(0xFF123456),
        rowHoveredColor: Color(0xFF654321),
        cellDefaultColor: Color(0xFF111222),
        cellDirtyColor: Color(0xFF333444),
        frozenRowColor: Color(0xFF555666),
        frozenRowBorderColor: Color(0xFF777888),
      );

      final copied = style.copyWith(rowHeight: 60);

      expect(copied.rowHeight, 60);
      expect(copied.enableRowHoverColor, true);
      expect(copied.rowCheckedColor, const Color(0xFF123456));
      expect(copied.rowHoveredColor, const Color(0xFF654321));
      expect(copied.cellDefaultColor, const Color(0xFF111222));
      expect(copied.cellDirtyColor, const Color(0xFF333444));
      expect(copied.frozenRowColor, const Color(0xFF555666));
      expect(copied.frozenRowBorderColor, const Color(0xFF777888));
    });

    test('preserves isDarkStyle for both fixed palettes', () {
      expect(
        const TrinaGridStyleConfig().copyWith(rowHeight: 50).isDarkStyle,
        false,
      );
      expect(
        const TrinaGridStyleConfig.dark().copyWith(rowHeight: 50).isDarkStyle,
        true,
      );
    });
  });

  group('TrinaGridConfiguration.fromTheme', () {
    testWidgets('derives the style from the ambient Material theme', (
      tester,
    ) async {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      );
      late TrinaGridConfiguration configuration;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              configuration = TrinaGridConfiguration.fromTheme(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(
        configuration.style.gridBackgroundColor,
        theme.colorScheme.surface,
      );
      expect(
        configuration.style.activatedColor,
        theme.colorScheme.primaryContainer,
      );
      expect(configuration.style.isDarkStyle, false);
    });

    testWidgets('follows a dark ambient theme', (tester) async {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      );
      late TrinaGridConfiguration configuration;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              configuration = TrinaGridConfiguration.fromTheme(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(configuration.style.isDarkStyle, true);
      expect(
        configuration.style.gridBackgroundColor,
        theme.colorScheme.surface,
      );
    });

    testWidgets('renders a grid using the themed surface color', (
      tester,
    ) async {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      );

      final columns = [
        TrinaColumn(title: 'name', field: 'name', type: TrinaColumnType.text()),
      ];
      final rows = [
        TrinaRow(cells: {'name': TrinaCell(value: 'a')}),
        TrinaRow(cells: {'name': TrinaCell(value: 'b')}),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Builder(
              builder: (context) => TrinaGrid(
                columns: columns,
                rows: rows,
                configuration: TrinaGridConfiguration.fromTheme(context),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TrinaGrid), findsOneWidget);
      expect(find.text('a'), findsOneWidget);

      final decorations = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((e) => e.decoration)
          .whereType<BoxDecoration>()
          .toList();

      expect(
        decorations.any((d) => d.color == theme.colorScheme.surface),
        isTrue,
        reason: 'expected at least one surface-colored box from the theme',
      );
    });
  });
}
