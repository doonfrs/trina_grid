# Changelog

## [2.1.0] - 2025. 09. 30

* Feature: Added comprehensive translations for pagination and time picker. @doonfrs
* Feature: Added pagination enhancements with global configuration (#228). @doonfrs
* Feature: Added simplified column filter API methods for programmatic filter management. @doonfrs
* Feature: Enable column filter visibility in TrinaGrid. @doonfrs
* Fix: Include hidden columns when creating new rows (#226). @doonfrs
* Fix: Update sdk, apply standard dart formatting to all file (#222). @doonfrs
* Fix: Pagination theme updates and height accumulation bug (#221). @doonfrs
* Fix: Export TrinaDropdownMenuVariant to make it publicly accessible (#220). @doonfrs
* Fix: Restored mouse scrolling/dragging functionality that was broken since v1.6.11. @doonfrs
* Breaking Change: Enhanced rowWrapper callback to include TrinaRow data parameter and renamed row widget parameter to rowWidget for clarity. @doonfrs
* Refactor: Use polymorphism to build cell widgets (#167). @DMouayad
* Test: Added comprehensive unit tests for column filter functionality (#209). @doonfrs
* Test: Added comprehensive unit tests for rowWrapper functionality. @doonfrs
* Docs: Added documentation for checkReadOnly dynamic cell read-only functionality (#223). @doonfrs


## [2.0.1] - 2025. 09. 01

* Feature: Enhanced filter color customization system. @doonfrs
* Feature: Added cell-level padding property to TrinaCell. @doonfrs
* Feature: Added validate parameter to changeCellValue method. @doonfrs
* Feature: Added keyboard event handling to TrinaCell. @doonfrs
* Feature: Enhanced TrinaGrid with customizable cell text style. @doonfrs
* Feature: Added cell color functionality to TrinaGrid. @doonfrs
* Enhancement: Added cell field to TrinaGridOnChangedEvent. @doonfrs
* Fix: Preserved horizontal borders for cells with custom background colors. @doonfrs
* Fix: Set default cellReadonlyColor to null to use default cell style. @doonfrs
* Fix: Improved text cell vertical alignment during editing. @doonfrs
* Fix: Reduced multi-line filter icon size to 16px. @doonfrs
* Fix: Improved vertical centering and text styling for edited cells. @doonfrs
* Fix: Enabled onSelected callback to fire in normal mode with comprehensive row selection support. @doonfrs
* Fix: Resolved frozen row alignment issue with dynamic row heights. @doonfrs
* Fix: Improved popup handling in TrinaDateCell. @doonfrs
* Fix: Improved date time cell styling and height adaptation. @doonfrs
* Fix: Prevented cell overflow when both Row checking & drag are enabled. @DMouayad
* Fix: Fixed checkbox overflow in column title. @DMouayad
* Fix: Grid no longer absorbs unregistered shortcuts. @DMouayad
* Fix: Key events now properly ignored when grid doesn't have primary focus. @DMouayad
* Fix: Editing popup no longer shown for readonly cells. @DMouayad

## [2.0.0] - 2025. 08. 16

* Feature: Added new popup cells editing widget, including TrinaSelectMenu, TrinaTimePicker, and TrinaPopup. @DMouayad
* Feature: Added dynamic row height support. @doonfrs
* Fix: Ensure combined date and time validation in TrinaDateTimeCell. @DMouayad
* Feature: Improved initial value handling for date/time pickers. @DMouayad
* Feature: Enhanced pagination footer with direct page input functionality. @doonfrs
* Feature: Added CustomFooterScreen to demo and home screens. @doonfrs
* Feature: Improved time picker UI with scroll-to-change hint. @DMouayad
* Feature: Added closePopupOnSelection option for date columns. @DMouayad
* Feature: Added examples for select and time column constraints in editing popups. @DMouayad
* Fix: Prevent sorting from being triggered when clicking context menu in custom title. @DMouayad
* Feature: Added loading customization to TrinaLazyPagination. @DMouayad
* Feature: Added custom pagination UI and demo support. @DMouayad
* Fix: Corrected empty cell value handling for date/dateTime columns with custom format. @DMouayad
* Fix: Corrected column title height when enableColumnDrag is false. @DMouayad
* Feature: Added read-only color configuration to TrinaGrid. @doonfrs

## [1.6.12] - 2025. 07. 28

* Revert Merge cell feature and add it to private branch. ( by @doonfrs )
* Fix 'There may be a logical error statement in the file filtered_list.dart' ( by @doonfrs )


## [1.6.11] - 2025. 07. 28

* fix: can't start editing while pressing SHIFT key ( by @DMouayad )
* fix: update number formatting in TrinaAggregateColumnFooter ( by @doonfrs )
* fix bug [Bug] Drag&Drop moves selected row but not the dragged row ( by @doonfrs )
* fix bug [Bug] TrinaColumn.formattedValueForType() has to call column types applyFormat() in case TrinaColumnTypeHasFormat implemented by column type. ( by @doonfrs )
* feat: add cell merging functionality ( by @doonfrs )
* fix: column-title background color not applied ( by @DMouayad )
* fix: handle null maxWidth in layout offsets ( by @doonfrs )
* dev: move pluto grid reference into support section ( by @Elia Tolin )
* dev: increase size of Try Live Demo and convert to paragraph "please star" section ( by Elia Tolin)
* fix: unregistered key events do not function when grid in focus ( by @DMouayad)
* fix: Fix empty cell value for date\dateTime columns with custom format (#129) ( by @DMouayad )


## [1.6.10] - 2025. 07. 08

* fix: show_column_menu in scaled screens ( by @WagDevX )
* Use NumberFormat to format the value of TrinaAggregateColumnFooter ( by @DMouayad )
* fix: discontinued cells vertical border when enableCellBorderHorizontal is false ( by @DMouayad )
* fix: change tracking doesn't work when pasting into a cell ( by @DMouayad )
* fix: change tracking doesn't work when cell initial value is null ( by @DMouayad )
* fix: validation in TrinaColumnTypeDate by using dateFormat instead of DateTime for parsing ( by @DMouayad )
* Add configuration for cell border width ( by @DMouayad )
* fix: column sorting when TrinaColumn.titleRenderer is provided ( by @DMouayad )
* Implement RTL-aware movement for grid navigation ( by @doonfrs )
* Fix column freezing not resorted #110 ( by @DMouayad )
* fix failing tests for cell height in popup grids ( by @DMouayad )

## [1.6.9] - 2025. 05. 28

* Fix text input bug where the first character is replaced when typing the second character ( by @doonfrs )
* Add enableAutoSelectFirstRow option to automatically select the first row when in selection mode ( by @doonfrs )
* Add TrinaFilterTypeRegex for filtering using regular expressions (#64) ( by @doonfrs )
* Fix row color bug when activatedColor is transparent ( by @doonfrs )
* Add expandAllRowGroups and collapseAllRowGroups methods to TrinaGridStateManager ( by @doonfrs )
* Add expand flag to toggleExpandedRowGroup method ( by @doonfrs )
* Remove Smooth scrolling, it is not ready in the flutter stable version yet ( by @doonfrs )

## [1.6.8] - 2025. 04. 15

* Fix focus issue when header is a TextField or TextFormField ( by @doonfrs )
* Add RowWrapperScreen to navigation and home screen; update demo with new feature tile ( by @doonfrs )
* Introduce Multi-Items Filter ( by @doonfrs )
* Enhance moving to next row when enter key action is editingAndMoveRight ( by @doonfrs )
* Enhance RTL support by fixing scrollbar positioning and adding RTL scrollbar demo ( by @doonfrs )

## [1.6.7] - 2025. 04. 14

* Introduce date time column type, add example & documentation ( by @doonfrs )
* Add filterEnterKeyAction to TrinaColumn for controlling keyboard navigation in column filters ( by @doonfrs )
* Update row color example ( by @doonfrs )
* Fix horizontal scrollbar calculation issue for the header & footer ( by @doonfrs )
* Added filterIcon option to TrinaGridStyleConfig ( by @doonfrs )

## [1.6.6] - 2025. 03. 22

* Fix lazy pagination rebuild issue for simple pagination & refresh
* Add TrinaGridChangeLazyPageEvent ( by @slavap )
* Flutter 3.27 compatibility ( by @slavap )
* Introduce TitleRenderer for customizable column titles ( by @doonfrs )
* Implement custom loading widget support and add Loading Options feature to documentation and demo ( by @doonfrs )
* Introduce Percentage Column Type ( by @doonfrs )
* add decimalInput option to percentage column type ( by @doonfrs )
* fix unit tests, all tests working, remove skipped tests, translate Korean comments to English ( by @doonfrs )

## [1.6.5] - 2025. 03. 22

* Add PDF export functionality with customizable options
* Introduced PDF export capabilities in the grid export feature, allowing users to export data in PDF format.
* Added options for customizing PDF title, creator, orientation, header and text colors, and styling through a new `TrinaGridExportPdfSettings` class.
* Updated the export dialog to include PDF-specific settings and improved the user interface for selecting columns to export.
* Enhanced documentation to reflect new PDF export features and usage examples.
* Export TrinaColumnTypeHasFormat

## [1.6.4] - 2025. 03. 20

* Use dynamic for column menu delegate, instead of String, update the documentation
* Add ignoreFixedRows option to CSV, JSON, and PDF exports for better data handling

## [1.6.3] - 2025. 03. 20

* Fix selected row style
* Include current row with currentSelectedRows list in case of grid selection mode is row.
* add missing arguments to gridConfiguration.copyWith
* Update column menu example allow merging with the default menu
* Simplify the column menu delegate, adding example for removing one of the default menu items
* Add demo for displaying different menu items for specific columns, update the documentation

## [1.6.2] - 2025. 03. 19

* Enhance Export, fix bug with visible columns
* Change getVisibleColumns to getViewPortVisibleColumns
* Add documentation for view port visible columns, gotoColumn

## [1.6.1] - 2025. 03. 19

* Fix scrollbar drag performance issue
* Add export service to export grid data to csv, pdf, json

## [1.6.0] - 2025. 03. 18

* Refactor scrollbars to be more efficient, support more styling & draggable, add example & documentation
* Add filter to the demo screen to make it easier to find a feature demo code.
* Add some gif images to the documentation, document more features
* add onLazyFetchCompleted event
* add initial export service to export grid data to csv, pdf, json ( under development )
* Update the documentation for boolean columns
* Add scrollbar thumb hover color

## [1.5.3] - 2025. 03. 17

* Implemented functionality to display and customize scrollbars

## [1.5.2] - 2025. 03. 17

* Introduce Boolean Type Column

## [1.5.1] - 2025. 03. 15

* Introduce Change Tracking feature

## [1.5.0] - 2025. 03. 15

### Breaking Changes

* Renamed `editCellWrapper` to `editCellRenderer` for better semantic clarity
* Renamed parameter `editCellWidget` to `defaultEditCellWidget` in editCellRenderer function signature

### Enhancements

* Enhanced editCellRenderer to be column-based
* Added focus node parameter to editCellRenderer to allow custom widgets to maintain grid focus control

## [1.4.16] - 2025. 03. 12

* Enhanced editCellWrapper to be column-based
* Added focus node parameter to editCellWrapper to allow custom widgets to maintain grid focus control

## [1.4.15] - 2025. 03. 11

* Enhance the pluto grid migration script
* Add more documentation

## [1.4.14] - 2025. 03. 11

* Added cell validator for plutoColumn & onValidationFailed for TrinaGrid
* updated some docs

## [1.4.13] - 2025. 03. 10

* Added cell-level renderer support with TrinaCellRenderer

## [1.4.12] - 2025. 03. 10

* fix incase frozen columns & frozen rows
* Enhance the readme texts

## [1.4.11] - 2025. 03. 10

* Introducing Frozen Rows

## [1.4.10] - 2025. 03. 08

* Translate all korean comments & unit tests to english

## [1.4.9] - 2025. 03. 06

* Added scrollToColumn method

## [1.4.8] - 2025. 03. 06

* Added getVisibleColumns method & isColumnVisible

## [1.4.7] - 2025. 03. 04

* Fix pagination bug

## [1.4.6] - 2025. 03. 04

* Remove Stratagy pattern from the pagination widget and simplify the code
* Add total records
* Enhance the ui of the pagination widget

## [1.4.5] - 2025. 03. 01

* add initialPageSize to PageSizeDropdownTrinaLazyPaginationStrategy and default pageSizeToMove to 1
* Fix pagination bug

## [1.4.4] - 2025. 03. 01

* Added pagesize dropdown using strategy pattern
* Upgraded to latest Flutter version
* Used intl any version for compatibility
* Added onClear and clearIcon parameters to filter widgets
* Added filterWidgetDelegate to TrinaColumn
* Added missing filterWidgetBuilder and onFilterSuffixTap parameters
* Updated GitHub Actions tests
* Added optional width parameter to column in TrinaColumnType.select
* Added ability to disable row checkbox under specific conditions
* Fixed issue #105
* Added clear columns filter event
* Added empty screen to homepage
* Added VS Code formatting restrictions
* Fixed unit tests
* Added guard against missing scroll client (when disposed)
* Improved row wrapper implementation
* Changed WidgetBuilder to Widget Function(BuildContext, Widget)
* Enhanced infinity scroll to continue updating if screen not filled
* Fixed homescreen pointing to old package
* Implemented ability to disable row checkbox under conditions
* Added handling for pure checkbox values when disabled
* Added null check to prevent 'Null check operator used on a null value' exception
* Updated intl library to ^0.20.0
* Added onActiveCellChanged event

## [1.4.3] - 2024. 10. 23

* Added rowWrapper & editCellWrapper for the state manager
* Manually detect doubleTaps on desktop platform to eliminate delay
* Several improvements
* Add TrinaGridRowSelectionCheckBehavior which enables automatically setting the CheckBox values of selected rows
* Add TrinaGridRowSelectionCheckBehavior
* Upgrade packages

## [1.4.2] - 2024. 07. 15

* add rowWrapper
* Added an option for developers to use either the standard Material DatePicker or a custom datepicker.
* Datepicker - moved isOpenedPopup = true
* Added the ability to add a custom data property at the row level. For example: you can pass data to onSelect or any other onHandler. (not required)
* Upgrade some used package to the latest version.

## [1.4.1] - 2024. 05. 15

upgrade for flutter 3.22.0

## [1.4.0] - 2024. 04. 01

* Added onRowEnter, onRowExit callbacks to react on. @coruscant187
* Added logic to change background color of row if hovered. @coruscant187 doonfrs/trina_grid#29

## [1.3.1] - 2024. 03. 19

* upgrade packages to latest major version
