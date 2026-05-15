import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Wraps [child] in a default [ShadTheme] when no ancestor [ShadTheme]
/// is found in the widget tree.
///
/// Lets the grid be used inside a plain [MaterialApp] without forcing
/// consumers to wrap their app in [ShadApp]. The fallback theme adopts
/// the host Material [Brightness] so dark mode stays consistent.
class EnsureShadTheme extends StatelessWidget {
  const EnsureShadTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (ShadTheme.maybeOf(context) != null) return child;
    return ShadTheme(
      data: ShadThemeData(brightness: Theme.of(context).brightness),
      child: child,
    );
  }
}
