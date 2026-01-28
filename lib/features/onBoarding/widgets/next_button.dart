import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uangin/core/theme/colors.dart';

class NextButton extends StatelessWidget {
  final VoidCallback onTap;
  const NextButton({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: MyColors.black,
            borderRadius: BorderRadius.all(const Radius.circular(16))),
        padding: EdgeInsets.all(16),
        child: SvgPicture.asset('lib/assets/icons/arrow-right.svg'),
      ),
    );
  }
}
