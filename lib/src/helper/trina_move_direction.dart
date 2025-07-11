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
  /// In RTL mode, left and right are swapped to match visual expectations.
  /// Up and down remain unchanged.
  TrinaMoveDirection getRTLAwareDirection(bool isRTL) {
    if (!isRTL || !horizontal) {
      return this;
    }

    switch (this) {
      case TrinaMoveDirection.left:
        return TrinaMoveDirection.right;
      case TrinaMoveDirection.right:
        return TrinaMoveDirection.left;
      case TrinaMoveDirection.up:
      case TrinaMoveDirection.down:
        return this;
    }
  }
}
