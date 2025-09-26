import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  test('TrinaDropdownMenuVariant should be publicly exported', () {
    // This test verifies that TrinaDropdownMenuVariant is accessible
    // without needing implementation imports

    const variant1 = TrinaDropdownMenuVariant.select;
    const variant2 = TrinaDropdownMenuVariant.selectWithSearch;
    const variant3 = TrinaDropdownMenuVariant.selectWithFilters;

    expect(variant1, TrinaDropdownMenuVariant.select);
    expect(variant2, TrinaDropdownMenuVariant.selectWithSearch);
    expect(variant3, TrinaDropdownMenuVariant.selectWithFilters);

    // Test that all enum values are accessible
    expect(TrinaDropdownMenuVariant.values.length, 3);
  });
}
