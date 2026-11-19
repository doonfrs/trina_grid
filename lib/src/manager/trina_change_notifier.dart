import 'package:material_ui/material_ui.dart';
import 'package:rxdart/rxdart.dart';

class TrinaChangeNotifier extends ChangeNotifier {
  final PublishSubject<TrinaNotifierEvent> _streamNotifier =
      PublishSubject<TrinaNotifierEvent>();

  final Set<int> _notifier = {};

  PublishSubject<TrinaNotifierEvent> get streamNotifier => _streamNotifier;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;

    _streamNotifier.close();

    super.dispose();
  }

  @override
  void notifyListeners([bool notify = true, int? notifier]) {
    if (notifier != null) {
      addNotifier(notifier);
    }

    if (!notify) {
      return;
    }

    if (!_disposed) {
      super.notifyListeners();

      _streamNotifier.add(TrinaNotifierEvent(_drainNotifier()));
    }
  }

  void notifyListenersOnPostFrame([bool notify = true, int? notifier]) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners(notify, notifier);
    });
  }

  @protected
  void addNotifier(int hash) {
    _notifier.add(hash);
  }

  Set<int> _drainNotifier() {
    final drain = <int>{..._notifier};
    _notifier.clear();
    return drain;
  }
}

class TrinaNotifierEvent {
  TrinaNotifierEvent(this._notifier);

  final Set<int> _notifier;

  Set<int> get notifier => {..._notifier};

  bool any(Set<int> hashes) {
    return _notifier.isEmpty ? true : _notifier.any((e) => hashes.contains(e));
  }
}

class TrinaNotifierEventForceUpdate extends TrinaNotifierEvent {
  TrinaNotifierEventForceUpdate._() : super({});

  static TrinaNotifierEventForceUpdate instance =
      TrinaNotifierEventForceUpdate._();

  @override
  bool any(Set<int> hashes) {
    return true;
  }
}
