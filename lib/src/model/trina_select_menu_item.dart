class TrinaSelectMenuItem {
  final dynamic value;
  final String? label;

  TrinaSelectMenuItem({required this.value, this.label});

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is TrinaSelectMenuItem &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          label == other.label;

  @override
  int get hashCode => value.hashCode ^ label.hashCode;
}
