import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  testWidgets('Checkbox should be rendered', (WidgetTester tester) async {
    // given
    const bool value = false;

    handleOnChanged(bool? changed) {}

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaScaledCheckbox(
            value: value,
            handleOnChanged: handleOnChanged,
          ),
        ),
      ),
    );

    // then
    expect(find.byType(Checkbox), findsOneWidget);
  });

  testWidgets('Tapping checkbox should call handleOnChanged', (
    WidgetTester tester,
  ) async {
    // given
    bool? value = false;

    handleOnChanged(bool? changed) {
      value = changed;
    }

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrinaScaledCheckbox(
            value: value,
            handleOnChanged: handleOnChanged,
          ),
        ),
      ),
    );

    expect(value, isFalse);

    // then
    await tester.tap(find.byType(Checkbox));

    expect(value, isTrue);
  });
}
