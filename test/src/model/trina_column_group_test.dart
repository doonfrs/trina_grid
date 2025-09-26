import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  test('When fields is null'
      'and children is null'
      'then assert error should be thrown.', () {
    expect(
      () =>
          TrinaColumnGroup(title: 'column group', fields: null, children: null),
      throwsAssertionError,
    );
  });

  test('When fields is null'
      'and children is empty list'
      'then assert error should be thrown.', () {
    expect(
      () => TrinaColumnGroup(title: 'column group', fields: null, children: []),
      throwsAssertionError,
    );
  });

  test('When fields is null'
      'and children has at least one element'
      'then assert error should not be thrown.', () {
    expect(
      () => TrinaColumnGroup(
        title: 'column group',
        fields: null,
        children: [
          TrinaColumnGroup(title: 'title', fields: ['column1']),
        ],
      ),
      isNot(throwsAssertionError),
    );
  });

  test('When fields is empty list'
      'and children is null'
      'then assert error should be thrown.', () {
    expect(
      () => TrinaColumnGroup(title: 'column group', fields: [], children: null),
      throwsAssertionError,
    );
  });

  test('When fields is empty list'
      'and children is empty list'
      'then assert error should be thrown.', () {
    expect(
      () => TrinaColumnGroup(title: 'column group', fields: [], children: []),
      throwsAssertionError,
    );
  });

  test('When fields is empty list'
      'and children is not empty list'
      'then assert error should be thrown.', () {
    expect(
      () => TrinaColumnGroup(
        title: 'column group',
        fields: [],
        children: [
          TrinaColumnGroup(title: 'title', fields: ['column1']),
        ],
      ),
      throwsAssertionError,
    );
  });

  test('When fields is not empty list'
      'and children is empty list'
      'then assert error should be thrown.', () {
    expect(
      () => TrinaColumnGroup(
        title: 'column group',
        fields: ['column1'],
        children: [],
      ),
      throwsAssertionError,
    );
  });

  test('When fields is not empty list'
      'and children is not empty list'
      'then assert error should be thrown.', () {
    expect(
      () => TrinaColumnGroup(
        title: 'column group',
        fields: ['column1'],
        children: [
          TrinaColumnGroup(title: 'sub group', fields: ['column2']),
        ],
      ),
      throwsAssertionError,
    );
  });

  test('When fields is not empty list'
      'and children is null'
      'then assert error should not be thrown.', () {
    expect(
      () => TrinaColumnGroup(
        title: 'column group',
        fields: ['column1'],
        children: null,
      ),
      isNot(throwsAssertionError),
    );
  });

  test('When fields is null'
      'and children has at least one element'
      'then hasFields should be false and hasChildren should be true.', () {
    final columnGroup = TrinaColumnGroup(
      title: 'column group',
      fields: null,
      children: [
        TrinaColumnGroup(title: 'sub group', fields: ['column1']),
      ],
    );

    expect(columnGroup.hasFields, false);
    expect(columnGroup.hasChildren, true);
  });

  test('When fields has at least one element'
      'and children is null'
      'then hasFields should be true and hasChildren should be false.', () {
    final columnGroup = TrinaColumnGroup(
      title: 'column group',
      fields: ['column1'],
      children: null,
    );

    expect(columnGroup.hasFields, true);
    expect(columnGroup.hasChildren, false);
  });

  test('When expandedColumn is true'
      'and fields has more than one element'
      'then assert error should be thrown.', () {
    expect(
      () => TrinaColumnGroup(
        title: 'column group',
        fields: ['column1', 'column2'],
        children: null,
        expandedColumn: true,
      ),
      throwsAssertionError,
    );
  });

  test('When expandedColumn is true'
      'and fields has one element'
      'then assert error should not be thrown.', () {
    expect(
      () => TrinaColumnGroup(
        title: 'column group',
        fields: ['column1'],
        children: null,
        expandedColumn: true,
      ),
      isNot(throwsAssertionError),
    );
  });
}
