import 'package:flutter/material.dart';
import 'package:uangin/core/theme/colors.dart';

class LongButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  const LongButton({required this.text, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: MyColors.black,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(12))
          ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 16, color: MyColors.white),
        )),
    );
  }
}