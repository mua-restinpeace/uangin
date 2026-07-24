import 'package:flutter/material.dart';
import 'package:uangin/core/theme/colors.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SectionCard({required this.title, required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 16),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          decoration: BoxDecoration(
            color: MyColors.fillColor,
            border: Border.all(color: MyColors.lightGrey),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: children,
            ),
          ),
        )
      ],
    );
  }
}
