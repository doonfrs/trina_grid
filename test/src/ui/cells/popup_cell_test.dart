import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  group('PopupCell Dark Mode Tests', () {
    test('should detect dark mode configuration correctly', () {
      // Test that dark configuration is properly detected
      final darkConfig = const TrinaGridConfiguration.dark();
      expect(darkConfig.style.isDarkStyle, isTrue);
      expect(darkConfig.style.gridBackgroundColor, const Color(0xFF111111));

      final lightConfig = const TrinaGridConfiguration();
      expect(lightConfig.style.isDarkStyle, isFalse);
      expect(lightConfig.style.gridBackgroundColor, Colors.white);
    });

    test('should create correct base configuration for popups', () {
      // Test the logic used in popup cells
      final darkConfig = const TrinaGridConfiguration.dark();
      final lightConfig = const TrinaGridConfiguration();

      // Simulate the logic from popup_cell.dart
      final baseConfigurationForDark = darkConfig.style.isDarkStyle
          ? const TrinaGridConfiguration.dark()
          : const TrinaGridConfiguration();

      final baseConfigurationForLight = lightConfig.style.isDarkStyle
          ? const TrinaGridConfiguration.dark()
          : const TrinaGridConfiguration();

      expect(baseConfigurationForDark.style.isDarkStyle, isTrue);
      expect(baseConfigurationForLight.style.isDarkStyle, isFalse);
    });

    test('should preserve dark theme properties in popup configuration', () {
      // Test that dark theme properties are preserved when creating popup configuration
      final darkConfig = const TrinaGridConfiguration.dark();

      // Simulate creating a popup configuration with dark theme
      final popupConfiguration = TrinaGridConfiguration(
        tabKeyAction: TrinaGridTabKeyAction.normal,
        style: TrinaGridStyleConfig(
          // Use the base configuration's dark/light theme
          gridBackgroundColor: darkConfig.style.gridBackgroundColor,
          rowColor: darkConfig.style.rowColor,
          activatedColor: darkConfig.style.activatedColor,
          borderColor: darkConfig.style.borderColor,
          gridBorderColor: darkConfig.style.gridBorderColor,
          cellTextStyle: darkConfig.style.cellTextStyle,
          columnTextStyle: darkConfig.style.columnTextStyle,
          iconColor: darkConfig.style.iconColor,
          menuBackgroundColor: darkConfig.style.menuBackgroundColor,
          // Override only the popup-specific properties
          oddRowColor: null,
          evenRowColor: null,
          gridBorderRadius: BorderRadius.zero,
          defaultColumnTitlePadding: TrinaGridSettings.columnTitlePadding,
          defaultCellPadding: TrinaGridSettings.cellPadding,
          rowHeight: TrinaGridSettings.rowHeight,
          enableRowColorAnimation: false,
        ),
      );

      // Verify that dark theme properties are preserved
      expect(
        popupConfiguration.style.gridBackgroundColor,
        const Color(0xFF111111),
      );
      expect(popupConfiguration.style.rowColor, const Color(0xFF111111));
      expect(popupConfiguration.style.activatedColor, const Color(0xFF313131));
      expect(popupConfiguration.style.borderColor, const Color(0xFF222222));
      expect(popupConfiguration.style.gridBorderColor, const Color(0xFF666666));
      expect(popupConfiguration.style.cellTextStyle.color, Colors.white);
      expect(popupConfiguration.style.columnTextStyle.color, Colors.white);
      expect(popupConfiguration.style.iconColor, Colors.white38);
      expect(
        popupConfiguration.style.menuBackgroundColor,
        const Color(0xFF414141),
      );
    });

    test('should preserve dark theme when using copyWith', () {
      // Test that copyWith now correctly preserves dark theme
      final darkConfig = const TrinaGridConfiguration.dark();

      // Test copyWith on the style
      final copiedStyle = darkConfig.style.copyWith(
        oddRowColor: const TrinaOptional(null),
        evenRowColor: const TrinaOptional(null),
        enableRowColorAnimation: false,
      );

      // Verify that dark theme properties are preserved after copyWith
      expect(copiedStyle.isDarkStyle, isTrue);
      expect(copiedStyle.gridBackgroundColor, const Color(0xFF111111));
      expect(copiedStyle.rowColor, const Color(0xFF111111));
      expect(copiedStyle.activatedColor, const Color(0xFF313131));
      expect(copiedStyle.borderColor, const Color(0xFF222222));
      expect(copiedStyle.gridBorderColor, const Color(0xFF666666));
      expect(copiedStyle.cellTextStyle.color, Colors.white);
      expect(copiedStyle.columnTextStyle.color, Colors.white);
      expect(copiedStyle.iconColor, Colors.white38);
      expect(copiedStyle.menuBackgroundColor, const Color(0xFF414141));
    });
  });
}
