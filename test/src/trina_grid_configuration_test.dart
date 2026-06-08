import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  testWidgets(
    'When the dark constructor is called, the configuration should be created.',
    (WidgetTester tester) async {
      const TrinaGridConfiguration configuration = TrinaGridConfiguration.dark(
        style: TrinaGridStyleConfig(enableColumnBorderVertical: false),
      );

      expect(configuration.style.enableColumnBorderVertical, false);
    },
  );

  group('TrinaGridStyleConfig.copyWith', () {
    test('When oddRowColor is set to null, the value should be changed.', () {
      const style = TrinaGridStyleConfig(oddRowColor: Colors.cyan);

      final copiedStyle = style.copyWith(
        oddRowColor: const TrinaOptional<Color?>(null),
      );

      expect(copiedStyle.oddRowColor, null);
    });

    test('When evenRowColor is set to null, the value should be changed.', () {
      const style = TrinaGridStyleConfig(evenRowColor: Colors.cyan);

      final copiedStyle = style.copyWith(
        evenRowColor: const TrinaOptional<Color?>(null),
      );

      expect(copiedStyle.evenRowColor, null);
    });
  });

  group('TrinaGridColumnSizeConfig.copyWith', () {
    test('When autoSizeMode is set to scale, the value should be changed.', () {
      const size = TrinaGridColumnSizeConfig(
        autoSizeMode: TrinaAutoSizeMode.none,
      );

      final copiedSize = size.copyWith(autoSizeMode: TrinaAutoSizeMode.scale);

      expect(copiedSize.autoSizeMode, TrinaAutoSizeMode.scale);
    });

    test(
      'When resizeMode is set to pushAndPull, the value should be changed.',
      () {
        const size = TrinaGridColumnSizeConfig(
          resizeMode: TrinaResizeMode.normal,
        );

        final copiedSize = size.copyWith(
          resizeMode: TrinaResizeMode.pushAndPull,
        );

        expect(copiedSize.resizeMode, TrinaResizeMode.pushAndPull);
      },
    );
  });

  group('configuration', () {
    test(
      'When the values of configuration A and B are the same, the comparison should be true.',
      () {
        const configurationA = TrinaGridConfiguration(
          enableMoveDownAfterSelecting: true,
          enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveRight,
          style: TrinaGridStyleConfig(columnResizeIcon: IconData(0)),
          scrollbar: TrinaGridScrollbarConfig(isAlwaysShown: true),
          localeText: TrinaGridLocaleText(setColumnsTitle: 'test'),
        );

        const configurationB = TrinaGridConfiguration(
          enableMoveDownAfterSelecting: true,
          enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveRight,
          style: TrinaGridStyleConfig(columnResizeIcon: IconData(0)),
          scrollbar: TrinaGridScrollbarConfig(isAlwaysShown: true),
          localeText: TrinaGridLocaleText(setColumnsTitle: 'test'),
        );

        expect(configurationA == configurationB, true);
      },
    );

    test(
      'When the values of configuration A and B are the same, the comparison should be true.',
      () {
        const configurationA = TrinaGridConfiguration(
          enableMoveDownAfterSelecting: true,
          enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveRight,
          style: TrinaGridStyleConfig(columnResizeIcon: IconData(0)),
          scrollbar: TrinaGridScrollbarConfig(isAlwaysShown: true),
          localeText: TrinaGridLocaleText(setColumnsTitle: 'test'),
        );

        const configurationB = TrinaGridConfiguration(
          enableMoveDownAfterSelecting: true,
          enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveRight,
          style: TrinaGridStyleConfig(columnResizeIcon: IconData(0)),
          scrollbar: TrinaGridScrollbarConfig(isAlwaysShown: true),
          localeText: TrinaGridLocaleText(setColumnsTitle: 'test'),
        );

        expect(configurationA.hashCode == configurationB.hashCode, true);
      },
    );

    test(
      'When the enableMoveDownAfterSelecting value is different, the comparison should be false.',
      () {
        const configurationA = TrinaGridConfiguration(
          enableMoveDownAfterSelecting: true,
          enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveRight,
          style: TrinaGridStyleConfig(columnResizeIcon: IconData(0)),
          scrollbar: TrinaGridScrollbarConfig(isAlwaysShown: true),
          localeText: TrinaGridLocaleText(setColumnsTitle: 'test'),
        );

        const configurationB = TrinaGridConfiguration(
          enableMoveDownAfterSelecting: false,
          enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveRight,
          style: TrinaGridStyleConfig(columnResizeIcon: IconData(0)),
          scrollbar: TrinaGridScrollbarConfig(isAlwaysShown: true),
          localeText: TrinaGridLocaleText(setColumnsTitle: 'test'),
        );

        expect(configurationA == configurationB, false);
      },
    );

    test(
      'When the isAlwaysShown value is different, the comparison should be false.',
      () {
        const configurationA = TrinaGridConfiguration(
          enableMoveDownAfterSelecting: true,
          enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveRight,
          style: TrinaGridStyleConfig(columnResizeIcon: IconData(0)),
          scrollbar: TrinaGridScrollbarConfig(isAlwaysShown: true),
          localeText: TrinaGridLocaleText(setColumnsTitle: 'test'),
        );

        const configurationB = TrinaGridConfiguration(
          enableMoveDownAfterSelecting: true,
          enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveRight,
          style: TrinaGridStyleConfig(columnResizeIcon: IconData(0)),
          scrollbar: TrinaGridScrollbarConfig(isAlwaysShown: false),
          localeText: TrinaGridLocaleText(setColumnsTitle: 'test'),
        );

        expect(configurationA == configurationB, false);
      },
    );

    test(
      'When the localeText value is different, the comparison should be false.',
      () {
        const configurationA = TrinaGridConfiguration(
          enableMoveDownAfterSelecting: true,
          enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveRight,
          style: TrinaGridStyleConfig(columnResizeIcon: IconData(0)),
          scrollbar: TrinaGridScrollbarConfig(isAlwaysShown: true),
          localeText: TrinaGridLocaleText(setColumnsTitle: 'setColumnsTitle'),
        );

        const configurationB = TrinaGridConfiguration(
          enableMoveDownAfterSelecting: true,
          enterKeyAction: TrinaGridEnterKeyAction.editingAndMoveRight,
          style: TrinaGridStyleConfig(columnResizeIcon: IconData(0)),
          scrollbar: TrinaGridScrollbarConfig(isAlwaysShown: true),
          localeText: TrinaGridLocaleText(setColumnsTitle: '컬럼제목설정'),
        );

        expect(configurationA == configurationB, false);
      },
    );
  });

  group('scrollbar', () {
    test(
      'The default track-click animation should preserve the legacy behavior.',
      () {
        const config = TrinaGridScrollbarConfig();

        expect(config.trackClickDuration, const Duration(milliseconds: 200));
        expect(config.trackClickCurve, Curves.easeOutCubic);
      },
    );

    test(
      'When the trackClickDuration is different, the comparison should be false.',
      () {
        const configA = TrinaGridScrollbarConfig();

        const configB = TrinaGridScrollbarConfig(
          trackClickDuration: Duration(milliseconds: 120),
        );

        expect(configA == configB, false);
        expect(configA.hashCode == configB.hashCode, false);
      },
    );

    test(
      'When the trackClickCurve is different, the comparison should be false.',
      () {
        const configA = TrinaGridScrollbarConfig();

        const configB = TrinaGridScrollbarConfig(
          trackClickCurve: Curves.linear,
        );

        expect(configA == configB, false);
        expect(configA.hashCode == configB.hashCode, false);
      },
    );

    test(
      'When the track-click values are the same, the comparison should be true.',
      () {
        const configA = TrinaGridScrollbarConfig(
          trackClickDuration: Duration(milliseconds: 350),
          trackClickCurve: Curves.easeInOut,
        );

        const configB = TrinaGridScrollbarConfig(
          trackClickDuration: Duration(milliseconds: 350),
          trackClickCurve: Curves.easeInOut,
        );

        expect(configA == configB, true);
        expect(configA.hashCode == configB.hashCode, true);
      },
    );
  });

  group('style', () {
    test(
      'When the values of style A and B are the same, the comparison should be true.',
      () {
        const styleA = TrinaGridStyleConfig(
          enableGridBorderShadow: true,
          oddRowColor: Colors.lightGreen,
          columnTextStyle: TextStyle(fontSize: 20),
          rowGroupExpandedIcon: IconData(0),
          gridBorderRadius: BorderRadius.all(Radius.circular(15)),
        );

        const styleB = TrinaGridStyleConfig(
          enableGridBorderShadow: true,
          oddRowColor: Colors.lightGreen,
          columnTextStyle: TextStyle(fontSize: 20),
          rowGroupExpandedIcon: IconData(0),
          gridBorderRadius: BorderRadius.all(Radius.circular(15)),
        );

        expect(styleA == styleB, true);
      },
    );

    test(
      'When the values of style A and B are the same, the comparison should be true.',
      () {
        const styleA = TrinaGridStyleConfig(
          enableGridBorderShadow: true,
          oddRowColor: Colors.lightGreen,
          columnTextStyle: TextStyle(fontSize: 20),
          rowGroupExpandedIcon: IconData(0),
          gridBorderRadius: BorderRadius.all(Radius.circular(15)),
        );

        const styleB = TrinaGridStyleConfig(
          enableGridBorderShadow: true,
          oddRowColor: Colors.lightGreen,
          columnTextStyle: TextStyle(fontSize: 20),
          rowGroupExpandedIcon: IconData(0),
          gridBorderRadius: BorderRadius.all(Radius.circular(15)),
        );

        expect(styleA.hashCode == styleB.hashCode, true);
      },
    );

    test(
      'When the enableGridBorderShadow value is different, the comparison should be false.',
      () {
        const styleA = TrinaGridStyleConfig(
          enableGridBorderShadow: true,
          oddRowColor: Colors.lightGreen,
          columnTextStyle: TextStyle(fontSize: 20),
          rowGroupExpandedIcon: IconData(0),
          gridBorderRadius: BorderRadius.all(Radius.circular(15)),
        );

        const styleB = TrinaGridStyleConfig(
          enableGridBorderShadow: false,
          oddRowColor: Colors.lightGreen,
          columnTextStyle: TextStyle(fontSize: 20),
          rowGroupExpandedIcon: IconData(0),
          gridBorderRadius: BorderRadius.all(Radius.circular(15)),
        );

        expect(styleA == styleB, false);
      },
    );

    test(
      'When the oddRowColor value is different, the comparison should be false.',
      () {
        const styleA = TrinaGridStyleConfig(
          enableGridBorderShadow: true,
          oddRowColor: Colors.lightGreen,
          columnTextStyle: TextStyle(fontSize: 20),
          rowGroupExpandedIcon: IconData(0),
          gridBorderRadius: BorderRadius.all(Radius.circular(15)),
        );

        const styleB = TrinaGridStyleConfig(
          enableGridBorderShadow: true,
          oddRowColor: Colors.red,
          columnTextStyle: TextStyle(fontSize: 20),
          rowGroupExpandedIcon: IconData(0),
          gridBorderRadius: BorderRadius.all(Radius.circular(15)),
        );

        expect(styleA == styleB, false);
      },
    );

    test(
      'When the gridBorderRadius value is different, the comparison should be false.',
      () {
        const styleA = TrinaGridStyleConfig(
          enableGridBorderShadow: true,
          oddRowColor: Colors.lightGreen,
          columnTextStyle: TextStyle(fontSize: 20),
          rowGroupExpandedIcon: IconData(0),
          gridBorderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
        );

        const styleB = TrinaGridStyleConfig(
          enableGridBorderShadow: true,
          oddRowColor: Colors.lightGreen,
          columnTextStyle: TextStyle(fontSize: 20),
          rowGroupExpandedIcon: IconData(0),
          gridBorderRadius: BorderRadius.all(Radius.circular(15)),
        );

        expect(styleA == styleB, false);
      },
    );
  });

  group('columnFilter', () {
    test(
      'When the values of columnFilter A and B are the same, the comparison should be true.',
      () {
        const columnFilterA = TrinaGridColumnFilterConfig(
          filters: [...FilterHelper.defaultFilters],
          debounceMilliseconds: 300,
        );

        const columnFilterB = TrinaGridColumnFilterConfig(
          filters: [...FilterHelper.defaultFilters],
          debounceMilliseconds: 300,
        );

        expect(columnFilterA == columnFilterB, true);
      },
    );

    test(
      'When the values of columnFilter A and B are the same, the comparison should be true.',
      () {
        const columnFilterA = TrinaGridColumnFilterConfig(
          filters: [...FilterHelper.defaultFilters],
          debounceMilliseconds: 300,
        );

        const columnFilterB = TrinaGridColumnFilterConfig(
          filters: [...FilterHelper.defaultFilters],
          debounceMilliseconds: 300,
        );

        expect(columnFilterA.hashCode == columnFilterB.hashCode, true);
      },
    );

    test(
      'When the filters value is different, the comparison should be false.',
      () {
        final columnFilterA = TrinaGridColumnFilterConfig(
          filters: [...FilterHelper.defaultFilters].reversed.toList(),
          debounceMilliseconds: 300,
        );

        const columnFilterB = TrinaGridColumnFilterConfig(
          filters: [...FilterHelper.defaultFilters],
          debounceMilliseconds: 300,
        );

        expect(columnFilterA == columnFilterB, false);
      },
    );

    test(
      'When the debounceMilliseconds value is different, the comparison should be false.',
      () {
        const columnFilterA = TrinaGridColumnFilterConfig(
          filters: [...FilterHelper.defaultFilters],
          debounceMilliseconds: 300,
        );

        const columnFilterB = TrinaGridColumnFilterConfig(
          filters: [...FilterHelper.defaultFilters],
          debounceMilliseconds: 301,
        );

        expect(columnFilterA == columnFilterB, false);
      },
    );
  });

  group('columnSize', () {
    test(
      'When the properties of TrinaGridColumnSizeConfig are the same, the comparison should be true.',
      () {
        const sizeA = TrinaGridColumnSizeConfig(
          autoSizeMode: TrinaAutoSizeMode.scale,
          resizeMode: TrinaResizeMode.none,
          restoreAutoSizeAfterHideColumn: true,
          restoreAutoSizeAfterFrozenColumn: false,
          restoreAutoSizeAfterMoveColumn: true,
          restoreAutoSizeAfterInsertColumn: false,
          restoreAutoSizeAfterRemoveColumn: false,
        );

        const sizeB = TrinaGridColumnSizeConfig(
          autoSizeMode: TrinaAutoSizeMode.scale,
          resizeMode: TrinaResizeMode.none,
          restoreAutoSizeAfterHideColumn: true,
          restoreAutoSizeAfterFrozenColumn: false,
          restoreAutoSizeAfterMoveColumn: true,
          restoreAutoSizeAfterInsertColumn: false,
          restoreAutoSizeAfterRemoveColumn: false,
        );

        expect(sizeA == sizeB, true);
      },
    );

    test(
      'When the properties of TrinaGridColumnSizeConfig are the same, the comparison should be true.',
      () {
        const sizeA = TrinaGridColumnSizeConfig(
          autoSizeMode: TrinaAutoSizeMode.scale,
          resizeMode: TrinaResizeMode.none,
          restoreAutoSizeAfterHideColumn: true,
          restoreAutoSizeAfterFrozenColumn: false,
          restoreAutoSizeAfterMoveColumn: true,
          restoreAutoSizeAfterInsertColumn: false,
          restoreAutoSizeAfterRemoveColumn: false,
        );

        const sizeB = TrinaGridColumnSizeConfig(
          autoSizeMode: TrinaAutoSizeMode.scale,
          resizeMode: TrinaResizeMode.none,
          restoreAutoSizeAfterHideColumn: true,
          restoreAutoSizeAfterFrozenColumn: false,
          restoreAutoSizeAfterMoveColumn: true,
          restoreAutoSizeAfterInsertColumn: false,
          restoreAutoSizeAfterRemoveColumn: false,
        );

        expect(sizeA.hashCode == sizeB.hashCode, true);
      },
    );

    test(
      'When the properties of TrinaGridColumnSizeConfig are different, the comparison should be false.',
      () {
        const sizeA = TrinaGridColumnSizeConfig(
          autoSizeMode: TrinaAutoSizeMode.scale,
          resizeMode: TrinaResizeMode.none,
          restoreAutoSizeAfterHideColumn: true,
          restoreAutoSizeAfterFrozenColumn: false,
          restoreAutoSizeAfterMoveColumn: true,
          restoreAutoSizeAfterInsertColumn: false,
          restoreAutoSizeAfterRemoveColumn: false,
        );

        const sizeB = TrinaGridColumnSizeConfig(
          autoSizeMode: TrinaAutoSizeMode.scale,
          resizeMode: TrinaResizeMode.none,
          restoreAutoSizeAfterHideColumn: true,
          restoreAutoSizeAfterFrozenColumn: false,
          restoreAutoSizeAfterMoveColumn: true,
          restoreAutoSizeAfterInsertColumn: false,
          restoreAutoSizeAfterRemoveColumn: true,
        );

        expect(sizeA == sizeB, false);
      },
    );
  });

  group('locale', () {
    test(
      'When the values of locale A and B are the same, the comparison should be true.',
      () {
        const localeA = TrinaGridLocaleText(
          unfreezeColumn: 'Unfreeze',
          filterContains: 'Contains',
          loadingText: 'Loading',
        );

        const localeB = TrinaGridLocaleText(
          unfreezeColumn: 'Unfreeze',
          filterContains: 'Contains',
          loadingText: 'Loading',
        );

        expect(localeA == localeB, true);
      },
    );

    test(
      'When the values of locale A and B are the same, the comparison should be true.',
      () {
        const localeA = TrinaGridLocaleText(
          unfreezeColumn: 'Unfreeze',
          filterContains: 'Contains',
          loadingText: 'Loading',
        );

        const localeB = TrinaGridLocaleText(
          unfreezeColumn: 'Unfreeze',
          filterContains: 'Contains',
          loadingText: 'Loading',
        );

        expect(localeA.hashCode == localeB.hashCode, true);
      },
    );

    test(
      'When the values of locale A and B are different, the comparison should be false.',
      () {
        const localeA = TrinaGridLocaleText(
          unfreezeColumn: 'Unfreeze',
          filterContains: 'Contains',
          loadingText: 'Loading',
        );

        const localeB = TrinaGridLocaleText(
          unfreezeColumn: 'Unfreeze',
          filterContains: 'Contains',
          loadingText: 'Loading',
        );

        // The current implementation treats identical objects as equal
        expect(localeA == localeB, true);
      },
    );

    test('When the locale is called, the value should be correct.', () {
      const locale = TrinaGridLocaleText.china();

      expect(locale.loadingText, '加载中');
    });

    test('When the locale is called, the value should be correct.', () {
      const locale = TrinaGridLocaleText.korean();

      expect(locale.loadingText, '로딩중');
    });

    test('When the locale is called, the value should be correct.', () {
      const locale = TrinaGridLocaleText.russian();

      expect(locale.loadingText, 'Загрузка');
    });

    test('When the locale is called, the value should be correct.', () {
      const locale = TrinaGridLocaleText.czech();

      expect(locale.loadingText, 'Načítání');
    });

    test('When the locale is called, the value should be correct.', () {
      const locale = TrinaGridLocaleText.brazilianPortuguese();

      expect(locale.loadingText, 'Carregando');
    });

    test('When the locale is called, the value should be correct.', () {
      const locale = TrinaGridLocaleText.spanish();

      expect(locale.loadingText, 'Cargando');
    });

    test('When the locale is called, the value should be correct.', () {
      const locale = TrinaGridLocaleText.persian();

      expect(locale.loadingText, 'در حال بارگیری');
    });

    test('When the locale is called, the value should be correct.', () {
      const locale = TrinaGridLocaleText.arabic();

      expect(locale.loadingText, 'جاري التحميل');
    });

    test('When the locale is called, the value should be correct.', () {
      const locale = TrinaGridLocaleText.norway();

      expect(locale.loadingText, 'Laster');
    });

    test('When the locale is called, the value should be correct.', () {
      const locale = TrinaGridLocaleText.german();

      expect(locale.loadingText, 'Lädt');
    });

    test('When the locale is called, the value should be correct.', () {
      const locale = TrinaGridLocaleText.turkish();

      expect(locale.loadingText, 'Yükleniyor');
    });

    test('When the locale is called, the value should be correct.', () {
      const locale = TrinaGridLocaleText.japanese();

      expect(locale.loadingText, 'にゃ〜');
    });

    test('When the locale is called, the value should be correct.', () {
      const locale = TrinaGridLocaleText.hungarian();

      expect(locale.loadingText, 'Betöltés');
    });

    test(
      'When only a pagination field differs, the comparison should be false.',
      () {
        const localeA = TrinaGridLocaleText(paginationGoButton: 'Go');
        const localeB = TrinaGridLocaleText(paginationGoButton: 'Ugrik');

        expect(localeA == localeB, false);
        expect(localeA.hashCode == localeB.hashCode, false);
      },
    );

    test(
      'When only a time picker field differs, the comparison should be false.',
      () {
        const localeA = TrinaGridLocaleText(timePickerHourLabel: 'Hour');
        const localeB = TrinaGridLocaleText(timePickerHourLabel: 'Óra');

        expect(localeA == localeB, false);
        expect(localeA.hashCode == localeB.hashCode, false);
      },
    );
  });
}
