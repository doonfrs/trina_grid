import 'package:demo/screen/feature/boolean_type_column_screen.dart';
import 'package:demo/screen/feature/change_tracking_screen.dart';
import 'package:demo/screen/feature/check_view_port_visible_columns_screen.dart';
import 'package:demo/screen/feature/column_title_renderer_screen.dart';
import 'package:demo/screen/feature/date_time_column_screen.dart';
import 'package:demo/screen/feature/percentage_type_column_screen.dart';
import 'package:demo/screen/feature/rtl_scrollbar_screen.dart';
import 'package:demo/screen/feature/custom_pagination_screen.dart';
import 'package:flutter/material.dart';

import 'constants/trina_grid_example_colors.dart';
import 'screen/empty_screen.dart';
import 'screen/feature/add_and_remove_column_row_screen.dart';
import 'screen/feature/add_rows_asynchronously.dart';
import 'screen/feature/column_renderer_screen.dart';
import 'screen/feature/cell_color_screen.dart';
import 'screen/feature/cell_renderer_screen.dart';
import 'screen/feature/cell_selection_screen.dart';
import 'screen/feature/column_filtering_screen.dart';
import 'screen/feature/column_footer_screen.dart';
import 'screen/feature/column_freezing_screen.dart';
import 'screen/feature/column_group_screen.dart';
import 'screen/feature/column_hiding_screen.dart';
import 'screen/feature/column_menu_screen.dart';
import 'screen/feature/column_moving_screen.dart';
import 'screen/feature/column_resizing_screen.dart';
import 'screen/feature/column_sorting_screen.dart';
import 'screen/feature/copy_and_paste_screen.dart';
import 'screen/feature/currency_type_column_screen.dart';
import 'screen/feature/dark_mode_screen.dart';
import 'screen/feature/date_type_column_screen.dart';
import 'screen/feature/dual_mode_screen.dart';
import 'screen/feature/edit_cell_renderer_screen.dart';
import 'screen/feature/editing_state_screen.dart';
import 'screen/feature/filter_icon_customization_screen.dart';
import 'screen/feature/grid_as_popup_screen.dart';
import 'screen/feature/grid_export_screen.dart';
import 'screen/feature/loading_options_screen.dart';
import 'screen/feature/listing_mode_screen.dart';
import 'screen/feature/moving_screen.dart';
import 'screen/feature/number_type_column_screen.dart';
import 'screen/feature/row_color_screen.dart';
import 'screen/feature/row_group_screen.dart';
import 'screen/feature/row_infinity_scroll_screen.dart';
import 'screen/feature/row_lazy_pagination_screen.dart';
import 'screen/feature/row_moving_screen.dart';
import 'screen/feature/row_pagination_screen.dart';
import 'screen/feature/row_selection_screen.dart';
import 'screen/feature/row_with_checkbox_screen.dart';
import 'screen/feature/rtl_screen.dart';
import 'screen/feature/selection_type_column_screen.dart';
import 'screen/feature/text_type_column_screen.dart';
import 'screen/feature/time_type_column_screen.dart';
import 'screen/feature/value_formatter_screen.dart';
import 'screen/home_screen.dart';
import 'screen/feature/pages_list_screen.dart';
import 'screen/feature/frozen_rows_screen.dart';
import 'screen/feature/scrollbars.dart';
import 'screen/feature/row_wrapper_screen.dart';
import 'screen/feature/frozen_rows_positions_screen.dart';
import 'screen/feature/multiitems_delegate_demo_screen.dart';
import 'screen/feature/custom_footer_screen.dart';
import 'screen/feature/dynamic_row_height_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        AddAndRemoveColumnRowScreen.routeName: (context) =>
            const AddAndRemoveColumnRowScreen(),
        AddRowsAsynchronouslyScreen.routeName: (context) =>
            const AddRowsAsynchronouslyScreen(),
        ColumnRendererScreen.routeName: (context) =>
            const ColumnRendererScreen(),
        ColumnTitleRendererScreen.routeName: (context) =>
            const ColumnTitleRendererScreen(),
        CellColorScreen.routeName: (context) => const CellColorScreen(),
        CellRendererScreen.routeName: (context) => const CellRendererScreen(),
        CellSelectionScreen.routeName: (context) => const CellSelectionScreen(),
        ChangeTrackingScreen.routeName: (context) =>
            const ChangeTrackingScreen(),
        BooleanTypeColumnScreen.routeName: (context) =>
            const BooleanTypeColumnScreen(),
        CheckViewPortVisibleColumnsScreen.routeName: (context) =>
            const CheckViewPortVisibleColumnsScreen(),
        DateTimeColumnScreen.routeName: (context) =>
            const DateTimeColumnScreen(),
        EditCellRendererScreen.routeName: (context) =>
            const EditCellRendererScreen(),
        RTLScreen.routeName: (context) => const RTLScreen(),
        ColumnFilteringScreen.routeName: (context) =>
            const ColumnFilteringScreen(),
        ColumnFooterScreen.routeName: (context) => const ColumnFooterScreen(),
        ColumnFreezingScreen.routeName: (context) =>
            const ColumnFreezingScreen(),
        ColumnGroupScreen.routeName: (context) => const ColumnGroupScreen(),
        ColumnHidingScreen.routeName: (context) => const ColumnHidingScreen(),
        ColumnMenuScreen.routeName: (context) => const ColumnMenuScreen(),
        ColumnMovingScreen.routeName: (context) => const ColumnMovingScreen(),
        ColumnResizingScreen.routeName: (context) =>
            const ColumnResizingScreen(),
        ColumnSortingScreen.routeName: (context) => const ColumnSortingScreen(),
        CopyAndPasteScreen.routeName: (context) => const CopyAndPasteScreen(),
        CurrencyTypeColumnScreen.routeName: (context) =>
            const CurrencyTypeColumnScreen(),
        CustomPaginationScreen.routeName: (context) =>
            const CustomPaginationScreen(),
        DarkModeScreen.routeName: (context) => const DarkModeScreen(),
        DateTypeColumnScreen.routeName: (context) =>
            const DateTypeColumnScreen(),
        DualModeScreen.routeName: (context) => const DualModeScreen(),
        EditingStateScreen.routeName: (context) => const EditingStateScreen(),
        FilterIconCustomizationScreen.routeName: (context) =>
            const FilterIconCustomizationScreen(),
        GridAsPopupScreen.routeName: (context) => const GridAsPopupScreen(),
        GridExportScreen.routeName: (context) => const GridExportScreen(),
        ListingModeScreen.routeName: (context) => const ListingModeScreen(),
        MovingScreen.routeName: (context) => const MovingScreen(),
        NumberTypeColumnScreen.routeName: (context) =>
            const NumberTypeColumnScreen(),
        PercentageTypeColumnScreen.routeName: (context) =>
            const PercentageTypeColumnScreen(),
        RowColorScreen.routeName: (context) => const RowColorScreen(),
        RowGroupScreen.routeName: (context) => const RowGroupScreen(),
        RowInfinityScrollScreen.routeName: (context) =>
            const RowInfinityScrollScreen(),
        RowLazyPaginationScreen.routeName: (context) =>
            const RowLazyPaginationScreen(),
        RowMovingScreen.routeName: (context) => const RowMovingScreen(),
        RowPaginationScreen.routeName: (context) => const RowPaginationScreen(),
        RowSelectionScreen.routeName: (context) => const RowSelectionScreen(),
        RowWithCheckboxScreen.routeName: (context) =>
            const RowWithCheckboxScreen(),
        SelectionTypeColumnScreen.routeName: (context) =>
            const SelectionTypeColumnScreen(),
        TextTypeColumnScreen.routeName: (context) =>
            const TextTypeColumnScreen(),
        TimeTypeColumnScreen.routeName: (context) =>
            const TimeTypeColumnScreen(),
        ValueFormatterScreen.routeName: (context) =>
            const ValueFormatterScreen(),
        // only development
        EmptyScreen.routeName: (context) => const EmptyScreen(),
        PagesListScreen.routeName: (context) => const PagesListScreen(),
        FrozenRowsScreen.routeName: (context) => const FrozenRowsScreen(),
        ScrollbarsScreen.routeName: (context) => const ScrollbarsScreen(),
        LoadingOptionsScreen.routeName: (context) =>
            const LoadingOptionsScreen(),
        RowWrapperScreen.routeName: (context) => const RowWrapperScreen(),
        FrozenRowsPositionsScreen.routeName: (context) =>
            const FrozenRowsPositionsScreen(),
        MultiItemsDelegateDemoScreen.routeName: (context) =>
            const MultiItemsDelegateDemoScreen(),
        DynamicRowHeightDemo.routeName: (context) =>
            const DynamicRowHeightDemo(),
        RTLScrollbarScreen.routeName: (context) => const RTLScrollbarScreen(),
        CustomFooterScreen.routeName: (context) => const CustomFooterScreen(),
      },
      theme: ThemeData(
        primaryColor: TrinaGridExampleColors.primaryColor,
        fontFamily: 'OpenSans',
        scaffoldBackgroundColor: TrinaGridExampleColors.backgroundColor,
        colorScheme: const ColorScheme.light(
          primary: TrinaGridExampleColors.primaryColor,
          surface: TrinaGridExampleColors.backgroundColor,
        ),
      ),
    );
  }
}
