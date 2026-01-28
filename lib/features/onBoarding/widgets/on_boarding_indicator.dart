import 'package:flutter/material.dart';
import 'package:uangin/core/theme/colors.dart';

class OnBoardingIndicator extends StatelessWidget {
  final int currentIndex;
  final int total = 4;

  const OnBoardingIndicator({required this.currentIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => AnimatedContainer(
          duration: Duration(milliseconds: 400),
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: index == currentIndex ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentIndex
              ? MyColors.primary
              : MyColors.lightGrey,
            borderRadius: BorderRadius.circular(4)
          ),
        ),
      ),
    );
  }
}