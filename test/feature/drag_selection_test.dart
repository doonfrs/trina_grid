import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  group('Drag Selection Configuration', () {
    test('enableDragSelection defaults to false', () {
      const config = TrinaGridConfiguration();
      expect(config.enableDragSelection, false);
    });

    test('enableDragSelection can be set to true', () {
      const config = TrinaGridConfiguration(enableDragSelection: true);
      expect(config.enableDragSelection, true);
    });

    test('enableDragSelection works with copyWith', () {
      const config = TrinaGridConfiguration();
      final updatedConfig = config.copyWith(enableDragSelection: true);
      expect(updatedConfig.enableDragSelection, true);
    });
  });

  // TODO: Add integration tests for drag selection behavior
  // These will require proper widget testing infrastructure:
  // - Test pointer down starts drag selection
  // - Test pointer move updates selection range
  // - Test pointer up ends drag selection
  // - Test auto-scroll during drag near edges
  // - Test drag only works in cell selecting mode
  // - Test Ctrl/Shift keys don't trigger drag
}
