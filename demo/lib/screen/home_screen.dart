import 'dart:math';

import 'package:demo/screen/empty_screen.dart';
import 'package:demo/screen/feature/boolean_type_column_screen.dart';
import 'package:demo/screen/feature/change_tracking_screen.dart';
import 'package:demo/screen/feature/check_view_port_visible_columns_screen.dart';
import 'package:demo/screen/feature/column_title_renderer_screen.dart';
import 'package:demo/screen/feature/filter_icon_customization_screen.dart';
import 'package:demo/screen/feature/loading_options_screen.dart';
import 'package:demo/screen/feature/edit_cell_renderer_screen.dart';
import 'package:demo/screen/feature/frozen_rows_screen.dart';
import 'package:demo/screen/feature/grid_export_screen.dart';
import 'package:demo/screen/feature/percentage_type_column_screen.dart';
import 'package:demo/screen/feature/rtl_scrollbar_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../helper/launch_url.dart';
import '../widget/trina_contributor_tile.dart';
import '../widget/trina_grid_title.dart';
import '../widget/trina_list_tile.dart';
import '../widget/trina_section.dart';
import '../widget/trina_text_color_animation.dart';
import 'feature/add_and_remove_column_row_screen.dart';
import 'feature/add_rows_asynchronously.dart';
import 'feature/column_renderer_screen.dart';
import 'feature/cell_color_screen.dart';
import 'feature/cell_renderer_screen.dart';
import 'feature/cell_selection_screen.dart';
import 'feature/column_filtering_screen.dart';
import 'feature/column_filter_methods_screen.dart';
import 'feature/column_footer_screen.dart';
import 'feature/column_freezing_screen.dart';
import 'feature/column_group_screen.dart';
import 'feature/column_hiding_screen.dart';
import 'feature/column_menu_screen.dart';
import 'feature/column_moving_screen.dart';
import 'feature/column_resizing_screen.dart';
import 'feature/column_sorting_screen.dart';
import 'feature/copy_and_paste_screen.dart';
import 'feature/currency_type_column_screen.dart';
import 'feature/custom_pagination_screen.dart';
import 'feature/dark_mode_screen.dart';
import 'feature/date_type_column_screen.dart';
import 'feature/dual_mode_screen.dart';
import 'feature/editing_state_screen.dart';
import 'feature/grid_as_popup_screen.dart';
import 'feature/listing_mode_screen.dart';
import 'feature/moving_screen.dart';
import 'feature/number_type_column_screen.dart';
import 'feature/row_color_screen.dart';
import 'feature/row_group_screen.dart';
import 'feature/row_infinity_scroll_screen.dart';
import 'feature/row_lazy_pagination_screen.dart';
import 'feature/row_moving_screen.dart';
import 'feature/row_pagination_screen.dart';
import 'feature/row_selection_screen.dart';
import 'feature/row_with_checkbox_screen.dart';
import 'feature/rtl_screen.dart';
import 'feature/selection_type_column_screen.dart';
import 'feature/text_type_column_screen.dart';
import 'feature/theme_switching_screen.dart';
import 'feature/time_type_column_screen.dart';
import 'feature/value_formatter_screen.dart';
import 'feature/pages_list_screen.dart';
import 'feature/scrollbars.dart';
import 'feature/date_time_column_screen.dart';
import 'feature/row_wrapper_screen.dart';
import 'feature/multiitems_delegate_demo_screen.dart';
import 'feature/custom_footer_screen.dart';
import 'feature/dynamic_row_height_demo.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (ctx, size) {
            return Stack(
              children: [
                Positioned.fill(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF2E4370), Color(0xFF33C1E8)],
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 100, 30, 0),
                            child: Align(
                              alignment: Alignment.center,
                              child: TrinaGridTitle(
                                fontSize: max(size.maxWidth / 20, 38),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: const TrinaTextColorAnimation(
                              text: 'The DataGrid for Flutter.',
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 50),
                          Center(
                            child: Column(
                              children: [
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.link),
                                  color: Colors.white,
                                  onPressed: () {
                                    launchUrl(
                                      'https://pub.dev/packages/trina_grid',
                                    );
                                  },
                                ),
                                const Text(
                                  'pub.dev',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const TrinaSection(
                            title: 'Features',
                            fontColor: Colors.white,
                            child: TrinaFeatures(),
                            // color: Colors.white,
                          ),
                          const TrinaSection(
                            title: 'Contributors',
                            fontColor: Colors.white,
                            child: TrinaContributors(),
                          ),
                          const SizedBox(height: 50),
                          Center(
                            child: Column(
                              children: [
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.github),
                                  color: Colors.white,
                                  onPressed: () {
                                    launchUrl(
                                      'https://github.com/doonfrs/trina_grid',
                                    );
                                  },
                                ),
                                const Text(
                                  'Github',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 50),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TrinaFeatures extends StatefulWidget {
  const TrinaFeatures({super.key});

  @override
  State<TrinaFeatures> createState() => _TrinaFeaturesState();
}

class _TrinaFeaturesState extends State<TrinaFeatures> {
  final Icon newIcon = const Icon(Icons.fiber_new, color: Colors.deepOrange);

  final Icon updateIcon = const Icon(Icons.update, color: Colors.deepOrange);

  String _searchQuery = '';

  List<Widget> _buildFeatureItems(BuildContext context) {
    final List<Widget> allItems = [
      TrinaListTile(
        title: 'Custom Pagination UI',
        description: 'Customize rows pagination UI',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, CustomPaginationScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'Column Title Renderer',
        description:
            'Fully customize column titles with your own widgets while preserving all column functionality.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ColumnTitleRendererScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'Change Tracking',
        description:
            'Track changes in cells and highlight dirty cells. You can commit or revert changes.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ChangeTrackingScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'Boolean type column',
        description:
            'A column to enter a boolean value. You can select from a list of options.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, BooleanTypeColumnScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'Column moving',
        description:
            'Dragging the column heading left or right moves the column left and right.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ColumnMovingScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Column freezing',
        description: 'Freeze the column to the left or right.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ColumnFreezingScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Column group',
        description: 'Group columns by the desired depth.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ColumnGroupScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Column resizing',
        description:
            'Dragging the icon to the right of the column title left or right changes the width of the column.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ColumnResizingScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Column sorting',
        description:
            'Ascending or Descending by clicking on the column heading.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ColumnSortingScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Column Filtering',
        description: 'Column filtering allows to filter all data.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ColumnFilteringScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Column Filter Methods',
        description: 'Programmatically set, update, and clear column filters.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ColumnFilterMethodsScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Filter Icon Customization',
        description:
            'Customize or hide the filter icon that appears in column titles after filtering.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, FilterIconCustomizationScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'Column Footer',
        description:
            'Column footer allows to display footer cell. '
            'The default built-in footer is aggregate. '
            'But you can also customize it.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ColumnFooterScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Pagination Footer',
        description:
            'Create custom pagination footer widgets at the bottom of the grid using createFooter callback. '
            'Includes basic, styled, and compact pagination designs.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, CustomFooterScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'Column hiding',
        description: 'Hide or un-hide the column.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ColumnHidingScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Column menu',
        description: 'Customize the menu on the right side of the column.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ColumnMenuScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Text type column',
        description: 'A column to enter a character value.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, TextTypeColumnScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Number type column',
        description: 'A column to enter a number value.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, NumberTypeColumnScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Percentage type column',
        description: 'A column to display and edit percentage values.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, PercentageTypeColumnScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'Currency type column',
        description: 'A column to enter a number as currency value.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, CurrencyTypeColumnScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'Date type column',
        description: 'A column to enter a date value.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, DateTypeColumnScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'DateTime type column',
        description:
            'A column to enter both date and time values in a single field.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, DateTimeColumnScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'Time type column',
        description: 'A column to enter a time value.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, TimeTypeColumnScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Selection type column',
        description: 'A column to enter a selection value.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, SelectionTypeColumnScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Value formatter',
        description: 'Formatter for display of cell values.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ValueFormatterScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Row color',
        description: 'Dynamically change the background color of row.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, RowColorScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Cell color',
        description:
            'Dynamically change the background color of individual cells.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, CellColorScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Row selection',
        description:
            'In Row selection mode, Shift + tap or long tap and then move or Control + tap to select a row.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, RowSelectionScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Row moving',
        description: 'You can move the row by dragging it.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, RowMovingScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Row pagination',
        description: 'You can paginate the rows.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, RowPaginationScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Row lazy pagination',
        description:
            'Implement pagination in the form of fetching data from the server.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, RowLazyPaginationScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'Row infinity scroll',
        description: 'Add a new row when scrolling reaches the bottom end.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, RowInfinityScrollScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'Row group',
        description: 'Grouping rows in a column or tree structure.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, RowGroupScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Grid Export',
        description: 'Export grid data in various formats (PDF, CSV, JSON).',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, GridExportScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'Row with checkbox',
        description: 'You can select rows with checkbox.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, RowWithCheckboxScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Frozen Rows',
        description:
            'Demonstrates rows frozen at top and bottom with pagination',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, FrozenRowsScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Scrollbars',
        description: 'Customize scrollbar appearance, behavior, and visibility',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ScrollbarsScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'Add rows asynchronously',
        description: 'Adds or sets rows asynchronously.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, AddRowsAsynchronouslyScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Cell selection',
        description:
            'In cell selection mode, Shift + tap or long tap and then move to select cells.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, CellSelectionScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Column renderer',
        description:
            'You can change the widget of the column through the renderer.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ColumnRendererScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Cell renderer',
        description:
            'You can customize individual cells with cell-level renderers.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, CellRendererScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Copy and Paste',
        description:
            'Copy and paste are operated depending on the cell and row selection status.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, CopyAndPasteScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Moving',
        description:
            'Change the current cell position with the arrow keys, enter key, and tab key.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, MovingScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Editing state',
        description: 'Controls the editing state of a cell.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, EditingStateScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Edit Cell Renderer',
        description: 'Customize the appearance of cells in edit mode.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, EditCellRendererScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'RTL - TextDirection.',
        description: 'Activate Right-To-Left which is a TextDirection.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, RTLScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'RTL Scrollbar Demo',
        description:
            'Demo showing proper scrollbar positioning in RTL mode for Arabic and other RTL languages.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, RTLScrollbarScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'Add and Remove Columns, Rows',
        description: 'You can add or delete columns, rows.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, AddAndRemoveColumnRowScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Dual mode',
        description:
            'Place the grid on the left and right and move or edit with the keyboard.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, DualModeScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Grid as Popup',
        description: 'You can call the grid by popping up with the TextField.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, GridAsPopupScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Listing mode',
        description: 'Listing mode to open or navigate to the Detail page.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ListingModeScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Pages list',
        description: 'A list of pages to test various functions.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, PagesListScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Check view port visible columns',
        description: 'Check view port visible columns.',
        onTapLiveDemo: () {
          Navigator.pushNamed(
            context,
            CheckViewPortVisibleColumnsScreen.routeName,
          );
        },
      ),
      TrinaListTile.dark(
        title: 'Dark mode',
        description: 'Change the entire theme of the grid to Dark.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, DarkModeScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Dark mode Switching',
        description: 'Test live theme switching with pagination controls.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, ThemeSwitchingScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile.amber(
        title: 'Empty',
        description:
            'This screen is used during development, this is a template to test issues',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, EmptyScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Loading Options',
        description:
            'Configure loading displays with different levels and custom loading widgets.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, LoadingOptionsScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'Row Wrapper',
        description:
            'Wrap each row with your own widget for custom styling or interactivity.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, RowWrapperScreen.routeName);
        },
        trailing: newIcon,
      ),
      TrinaListTile(
        title: 'MultiItems Filter Delegate',
        description:
            'Demonstrates the use of TrinaFilterColumnWidgetDelegate.multiItems for multi-line or multi-item column filtering.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, MultiItemsDelegateDemoScreen.routeName);
        },
      ),
      TrinaListTile(
        title: 'Dynamic Row Height',
        description:
            'Test dynamic row height functionality with custom setRowHeight method for individual rows.',
        onTapLiveDemo: () {
          Navigator.pushNamed(context, DynamicRowHeightDemo.routeName);
        },
        trailing: newIcon,
      ),
    ];
    return allItems;
  }

  Container _filterInput() {
    return Container(
      constraints: const BoxConstraints(minWidth: 300, maxWidth: 300),
      margin: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Filter features...',
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade500),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade500),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim().toLowerCase();
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildFeatureItems(context);
    final filteredItems = _searchQuery.isEmpty
        ? items
        : items.where((widget) {
            if (widget is! TrinaListTile) {
              return true;
            }
            final title = widget.title.toLowerCase();
            final description = widget.description?.toLowerCase() ?? '';
            _searchQuery = _searchQuery.toLowerCase();
            return title.contains(_searchQuery) ||
                description.contains(_searchQuery);
          }).toList();

    return Column(
      children: [
        _filterInput(),
        Center(
          child: Wrap(spacing: 10, runSpacing: 10, children: filteredItems),
        ),
      ],
    );
  }
}

class TrinaContributors extends StatelessWidget {
  const TrinaContributors({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          TrinaContributorTile(
            name: 'Manki Kim',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/bosskmk');
            },
          ),
          TrinaContributorTile(
            name: 'Feras Abdalrahman',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/doonfrs');
            },
          ),
          TrinaContributorTile(
            name: 'Mouayad Alhamwi',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/DMouayad');
            },
          ),
          TrinaContributorTile(
            name: 'Gian',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/Macacoazul01');
            },
          ),
          TrinaContributorTile(
            name: 'Enrique Cardona',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/henry2man');
            },
          ),
          TrinaContributorTile(
            name: 'Christian Arduino',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/christianarduino');
            },
          ),
          TrinaContributorTile(
            name: 'Wang Chuanbin',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/Chuanbin-Wang');
            },
          ),
          TrinaContributorTile(
            name: 'HasanCihatS',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/HasanCihatS');
            },
          ),
          TrinaContributorTile(
            name: 'Majed DH',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/MajedDH');
            },
          ),
          TrinaContributorTile(
            name: 'Matěj Žídek',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/mzdm');
            },
          ),
          TrinaContributorTile(
            name: 'Henrique Deodato',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/h3nr1ke');
            },
          ),
          TrinaContributorTile(
            name: 'tilongzs',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/tilongzs');
            },
          ),
          TrinaContributorTile(
            name: 'Alexey Volkov',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/ASGAlex');
            },
          ),
          TrinaContributorTile(
            name: 'Dmitry Sboychakov',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/DmitrySboychakov');
            },
          ),
          TrinaContributorTile(
            name: 'MrCasCode',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/MrCasCode');
            },
          ),
          TrinaContributorTile(
            name: 'hos3ein',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/hos3ein');
            },
          ),
          TrinaContributorTile(
            name: 'Hu-Wentao',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/Hu-Wentao');
            },
          ),
          TrinaContributorTile(
            name: 's-yanev',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/s-yanev');
            },
          ),
          TrinaContributorTile(
            name: 'Ivan Daniluk',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/divan');
            },
          ),
          TrinaContributorTile(
            name: 'sheentim',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/sheentim');
            },
          ),
          TrinaContributorTile(
            name: 'Anders',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/RedRozio');
            },
          ),
          TrinaContributorTile(
            name: 'Ahmed Elshorbagy',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/Ahmed-elshorbagy');
            },
          ),
          TrinaContributorTile(
            name: 'Milad akarie',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/Milad-Akarie');
            },
          ),
          TrinaContributorTile(
            name: 'Verry',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/novas1r1');
            },
          ),
          TrinaContributorTile(
            name: 'coda538',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/coda538');
            },
          ),
          TrinaContributorTile(
            name: 'billyio',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/billyio');
            },
          ),
          TrinaContributorTile(
            name: 'Mehmet',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/mehmetkalayci');
            },
          ),
          TrinaContributorTile(
            name: 'Tautvydas Šidlauskas',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/sidlatau');
            },
          ),
          TrinaContributorTile(
            name: 'coruscant187',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/coruscant187');
            },
          ),
          TrinaContributorTile.invisible(
            name: 'And you.',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/doonfrs/trina_grid');
            },
          ),
        ],
      ),
    );
  }
}
