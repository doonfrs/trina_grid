import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../helper/launch_url.dart';
import '../widget/trina_expansion_tile.dart';

class TrinaExampleScreen extends StatelessWidget {
  final String? title;
  final String? topTitle;
  final List<Widget>? topContents;
  final List<Widget>? topButtons;
  final Widget? body;

  const TrinaExampleScreen({
    super.key,
    this.title,
    this.topTitle,
    this.topContents,
    this.topButtons,
    this.body,
  });

  AlertDialog reportingDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Reporting'),
      content: const SizedBox(
        width: 300,
        child: Text(
          'Have you found the problem? Or do you have any questions?\n(Selecting Yes will open the Github issue.)',
        ),
      ),
      actions: [
        TextButton(
          child: const Text('No', style: TextStyle(color: Colors.deepOrange)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Yes'),
          onPressed: () {
            launchUrl('https://github.com/doonfrs/trina_grid/issues');
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title - TrinaGrid'),
        actions: [
          ElevatedButton.icon(
            label: const Text('Report'),
            icon: const FaIcon(FontAwesomeIcons.exclamation),
            onPressed: () {
              showDialog<void>(context: context, builder: reportingDialog);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (ctx, size) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: size.maxWidth,
                height: size.maxHeight,
                constraints: const BoxConstraints(minHeight: 750),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    TrinaExpansionTile(
                      title: topTitle!,
                      buttons: topButtons,
                      children: topContents,
                    ),
                    const SizedBox(height: 10),
                    Expanded(child: body!),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
