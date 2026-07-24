import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uangin/core/theme/colors.dart';

class SettingItem extends StatelessWidget {
  final String name;
  final String icon;
  final VoidCallback onTap;

  const SettingItem({
    required this.name,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    icon,
                    height: 30,
                    width: 30,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 16,
                          // fontWeight: FontWeight.bold,
                          color: MyColors.black,
                        ),
                  )
                ],
              ),
              SvgPicture.asset(
                'lib/assets/icons/cevron-right-circle.svg',
                width: 24,
                height: 24,
              )
            ],
          ),
        ),
        const Divider(
          color: MyColors.lightGrey,
        )
      ],
    );
  }
}
