import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TapRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const TapRow({required this.label, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
            ),
            SvgPicture.asset(
              'lib/assets/icons/cevron-right-circle.svg',
              width: 20,
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
