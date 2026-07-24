import 'package:flutter/material.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/features/help_center/widgets/faq_tile.dart';

class FaqSection extends StatelessWidget {
  final String title;
  final List<FaqItem> items;
  const FaqSection({required this.title, required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 16,
                color: MyColors.onPrimary,
              ),
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
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      color: MyColors.lightGrey,
                    ),
                  FaqTile(item: items[i]),
                ]
              ],
            ),
          ),
        )
      ],
    );
  }
}
