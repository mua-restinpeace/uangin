import 'package:flutter/material.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/profile_avatar.dart';
import 'package:user_repository/user_repository.dart';

class ProfileHeader extends StatelessWidget {
  final MyUser user;
  const ProfileHeader({
    required this.user,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 398,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // white info panel
          Positioned(
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              decoration: BoxDecoration(
                color: MyColors.fillColor,
                border: Border.all(
                  color: MyColors.lightGrey,
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(100),
                ),
              ),
            ),
          ),

          // green shape
          Positioned.fill(
            bottom: 174,
            child: Container(
              decoration: BoxDecoration(
                color: MyColors.primary,
                border: Border.all(color: const Color(0xffA0D037)),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(100),
                ),
              ),
            ),
          ),

          // floating avatar
          Positioned(
            top: 153,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                  width: 138,
                  height: 138,
                  decoration: BoxDecoration(
                    color: MyColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: MyColors.white,
                      width: 8,
                    ),
                  ),
                  child: ProfileAvatar(
                    user: user,
                  )),
            ),
          ),

          // name and email
          Positioned(
            left: 16,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 170,
                  child: Text(
                    user.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 30,
                          height: 1.08,
                          color: MyColors.onPrimary,
                        ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        color: MyColors.grey,
                      ),
                )
              ],
            ),
          ),

          // goals achieved
          Positioned(
            right: 65,
            bottom: 36,
            child: Column(
              children: [
                Text(
                  'Goals Achieved',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        color: MyColors.grey,
                      ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  user.goalsAchieved.toString(),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        color: MyColors.onPrimary,
                      ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
