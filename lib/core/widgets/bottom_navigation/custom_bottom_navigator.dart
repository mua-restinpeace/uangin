import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/bottom_navigation/navigation_item.dart';

class CustomBottomNavigator extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback onAddTap;
  const CustomBottomNavigator(
      {required this.selectedIndex,
      required this.onIndexChanged,
      required this.onAddTap,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24)
          .add(const EdgeInsets.only(bottom: 24)),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                  color: MyColors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                        color: MyColors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8))
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NavigationItem(
                    icon: 'lib/assets/icons/home.svg',
                    isSelected: selectedIndex == 0,
                    onTap: () => onIndexChanged(0),
                  ),
                  const SizedBox(
                    width: 56,
                  ),
                  NavigationItem(
                    icon: 'lib/assets/icons/nav_profile.svg',
                    isSelected: selectedIndex == 1,
                    onTap: () => onIndexChanged(1),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            child: GestureDetector(
              onTap: onAddTap,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4)
                    )
                  ]
                ),
                child: SvgPicture.asset(
                  'lib/assets/icons/nav_plus.svg',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
