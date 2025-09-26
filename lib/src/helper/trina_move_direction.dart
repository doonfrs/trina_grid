enum TrinaMoveDirection {
  left,
  right,
  up,
  down;

  bool get horizontal {
    switch (this) {
      case TrinaMoveDirection.left:
      case TrinaMoveDirection.right:
        return true;
      default:
        return false;
    }
  }

  bool get vertical {
    switch (this) {
      case TrinaMoveDirection.up:
      case TrinaMoveDirection.down:
        return true;
      default:
        return false;
    }
  }

  int get offset {
    switch (this) {
      case TrinaMoveDirection.left:
      case TrinaMoveDirection.up:
        return -1;
      case TrinaMoveDirection.right:
      case TrinaMoveDirection.down:
        return 1;
    }
  }

  bool get isLeft {
    return TrinaMoveDirection.left == this;
  }

  bool get isRight {
    return TrinaMoveDirection.right == this;
  }

  bool get isUp {
    return TrinaMoveDirection.up == this;
  }

  bool get isDown {
    return TrinaMoveDirection.down == this;
  }

  /// Returns the RTL-aware direction.
  ///
  /// In RTL mode, left and right are swapped to match visual expectations.
  /// Up and down remain unchanged.
  TrinaMoveDirection asRTLAwareDirection(bool isRTL) {
    if (!isRTL || !horizontal) {
      return this;
    }

    return switch (this) {
      TrinaMoveDirection.left => TrinaMoveDirection.right,
      TrinaMoveDirection.right => TrinaMoveDirection.left,
      TrinaMoveDirection.up || TrinaMoveDirection.down => this,
    };
  }
}
