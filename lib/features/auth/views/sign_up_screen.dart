import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uangin/core/widgets/long_button.dart';
import 'package:uangin/core/widgets/my_text_field.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onSwitch;
  const SignUpScreen({required this.onSwitch, super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _rememberMe = false;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2,),
                Text(
                  'Create Your Account',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 24),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  "Start managing your weekly allowance with ease.",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 14),
                ),
                const Spacer(flex: 1,),
                MyTextField(
                  textEditingController: nameController,
                  hintText: 'Name',
                  prefixIcon: SvgPicture.asset(
                    'lib/assets/icons/person.svg',
                    height: 28,
                    width: 28,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
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
                  isObscureText: _isPasswordObscured,
                  prefixIcon: SvgPicture.asset(
                    'lib/assets/icons/lock.svg',
                    height: 28,
                    width: 28,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                MyTextField(
                  textEditingController: confirmPasswordController,
                  hintText: 'Confirm Password',
                  isObscureText: _isConfirmPasswordObscured,
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
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    )
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                LongButton(text: 'Sign Up', onPressed: () {}),
                const SizedBox(height: 40,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
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
                          'Sign In',
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