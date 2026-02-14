import 'package:flutter/material.dart';
import 'package:uangin/core/theme/colors.dart';

class MyButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget content;
  final EdgeInsets padding;
  const MyButton({required this.onTap, required this.content, this.padding = const EdgeInsets.all(16), super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
            color: MyColors.black,
            borderRadius: BorderRadius.all(Radius.circular(16))),
        padding: padding,
        child: content,
      ),
    );
  }
}
