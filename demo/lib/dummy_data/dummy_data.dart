import 'dart:math';
import 'package:trina_grid/trina_grid.dart';

/// Class to generate dummy data for demo purposes
class DummyData {
  /// Generate employee data for the grid export demo
  static List<TrinaRow> generateEmployeeData(int count) {
    final random = Random();
    final List<String> roles = [
      'Developer',
      'Designer',
      'Manager',
      'QA Engineer',
      'DevOps',
      'Product Owner',
      'Scrum Master',
      'CEO',
      'CTO',
      'CFO',
    ];

    final List<String> firstNames = [
      'John',
      'Jane',
      'Michael',
      'Emily',
      'David',
      'Sarah',
      'Robert',
      'Lisa',
      'William',
      'Emma',
      'James',
      'Olivia',
      'Daniel',
      'Sophia',
      'Matthew',
      'Ava',
      'Joseph',
      'Isabella',
      'Andrew',
      'Mia',
      'Thomas',
      'Charlotte',
      'Christopher',
      'Amelia',
    ];

    final List<String> lastNames = [
      'Smith',
      'Johnson',
      'Williams',
      'Jones',
      'Brown',
      'Davis',
      'Miller',
      'Wilson',
      'Moore',
      'Taylor',
      'Anderson',
      'Thomas',
      'Jackson',
      'White',
      'Harris',
      'Martin',
      'Thompson',
      'Garcia',
      'Martinez',
      'Robinson',
      'Clark',
      'Rodriguez',
      'Lewis',
      'Lee',
    ];

    return List.generate(count, (index) {
      final firstName = firstNames[random.nextInt(firstNames.length)];
      final lastName = lastNames[random.nextInt(lastNames.length)];
      final role = roles[random.nextInt(roles.length)];
      final age = 22 + random.nextInt(40); // Ages between 22 and 61
      final salary =
          30000 + random.nextInt(120000); // Salaries between 30k and 150k
      final isActive = random.nextBool();

      // Generate a random date within the last 10 years
      final now = DateTime.now();
      final daysToSubtract = random.nextInt(
        3650,
      ); // Max 10 years back (365 * 10)
      final joinedDate = now.subtract(Duration(days: daysToSubtract));

      return TrinaRow(
        cells: {
          'id': TrinaCell(value: index + 1),
          'name': TrinaCell(value: '$firstName $lastName'),
          'age': TrinaCell(value: age),
          'role': TrinaCell(value: role),
          'joined_date': TrinaCell(value: joinedDate),
          'salary': TrinaCell(value: salary),
          'active': TrinaCell(value: isActive),
        },
      );
    });
  }
}
