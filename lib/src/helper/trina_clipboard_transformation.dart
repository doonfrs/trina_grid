class TrinaClipboardTransformation {
  /// Converts [text] separated by custom or default separators into a two-dimensional array.
  ///
  /// [cellSeparator] defaults to tab character '\t' for separating cells within a row.
  /// [lineSeparator] defaults to newline '\n' for separating rows. Also accepts CRLF '\r\n'.
  static List<List<String>> stringToList(
    String text, {
    String cellSeparator = '\t',
    String lineSeparator = '\n',
  }) {
    // Create a regex pattern that matches the specified line separator or CRLF variant
    final escapedLineSeparator = RegExp.escape(lineSeparator);
    // Always accept both the specified separator and its CRLF variant for flexibility
    final linePattern = lineSeparator == '\n'
        ? RegExp(r'\n|\r\n')
        : RegExp('$escapedLineSeparator|\r$escapedLineSeparator');

    return text
        .split(linePattern)
        .map((line) => line.split(cellSeparator))
        .toList();
  }
}
