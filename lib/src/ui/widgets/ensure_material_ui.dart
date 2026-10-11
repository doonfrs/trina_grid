import 'package:material_ui/material_ui.dart';

/// Wraps [child] in a [Material] and fallback [MaterialLocalizations]
/// when no ancestor [MaterialLocalizations] is found in the widget tree.
///
/// Lets the grid's [material_ui] filter widgets be used inside a standard
/// [MaterialApp] without forcing consumers to configure [GlobalMaterialLocalizations].
class EnsureMaterialUi extends StatelessWidget {
  const EnsureMaterialUi({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget content = Material(
      type: MaterialType.transparency,
      child: child,
    );

    if (Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) == null) {
      content = Localizations(
        locale: Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'),
        delegates: const [
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
        ],
        child: content,
      );
    }

    return content;
  }
}
