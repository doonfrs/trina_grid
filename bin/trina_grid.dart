#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path/path.dart' as path;

void main(List<String> args) {
  // Check if migration flag is present
  if (args.contains('--migrate-from-pluto-grid')) {
    // Remove the migration flag from args to pass remaining args to the migration tool
    final migrationArgs = args
        .where((arg) => arg != '--migrate-from-pluto-grid')
        .toList();

    print('🔄 TrinaGrid Migration Tool');
    print('---------------------------');
    print('Migrating from PlutoGrid to TrinaGrid...\n');

    // Run the migration tool
    runMigration(migrationArgs);
  } else {
    // Show general help if no specific command is provided
    printUsage();
  }
}

void runMigration(List<String> args) {
  // Parse arguments
  bool dryRun = args.contains('--dry-run');
  bool verbose = args.contains('--verbose') || args.contains('-v');
  bool scanAll = args.contains('--scan-all');
  String directory = '.';

  // Check for directory argument
  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--dir' || args[i] == '-d') {
      if (i + 1 < args.length) {
        directory = args[i + 1];
      }
    }
  }

  // Show help if requested
  if (args.contains('--help') || args.contains('-h')) {
    printMigrationUsage();
    return;
  }

  print('🔍 Scanning for PlutoGrid references in $directory...');
  print(
    '${dryRun ? '[DRY RUN] ' : ''}Changes will ${dryRun ? 'NOT ' : ''}be applied.',
  );
  if (scanAll) {
    print(
      'Scanning ALL directories (including build and platform-specific directories).',
    );
  }

  // Define replacements
  final replacements = {
    // Package imports - exact matches for import statements
    "import 'package:pluto_grid/pluto_grid.dart'":
        "import 'package:trina_grid/trina_grid.dart'",
    "import 'package:pluto_grid_plus/pluto_grid_plus.dart'":
        "import 'package:trina_grid/trina_grid.dart'",
    'import "package:pluto_grid/pluto_grid.dart"':
        'import "package:trina_grid/trina_grid.dart"',
    'import "package:pluto_grid_plus/pluto_grid_plus.dart"':
        'import "package:trina_grid/trina_grid.dart"',

    // Package names in pubspec.yaml
    'pluto_grid:': 'trina_grid:',
    'pluto_grid_plus:': 'trina_grid:',

    // Package and main class
    'PlutoGrid': 'TrinaGrid',

    // Column related
    'PlutoColumn': 'TrinaColumn',
    'PlutoColumnGroup': 'TrinaColumnGroup',
    'PlutoColumnType': 'TrinaColumnType',
    'PlutoColumnSort': 'TrinaColumnSort',
    'PlutoColumnFreeze': 'TrinaColumnFreeze',
    'PlutoColumnTextAlign': 'TrinaColumnTextAlign',

    // Row related
    'PlutoRow': 'TrinaRow',
    'PlutoRowType': 'TrinaRowType',
    'PlutoRowColorContext': 'TrinaRowColorContext',

    // Cell related
    'PlutoCell': 'TrinaCell',
    'PlutoCellDisplayType': 'TrinaCellDisplayType',

    // State management
    'PlutoGridStateManager': 'TrinaGridStateManager',
    'PlutoNotifierEvent': 'TrinaNotifierEvent',
    'PlutoGridEventManager': 'TrinaGridEventManager',

    // Selection
    'PlutoGridSelectingMode': 'TrinaGridSelectingMode',

    // Other components
    'PlutoGridConfiguration': 'TrinaGridConfiguration',
    'PlutoGridScrollbarConfig': 'TrinaGridScrollbarConfig',
    'PlutoGridStyleConfig': 'TrinaGridStyleConfig',
    'PlutoGridLocaleText': 'TrinaGridLocaleText',
    'PlutoGridKeyManager': 'TrinaGridKeyManager',
    'PlutoGridKeyPressed': 'TrinaGridKeyPressed',

    // Enums and constants
    'PlutoGridMode': 'TrinaGridMode',
    'PlutoGridScrollUpdateEvent': 'TrinaGridScrollUpdateEvent',
    'PlutoGridScrollAnimationEvent': 'TrinaGridScrollAnimationEvent',
    'PlutoMoveDirection': 'TrinaMoveDirection',

    // Widgets
    'PlutoBaseCell': 'TrinaBaseCell',
    'PlutoBaseColumn': 'TrinaBaseColumn',
    'PlutoBaseRow': 'TrinaBaseRow',
    'PlutoFilterColumnWidgetDelegate': 'TrinaFilterColumnWidgetDelegate',

    // Additional components
    'PlutoAutoSizeMode': 'TrinaAutoSizeMode',
    'PlutoLazyPagination': 'TrinaLazyPagination',
    'PlutoLazyPaginationResponse': 'TrinaLazyPaginationResponse',
    'PlutoPagination': 'TrinaPagination',
  };

  // Run migration
  final stats = migrateDirectory(
    Directory(directory),
    replacements,
    dryRun: dryRun,
    verbose: verbose,
    scanAll: scanAll,
  );

  // Print summary
  print('\n✅ Migration scan complete!');
  print('Directories scanned: ${stats.directoriesScanned}');
  print('Files scanned: ${stats.filesScanned}');
  print('Files modified: ${stats.filesModified}');
  print('Total replacements: ${stats.totalReplacements}');

  if (stats.skippedDirectories.isNotEmpty) {
    print('\nSkipped directories: ${stats.skippedDirectories.length}');
    if (verbose) {
      for (final dir in stats.skippedDirectories) {
        print('  - $dir');
      }
    } else {
      print('  (Use --verbose to see the list of skipped directories)');
    }
    print('\nTo scan ALL directories, use the --scan-all flag.');
  }

  if (dryRun) {
    print('\nRun without --dry-run to apply these changes.');
  }
}

class MigrationStats {
  int directoriesScanned = 0;
  int filesScanned = 0;
  int filesModified = 0;
  int totalReplacements = 0;
  List<String> skippedDirectories = [];
}

MigrationStats migrateDirectory(
  Directory dir,
  Map<String, String> replacements, {
  bool dryRun = false,
  bool verbose = false,
  bool scanAll = false,
}) {
  final stats = MigrationStats();
  stats.directoriesScanned++;

  final dirPath = path.relative(dir.path);
  if (verbose) {
    print('Scanning directory: $dirPath');
  }

  try {
    for (var entity in dir.listSync()) {
      if (entity is File) {
        final ext = path.extension(entity.path).toLowerCase();
        if (['.dart', '.yaml', '.json'].contains(ext)) {
          final fileStats = migrateFile(
            entity,
            replacements,
            dryRun: dryRun,
            verbose: verbose,
          );
          stats.filesScanned++;
          stats.filesModified += fileStats.filesModified;
          stats.totalReplacements += fileStats.totalReplacements;
        }
      } else if (entity is Directory) {
        final dirName = path.basename(entity.path);
        final excludedDirs = [
          'build',
          '.dart_tool',
          '.pub',
          'ios',
          'android',
          'windows',
          'macos',
          'linux',
          'web',
        ];

        // Skip hidden directories and build/cache directories unless scanAll is true
        if (scanAll ||
            (!dirName.startsWith('.') && !excludedDirs.contains(dirName))) {
          final dirStats = migrateDirectory(
            entity,
            replacements,
            dryRun: dryRun,
            verbose: verbose,
            scanAll: scanAll,
          );
          stats.directoriesScanned += dirStats.directoriesScanned;
          stats.filesScanned += dirStats.filesScanned;
          stats.filesModified += dirStats.filesModified;
          stats.totalReplacements += dirStats.totalReplacements;
          stats.skippedDirectories.addAll(dirStats.skippedDirectories);
        } else {
          stats.skippedDirectories.add(path.relative(entity.path));
          if (verbose) {
            print('Skipping directory: ${path.relative(entity.path)}');
          }
        }
      }
    }
  } catch (e) {
    print('Error processing directory ${dir.path}: $e');
  }

  return stats;
}

MigrationStats migrateFile(
  File file,
  Map<String, String> replacements, {
  bool dryRun = false,
  bool verbose = false,
}) {
  final stats = MigrationStats();

  try {
    final content = file.readAsStringSync();
    var newContent = content;
    int replacementCount = 0;

    // Apply all replacements
    for (final entry in replacements.entries) {
      final before = newContent;
      newContent = newContent.replaceAll(entry.key, entry.value);
      final count = _countReplacements(before, newContent, entry.key);
      replacementCount += count;
    }

    // Handle special case for redundant imports
    if (newContent.contains(
      "import 'package:trina_grid_plus/trina_grid_plus.dart';",
    )) {
      newContent = newContent.replaceAll(
        "import 'package:trina_grid_plus/trina_grid_plus.dart';",
        "",
      );
    }

    if (newContent.contains(
      'import "package:trina_grid_plus/trina_grid_plus.dart";',
    )) {
      newContent = newContent.replaceAll(
        'import "package:trina_grid_plus/trina_grid_plus.dart";',
        "",
      );
    }

    // Clean up multiple empty lines
    while (newContent.contains('\n\n\n')) {
      newContent = newContent.replaceAll('\n\n\n', '\n\n');
    }

    if (content != newContent) {
      stats.filesModified = 1;
      stats.totalReplacements = replacementCount;

      final relativePath = path.relative(file.path);
      print('📄 $relativePath: $replacementCount replacements');

      if (verbose) {
        for (final entry in replacements.entries) {
          final count = _countOccurrences(content, entry.key);
          if (count > 0) {
            print('   - ${entry.key} → ${entry.value}: $count occurrences');
          }
        }
      }

      if (!dryRun) {
        file.writeAsStringSync(newContent);
      }
    }
  } catch (e) {
    print('Error processing file ${file.path}: $e');
  }

  return stats;
}

int _countReplacements(String before, String after, String pattern) {
  return _countOccurrences(before, pattern) - _countOccurrences(after, pattern);
}

int _countOccurrences(String text, String pattern) {
  int count = 0;
  int index = 0;
  while (true) {
    index = text.indexOf(pattern, index);
    if (index == -1) break;
    count++;
    index += pattern.length;
  }
  return count;
}

void printUsage() {
  print('TrinaGrid CLI Tool');
  print('----------------');
  print('');
  print('Available commands:');
  print('');
  print(
    '  --migrate-from-pluto-grid  Migrate your codebase from PlutoGrid to TrinaGrid',
  );
  print('');
  print('Example:');
  print('  flutter pub run trina_grid --migrate-from-pluto-grid');
  print('');
  print('For more information on a specific command, run:');
  print('  flutter pub run trina_grid --migrate-from-pluto-grid --help');
}

void printMigrationUsage() {
  print('TrinaGrid Migration Tool');
  print('----------------------');
  print('');
  print(
    'Usage: flutter pub run trina_grid --migrate-from-pluto-grid [options]',
  );
  print('');
  print('Options:');
  print('  --dry-run       Show changes without applying them');
  print(
    '  --dir, -d DIR   Directory to migrate (defaults to current directory)',
  );
  print('  --verbose, -v   Show detailed output');
  print(
    '  --scan-all      Scan all directories, including build and platform-specific directories',
  );
  print('  --help, -h      Show this help message');
  print('');
  print('Examples:');
  print('  # Dry run to see what would be changed');
  print('  flutter pub run trina_grid --migrate-from-pluto-grid --dry-run');
  print('');
  print('  # Migrate a specific directory');
  print(
    '  flutter pub run trina_grid --migrate-from-pluto-grid --dir=lib/screens',
  );
  print('');
  print('  # Show detailed output and scan all directories');
  print(
    '  flutter pub run trina_grid --migrate-from-pluto-grid --verbose --scan-all',
  );
}
