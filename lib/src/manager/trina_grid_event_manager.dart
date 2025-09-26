import 'dart:async';

import 'package:trina_grid/trina_grid.dart';
import 'package:rxdart/rxdart.dart';

class TrinaGridEventManager {
  final TrinaGridStateManager stateManager;

  TrinaGridEventManager({required this.stateManager});

  final PublishSubject<TrinaGridEvent> _subject =
      PublishSubject<TrinaGridEvent>();

  PublishSubject<TrinaGridEvent> get subject => _subject;

  late final StreamSubscription _subscription;

  StreamSubscription get subscription => _subscription;

  void dispose() {
    _subscription.cancel();

    _subject.close();
  }

  void init() {
    final normalStream = _subject.stream.where((event) => event.type.isNormal);

    final throttleLeadingStream = _subject.stream
        .where((event) => event.type.isThrottleLeading)
        .transform(
          ThrottleStreamTransformer(
            (e) => TimerStream<TrinaGridEvent>(e, e.duration as Duration),
            trailing: false,
            leading: true,
          ),
        );

    final throttleTrailingStream = _subject.stream
        .where((event) => event.type.isThrottleTrailing)
        .transform(
          ThrottleStreamTransformer(
            (e) => TimerStream<TrinaGridEvent>(e, e.duration as Duration),
            trailing: true,
            leading: false,
          ),
        );

    final debounceStream = _subject.stream
        .where((event) => event.type.isDebounce)
        .transform(
          DebounceStreamTransformer(
            (e) => TimerStream<TrinaGridEvent>(e, e.duration as Duration),
          ),
        );

    _subscription = MergeStream([
      normalStream,
      throttleLeadingStream,
      throttleTrailingStream,
      debounceStream,
    ]).listen(_handler);
  }

  void addEvent(TrinaGridEvent event) {
    _subject.add(event);
  }

  StreamSubscription<TrinaGridEvent> listener(
    void Function(TrinaGridEvent event) onData,
  ) {
    return _subject.stream.listen(onData);
  }

  void _handler(TrinaGridEvent event) {
    event.handler(stateManager);
  }
}
