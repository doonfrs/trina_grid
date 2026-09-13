class TrinaGeneralHelper {
  static final Map<String, RegExp> _regExpCache = {};

  /// Returns a compiled [RegExp] for [pattern], reusing it across calls.
  ///
  /// Filtering compares every cell of every row against the same handful of
  /// patterns, and compiling a [RegExp] per cell dominated that work on large
  /// grids. The cache is small and bounded: it is cleared once it holds more
  /// than 64 patterns, so a long session of distinct searches cannot grow it.
  /// An invalid [pattern] throws [FormatException] like `RegExp(pattern)`.
  static RegExp cachedRegExp(String pattern, {bool caseSensitive = true}) {
    final key = caseSensitive ? 's:$pattern' : 'i:$pattern';
    final cached = _regExpCache[key];
    if (cached != null) return cached;
    final regExp = RegExp(pattern, caseSensitive: caseSensitive);
    if (_regExpCache.length >= 64) _regExpCache.clear();
    _regExpCache[key] = regExp;
    return regExp;
  }

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
