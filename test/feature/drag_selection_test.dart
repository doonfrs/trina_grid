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
}
