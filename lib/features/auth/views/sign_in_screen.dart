import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uangin/core/widgets/long_button.dart';
import 'package:uangin/core/widgets/my_text_field.dart';
import 'package:uangin/features/auth/blocs/sign_in_bloc/sign_in_bloc.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback onSwitch;
  const SignInScreen({required this.onSwitch, super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  bool _isObscured = true;
  Widget suffixIconPassword = SvgPicture.asset(
    'lib/assets/icons/eye_disable.svg',
    height: 28,
    width: 28,
  );

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) {
        if (state is SignInFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid Email or Password')));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(
                      flex: 2,
                    ),
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
                      "Let’s continue tracking your weekly allowance.",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontSize: 14),
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    MyTextField(
                      textEditingController: emailController,
                      textInputType: TextInputType.emailAddress,
                      hintText: 'Email Address',
                      prefixIcon: SvgPicture.asset(
                        'lib/assets/icons/mail.svg',
                        height: 28,
                        width: 28,
                      ),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please fill this field';
                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+.)+[\w-]{2,4}$')
                            .hasMatch(val)) {
                          return 'Please enter valid email';
                        }
                        return null;
                      },
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
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please fill this field';
                        }
                        return null;
                      },
                      sufixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                            if (!_isObscured) {
                              suffixIconPassword = SvgPicture.asset(
                                'lib/assets/icons/eye_open.svg',
                                height: 28,
                                width: 28,
                              );
                            } else {
                              suffixIconPassword = SvgPicture.asset(
                                'lib/assets/icons/eye_disable.svg',
                                height: 28,
                                width: 28,
                              );
                            }
                          });
                        },
                        icon: suffixIconPassword,
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
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
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
                    BlocBuilder<SignInBloc, SignInState>(
                      builder: (context, state) {
                        if (state is SignInLoading) {
                          return const CircularProgressIndicator();
                        }

                        return LongButton(
                            text: 'Sign In',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<SignInBloc>().add(SignInRequired(
                                    emailController.text,
                                    passwordController.text));
                              }
                            });
                      },
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontSize: 16),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
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
                                  ?.copyWith(
                                      fontSize: 14,
                                      color: const Color(0xff8DAC4A)),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
