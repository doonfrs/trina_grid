import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  group('Filtering Int List for even numbers.', () {
    List<int> originalList;

    late FilteredList<int> list;

    setUp(() {
      originalList = [1, 2, 3, 4, 5, 6, 7, 8, 9];

      list = FilteredList(initialList: originalList);

      list.setFilter((element) => element % 2 == 0);
    });

    test('originalList should return unfiltered values', () {
      expect(list.originalList.length, 9);

      list.setFilter(null);

      expect(list.originalList.length, 9);
    });

    test('filteredList should return filtered values', () {
      expect(list.filteredList.length, 4);

      list.setFilter(null);

      expect(list.filteredList.length, 0);
    });

    test('length should be applied', () {
      expect(list.length, 4);

      list.setFilter(null);

      expect(list.length, 9);
    });

    test('should return value at specific index', () {
      expect(list[0], 2);
      expect(list.first, 2);

      expect(list[3], 8);
      expect(list.last, 8);

      list.setFilter(null);

      expect(list[0], 1);
      expect(list.first, 1);

      expect(list[8], 9);
      expect(list.last, 9);
    });

    test('Destructuring return values should be reflected', () {
      expect([...list], [2, 4, 6, 8]);

      list.setFilter(null);

      expect([...list], [1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });

    group('Modifying elements.', () {
      setUp(() {
        list[1] = 40;
      });

      test('Modified elements should be reflected', () {
        expect(list, [2, 40, 6, 8]);

        list.setFilter(null);

        expect(list, [1, 2, 3, 40, 5, 6, 7, 8, 9]);
      });

      test('Modified elements should be reflected when sorting', () {
        list.sort();

        expect(list, [2, 6, 8, 40]);

        reverse(int a, int b) => a < b ? 1 : (a > b ? -1 : 0);

        list.sort(reverse);

        expect(list, [40, 8, 6, 2]);

        list.setFilter(null);

        list.sort();

        expect(list, [1, 2, 3, 5, 6, 7, 8, 9, 40]);
      });
    });

    group('Adding elements.', () {
      setUp(() {
        list.add(10);
      });

      test('Added elements should be reflected', () {
        expect(list, [2, 4, 6, 8, 10]);

        list.setFilter(null);

        expect(list, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      });

      test('length should be reflected', () {
        expect(list.length, 5);

        list.setFilter(null);

        expect(list.length, 10);
      });
    });

    group('Removing elements using remove.', () {
      setUp(() {
        // When filtering, elements outside the filter range cannot be deleted
        var removeOne = list.remove(1);
        expect(removeOne, isFalse);

        var removeTwo = list.remove(2);
        expect(removeTwo, isTrue);
      });

      test('length should be reflected', () {
        expect(list.length, 3);

        expect(list, [4, 6, 8]);

        list.setFilter(null);

        expect(list.length, 8);

        expect(list, [1, 3, 4, 5, 6, 7, 8, 9]);
      });
    });

    group('Removing elements using removeFromOriginal.', () {
      setUp(() {
        var removeOne = list.removeFromOriginal(1);
        expect(removeOne, isTrue);

        var removeTwo = list.removeFromOriginal(2);
        expect(removeTwo, isTrue);
      });

      test('length should be reflected', () {
        expect(list.length, 3);

        expect(list, [4, 6, 8]);

        list.setFilter(null);

        expect(list.length, 7);

        expect(list, [3, 4, 5, 6, 7, 8, 9]);
      });
    });

    group('Removing elements using removeWhere.', () {
      setUp(() {
        // When filtering, elements outside the filter range cannot be deleted
        list.removeWhere((element) => element == 1);
        list.removeWhere((element) => element == 2);
      });

      test('length should be reflected', () {
        expect(list.length, 3);

        expect(list, [4, 6, 8]);

        list.setFilter(null);

        expect(list.length, 8);

        expect(list, [1, 3, 4, 5, 6, 7, 8, 9]);
      });
    });

    group('Removing elements using removeWhereFromOriginal.', () {
      setUp(() {
        list.removeWhereFromOriginal((element) => element == 1);
        list.removeWhereFromOriginal((element) => element == 2);
      });

      test('length should be reflected', () {
        expect(list.length, 3);

        expect(list, [4, 6, 8]);

        list.setFilter(null);

        expect(list.length, 7);

        expect(list, [3, 4, 5, 6, 7, 8, 9]);
      });
    });

    group('Removing elements using retainWhere.', () {
      setUp(() {
        // When filtering, elements outside the filter range cannot be deleted
        list.retainWhere((element) => element > 2);
      });

      test('length should be reflected', () {
        expect(list.length, 3);

        expect(list, [4, 6, 8]);

        list.setFilter(null);

        expect(list.length, 8);

        expect(list, [1, 3, 4, 5, 6, 7, 8, 9]);
      });
    });

    group('Removing elements using retainWhereFromOriginal.', () {
      setUp(() {
        list.retainWhereFromOriginal((element) => element > 2);
      });

      test('length should be reflected', () {
        expect(list.length, 3);

        expect(list, [4, 6, 8]);

        list.setFilter(null);

        expect(list.length, 7);

        expect(list, [3, 4, 5, 6, 7, 8, 9]);
      });
    });

    group('Removing elements using clear.', () {
      setUp(() {
        // When filtering, elements outside the filter range cannot be deleted
        list.clear();
      });

      test('length should be reflected', () {
        expect(list.length, 0);

        expect(list, <int>[]);

        list.setFilter(null);

        expect(list.length, 5);

        expect(list, [1, 3, 5, 7, 9]);
      });
    });

    group('Removing elements using clearFromOriginal.', () {
      setUp(() {
        list.clearFromOriginal();
      });

      test('length should be reflected', () {
        expect(list.length, 0);

        expect(list, <int>[]);

        list.setFilter(null);

        expect(list.length, 0);

        expect(list, <int>[]);
      });
    });

    group('Removing elements using removeLast.', () {
      setUp(() {
        list.removeLast();
      });

      test('length should be reflected', () {
        expect(list.length, 3);

        expect(list, [2, 4, 6]);

        list.setFilter(null);

        expect(list.length, 8);

        expect(list, [1, 2, 3, 4, 5, 6, 7, 9]);
      });
    });

    group('Removing elements using removeLastFromOriginal.', () {
      setUp(() {
        list.removeLastFromOriginal();
      });

      test('length should be reflected', () {
        expect(list.length, 4);

        expect(list, [2, 4, 6, 8]);

        list.setFilter(null);

        expect(list.length, 8);

        expect(list, [1, 2, 3, 4, 5, 6, 7, 8]);
      });
    });

    group('Shuffling elements.', () {
      setUp(() {
        list.shuffle();
      });

      test('length should be reflected', () {
        expect(list.length, 4);

        expect(list.contains(2), isTrue);
        expect(list.contains(4), isTrue);
        expect(list.contains(6), isTrue);
        expect(list.contains(8), isTrue);

        list.setFilter(null);

        expect(list.length, 9);

        expect(list.contains(1), isTrue);
        expect(list.contains(2), isTrue);
        expect(list.contains(3), isTrue);
        expect(list.contains(4), isTrue);
        expect(list.contains(5), isTrue);
        expect(list.contains(6), isTrue);
        expect(list.contains(7), isTrue);
        expect(list.contains(8), isTrue);
        expect(list.contains(9), isTrue);
      });
    });

    test('asMap.', () {
      final filteredMap = list.asMap();

      expect(filteredMap, {0: 2, 1: 4, 2: 6, 3: 8});

      list.setFilter(null);

      final map = list.asMap();

      expect(map, {0: 1, 1: 2, 2: 3, 3: 4, 4: 5, 5: 6, 6: 7, 7: 8, 8: 9});
    });

    group('Inserting elements using insert.', () {
      setUp(() {
        list.setFilter(null);

        list.insert(0, -2);
      });
    });

    group('Inserting elements using insertAll.', () {
      setUp(() {
        list.insert(4, 10);
      });

      test('length should be reflected', () {
        expect(list.length, 5);

        expect(list, [2, 4, 6, 8, 10]);

        list.setFilter(null);

        expect(list.length, 10);

        expect(list, [1, 2, 3, 4, 5, 6, 7, 8, 10, 9]);
      });
    });

    group('Removing 4 elements with removeAt.', () {
      setUp(() {
        list.removeAt(1);
      });

      test('length should be reflected', () {
        expect(list.length, 3);

        expect(list, [2, 6, 8]);

        list.setFilter(null);

        expect(list.length, 8);

        expect(list, [1, 2, 3, 5, 6, 7, 8, 9]);
      });

      test(
        'index out of range error should be thrown when removing element outside the filter range',
        () {
          expect(list.length, 3);

          expect(
            () => list.removeAt(3),
            throwsA(const TypeMatcher<RangeError>()),
          );

          list.setFilter(null);

          expect(list.length, 8);

          expect(
            () => list.removeAt(8),
            throwsA(const TypeMatcher<RangeError>()),
          );
        },
      );
    });

    group('Inserting elements using insertAll.', () {
      setUp(() {
        list.insertAll(0, [-3, -2]);
      });

      test('length should be reflected', () {
        expect(list.length, 5);

        expect(list, [-2, 2, 4, 6, 8]);

        list.setFilter(null);

        expect(list.length, 11);

        expect(list, [1, -3, -2, 2, 3, 4, 5, 6, 7, 8, 9]);
      });
    });

    group('Inserting elements at position 8', () {
      setUp(() {
        list.setFilter(null);

        list.insertAll(8, [-9, -10]);
      });

      test('length should be reflected', () {
        expect(list.length, 11);

        expect(list, [1, 2, 3, 4, 5, 6, 7, 8, -9, -10, 9]);
      });
    });

    group('Inserting elements at end', () {
      setUp(() {
        list.setFilter(null);

        list.insertAll(9, [10, 11]);
      });

      test('length should be reflected', () {
        expect(list.length, 11);

        expect(list, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);
      });
    });
  });

  group('pagination', () {
    late List<int> originalList;

    late FilteredList<int> list;

    setUp(() {
      originalList = [1, 2, 3, 4, 5, 6, 7, 8, 9];

      list = FilteredList(initialList: originalList);
    });

    test('Setting initial range 0, 3 should return [1, 2, 3]', () {
      list.setFilterRange(FilteredListRange(0, 3));

      expect(list, [1, 2, 3]);
      expect(list.length, 3);
    });

    test('Setting range 3, 6 should return [4, 5, 6]', () {
      list.setFilterRange(FilteredListRange(3, 6));

      expect(list, [4, 5, 6]);
      expect(list.length, 3);
    });

    test('Setting filterRange to null should return originalList', () {
      list.setFilterRange(null);

      expect(list, originalList);
      expect(list.length, originalList.length);
    });

    test('Setting range back to 3, 6 should return [4, 5, 6]', () {
      list.setFilterRange(FilteredListRange(3, 6));

      expect(list, [4, 5, 6]);
      expect(list.length, 3);
    });

    test('Setting out of bounds filterRange should return empty list', () {
      list.setFilterRange(FilteredListRange(10, 13));

      expect(list, []);
      expect(list.length, 0);
    });

    group('With List filtering ', () {
      setUp(() {
        list.setFilter((element) => element % 2 == 0);
      });

      test('Setting range 0, 3 should return [2, 4, 6]', () {
        list.setFilterRange(FilteredListRange(0, 3));

        expect(list, [2, 4, 6]);
        expect(list.length, 3);
      });

      test('Setting range 1, 3 should return [4, 6]', () {
        list.setFilterRange(FilteredListRange(1, 3));

        expect(list, [4, 6]);
        expect(list.length, 2);
      });

      test('Setting filterRange to null should return originalList', () {
        list.setFilterRange(null);

        expect(list, [2, 4, 6, 8]);
        expect(list.length, 4);
      });

      test('The array should be filtered and paginated.', () {
        list = FilteredList(
          initialList: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        );

        // 2, 4, 6, 8, 10, 12
        list.setFilter((value) => value % 2 == 0);

        // 4, 6
        list.setFilterRange(FilteredListRange(1, 3));

        expect(list, [4, 6]);
        expect(list.length, 2);

        // 2, 4, 6, 8, 10, 12
        list.setFilterRange(null);

        expect(list, [2, 4, 6, 8, 10, 12]);
        expect(list.length, 6);

        // 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
        list.setFilter(null);

        expect(list, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
        expect(list.length, 12);

        // 4, 5, 6
        list.setFilterRange(FilteredListRange(3, 6));

        expect(list, [4, 5, 6]);
        expect(list.length, 3);
      });
    });
  });

  group('pagination and insertAll', () {
    late List<int> originalList;

    late FilteredList<int> list;

    setUp(() {
      originalList = [1, 2, 3, 4, 5, 6, 7, 8, 9];

      list = FilteredList(initialList: originalList);
    });

    test('After filtering with 0, 3, insertAll [31, 32] after 3', () {
      list.setFilterRange(FilteredListRange(0, 3));

      expect(list, [1, 2, 3]);

      list.insertAll(3, [31, 32]);

      expect(list.originalList, [1, 2, 3, 31, 32, 4, 5, 6, 7, 8, 9]);
    });

    test('After filtering with 0, 3, insertAll [31, 32] before 1', () {
      list.setFilterRange(FilteredListRange(0, 3));

      expect(list, [1, 2, 3]);

      list.insertAll(0, [31, 32]);

      expect(list.originalList, [31, 32, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });

    test('After filtering with 7, 9, insertAll [91, 92] after 9', () {
      list.setFilterRange(FilteredListRange(7, 9));

      expect(list, [8, 9]);

      list.insertAll(2, [91, 92]);

      expect(list.originalList, [1, 2, 3, 4, 5, 6, 7, 8, 9, 91, 92]);
    });

    test('After filtering with 7, 9, insertAll [91, 92] after 8', () {
      list.setFilterRange(FilteredListRange(7, 9));

      expect(list, [8, 9]);

      list.insertAll(1, [91, 92]);

      expect(list.originalList, [1, 2, 3, 4, 5, 6, 7, 8, 91, 92, 9]);
    });

    test('After filtering with 8, 10, insertAll [91, 92] before 8', () {
      list.setFilterRange(FilteredListRange(7, 9));

      expect(list, [8, 9]);

      list.insertAll(0, [91, 92]);

      expect(list.originalList, [1, 2, 3, 4, 5, 6, 7, 91, 92, 8, 9]);
    });
  });

  group('Edge case tests for range boundary conditions', () {
    late FilteredList<int> list;

    setUp(() {
      list = FilteredList(initialList: [1, 2, 3, 4, 5, 6]);
    });

    test(
      'Setting range to exactly maxLength should work without index out of bounds',
      () {
        // Test with unfiltered list: maxLength = 6
        list.setFilterRange(FilteredListRange(0, 6));
        expect(list, [1, 2, 3, 4, 5, 6]);
        expect(list.length, 6);

        // Test accessing elements to ensure no index out of bounds
        expect(list[0], 1);
        expect(list[5], 6);
      },
    );

    test(
      'Setting range to exactly filteredList length should work without index out of bounds',
      () {
        // Filter for even numbers: [2, 4, 6] - maxLength = 3
        list.setFilter((element) => element % 2 == 0);
        expect(list.filteredList, [2, 4, 6]);

        // Set range to exactly the filtered length
        list.setFilterRange(FilteredListRange(0, 3));
        expect(list, [2, 4, 6]);
        expect(list.length, 3);

        // Test accessing elements to ensure no index out of bounds
        expect(list[0], 2);
        expect(list[2], 6);
      },
    );

    test(
      'Setting range that would go beyond maxLength should be safely clamped',
      () {
        // Test with unfiltered list: maxLength = 6
        list.setFilterRange(FilteredListRange(0, 10)); // Beyond maxLength
        expect(list, [1, 2, 3, 4, 5, 6]);
        expect(list.length, 6);
      },
    );

    test(
      'Setting range with from equals to maxLength should return empty list',
      () {
        // Test with unfiltered list: maxLength = 6
        list.setFilterRange(FilteredListRange(6, 8)); // from >= maxLength
        expect(list, []);
        expect(list.length, 0);
      },
    );
  });
}
