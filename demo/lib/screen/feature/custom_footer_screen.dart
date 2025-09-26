import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/trina_example_button.dart';
import '../../widget/trina_example_screen.dart';

class CustomFooterScreen extends StatefulWidget {
  static const routeName = 'feature/custom-footer';

  const CustomFooterScreen({super.key});

  @override
  State<CustomFooterScreen> createState() => _CustomFooterScreenState();
}

class _CustomFooterScreenState extends State<CustomFooterScreen> {
  late final TrinaGridStateManager stateManager;
  late List<TrinaColumn> columns;
  late List<TrinaRow> rows;

  @override
  void initState() {
    super.initState();

    columns = [
      TrinaColumn(
        title: 'ID',
        field: 'id',
        type: TrinaColumnType.text(),
        width: 80,
      ),
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
        width: 150,
      ),
      TrinaColumn(
        title: 'Age',
        field: 'age',
        type: TrinaColumnType.number(),
        width: 80,
      ),
      TrinaColumn(
        title: 'Salary',
        field: 'salary',
        type: TrinaColumnType.number(format: '#,###'),
        width: 120,
      ),
      TrinaColumn(
        title: 'Position',
        field: 'position',
        type: TrinaColumnType.text(),
        width: 150,
      ),
      TrinaColumn(
        title: 'Department',
        field: 'department',
        type: TrinaColumnType.select([
          'Engineering',
          'Sales',
          'Marketing',
          'HR',
        ]),
        width: 130,
      ),
      TrinaColumn(
        title: 'Status',
        field: 'status',
        type: TrinaColumnType.select(['Active', 'Inactive', 'Pending']),
        width: 100,
      ),
    ];

    rows = DummyData.rowsByColumns(length: 50, columns: columns);
  }

  @override
  Widget build(BuildContext context) {
    return TrinaExampleScreen(
      title: 'Custom Pagination Footer',
      topTitle: 'Custom Pagination Footer',
      topContents: const [
        Text(
          'This demo shows how to create a custom pagination footer using the createFooter callback.',
        ),
        Text(
          'The footer displays current page, navigation controls, page size selector, and total records.',
        ),
        Text(
          'All pagination functionality is controlled through the TrinaGridStateManager.',
        ),
      ],
      topButtons: [
        TrinaExampleButton(
          url:
              'https://github.com/doonfrs/trina_grid/blob/master/demo/lib/screen/feature/custom_footer_screen.dart',
        ),
      ],
      body: TrinaGrid(
        columns: columns,
        rows: rows,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setSelectingMode(TrinaGridSelectingMode.row);
          // Set initial page size to match our dropdown options
          stateManager.setPageSize(40);
          setState(() {}); // Trigger rebuild to show footer
        },
        onChanged: (TrinaGridOnChangedEvent event) {
          print(event);
        },
        configuration: const TrinaGridConfiguration(
          style: TrinaGridStyleConfig(enableRowColorAnimation: true),
        ),
        createFooter: (stateManager) {
          // Only create footer when state manager is ready and has data
          try {
            if (stateManager.refRows.isNotEmpty) {
              return PaginationFooterWidget(stateManager: stateManager);
            }
          } catch (e) {
            // If any error occurs, return empty widget
            print('Error creating footer: $e');
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class PaginationFooterWidget extends StatefulWidget {
  final TrinaGridStateManager stateManager;

  const PaginationFooterWidget({super.key, required this.stateManager});

  @override
  State<PaginationFooterWidget> createState() => _PaginationFooterWidgetState();
}

class _PaginationFooterWidgetState extends State<PaginationFooterWidget> {
  // Define available page sizes including the default
  final List<int> availablePageSizes = [10, 20, 40, 50, 100];

  // Controller for the page input field
  final TextEditingController _pageController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure state manager is properly initialized and has data
    if (widget.stateManager.refRows.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get pagination values from state manager
    final currentPage = widget.stateManager.page;
    final pageSize = widget.stateManager.pageSize;
    final totalPage = widget.stateManager.totalPage;
    final totalRows = widget.stateManager.refRows.length;

    // Update the text controller when current page changes
    if (_pageController.text != currentPage.toString()) {
      _pageController.text = currentPage.toString();
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          // Page size selector
          Row(
            children: [
              const Text('Rows per page:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: pageSize,
                items: availablePageSizes.map((size) {
                  return DropdownMenuItem(value: size, child: Text('$size'));
                }).toList(),
                onChanged: (newSize) {
                  if (newSize != null) {
                    widget.stateManager.setPageSize(newSize);
                    widget.stateManager.setPage(1);
                    setState(() {});
                  }
                },
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Page navigation controls
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.first_page),
                  onPressed: currentPage > 1 ? () => _goToPage(1) : null,
                  tooltip: 'First Page',
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: currentPage > 1
                      ? () => _goToPage(currentPage - 1)
                      : null,
                  tooltip: 'Previous Page',
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Page ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      // Direct page input field
                      SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _pageController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          onSubmitted: (value) {
                            _goToPageFromInput(value);
                          },
                          onEditingComplete: () {
                            _goToPageFromInput(_pageController.text);
                          },
                        ),
                      ),
                      Text(
                        ' of $totalPage',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: currentPage < totalPage
                      ? () => _goToPage(currentPage + 1)
                      : null,
                  tooltip: 'Next Page',
                ),
                IconButton(
                  icon: const Icon(Icons.last_page),
                  onPressed: currentPage < totalPage
                      ? () => _goToPage(totalPage)
                      : null,
                  tooltip: 'Last Page',
                ),
              ],
            ),
          ),
          // Total records display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '$totalRows total records',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToPage(int page) {
    widget.stateManager.setPage(page);
    setState(() {}); // Trigger rebuild to update UI
  }

  void _goToPageFromInput(String input) {
    final page = int.tryParse(input);
    if (page != null && page >= 1 && page <= widget.stateManager.totalPage) {
      _goToPage(page);
    } else {
      // Reset to current page if input is invalid
      _pageController.text = widget.stateManager.page.toString();
      // Show a brief feedback that the input was invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid page number between 1 and ${widget.stateManager.totalPage}',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
