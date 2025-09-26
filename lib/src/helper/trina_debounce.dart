import 'dart:async';

class TrinaDebounce {
  final Duration duration;

  TrinaDebounce({this.duration = const Duration(milliseconds: 1)});

  Timer? _debounce;

  void dispose() {
    _debounce?.cancel();
  }

  void debounce({required void Function() callback}) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(duration, callback);
  }
}

class TrinaDebounceByHashCode {
  final Duration duration;

  TrinaDebounceByHashCode({this.duration = const Duration(milliseconds: 1)});

  Timer? _debounce;

  int? _previousHashCode;

  void dispose() {
    _debounce?.cancel();
  }

  bool isDebounced({required int hashCode, bool ignore = false}) {
    if (ignore) {
      return false;
    }

    if (_previousHashCode == hashCode) {
      return true;
    }

    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(duration, () {
      _previousHashCode = null;
    });

    _previousHashCode = hashCode;

    return false;
  }
}
