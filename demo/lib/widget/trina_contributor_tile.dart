import 'package:flutter/material.dart';

import '../constants/trina_grid_example_colors.dart';

class TrinaContributorTile extends StatelessWidget {
  final String name;

  final String? description;

  final String? linkTitle;

  final Function()? onTapLink;

  const TrinaContributorTile({
    super.key,
    required this.name,
    this.description,
    this.linkTitle,
    this.onTapLink,
  }) : _color = Colors.white,
       _fontColor = TrinaGridExampleColors.fontColor;

  const TrinaContributorTile.invisible({
    super.key,
    required this.name,
    this.description,
    this.linkTitle,
    this.onTapLink,
  }) : _color = Colors.white70,
       _fontColor = Colors.black54;

  final Color _color;
  final Color _fontColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 300,
        maxWidth: 300,
        minHeight: 120,
        maxHeight: 120,
      ),
      child: Card(
        color: _color,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: ListTile(
            title: Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (onTapLink != null)
                  Wrap(
                    spacing: 10,
                    children: [
                      if (onTapLink != null)
                        TextButton(
                          onPressed: onTapLink,
                          child: Text(linkTitle ?? 'Link'),
                        ),
                    ],
                  ),
                if (description != null)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      description!,
                      style: TextStyle(
                        color: _fontColor,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                      ),
                    ),
                  ),
              ],
            ),
            contentPadding: const EdgeInsets.all(15),
          ),
        ),
      ),
    );
  }
}
