import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/features/about_us/views/about_us_screen.dart';
import 'package:uangin/features/account_information/views/account_information_screen.dart';
import 'package:uangin/features/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:uangin/features/help_center/views/help_center_screeen.dart';
import 'package:uangin/features/profile/widgets/setting_item.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account management
          Text(
            'Account',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 20),
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: MyColors.fillColor,
              border: Border.all(color: MyColors.lightGrey),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              children: [
                SettingItem(
                  name: 'Account Information',
                  icon: 'lib/assets/icons/person-circle.svg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountInformationScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 4,
                ),
                SettingItem(
                  name: 'Password & Security',
                  icon: 'lib/assets/icons/lock-invert.svg',
                  onTap: () {},
                ),
                const SizedBox(
                  height: 4,
                ),
                SettingItem(
                  name: 'Notification',
                  icon: 'lib/assets/icons/bell-transparent.svg',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),

          // Preference
          Text(
            'Preferences',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 20),
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: MyColors.fillColor,
              border: Border.all(color: MyColors.lightGrey),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              children: [
                SettingItem(
                  name: 'Theme',
                  icon: 'lib/assets/icons/color-pallete.svg',
                  onTap: () {},
                ),
                const SizedBox(
                  height: 4,
                ),
                SettingItem(
                  name: 'About Us',
                  icon: 'lib/assets/icons/archive.svg',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutUsScreen(),
                        ));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),

          // Support
          Text(
            'Support',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 20),
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: MyColors.fillColor,
              border: Border.all(color: MyColors.lightGrey),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              children: [
                SettingItem(
                  name: 'Help Center',
                  icon: 'lib/assets/icons/question-mark-circle.svg',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpCenterScreeen(),
                        ));
                  },
                ),
                const SizedBox(
                  height: 4,
                ),
                SettingItem(
                  name: 'Logout',
                  icon: 'lib/assets/icons/logout-red.svg',
                  onTap: () {
                    context.read<SignInBloc>().add(SignOutRequired());
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
