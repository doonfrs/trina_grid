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

  // TODO: Add integration tests for Ctrl+Click multi-select behavior
  // These will require proper widget testing infrastructure:
  // - Test Ctrl+Click toggles individual cell selection
  // - Test Ctrl+Click on selected cell deselects it
  // - Test multiple Ctrl+Clicks build selection set
  // - Test click without Ctrl clears individual selections
  // - Test Shift+Click still works alongside individual selections
  // - Test individual selections are included in currentSelectingPositionList
  // - Test only works in cell selecting mode
}
