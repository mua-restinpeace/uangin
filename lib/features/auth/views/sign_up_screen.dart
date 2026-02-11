import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uangin/core/widgets/long_button.dart';
import 'package:uangin/core/widgets/my_text_field.dart';
import 'package:uangin/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:user_repository/user_repository.dart';

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
  final _formKey = GlobalKey<FormState>();

  bool _rememberMe = false;
  bool _isPasswordObscured = true;
  Widget sufixPasswordIcon = SvgPicture.asset(
    'lib/assets/icons/eye_disable.svg',
    width: 28,
    height: 28,
  );
  bool _isConfirmPasswordObscured = true;
  Widget sufixConfirmPasswordIcon = SvgPicture.asset(
    'lib/assets/icons/eye_disable.svg',
    width: 28,
    height: 28,
  );

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpFailure) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Signup failed: Something wrong in the process. Please try again')));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
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
                    const Spacer(
                      flex: 1,
                    ),
                    MyTextField(
                      textEditingController: nameController,
                      hintText: 'Name',
                      prefixIcon: SvgPicture.asset(
                        'lib/assets/icons/person.svg',
                        height: 28,
                        width: 28,
                      ),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please fill in this field';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
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
                          return 'Please fill in this field';
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
                      isObscureText: _isPasswordObscured,
                      prefixIcon: SvgPicture.asset(
                        'lib/assets/icons/lock.svg',
                        height: 28,
                        width: 28,
                      ),
                      sufixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                            if (!_isPasswordObscured) {
                              sufixPasswordIcon = SvgPicture.asset(
                                'lib/assets/icons/eye_open.svg',
                                width: 28,
                                height: 28,
                              );
                            } else {
                              sufixPasswordIcon = SvgPicture.asset(
                                'lib/assets/icons/eye_disable.svg',
                                width: 28,
                                height: 28,
                              );
                            }
                          });
                        },
                        icon: sufixPasswordIcon,
                      ),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please fill in this field';
                        }

                        if (!val.contains(RegExp(r'[A-Z]'))) {
                          return 'Password must contain uppercase';
                        }

                        if (!val.contains(RegExp(r'[a-z]'))) {
                          return 'Password must contain lowercase';
                        }

                        if (!val.contains(RegExp(r'[0-9]'))) {
                          return 'Password must contain number';
                        }

                        if (!val.contains(RegExp(
                            r'^(?=.*?[!@#$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^])'))) {
                          return 'Password must contain special character';
                        }

                        if (val.length < 8) {
                          return 'Password must at least 8 characters';
                        }

                        return null;
                      },
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
                      sufixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordObscured =
                                !_isConfirmPasswordObscured;
                            if (!_isConfirmPasswordObscured) {
                              sufixConfirmPasswordIcon = SvgPicture.asset(
                                'lib/assets/icons/eye_open.svg',
                                width: 28,
                                height: 28,
                              );
                            } else {
                              sufixConfirmPasswordIcon = SvgPicture.asset(
                                'lib/assets/icons/eye_disable.svg',
                                width: 28,
                                height: 28,
                              );
                            }
                          });
                        },
                        icon: sufixConfirmPasswordIcon,
                      ),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please fill in this field';
                        }

                        if (val != passwordController.text) {
                          return 'Password does not match';
                        }

                        return null;
                      },
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
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    BlocBuilder<SignUpBloc, SignUpState>(
                      builder: (context, state) {
                        if (state is SignUpLoading) {
                          return const CircularProgressIndicator();
                        }

                        return LongButton(
                            text: 'Sign Up',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                MyUser myUser = MyUser.empty;
                                myUser.email = emailController.text;
                                myUser.name = nameController.text;
                                myUser.goalsAchieved = 0;

                                setState(() {
                                  context.read<SignUpBloc>().add(SignUpRequired(myUser, passwordController.text));
                                });
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
                          "Already have an account?",
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
                              'Sign In',
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
}
