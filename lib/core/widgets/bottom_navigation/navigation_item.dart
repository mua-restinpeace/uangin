import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uangin/core/theme/colors.dart';

class NavigationItem extends StatelessWidget {
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;
  const NavigationItem(
      {required this.icon,
      required this.isSelected,
      required this.onTap,
      super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isSelected ? 40 : 0,
            height: isSelected ? 40 : 0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.4,
            duration: const Duration(microseconds: 300),
            child: SvgPicture.asset(
              icon,
              width: 32,
              height: 32,
              colorFilter: ColorFilter.mode(
                  isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : MyColors.grey,
                  BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }
}
