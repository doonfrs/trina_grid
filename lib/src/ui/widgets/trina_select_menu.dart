import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trina_grid/src/helper/trina_key_manager_event.dart';
import 'package:trina_grid/src/model/trina_select_menu_item.dart';
import 'package:trina_grid/src/model/trina_select_popup_menu_filter.dart';

/// A customizable select menu widget for TrinaGrid.
///
/// It provides a dropdown-style menu with options for searching, filtering,
/// and custom item rendering. It is designed to be used within a cell of the grid
/// to allow users to select a value from a predefined list.
class TrinaSelectMenu extends StatefulWidget {
  /// The list of items to display in the popup menu.
  final List<TrinaSelectMenuItem> menuItems;

  /// Enables a search field to filter the [menuItems].
  final bool enableSearch;

  /// Enables a filtering section based on the provided [filters].
  final bool enableFiltering;

  /// Called when an item is selected.
  final Function(dynamic) onItemSelected;

  /// The width of the popup menu.
  final double width;

  /// The currently selected value.
  final dynamic currentValue;

  /// Determines if the widget should use a dark or light theme.
  final bool isDarkMode;

  /// A builder function to create a custom widget for each item.
  final Widget Function(dynamic item)? itemBuilder;

  /// The height of each item in the list.
  final double itemHeight;

  /// The maximum height of the popup menu.
  final double maxHeight;

  /// A list of filters that can be applied to the items.
  final List<TrinaSelectMenuFilter> filters;

  const TrinaSelectMenu({
    required this.menuItems,
    required this.enableSearch,
    required this.onItemSelected,
    required this.width,
    required this.currentValue,
    required this.isDarkMode,
    required this.itemHeight,
    required this.enableFiltering,
    required this.maxHeight,
    this.itemBuilder,
    this.filters = const [],
    super.key,
  });

  @override
  State<TrinaSelectMenu> createState() => _TrinaSelectMenuState();
}

class _TrinaSelectMenuState extends State<TrinaSelectMenu> {
  late final TextEditingController searchFieldController;
  late final FocusNode searchFieldFocusNode = FocusNode();

  late final ValueNotifier<List<TrinaSelectMenuFilter>> activeFiltersNotifier;
  late final Map<TrinaSelectMenuFilter, TextEditingController>
      filterValueControllers;

  late final ValueNotifier<List<TrinaSelectMenuItem>>
      filteredPopupItemsNotifier;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    activeFiltersNotifier = ValueNotifier([]);
    filterValueControllers = {};
    activeFiltersNotifier.addListener(_onFilterChanged);

    searchFieldController = TextEditingController();
    searchFieldController.addListener(_onFilterChanged);

    filteredPopupItemsNotifier = ValueNotifier(widget.menuItems);
  }

  /// Adds a filter to the active filters list and sets up its controller.
  void _addFilter(TrinaSelectMenuFilter filter) {
    final newController = TextEditingController();
    newController.addListener(_onFilterChanged);
    filterValueControllers[filter] = newController;
    activeFiltersNotifier.value = [...activeFiltersNotifier.value, filter];
  }

  /// Removes a filter from the active filters list and disposes its controller.
  void _removeFilter(TrinaSelectMenuFilter filter) {
    filterValueControllers[filter]?.dispose();
    filterValueControllers.remove(filter);
    activeFiltersNotifier.value =
        activeFiltersNotifier.value.where((f) => f != filter).toList();
  }

  /// Debounced method to apply search and filters.
  void _onFilterChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _filterItems);
  }

  /// Filters the popup items based on the current search text and active filters.
  /// This method is optimized to perform filtering in a single pass.
  void _filterItems() {
    final filtersEnabled = widget.enableFiltering && widget.filters.isNotEmpty;
    final searchText = searchFieldController.text.toLowerCase();

    final tempItems = widget.menuItems.where((item) {
      // Apply search
      if (widget.enableSearch && searchText.isNotEmpty) {
        final itemText = (item.label ?? item.value.toString()).toLowerCase();
        if (!itemText.contains(searchText)) {
          return false;
        }
      }

      // Apply filters
      if (filtersEnabled) {
        for (final filter in activeFiltersNotifier.value) {
          final filterText = filterValueControllers[filter]?.text ?? '';
          if (filterText.isNotEmpty && !filter.filter(item.value, filterText)) {
            return false; // Fails this filter
          }
        }
      }

      return true; // Passes all conditions
    }).toList();

    filteredPopupItemsNotifier.value = tempItems;
  }

  @override
  void dispose() {
    _debounce?.cancel();

    activeFiltersNotifier.dispose();

    for (final controller in filterValueControllers.values) {
      controller.dispose();
    }

    searchFieldController.dispose();
    searchFieldFocusNode.dispose();

    filteredPopupItemsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtersEnabled = widget.enableFiltering && widget.filters.isNotEmpty;
    final colorScheme =
        widget.isDarkMode ? ColorScheme.dark() : ColorScheme.light();
    final themeData = Theme.of(context).copyWith(
      brightness: widget.isDarkMode ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
    );

    return Theme(
      data: themeData,
      child: Builder(
        builder: (context) {
          return FocusScope(
            autofocus: filtersEnabled
                ? false
                : widget.enableSearch == true &&
                    widget.menuItems.contains(widget.currentValue) == false,
            onKeyEvent: filtersEnabled
                ? null
                : (node, event) {
                    final trinaKeyEvent = TrinaKeyManagerEvent(
                      focusNode: node,
                      event: event,
                    );
                    if (trinaKeyEvent.isCharacter) {
                      if (searchFieldFocusNode.hasFocus == false) {
                        searchFieldFocusNode.requestFocus();
                      }
                    }
                    return KeyEventResult.ignored;
                  },
            child: SizedBox(
              width: widget.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (filtersEnabled)
                    ValueListenableBuilder<List<TrinaSelectMenuFilter>>(
                      valueListenable: activeFiltersNotifier,
                      builder: (context, activeFilters, child) {
                        return _FilterSection(
                          filters: widget.filters,
                          activeFilters: activeFilters,
                          filterValueControllers: filterValueControllers,
                          onAddFilter: _addFilter,
                          onRemoveFilter: _removeFilter,
                        );
                      },
                    ),
                  if (widget.enableSearch) ...[
                    Divider(
                      height: 5,
                      color: colorScheme.onSurface.withAlpha(50),
                    ),
                    _SearchSection(
                      searchFieldController: searchFieldController,
                      searchFieldFocusNode: searchFieldFocusNode,
                    ),
                  ],
                  Divider(
                    height: 5,
                    color: colorScheme.onSurface.withAlpha(50),
                  ),
                  ValueListenableBuilder<List<TrinaSelectMenuItem>>(
                    valueListenable: filteredPopupItemsNotifier,
                    builder: (context, filteredItems, child) {
                      return _ItemListView(
                        filteredItems: filteredItems,
                        width: widget.width,
                        maxHeight: widget.maxHeight,
                        itemHeight: widget.itemHeight,
                        currentValue: widget.currentValue,
                        onItemSelected: widget.onItemSelected,
                        itemBuilder: widget.itemBuilder,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A widget that displays the filtering UI.
class _FilterSection extends StatelessWidget {
  final List<TrinaSelectMenuFilter> filters;
  final List<TrinaSelectMenuFilter> activeFilters;
  final Map<TrinaSelectMenuFilter, TextEditingController>
      filterValueControllers;
  final void Function(TrinaSelectMenuFilter) onAddFilter;
  final void Function(TrinaSelectMenuFilter) onRemoveFilter;

  const _FilterSection({
    required this.filters,
    required this.activeFilters,
    required this.filterValueControllers,
    required this.onAddFilter,
    required this.onRemoveFilter,
  });

  Widget _buildActiveFilterRow(
    BuildContext context,
    TrinaSelectMenuFilter filter,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: filterValueControllers[filter],
              style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'value...',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: filter.title,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(
                    color: colorScheme.onSurface.withAlpha(80),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.remove_circle_outline,
              color: colorScheme.error,
              size: 20,
            ),
            onPressed: () => onRemoveFilter(filter),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addFilterMenuController = MenuController();
    final availableFilters =
        filters.where((f) => !activeFilters.contains(f)).toList();
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SubmenuButton(
            controller: addFilterMenuController,
            onHover: (value) {
              if (!value) {
                addFilterMenuController.close();
              }
            },
            submenuIcon: const WidgetStatePropertyAll(
              Icon(Icons.add_circle_outline, size: 20),
            ),
            menuStyle: MenuStyle(
              backgroundColor: colorScheme.brightness == Brightness.dark
                  ? WidgetStatePropertyAll(Colors.grey.shade800)
                  : const WidgetStatePropertyAll(Colors.white),
            ),
            menuChildren: [
              for (var filter in availableFilters)
                MenuItemButton(
                  closeOnActivate: false,
                  onPressed: () {
                    onAddFilter(filter);
                    addFilterMenuController.close();
                  },
                  style: const ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(Size(150, 50)),
                  ),
                  child: Text(filter.title),
                ),
            ],
            child: const Text('Filters'),
          ),
          if (activeFilters.isNotEmpty) const SizedBox(height: 10),
          Column(
            children: [
              for (var filter in activeFilters)
                _buildActiveFilterRow(context, filter),
            ],
          ),
        ],
      ),
    );
  }
}

/// A widget that displays the search input field.
class _SearchSection extends StatelessWidget {
  final TextEditingController searchFieldController;
  final FocusNode searchFieldFocusNode;

  const _SearchSection({
    required this.searchFieldController,
    required this.searchFieldFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: TextField(
        controller: searchFieldController,
        focusNode: searchFieldFocusNode,
        canRequestFocus: true,
        maxLines: 1,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 10.0,
          ),
          isDense: true,
        ),
      ),
    );
  }
}

/// A widget that displays the list of selectable items.
class _ItemListView extends StatefulWidget {
  final List<TrinaSelectMenuItem> filteredItems;
  final double width;
  final double maxHeight;
  final double itemHeight;
  final dynamic currentValue;
  final Function(dynamic) onItemSelected;
  final Widget Function(dynamic item)? itemBuilder;

  const _ItemListView({
    required this.filteredItems,
    required this.width,
    required this.maxHeight,
    required this.itemHeight,
    required this.currentValue,
    required this.onItemSelected,
    this.itemBuilder,
  });

  @override
  State<_ItemListView> createState() => _ItemListViewState();
}

class _ItemListViewState extends State<_ItemListView> {
  late final ScrollController scrollController = ScrollController();
  late final ValueNotifier<bool> showScrollToBottom = ValueNotifier(false);
  late final ValueNotifier<bool> showScrollToTop = ValueNotifier(false);
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (!scrollController.hasClients) return;
      showScrollToBottom.value =
          scrollController.offset < scrollController.position.maxScrollExtent;
      showScrollToTop.value = scrollController.offset > 0;
    });

    final heightOfItems = widget.filteredItems.length * widget.itemHeight;
    showScrollToBottom.value = heightOfItems > widget.maxHeight;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedItemIndex = widget.filteredItems.indexWhere(
        (element) => element.value == widget.currentValue,
      );

      if (selectedItemIndex != -1 && scrollController.hasClients) {
        scrollController.animateTo(
          selectedItemIndex * widget.itemHeight,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    scrollController.dispose();
    showScrollToBottom.dispose();
    showScrollToTop.dispose();
    super.dispose();
  }

  /// Starts a timer to continuously scroll the list.
  void _startScrolling(bool up) {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (up) {
        if (scrollController.offset <= 0) {
          _stopScrolling();
        } else {
          scrollController.jumpTo(max(0, scrollController.offset - 10));
        }
      } else {
        if (scrollController.offset >=
            scrollController.position.maxScrollExtent) {
          _stopScrolling();
        } else {
          scrollController.jumpTo(
            min(
              scrollController.position.maxScrollExtent,
              scrollController.offset + 10,
            ),
          );
        }
      }
    });
  }

  /// Stops the scrolling timer.
  void _stopScrolling() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.filteredItems.isEmpty) {
      return ListTile(
        dense: true,
        minTileHeight: widget.itemHeight,
        title: const Text('No matches'),
      );
    }

    final heightOfItems = widget.filteredItems.length * widget.itemHeight;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder(
          valueListenable: showScrollToTop,
          builder: (context, show, child) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: show
                  ? MouseRegion(
                      onEnter: (_) => _startScrolling(true),
                      onExit: (_) => _stopScrolling(),
                      child: Container(
                        width: widget.width,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          size: 16,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    )
                  : const SizedBox(),
            );
          },
        ),
        SizedBox(
          width: widget.width,
          height: heightOfItems > widget.maxHeight
              ? widget.maxHeight
              : heightOfItems,
          child: ListView.builder(
            itemExtent: widget.itemHeight,
            controller: scrollController,
            itemCount: widget.filteredItems.length,
            itemBuilder: (context, index) {
              final item = widget.filteredItems[index];
              final isSelected = item.value == widget.currentValue;
              return CallbackShortcuts(
                bindings: {
                  LogicalKeySet(LogicalKeyboardKey.enter): () {
                    widget.onItemSelected(item.value);
                  },
                },
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: widget.width),
                  child: MenuItemButton(
                    closeOnActivate: false,
                    autofocus: isSelected,
                    onPressed: () {
                      widget.onItemSelected(item.value);
                    },
                    trailingIcon:
                        isSelected ? const Icon(Icons.check, size: 20) : null,
                    child: widget.itemBuilder != null
                        ? widget.itemBuilder!(item.value)
                        : Text(item.label ?? item.value.toString()),
                  ),
                ),
              );
            },
          ),
        ),
        if (heightOfItems > widget.maxHeight)
          ValueListenableBuilder(
            valueListenable: showScrollToBottom,
            builder: (context, show, child) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: show
                    ? MouseRegion(
                        onEnter: (_) => _startScrolling(false),
                        onExit: (_) => _stopScrolling(),
                        child: Container(
                          width: widget.width,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: colorScheme.onSurface,
                            size: 16,
                          ),
                        ),
                      )
                    : const SizedBox(),
              );
            },
          ),
      ],
    );
  }
}
