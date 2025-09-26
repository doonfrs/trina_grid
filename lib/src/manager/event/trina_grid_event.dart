import 'package:trina_grid/trina_grid.dart';

enum TrinaGridEventType {
  normal,
  throttleTrailing,
  throttleLeading,
  debounce;

  bool get isNormal => this == TrinaGridEventType.normal;

  bool get isThrottleTrailing => this == TrinaGridEventType.throttleTrailing;

  bool get isThrottleLeading => this == TrinaGridEventType.throttleLeading;

  bool get isDebounce => this == TrinaGridEventType.debounce;
}

abstract class TrinaGridEvent {
  TrinaGridEvent({this.type = TrinaGridEventType.normal, this.duration})
    : assert(
        type.isNormal || duration != null,
        'If type is normal or type is not normal then duration is required.',
      );

  final TrinaGridEventType type;

  final Duration? duration;

  void handler(TrinaGridStateManager stateManager);
}
