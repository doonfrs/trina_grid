import 'package:flutter/material.dart';

class TrinaScaledCheckbox extends StatelessWidget {
  final bool? value;

  final Function(bool? changed)? handleOnChanged;

  final bool tristate;

  final double scale;

  final Color unselectedColor;

  final Color? activeColor;

  final Color checkColor;

  final BorderSide? side;

  const TrinaScaledCheckbox({
    super.key,
    required this.value,
    required this.handleOnChanged,
    this.tristate = false,
    this.scale = 1.0,
    this.unselectedColor = Colors.black26,
    this.activeColor = Colors.lightBlue,
    this.checkColor = const Color(0xFFDCF5FF),
    this.side,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Theme(
        data: ThemeData(
          unselectedWidgetColor: unselectedColor,
        ),
        child: Checkbox(
          value: value,
          tristate: tristate,
          onChanged: handleOnChanged,
          activeColor: value == null ? unselectedColor : activeColor,
          checkColor: checkColor,
          side: side,
        ),
      ),
    );
  }
}
