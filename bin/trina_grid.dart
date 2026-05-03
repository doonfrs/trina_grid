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
  } else if (args.contains('--generate-llms')) {
    generateLlmsFull();
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

void generateLlmsFull() {
  // Find the repository root by looking for pubspec.yaml
  var dir = Directory.current;
  while (!File(path.join(dir.path, 'pubspec.yaml')).existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      print('Error: Could not find repository root (no pubspec.yaml found).');
      exit(1);
    }
    dir = parent;
  }
  final repoRoot = dir.path;

  final llmTxtFile = File(path.join(repoRoot, 'llm.txt'));
  final docDir = Directory(path.join(repoRoot, 'doc'));
  final indexFile = File(path.join(repoRoot, 'doc', 'index.md'));
  final outputFile = File(path.join(repoRoot, 'llms-full.txt'));

  if (!llmTxtFile.existsSync()) {
    print('Error: llm.txt not found at ${llmTxtFile.path}');
    exit(1);
  }
  if (!docDir.existsSync()) {
    print('Error: doc/ directory not found at ${docDir.path}');
    exit(1);
  }

  const baseUrl = 'https://github.com/doonfrs/trina_grid/blob/main';

  // 1. Extract ordering from doc/index.md by parsing markdown links
  final orderedPaths = <String>[];
  if (indexFile.existsSync()) {
    final indexContent = indexFile.readAsStringSync();
    // Match markdown links like [text](path.md) or [text](path.md#anchor)
    final linkPattern = RegExp(r'\]\(([^)#]+\.md)');
    for (final match in linkPattern.allMatches(indexContent)) {
      orderedPaths.add(match.group(1)!);
    }
  }

  // 2. Discover all .md files in doc/ recursively
  final allDocFiles = docDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.md'))
      .toList();

  // Build a map of relative path -> File for quick lookup
  final fileMap = <String, File>{};
  for (final file in allDocFiles) {
    final relativePath = path
        .relative(file.path, from: docDir.path)
        .replaceAll('\\', '/');
    fileMap[relativePath] = file;
  }

  // 3. Build final ordered list: index.md order first, then remaining files
  //    Skip index.md itself and contributing/ docs (not useful for agents)
  final processedPaths = <String>{};
  final finalOrder = <String>[];

  for (final relPath in orderedPaths) {
    if (fileMap.containsKey(relPath) && !processedPaths.contains(relPath)) {
      if (relPath == 'index.md') continue;
      if (relPath.startsWith('contributing/')) continue;
      if (relPath == 'changelog.md') continue;
      finalOrder.add(relPath);
      processedPaths.add(relPath);
    }
  }

  // Append any .md files not referenced in index.md
  final remainingPaths =
      fileMap.keys
          .where(
            (p) =>
                !processedPaths.contains(p) &&
                p != 'index.md' &&
                !p.startsWith('contributing/'),
          )
          .toList()
        ..sort();
  finalOrder.addAll(remainingPaths);

  // 4. Extract header from llm.txt (everything before the first ## section)
  final llmContent = llmTxtFile.readAsStringSync();
  final firstH2 = llmContent.indexOf('\n## ');
  final header = firstH2 != -1 ? llmContent.substring(0, firstH2) : llmContent;

  // 5. Generate llms-full.txt
  final buffer = StringBuffer();

  // Write header with modified H1
  final headerWithoutH1 = header.replaceFirst(RegExp(r'^# .+'), '').trimLeft();
  buffer.writeln('# TrinaGrid - Complete Documentation');
  buffer.writeln();
  buffer.write(headerWithoutH1);
  buffer.writeln();
  buffer.writeln('---');
  buffer.writeln();

  int filesProcessed = 0;
  for (final relPath in finalOrder) {
    final file = fileMap[relPath]!;
    var content = file.readAsStringSync();

    // Convert the first H1 to H2
    content = content.replaceFirst(RegExp(r'^# ', multiLine: true), '## ');

    // Convert relative links to absolute GitHub URLs
    // ../features/foo.md -> absolute URL
    final docRelDir = path.dirname(relPath).replaceAll('\\', '/');
    content = content.replaceAllMapped(
      RegExp(r'\]\((\.\./[^)#]+\.md)(#[^)]+)?\)'),
      (match) {
        final linkPath = match.group(1)!;
        final anchor = match.group(2) ?? '';
        // Resolve the relative path
        final resolved = path
            .normalize('doc/$docRelDir/$linkPath')
            .replaceAll('\\', '/');
        return ']($baseUrl/$resolved$anchor)';
      },
    );
    // ./foo.md -> absolute URL
    content = content.replaceAllMapped(
      RegExp(r'\]\(\./([^)#]+\.md)(#[^)]+)?\)'),
      (match) {
        final linkPath = match.group(1)!;
        final anchor = match.group(2) ?? '';
        return ']($baseUrl/doc/$docRelDir/$linkPath$anchor)';
      },
    );

    buffer.writeln(content);
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();
    filesProcessed++;
  }

  outputFile.writeAsStringSync(buffer.toString());
  final lineCount = buffer.toString().split('\n').length;
  print(
    'Generated llms-full.txt ($filesProcessed doc files, $lineCount lines)',
  );
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
  print('  --generate-llms            Generate llms-full.txt from doc/ files');
  print('');
  print('Examples:');
  print('  flutter pub run trina_grid --migrate-from-pluto-grid');
  print('  flutter pub run trina_grid --generate-llms');
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
