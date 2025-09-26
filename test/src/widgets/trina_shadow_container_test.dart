import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  testWidgets('Child should be rendered', (WidgetTester tester) async {
    // given
    const child = Text('child widget');

    // when
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: TrinaShadowContainer(width: 100, height: 50, child: child),
        ),
      ),
    );

    // then
    expect(find.text('child widget'), findsOneWidget);
  });
}
