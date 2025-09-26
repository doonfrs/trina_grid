import 'package:flutter/material.dart';

class TrinaGridTitle extends StatelessWidget {
  final double? fontSize;

  const TrinaGridTitle({super.key, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'Trina',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF33BDE5),
        ),
        children: [
          TextSpan(
            text: 'Grid',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
