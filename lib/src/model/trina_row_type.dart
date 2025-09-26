import 'package:trina_grid/trina_grid.dart';

abstract class TrinaRowType {
  factory TrinaRowType.normal() {
    return TrinaRowTypeNormal.instance;
  }

  factory TrinaRowType.group({
    required FilteredList<TrinaRow> children,
    bool expanded = false,
  }) {
    return TrinaRowTypeGroup(children: children, expanded: expanded);
  }
}

extension TrinaRowTypeExtension on TrinaRowType {
  bool get isNormal => this is TrinaRowTypeNormal;

  bool get isGroup => this is TrinaRowTypeGroup;

  TrinaRowTypeNormal get normal {
    if (this is! TrinaRowTypeNormal) {
      throw TypeError();
    }

    return this as TrinaRowTypeNormal;
  }

  TrinaRowTypeGroup get group {
    if (this is! TrinaRowTypeGroup) {
      throw TypeError();
    }

    return this as TrinaRowTypeGroup;
  }
}

class TrinaRowTypeNormal implements TrinaRowType {
  const TrinaRowTypeNormal();

  static TrinaRowTypeNormal instance = const TrinaRowTypeNormal();
}

class TrinaRowTypeGroup implements TrinaRowType {
  TrinaRowTypeGroup({required this.children, bool expanded = false})
    : _expanded = expanded;

  final FilteredList<TrinaRow> children;

  bool get expanded => _expanded;

  bool _expanded;

  void setExpanded(bool flag) {
    _expanded = flag;
  }
}
