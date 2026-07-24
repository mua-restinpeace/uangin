import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/my_text_field.dart';
import 'package:uangin/core/widgets/password_strength_indicator.dart';
import 'package:uangin/features/password_and_security/blocs/update_password/update_password_bloc.dart';

class PasswordSecurityScreen extends StatefulWidget {
  const PasswordSecurityScreen({super.key});

  @override
  State<PasswordSecurityScreen> createState() => _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState extends State<PasswordSecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<UpdatePasswordBloc>().add(
          UpdatePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdatePasswordBloc, UpdatePasswordState>(
      listener: (context, state) {
        if (state is UpdatePasswordSuccess) {
          // clear form controller
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'Password updated successfully!',
            ),
            backgroundColor: MyColors.green,
          ));
          Navigator.pop(context);
        } else if (state is UpdatePasswordFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: MyColors.red,
            ),
          );
        }
      },
      child: Scaffold(
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
              'Password & Security',
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(fontSize: 20),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // info banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MyColors.lightGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset('lib/assets/icons/info-circle.svg'),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          'Enter your current password to verify your identity before setting a new one.',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: MyColors.onPrimary,
                                  ),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(
                  height: 32,
                ),

                // current password field
                Text(
                  'Current Password',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 14),
                ),
                const SizedBox(
                  height: 8,
                ),
                MyTextField(
                  textEditingController: _currentPasswordController,
                  hintText: 'Enter current password',
                  isObscureText: !_showCurrentPassword,
                  sufixIcon: _ToggleVisibilityIcon(
                    isVisible: _showCurrentPassword,
                    onToggle: () => setState(
                        () => _showCurrentPassword = !_showCurrentPassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),

                const SizedBox(
                  height: 24,
                ),

                // new password field
                Text(
                  'New Password',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 14),
                ),
                const SizedBox(
                  height: 8,
                ),
                MyTextField(
                  textEditingController: _newPasswordController,
                  hintText: 'Enter new password',
                  isObscureText: !_showNewPassword,
                  sufixIcon: _ToggleVisibilityIcon(
                    isVisible: _showNewPassword,
                    onToggle: () => setState(() {
                      _showNewPassword = !_showNewPassword;
                    }),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return 'Password must contain uppercase';
                    }

                    if (!value.contains(RegExp(r'[a-z]'))) {
                      return 'Password must contain lowercase';
                    }

                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'Password must contain number';
                    }

                    if (!value.contains(RegExp(
                        r'^(?=.*?[!@#$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^])'))) {
                      return 'Password must contain special character';
                    }
                    if (value == _currentPasswordController.text) {
                      return 'New password must be diffrent from current';
                    }
                    return null;
                  },
                ),

                const SizedBox(
                  height: 8,
                ),
                PasswordStrengthIndicator(password: _newPasswordController),

                const SizedBox(
                  height: 24,
                ),

                // confirm password
                Text(
                  'Confirm Password',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 14),
                ),
                const SizedBox(
                  height: 8,
                ),
                MyTextField(
                  textEditingController: _confirmPasswordController,
                  hintText: 'Re-enter new password',
                  isObscureText: !_showConfirmPassword,
                  sufixIcon: _ToggleVisibilityIcon(
                    isVisible: _showConfirmPassword,
                    onToggle: () => setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    }),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }

                    if (value != _newPasswordController.text) {
                      return 'Password do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(
                  height: 40,
                ),

                //save button
                BlocBuilder<UpdatePasswordBloc, UpdatePasswordState>(
                  builder: (context, state) {
                    final isLoading = state is UpdatePasswordLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.black,
                            foregroundColor: MyColors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            )),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: MyColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      fontSize: 16,
                                      color: MyColors.white,
                                    ),
                              ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleVisibilityIcon extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onToggle;

  const _ToggleVisibilityIcon({
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: SvgPicture.asset(
        isVisible
            ? 'lib/assets/icons/eye_open.svg'
            : 'lib/assets/icons/eye_disable.svg',
        height: 28,
        width: 28,
      ),
    );
  }
}
