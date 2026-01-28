import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uangin/core/widgets/long_button.dart';
import 'package:uangin/core/widgets/my_text_field.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback onSwitch;
  const SignInScreen({required this.onSwitch, super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2,),
                Text(
                  'Welcome Back',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 24),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  'Let’s continue tracking your weekly allowance.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 14),
                ),
                const Spacer(flex: 1,),
                MyTextField(
                  textEditingController: emailController,
                  hintText: 'Email Address',
                  prefixIcon: SvgPicture.asset(
                    'lib/assets/icons/mail.svg',
                    height: 28,
                    width: 28,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                MyTextField(
                  textEditingController: passwordController,
                  hintText: 'Password',
                  isObscureText: _isObscured,
                  prefixIcon: SvgPicture.asset(
                    'lib/assets/icons/lock.svg',
                    height: 28,
                    width: 28,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    Text(
                      'Remember Me',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontSize: 14),
                    ),
                    const Spacer(),
                    TextButton(
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero),
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontSize: 14),
                        ))
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                LongButton(text: 'Sign In', onPressed: () {}),
                const SizedBox(height: 40,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                    ),
                    const SizedBox(width: 8,),
                    TextButton(
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero),
                        onPressed: widget.onSwitch,
                        child: Text(
                          'Sign Up',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontSize: 14, color: const Color(0xff8DAC4A)),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
