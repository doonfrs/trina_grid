/// A filter for the items in a [TrinaSelectMenu].
class TrinaSelectMenuFilter {
  /// The name of the filter to be displayed in the menu.
  final String title;

  /// The filtering logic.
  ///
  /// Takes the item's value and the search text, and returns true if it's a match.
  final bool Function(dynamic itemValue, String searchText) filter;

  const TrinaSelectMenuFilter({required this.title, required this.filter});

  /// A filter that checks if the item's value contains the search text.
  static final contains = TrinaSelectMenuFilter(
    title: 'Contains',
    filter: (itemValue, searchText) =>
        itemValue.toString().toLowerCase().contains(searchText.toLowerCase()),
  );

  /// A filter that checks if the item's value is equal to the search text.
  static final equals = TrinaSelectMenuFilter(
    title: 'Equals',
    filter: (itemValue, searchText) =>
        itemValue.toString().toLowerCase() == searchText.toLowerCase(),
  );

  /// A filter that checks if the item's value starts with the search text.
  static final startsWith = TrinaSelectMenuFilter(
    title: 'Starts with',
    filter: (itemValue, searchText) =>
        itemValue.toString().toLowerCase().startsWith(searchText.toLowerCase()),
  );

  /// A filter that checks if the item's value ends with the search text.
  static final endsWith = TrinaSelectMenuFilter(
    title: 'Ends with',
    filter: (itemValue, searchText) =>
        itemValue.toString().toLowerCase().endsWith(searchText.toLowerCase()),
  );

  /// A filter that checks if the item's value is greater than the search text.
  static final greaterThan = TrinaSelectMenuFilter(
    title: 'Greater than',
    filter: (itemValue, searchText) {
      final valueNum = num.tryParse(itemValue.toString());
      final searchNum = num.tryParse(searchText);
      if (valueNum == null || searchNum == null) return false;
      return valueNum > searchNum;
    },
  );

  /// A filter that checks if the item's value is greater than or equal to the search text.
  static final greaterThanOrEqualTo = TrinaSelectMenuFilter(
    title: 'Greater than or equal to',
    filter: (itemValue, searchText) {
      final valueNum = num.tryParse(itemValue.toString());
      final searchNum = num.tryParse(searchText);
      if (valueNum == null || searchNum == null) return false;
      return valueNum >= searchNum;
    },
  );

  /// A filter that checks if the item's value is less than the search text.
  static final lessThan = TrinaSelectMenuFilter(
    title: 'Less than',
    filter: (itemValue, searchText) {
      final valueNum = num.tryParse(itemValue.toString());
      final searchNum = num.tryParse(searchText);
      if (valueNum == null || searchNum == null) return false;
      return valueNum < searchNum;
    },
  );

  /// A filter that checks if the item's value is less than or equal to the search text.
  static final lessThanOrEqualTo = TrinaSelectMenuFilter(
    title: 'Less than or equal to',
    filter: (itemValue, searchText) {
      final valueNum = num.tryParse(itemValue.toString());
      final searchNum = num.tryParse(searchText);
      if (valueNum == null || searchNum == null) return false;
      return valueNum <= searchNum;
    },
  );

  /// The default list of filters.
  static final defaultFilters = [contains, equals, startsWith, endsWith];
}
