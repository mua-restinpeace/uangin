import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InfoRow extends StatelessWidget {
  final String icon;
  final String label;
  const InfoRow({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
          ),
          const SizedBox(
            width: 12,
          ),
          Text(
            label,
            style:
                Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
          )
        ],
      ),
    );
  }
}
