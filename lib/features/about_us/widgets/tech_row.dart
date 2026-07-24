import 'package:flutter/material.dart';

class TechRow extends StatelessWidget {
  final String name;
  final String description;
  const TechRow({required this.name, required this.description, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style:
                Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13),
          ),
          Text(
            description,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
