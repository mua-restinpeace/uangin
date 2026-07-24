import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/features/about_us/widgets/info_row.dart';
import 'package:uangin/features/about_us/widgets/section_card.dart';
import 'package:uangin/features/about_us/widgets/tech_row.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String _version = '';

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();

    if (mounted) {
      setState(() {
        _version = 'Version ${info.version} (${info.buildNumber})';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: SvgPicture.asset(
              'lib/assets/icons/arrow_left.svg',
              width: 32,
              height: 32,
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'About Us',
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontSize: 20),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // App Identity
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: MyColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                      child: SvgPicture.asset(
                    'lib/assets/icons/logo.svg',
                    height: 64,
                    width: 64,
                  )),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Uangin',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                      ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  'Your personal allowance & expense tracker',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  _version.isEmpty ? '' : _version,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 32,
          ),

          // Developer
          const SectionCard(
            title: 'Developer',
            children: [
              InfoRow(icon: 'lib/assets/icons/person.svg', label: 'Muuaaa'),
              Divider(
                color: MyColors.lightGrey,
              ),
              InfoRow(
                  icon: 'lib/assets/icons/mail.svg',
                  label: 'disinilohaku@gmail.com')
            ],
          ),

          const SizedBox(
            height: 32,
          ),

          // Built with
          const SectionCard(
            title: 'Built With',
            children: [
              TechRow(name: 'Flutter', description: 'Ui Framework'),
              Divider(color: MyColors.lightGrey),
              TechRow(name: 'Firebase', description: 'Auth & cloud database'),
              Divider(color: MyColors.lightGrey),
              TechRow(name: 'flutter_bloc', description: 'State management'),
              Divider(color: MyColors.lightGrey),
              TechRow(
                  name: 'shared_preferences', description: 'Local data storage')
            ],
          ),
          const SizedBox(
            height: 32,
          ),

          // Footer
          Center(
            child: Text(
              'Made with ❤︎⁠ in Indonesia by muaaa>w<. © ${DateTime.now().year}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(
            height: 32,
          )
        ],
      ),
    );
  }
}
