import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  group('Ctrl+Click Multi-Select Configuration', () {
    test('enableCtrlClickMultiSelect defaults to false', () {
      const config = TrinaGridConfiguration();
      expect(config.enableCtrlClickMultiSelect, false);
    });

    test('enableCtrlClickMultiSelect can be set to true', () {
      const config = TrinaGridConfiguration(enableCtrlClickMultiSelect: true);
      expect(config.enableCtrlClickMultiSelect, true);
    });

    test('enableCtrlClickMultiSelect works with copyWith', () {
      const config = TrinaGridConfiguration();
      final updatedConfig = config.copyWith(enableCtrlClickMultiSelect: true);
      expect(updatedConfig.enableCtrlClickMultiSelect, true);
    });
  });
}
