import 'package:collection/collection.dart';
import 'package:mockito/mockito.dart';
import 'package:trina_grid/trina_grid.dart';
import '../matcher/trina_object_matcher.dart';
import '../mock/mock_methods.dart';

void verifyOnSelectedEvent({
  required MockMethods mock,
  List<TrinaRow> expectedSelectedRows = const [],
  List<TrinaCell> expectedSelectedCells = const [],
}) {
  verify(
    mock.oneParamReturnVoid(
        argThat(TrinaObjectMatcher<TrinaGridOnSelectedEvent>(rule: (event) {
      return event.selectedRows.length == expectedSelectedRows.length &&
          expectedSelectedRows.equals(event.selectedRows) &&
          expectedSelectedCells.length == event.selectedCells.length &&
          expectedSelectedCells.equals(event.selectedCells);
    }))),
  ).called(1);
}
