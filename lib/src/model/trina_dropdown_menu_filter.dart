/// A filter for the items in a [TrinaDropdownMenu].
class TrinaDropdownMenuFilter {
  /// The name of the filter to be displayed in the menu.
  final String title;

  /// The filtering logic.
  ///
  /// Takes the item's value and the search text, and returns true if it's a match.
  final bool Function(dynamic itemValue, String searchText) filter;

  const TrinaDropdownMenuFilter({required this.title, required this.filter})
    : assert(title != '', 'Filter title cannot be empty');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrinaDropdownMenuFilter &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;

  /// A filter that checks if the item's value contains the search text.
  static final contains = TrinaDropdownMenuFilter(
    title: 'Contains',
    filter: (itemValue, searchText) {
      final iv = itemValue.toString().toLowerCase();
      final st = searchText.toLowerCase().trim();
      return iv.contains(st);
    },
    // itemValue.toString().toLowerCase().contains(searchText.toLowerCase()),
  );

  /// A filter that checks if the item's value is equal to the search text.
  static final equals = TrinaDropdownMenuFilter(
    title: 'Equals',
    filter: (itemValue, searchText) =>
        itemValue.toString().toLowerCase() == searchText.toLowerCase(),
  );

  /// A filter that checks if the item's value starts with the search text.
  static final startsWith = TrinaDropdownMenuFilter(
    title: 'Starts with',
    filter: (itemValue, searchText) =>
        itemValue.toString().toLowerCase().startsWith(searchText.toLowerCase()),
  );

  /// A filter that checks if the item's value ends with the search text.
  static final endsWith = TrinaDropdownMenuFilter(
    title: 'Ends with',
    filter: (itemValue, searchText) =>
        itemValue.toString().toLowerCase().endsWith(searchText.toLowerCase()),
  );

  /// A filter that checks if the item's value is greater than the search text.
  static final greaterThan = TrinaDropdownMenuFilter(
    title: 'Greater than',
    filter: (itemValue, searchText) {
      final valueNum = itemValue is num
          ? itemValue
          : num.tryParse(itemValue.toString());

      final searchNum = num.tryParse(searchText.trim());
      if (valueNum == null || searchNum == null) return false;
      return valueNum > searchNum;
    },
  );

  /// A filter that checks if the item's value is greater than or equal to the search text.
  static final greaterThanOrEqualTo = TrinaDropdownMenuFilter(
    title: 'Greater than or equal to',
    filter: (itemValue, searchText) {
      final valueNum = itemValue is num
          ? itemValue
          : num.tryParse(itemValue.toString());

      final searchNum = num.tryParse(searchText.trim());
      if (valueNum == null || searchNum == null) return false;
      return valueNum >= searchNum;
    },
  );

  /// A filter that checks if the item's value is less than the search text.
  static final lessThan = TrinaDropdownMenuFilter(
    title: 'Less than',
    filter: (itemValue, searchText) {
      final valueNum = itemValue is num
          ? itemValue
          : num.tryParse(itemValue.toString());
      final searchNum = num.tryParse(searchText.trim());
      if (valueNum == null || searchNum == null) return false;
      return valueNum < searchNum;
    },
  );

  /// A filter that checks if the item's value is less than or equal to the search text.
  static final lessThanOrEqualTo = TrinaDropdownMenuFilter(
    title: 'Less than or equal to',
    filter: (itemValue, searchText) {
      final valueNum = itemValue is num
          ? itemValue
          : num.tryParse(itemValue.toString());
      final searchNum = num.tryParse(searchText.trim());
      if (valueNum == null || searchNum == null) return false;
      return valueNum <= searchNum;
    },
  );
}
