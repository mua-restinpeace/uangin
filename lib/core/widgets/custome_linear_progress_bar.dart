import 'package:flutter/material.dart';
import 'package:uangin/core/theme/colors.dart';

class CustomeLinearProgressBar extends StatelessWidget {
  final double percentage;
  final Color? backgroundColor;
  final Color progressColor;
  const CustomeLinearProgressBar(
      {required this.percentage,
      this.backgroundColor = MyColors.fillColor,
      required this.progressColor,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: MyColors.lightGrey),
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
              color: progressColor, borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}
