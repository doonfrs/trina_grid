import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trina_grid/src/model/trina_dropdown_menu_filter.dart';

typedef ItemBuilder<T> = Widget Function(T item);

class _InheritedTrinaDropdownMenu<T> extends InheritedWidget {
  const _InheritedTrinaDropdownMenu({
    required this.state,
    required super.child,
  });

  final TrinaDropdownMenuState<T> state;

  @override
  bool updateShouldNotify(_InheritedTrinaDropdownMenu oldWidget) {
    return state != oldWidget.state;
  }
}

/// Describes the specific variant of the [TrinaDropdownMenu].
enum TrinaDropdownMenuVariant {
  /// A simple dropdown list with no search or filtering.
  select,

  /// A dropdown list that includes a search field to filter items.
  selectWithSearch,

  /// A dropdown list that includes an advanced UI for applying multiple filters.
  selectWithFilters,
}

/// A customizable select menu widget for TrinaGrid.
///
/// It provides a dropdown-style menu with options for searching, filtering,
/// and custom item rendering.
///
/// ### Usage
/// - [TrinaDropdownMenu] for a basic select menu.
/// - [TrinaDropdownMenu.withSearch] for a menu with a search field.
/// - [TrinaDropdownMenu.withFilters] for a menu with filtering.
class TrinaDropdownMenu<T> extends StatefulWidget {
  /// A key used to identify the filter section for testing purposes.
  @visibleForTesting
  static const Key filterSectionKey = Key('__filter_section__');

  /// {@template TrinaDropdownMenu.variant}
  /// The variant of the menu to be built.
  ///
  /// This is used internally to determine which UI and state to use.
  /// {@endtemplate}
  final TrinaDropdownMenuVariant variant;

  /// The builder function that constructs the menu's UI.
  ///
  /// This is typically provided by the factory constructors.
  final WidgetBuilder builder;

  /// {@template TrinaDropdownMenu.items}
  /// The list of items to display in the popup menu.
  /// {@endtemplate}
  final List<T> items;

  /// {@template TrinaDropdownMenu.onItemSelected}
  /// Called when an item is selected from the list.
  /// {@endtemplate}
  final void Function(T) onItemSelected;

  /// {@template TrinaDropdownMenu.width}
  /// The width of the menu.
  /// {@endtemplate}
  final double width;

  /// {@template TrinaDropdownMenu.initialValue}
  /// The initially selected value, which will be highlighted in the list.
  /// If null, no item will be initially selected.
  /// {@endtemplate}
  final T? initialValue;

  /// {@template TrinaDropdownMenu.itemBuilder}
  /// A builder function to create a custom widget for each item in the list.
  ///
  /// If null, a default [Text] widget is used.
  /// {@endtemplate}
  final ItemBuilder<T>? itemBuilder;

  /// {@template TrinaDropdownMenu.itemHeight}
  /// The height of each item in the list.
  /// {@endtemplate}
  final double itemHeight;

  /// {@template TrinaDropdownMenu.maxHeight}
  /// The maximum height of the popup menu's scrollable area.
  /// {@endtemplate}
  final double maxHeight;

  /// {@template TrinaDropdownMenu.itemToString}
  /// A function that returns the string representation of an item.
  ///
  /// If provided, it's used as the display text if [itemBuilder] is not provided.
  /// {@endtemplate}
  final String Function(T item)? itemToString;

  /// {@template TrinaDropdownMenu.itemToValue}
  /// A function that returns a unique value for an item.
  ///
  /// Used to determine if an item is selected and for filtering.
  /// If not provided, the `==` operator is used.
  /// {@endtemplate}
  final dynamic Function(T item)? itemToValue;

  const TrinaDropdownMenu._({
    required this.variant,
    required this.builder,
    required this.items,
    required this.onItemSelected,
    required this.width,
    required this.initialValue,
    required this.itemHeight,
    required this.maxHeight,
    this.itemBuilder,
    this.itemToString,
    this.itemToValue,
    super.key,
  });

  /// Creates a basic select menu with a simple list of items.
  const TrinaDropdownMenu({
    required this.items,
    required this.onItemSelected,
    required this.width,
    required this.initialValue,
    required this.itemHeight,
    required this.maxHeight,
    this.itemBuilder,
    this.itemToString,
    this.itemToValue,
    super.key,
  }) : builder = _defaultBuilder<T>,
       variant = TrinaDropdownMenuVariant.select;

  static Widget _defaultBuilder<T>(BuildContext context) {
    final widget = TrinaDropdownMenu.of<T>(context).widget;
    return SizedBox(
      height: widget.maxHeight,
      width: widget.width,
      child: _ItemListView<T>(),
    );
  }

  /// A generic factory to build a [TrinaDropdownMenu] based on a [variant].
  ///
  /// This is used internally by [TrinaColumnType] to construct the appropriate
  /// menu. You should prefer using the more specific factory constructors like
  /// [TrinaDropdownMenu.withSearch] or [TrinaDropdownMenu.withFilters].
  factory TrinaDropdownMenu.variant(
    TrinaDropdownMenuVariant variant, {
    required List<T> items,
    required void Function(T item) onItemSelected,
    required double width,
    required T? initialValue,
    required double itemHeight,
    required double maxHeight,
    required List<TrinaDropdownMenuFilter> filters,
    bool filtersInitiallyExpanded = true,
    String Function(T item)? itemToString,
    WidgetBuilder? emptySearchResultBuilder,
    WidgetBuilder? emptyFilterResultBuilder,
    ItemBuilder<T>? itemBuilder,
    dynamic Function(T item)? itemToValue,
    Key? key,
  }) {
    switch (variant) {
      case TrinaDropdownMenuVariant.select:
        return TrinaDropdownMenu<T>._(
          key: key,
          variant: variant,
          builder: _defaultBuilder<T>,
          items: items,
          onItemSelected: onItemSelected,
          width: width,
          initialValue: initialValue,
          itemHeight: itemHeight,
          maxHeight: maxHeight,
          itemToString: itemToString,
          itemToValue: itemToValue,
          itemBuilder: itemBuilder,
        );
      case TrinaDropdownMenuVariant.selectWithSearch:
        assert(itemToString != null, 'itemToString must be provided');
        return TrinaDropdownMenu<T>.withSearch(
          key: key,
          items: items,
          itemToString: itemToString!,
          onItemSelected: onItemSelected,
          width: width,
          initialValue: initialValue,
          itemHeight: itemHeight,
          maxHeight: maxHeight,
          itemToValue: itemToValue,
          emptySearchResultBuilder: emptySearchResultBuilder,
          itemBuilder: itemBuilder,
        );
      case TrinaDropdownMenuVariant.selectWithFilters:
        return TrinaDropdownMenu<T>.withFilters(
          key: key,
          filters: filters,
          items: items,
          itemToString: itemToString,
          onItemSelected: onItemSelected,
          width: width,
          initialValue: initialValue,
          itemHeight: itemHeight,
          maxHeight: maxHeight,
          itemToValue: itemToValue,
          emptyFilterResultBuilder: emptyFilterResultBuilder,
          itemBuilder: itemBuilder,
          filtersInitiallyExpanded: filtersInitiallyExpanded,
        );
    }
  }

  /// Creates a select menu with a search field.
  ///
  /// Requires an [itemToString] function to perform the search.
  factory TrinaDropdownMenu.withSearch({
    required List<T> items,
    required String Function(T item) itemToString,
    required void Function(T item) onItemSelected,
    required double width,
    required T? initialValue,
    required double itemHeight,
    required double maxHeight,
    Key? key,
    WidgetBuilder? emptySearchResultBuilder,
    ItemBuilder<T>? itemBuilder,
    dynamic Function(T item)? itemToValue,
  }) = _TrinaSelectMenuWithSearch<T>;

  /// Creates a select menu with an advanced filtering UI.
  ///
  /// Requires a list of [filters] to be applied.
  factory TrinaDropdownMenu.withFilters({
    required List<T> items,
    required void Function(T item) onItemSelected,
    required List<TrinaDropdownMenuFilter> filters,
    required double width,
    required T? initialValue,
    required double itemHeight,
    required double maxHeight,
    required bool filtersInitiallyExpanded,
    WidgetBuilder? emptyFilterResultBuilder,
    String Function(T item)? itemToString,
    ItemBuilder<T>? itemBuilder,
    dynamic Function(T item)? itemToValue,
    Key? key,
  }) = _TrinaSelectMenuWithFilters<T>;

  /// The state from the closest instance of this class that encloses the given context.
  ///
  /// This is used by child widgets of the menu to access the menu's state,
  /// such as the list of items or the search controller.
  static TrinaDropdownMenuState<T> of<T>(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_InheritedTrinaDropdownMenu<T>>();
    assert(scope != null, 'TrinaDropdownMenu not found in context');
    return scope!.state;
  }

  @override
  TrinaDropdownMenuState<T> createState() => TrinaDropdownMenuState<T>();
}

/// The base state for the [TrinaDropdownMenu].
///
/// This class manages the basic state of the menu, such as the list of items
/// and the scroll controller.
base class TrinaDropdownMenuState<T> extends State<TrinaDropdownMenu<T>> {
  late final ScrollController scrollController = ScrollController();

  late final ValueNotifier<List<T>> itemsNotifier;

  /// A helper method to get the comparable value from an item using the
  /// provided [TrinaDropdownMenu.itemToValue] function.
  dynamic getComparableValue(T item) {
    return widget.itemToValue?.call(item) ?? item;
  }

  @override
  void initState() {
    super.initState();

    itemsNotifier = ValueNotifier(widget.items);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!scrollController.hasClients) return;
      final initialValue = widget.initialValue;
      if (initialValue == null) return;

      final initialValueComparable = getComparableValue(initialValue);
      final initialItemIndex = itemsNotifier.value.indexWhere(
        (element) => getComparableValue(element) == initialValueComparable,
      );
      if (initialItemIndex == -1) return;
      scrollController.animateTo(
        widget.itemHeight * initialItemIndex,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    itemsNotifier.dispose();
    scrollController.dispose();
    super.dispose();
  }

  /// Provides a widget builder for the empty state, if any.
  ///
  /// Subclasses should override this to provide context-specific empty states,
  /// for example, when a search or filter operation yields no results.
  WidgetBuilder? get emptyStateBuilder => null;

  @override
  Widget build(BuildContext context) {
    return _InheritedTrinaDropdownMenu<T>(
      state: this,
      child: Builder(
        builder: (context) {
          return ConstrainedBox(
            constraints: BoxConstraints(minWidth: widget.width),
            child: widget.builder(context),
          );
        },
      ),
    );
  }
}

/// The implementation of [TrinaDropdownMenu.withSearch].
final class _TrinaSelectMenuWithSearch<T> extends TrinaDropdownMenu<T> {
  _TrinaSelectMenuWithSearch({
    this.emptySearchResultBuilder,
    super.key,
    super.itemBuilder,
    super.itemToValue,
    required super.items,
    required String Function(T) itemToString,
    required super.onItemSelected,
    required super.width,
    required super.initialValue,
    required super.itemHeight,
    required super.maxHeight,
  }) : super._(
         variant: TrinaDropdownMenuVariant.selectWithSearch,
         itemToString: itemToString,
         builder: (context) {
           final state =
               (TrinaDropdownMenu.of<T>(context)
                   as _TrinaSelectMenuWithSearchState<T>);
           return FocusScope(
             onKeyEvent: (node, event) {
               if (event.character != null) {
                 if (state.focusNode.hasFocus == false) {
                   // Focus the search text field in order
                   // to receive input from the keyboard.
                   state.focusNode.requestFocus();
                 }
               }
               return KeyEventResult.ignored;
             },
             child: SizedBox(
               width: width,
               height: maxHeight,
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   _SearchField<T>(),
                   Divider(
                     height: 5,
                     color: Theme.of(
                       context,
                     ).colorScheme.onSurface.withAlpha(50),
                   ),
                   Flexible(child: _ItemListView<T>()),
                 ],
               ),
             ),
           );
         },
       );

  /// {@template TrinaDropdownMenu.emptySearchResultBuilder}
  /// Used to provide a custom widget to display when the search yields no results.
  /// {@endtemplate}
  final WidgetBuilder? emptySearchResultBuilder;

  @override
  TrinaDropdownMenuState<T> createState() {
    return _TrinaSelectMenuWithSearchState<T>();
  }
}

/// The state for [_TrinaSelectMenuWithSearch].
final class _TrinaSelectMenuWithSearchState<T>
    extends TrinaDropdownMenuState<T> {
  late final TextEditingController controller = TextEditingController();
  late final FocusNode focusNode = FocusNode();
  Timer? _debounce;
  String? _lastExecutedQuery;

  @override
  initState() {
    super.initState();
    controller.addListener(_onSearchQuery);
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  WidgetBuilder? get emptyStateBuilder {
    final hasSearchQuery = controller.text.isNotEmpty;
    if (hasSearchQuery) {
      return (widget as _TrinaSelectMenuWithSearch<T>).emptySearchResultBuilder;
    }
    return null;
  }

  void _onSearchQuery() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _searchItems);
  }

  void _searchItems() {
    final String query = controller.text.trim();
    // Avoid re-running the search for the same query, for example when the
    // user presses enter multiple times.
    if (query == _lastExecutedQuery) return;

    if (query.isEmpty) {
      itemsNotifier.value = widget.items;
    } else {
      itemsNotifier.value = widget.items.where((item) {
        return widget.itemToString
                ?.call(item)
                .toLowerCase()
                .contains(query.toLowerCase()) ??
            false;
      }).toList();
    }
    _lastExecutedQuery = query;
  }
}

/// A widget that displays the search input field.
class _SearchField<T> extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state =
        (TrinaDropdownMenu.of<T>(context)
            as _TrinaSelectMenuWithSearchState<T>);
    return _EnterKeyListener(
      onEnter: () {
        if (state._debounce?.isActive ?? false) state._debounce!.cancel();
        state._searchItems();
      },
      child: TextField(
        controller: state.controller,
        focusNode: state.focusNode,
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
          contentPadding: const EdgeInsets.all(10),
        ),
      ),
    );
  }
}

/// The implementation of [TrinaDropdownMenu.withFilters].
class _TrinaSelectMenuWithFilters<T> extends TrinaDropdownMenu<T> {
  _TrinaSelectMenuWithFilters({
    required this.filters,
    required super.items,
    required super.onItemSelected,
    required super.width,
    required super.initialValue,
    required super.itemHeight,
    required super.maxHeight,
    this.filtersInitiallyExpanded = true,
    super.itemToString,
    super.itemToValue,
    super.itemBuilder,
    super.key,
    this.emptyFilterResultBuilder,
  }) : assert(
         filters.map((e) => e.title).toSet().length == filters.length,
         'Filter titles must be unique.',
       ),
       super._(
         variant: TrinaDropdownMenuVariant.selectWithFilters,
         builder: (context) {
           final state =
               TrinaDropdownMenu.of<T>(context)
                   as _TrinaSelectMenuWithFiltersState<T>;
           final colorScheme = Theme.of(context).colorScheme;
           return FocusTraversalGroup(
             policy: WidgetOrderTraversalPolicy(),
             child: SizedBox(
               height: maxHeight,
               child: StatefulBuilder(
                 builder: (context, mSetState) {
                   return Row(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       SizedBox(
                         width: width,
                         child: Column(
                           children: [
                             _FiltersSectionButton(
                               filtersIsVisible: state.filtersIsVisible,
                               onPressed: () {
                                 mSetState(() {
                                   state.filtersIsVisible =
                                       !state.filtersIsVisible;
                                 });
                               },
                             ),
                             Divider(
                               height: 0,
                               color: colorScheme.onSurface.withAlpha(50),
                             ),
                             Flexible(child: _ItemListView<T>()),
                           ],
                         ),
                       ),
                       VerticalDivider(
                         width: 0,
                         color: colorScheme.onSurface.withAlpha(50),
                       ),
                       if (state.filtersIsVisible)
                         Container(
                           key: TrinaDropdownMenu.filterSectionKey,
                           child: _FiltersSection<T>(filters: filters),
                         ),
                     ],
                   );
                 },
               ),
             ),
           );
         },
       );

  /// {@template TrinaDropdownMenu.emptyFilterResultBuilder}
  /// The widget to display when the applied filters yield no results.
  /// {@endtemplate}
  final WidgetBuilder? emptyFilterResultBuilder;

  /// {@template TrinaDropdownMenu.filters}
  /// A list of filters that can be applied to the items.
  /// {@endtemplate}
  final List<TrinaDropdownMenuFilter> filters;

  /// {@template TrinaDropdownMenu.filtersInitiallyExpanded}
  /// Whether the filters section is initially visible.
  /// {@endtemplate}
  final bool filtersInitiallyExpanded;

  @override
  createState() => _TrinaSelectMenuWithFiltersState<T>();
}

/// The state for [_TrinaSelectMenuWithFilters].
///
/// This class manages the state of the filters, including which filters are
/// enabled and their current values. It uses a [ValueNotifier] to trigger
/// updates when the filters change.
final class _TrinaSelectMenuWithFiltersState<T>
    extends TrinaDropdownMenuState<T> {
  Timer? _debounce;
  _TrinaSelectMenuWithFilters<T> get _widget =>
      (widget as _TrinaSelectMenuWithFilters<T>);

  /// A [ValueNotifier] that holds the set of currently enabled filter titles.
  ///
  /// This is used to track which filters are active and to trigger updates
  /// when the set of enabled filters changes.
  late final enabledFiltersNotifier = ValueNotifier<Set<String>>(
    _widget.filters.map((e) => e.title).toSet(),
  );

  /// A map that associates each [TrinaDropdownMenuFilter] with a
  /// [TextEditingController].
  ///
  /// This is used to manage the input values for each filter.
  late final filterValueControllers = Map.fromEntries(
    _widget.filters.map((e) => MapEntry(e, TextEditingController())),
  );

  late final hasActiveFilterWithValueNotifier = ValueNotifier<bool>(false);

  late bool filtersIsVisible;

  @override
  void initState() {
    super.initState();
    filtersIsVisible =
        _widget.filtersInitiallyExpanded && _widget.filters.isNotEmpty;
    for (final controller in filterValueControllers.values) {
      controller.addListener(_onFilterChanged);
    }
    enabledFiltersNotifier.addListener(_onFilterChanged);
    hasActiveFilterWithValueNotifier.value = hasActiveFilterWithValue;
  }

  /// This method is called when the filter values change, and it uses a
  /// debounce to avoid applying filters on every keystroke.
  void _onFilterChanged() {
    // Debounce the filtering to avoid excessive updates while the user is typing.
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _filterItems);
    hasActiveFilterWithValueNotifier.value = hasActiveFilterWithValue;
  }

  /// Checks if a filter is currently enabled.
  bool isFilterEnabled(TrinaDropdownMenuFilter filter) {
    return enabledFiltersNotifier.value.contains(filter.title);
  }

  /// Filters the popup items based on the current search text and active filters.
  ///
  /// This method is optimized to perform filtering in a single pass over the
  /// items. It only considers filters that are both enabled and have a non-empty
  /// value.
  void _filterItems() {
    final activeFilters = filterValueControllers.entries.where((entry) {
      return entry.value.text.isNotEmpty && isFilterEnabled(entry.key);
    }).toList();

    if (activeFilters.isEmpty) {
      itemsNotifier.value = widget.items;
      return;
    }

    final tempItems = widget.items.where((item) {
      for (final filterEntry in activeFilters) {
        final valueToFilter = widget.itemToValue?.call(item) ?? item;
        if (!filterEntry.key.filter(valueToFilter, filterEntry.value.text)) {
          return false;
        }
      }
      return true;
    }).toList();

    itemsNotifier.value = tempItems;
  }

  /// Toggles the enabled state of a filter.
  void toggleFilter(TrinaDropdownMenuFilter filter) {
    final currentEnabledFilters = enabledFiltersNotifier.value;
    if (isFilterEnabled(filter)) {
      enabledFiltersNotifier.value = currentEnabledFilters.difference({
        filter.title,
      });
    } else {
      enabledFiltersNotifier.value = currentEnabledFilters.union({
        filter.title,
      });
    }
  }

  bool get hasActiveFilterWithValue =>
      filterValueControllers.values.any((c) => c.text.isNotEmpty);

  @override
  void dispose() {
    _debounce?.cancel();

    for (final controller in filterValueControllers.values) {
      controller.dispose();
    }
    enabledFiltersNotifier.dispose();
    hasActiveFilterWithValueNotifier.dispose();
    super.dispose();
  }

  @override
  WidgetBuilder? get emptyStateBuilder {
    if (hasActiveFilterWithValue) {
      return (widget as _TrinaSelectMenuWithFilters).emptyFilterResultBuilder;
    }
    return null;
  }
}

/// A widget that displays the action buttons for the filter section, such as
/// 'clear all' and 'toggle all'.
class _ActionButtons<T> extends StatelessWidget {
  const _ActionButtons({
    required this.filters,
    required this.menuState,
    required this.colorScheme,
    required this.onClearAll,
    required this.onToggleAll,
    required this.maxWidth,
  });

  final List<TrinaDropdownMenuFilter> filters;
  final _TrinaSelectMenuWithFiltersState<T> menuState;
  final ColorScheme colorScheme;
  final void Function() onClearAll;
  final void Function(bool?) onToggleAll;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(
        horizontal: filters.length >= 2 ? 4 : 22.0,
        vertical: 8,
      ),
      child: FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: menuState.hasActiveFilterWithValueNotifier,
              builder: (context, hasValue, child) {
                return _EnterKeyListener(
                  onEnter: hasValue ? onClearAll : () {},
                  child: TextButton.icon(
                    onPressed: hasValue ? onClearAll : null,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear all'),
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        return states.contains(WidgetState.disabled)
                            ? null
                            : colorScheme.onSurface;
                      }),
                    ),
                  ),
                );
              },
            ),
            ValueListenableBuilder<Set<String>>(
              valueListenable: menuState.enabledFiltersNotifier,
              builder: (context, enabledFilters, child) {
                // Determine the state of the checkbox based on the number of enabled
                // filters. It can be checked, unchecked, or indeterminate (mixed).
                final bool? checkboxValue;
                if (enabledFilters.length == filters.length) {
                  checkboxValue = true;
                } else if (enabledFilters.isEmpty) {
                  checkboxValue = false;
                } else {
                  checkboxValue = null;
                }
                // this's the default Material3 TextButton style
                final textButtonStyle = TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  disabledForegroundColor: colorScheme.onSurface.withAlpha(
                    (0.38 * 255).round(),
                  ),
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  elevation: 0,
                );
                return _EnterKeyListener(
                  onEnter: () => onToggleAll(checkboxValue),
                  child: InkWell(
                    overlayColor: textButtonStyle.overlayColor,
                    borderRadius: BorderRadius.circular(25),
                    onTap: () => onToggleAll(checkboxValue),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          ExcludeFocus(
                            excluding: true,
                            child: Checkbox(
                              visualDensity: VisualDensity.compact,
                              focusColor: Colors.transparent,
                              activeColor: colorScheme.onSurface,
                              hoverColor: Colors.transparent,
                              overlayColor: const WidgetStatePropertyAll(
                                Colors.transparent,
                              ),
                              value: checkboxValue,
                              tristate: true,
                              onChanged: (value) => onToggleAll(value),
                            ),
                          ),
                          const Text('Toggle'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that displays the grid of filters.
class _FiltersGridView<T> extends StatelessWidget {
  const _FiltersGridView({
    required this.filters,
    required this.gridCrossAxisCount,
  });

  final List<TrinaDropdownMenuFilter> filters;
  final int gridCrossAxisCount;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Scrollbar(
        thumbVisibility: true,
        interactive: true,
        child: GridView.builder(
          itemCount: filters.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisExtent: 107,
            maxCrossAxisExtent: 240,
          ),
          itemBuilder: (context, index) => _ActiveFilter<T>(filters[index]),
        ),
      ),
    );
  }
}

/// A widget that displays the entire filtering UI, including the action buttons
/// and the grid of filters.
class _FiltersSection<T> extends StatelessWidget {
  const _FiltersSection({required this.filters});

  final List<TrinaDropdownMenuFilter> filters;

  int get gridCrossAxisCount {
    // Determine the number of columns for the grid based on the number of
    // filters. This is to ensure the layout is responsive and doesn't
    // look too crowded.
    return switch (filters.length) {
      > 2 && < 6 => 2,
      >= 6 => 3,
      _ => 1,
    };
  }

  _TrinaSelectMenuWithFiltersState<T> _menuState(BuildContext context) =>
      TrinaDropdownMenu.of<T>(context) as _TrinaSelectMenuWithFiltersState<T>;

  void _onToggleAll(BuildContext context, bool? value) {
    final menuState = _menuState(context);
    final currentEnabledFilters = menuState.enabledFiltersNotifier.value;

    if (currentEnabledFilters.length == filters.length) {
      menuState.enabledFiltersNotifier.value = <String>{};
    } else {
      menuState.enabledFiltersNotifier.value = filters
          .map((e) => e.title)
          .toSet();
    }
  }

  void _onClearAll(BuildContext context) {
    final controllers = _menuState(context).filterValueControllers;
    for (var controller in controllers.values) {
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuState = _menuState(context);
    final colorScheme = Theme.of(context).colorScheme;
    final sectionWidth = gridCrossAxisCount * 240.0;
    return SizedBox(
      width: sectionWidth,
      child: FocusTraversalGroup(
        policy: WidgetOrderTraversalPolicy(),
        child: Column(
          children: [
            if (filters.length > 1)
              _ActionButtons<T>(
                filters: filters,
                menuState: menuState,
                colorScheme: colorScheme,
                maxWidth: sectionWidth,
                onClearAll: () => _onClearAll(context),
                onToggleAll: (value) => _onToggleAll(context, value),
              ),
            _FiltersGridView<T>(
              filters: filters,
              gridCrossAxisCount: gridCrossAxisCount,
            ),
          ],
        ),
      ),
    );
  }
}

/// A button that shows or hides the filter section.
class _FiltersSectionButton extends StatelessWidget {
  const _FiltersSectionButton({
    required this.onPressed,
    required this.filtersIsVisible,
  });

  final void Function() onPressed;
  final bool filtersIsVisible;

  @override
  Widget build(BuildContext context) {
    return _EnterKeyListener(
      onEnter: () {
        onPressed();
      },
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6),
        title: const Text(
          'Filters',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: AnimatedCrossFade(
          duration: const Duration(milliseconds: 100),
          firstChild: const Icon(Icons.chevron_left),
          secondChild: const Icon(Icons.chevron_right),
          crossFadeState: filtersIsVisible
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
        ),
        onTap: onPressed,
      ),
    );
  }
}

/// A widget that displays a single filter with its checkbox and text field.
class _ActiveFilter<T> extends StatelessWidget {
  const _ActiveFilter(this.filter, {super.key});
  final TrinaDropdownMenuFilter filter;

  @override
  Widget build(BuildContext context) {
    final menuState =
        TrinaDropdownMenu.of<T>(context) as _TrinaSelectMenuWithFiltersState<T>;
    final colorScheme = Theme.of(context).colorScheme;
    return _EnterKeyListener(
      onEnter: () => menuState.toggleFilter(filter),
      child: InkWell(
        onTap: () => menuState.toggleFilter(filter),
        focusColor: colorScheme.onSurface.withAlpha(15),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ValueListenableBuilder(
            valueListenable: menuState.enabledFiltersNotifier,
            builder: (context, value, _) {
              final bool isEnabled = value.contains(filter.title);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            filter.title,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ExcludeFocus(
                          excluding: true,
                          child: Checkbox(
                            overlayColor: WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                            value: isEnabled,
                            onChanged: (value) =>
                                menuState.toggleFilter(filter),
                            visualDensity: VisualDensity.compact,
                            hoverColor: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: _EnterKeyListener(
                      onEnter: () {
                        // Absorb the enter key to prevent the popup from closing
                        // when the user presses enter in the text field.
                      },
                      child: TextField(
                        controller: menuState.filterValueControllers[filter],
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                        mouseCursor: isEnabled
                            ? null
                            : SystemMouseCursors.click,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'value...',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                              color: colorScheme.onSurface.withAlpha(35),
                            ),
                          ),
                          enabled: isEnabled,
                          suffixIcon: isEnabled
                              ? ListenableBuilder(
                                  listenable:
                                      menuState.filterValueControllers[filter]!,
                                  builder: (context, child) {
                                    if (menuState
                                        .filterValueControllers[filter]!
                                        .text
                                        .isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return IconButton(
                                      onPressed: () {
                                        menuState.filterValueControllers[filter]
                                            ?.clear();
                                      },
                                      icon: const Icon(Icons.clear, size: 20),
                                    );
                                  },
                                )
                              : null,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2.0),
                            borderSide: BorderSide(
                              color: colorScheme.onSurface.withAlpha(35),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A widget that displays the list of selectable items.
class _ItemListView<T> extends StatelessWidget {
  const _ItemListView();

  @override
  Widget build(BuildContext context) {
    final menuState = TrinaDropdownMenu.of<T>(context);
    final itemsNotifier = menuState.itemsNotifier;
    final menuWidget = menuState.widget;
    final itemHeight = menuWidget.itemHeight;

    return ValueListenableBuilder<List<T>>(
      valueListenable: itemsNotifier,
      builder: (context, filteredItems, child) {
        if (filteredItems.isEmpty) {
          return menuState.emptyStateBuilder != null
              ? menuState.emptyStateBuilder!(context)
              : ListTile(
                  dense: true,
                  minTileHeight: itemHeight,
                  title: const Text('No matches'),
                );
        }

        return Scrollbar(
          controller: menuState.scrollController,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            controller: menuState.scrollController,
            itemExtent: itemHeight,
            shrinkWrap: true,
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final initialValue = menuWidget.initialValue;
              final isSelected =
                  initialValue != null &&
                  menuState.getComparableValue(item) ==
                      menuState.getComparableValue(initialValue);
              return _EnterKeyListener(
                onEnter: () {
                  menuWidget.onItemSelected(item);
                },
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: menuWidget.width),
                  child: MenuItemButton(
                    onPressed: () {
                      menuWidget.onItemSelected(item);
                    },
                    closeOnActivate: false,
                    autofocus: isSelected,
                    trailingIcon: isSelected
                        ? const Icon(Icons.check, size: 20)
                        : null,
                    child: menuWidget.itemBuilder != null
                        ? menuWidget.itemBuilder!(item)
                        : Text(
                            menuWidget.itemToString?.call(item) ??
                                item.toString(),
                          ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// A helper widget that listens for the 'Enter' key and triggers a callback.
///
/// This is used to work around a focus issue where pressing 'Enter' on a button
/// inside the menu would cause the menu to lose focus.
class _EnterKeyListener extends StatelessWidget {
  const _EnterKeyListener({required this.onEnter, required this.child});
  final void Function() onEnter;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.enter): () {
          onEnter();
        },
      },
      child: child,
    );
  }
}
