import 'package:flutter/material.dart';

import '../constants/trina_grid_example_colors.dart';

class TrinaListTile extends StatelessWidget {
  final String title;

  final String? description;

  final Function()? onTapPreview;

  final Function()? onTapLiveDemo;

  final Widget? trailing;

  const TrinaListTile({
    super.key,
    required this.title,
    this.description,
    this.onTapPreview,
    this.onTapLiveDemo,
    this.trailing,
  }) : _color = Colors.white,
       _fontColor = TrinaGridExampleColors.fontColor;

  const TrinaListTile.dark({
    super.key,
    required this.title,
    this.description,
    this.onTapPreview,
    this.onTapLiveDemo,
    this.trailing,
  }) : _color = Colors.black87,
       _fontColor = Colors.white70;

  const TrinaListTile.amber({
    super.key,
    required this.title,
    this.description,
    this.onTapPreview,
    this.onTapLiveDemo,
    this.trailing,
  }) : _color = Colors.amber,
       _fontColor = Colors.black87;

  final Color _color;
  final Color _fontColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 300,
        maxWidth: 300,
        minHeight: 160,
        maxHeight: 200,
      ),
      child: Card(
        color: _color,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: ListTile(
            trailing: trailing,
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (onTapPreview != null || onTapLiveDemo != null)
                  Wrap(
                    spacing: 10,
                    children: [
                      if (onTapPreview != null)
                        TextButton(
                          onPressed: onTapPreview,
                          child: const Text('Preview'),
                        ),
                      if (onTapLiveDemo != null)
                        TextButton(
                          onPressed: onTapLiveDemo,
                          child: const Text('LiveDemo'),
                        ),
                    ],
                  ),
                Text(description!, style: TextStyle(color: _fontColor)),
              ],
            ),
            contentPadding: const EdgeInsets.all(15),
          ),
        ),
      ),
    );
  }
}
