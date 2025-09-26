class TrinaGeneralHelper {
  static int compareWithNull(dynamic a, dynamic b, int Function() resolve) {
    if (a == null || b == null) {
      return a == b
          ? 0
          : a == null
          ? -1
          : 1;
    }

    return resolve();
  }
}
