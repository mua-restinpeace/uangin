import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uangin/blocs/user/get_user/get_user_bloc.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/my_text_field.dart';
import 'package:uangin/features/account_information/blocs/update_account_info/update_account_info_bloc.dart';
import 'package:user_repository/user_repository.dart';

class AccountInformationScreen extends StatefulWidget {
  const AccountInformationScreen({super.key});

  @override
  State<AccountInformationScreen> createState() =>
      _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Uint8List? _newPhotoBytes;
  bool _isProcessingImage = false;
  String? _newPhotoBase64;

  @override
  void initState() {
    super.initState();

    final userState = context.read<GetUserBloc>().state;
    if (userState is GetUserSuccess) {
      _nameController.text = userState.user.name;
      _emailController.text = userState.user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 400,
      maxWidth: 400,
    );

    if (picked == null) return;

    setState(() {
      _isProcessingImage = true;
    });

    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        picked.path,
        minHeight: 200,
        minWidth: 200,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      if (compressed == null) {
        log('image compression returned null');
        return;
      }

      final base64String = base64Encode(compressed);
      log('compressed image size: ${compressed.length} bytes');
      log('abse64 length: ${base64String.length} chars');

      if (compressed.length > 750000) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'Image is too large. Please choose a smaller photo',
            ),
            backgroundColor: MyColors.red,
          ));
        }

        return;
      }

      setState(() {
        _newPhotoBytes = compressed;
        _newPhotoBase64 = base64String;
      });
    } catch (e) {
      log('error processing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Failed to process image. Please try again.',
          ),
          backgroundColor: MyColors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingImage = false;
        });
      }
    }
  }

  void _save(String userId) {
    if (!_formKey.currentState!.validate()) return;

    context.read<UpdateAccountInfoBloc>().add(
          UpdateAccountInfo(
            userId: userId,
            name: _nameController.text.trim(),
            photoUrl: _newPhotoBase64,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetUserBloc, GetUserState>(
      builder: (context, userState) {
        if (userState is! GetUserSuccess) {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }

        final user = userState.user;

        return BlocListener<UpdateAccountInfoBloc, UpdateAccountInfoState>(
          listener: (context, state) {
            if (state is UpdateAccountInfoSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account updated successfully'),
                  backgroundColor: MyColors.green,
                ),
              );
              Navigator.pop(context);
            } else if (state is UpdateAccountInfoFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Failed to update: ${state.errorMessage}'),
                backgroundColor: MyColors.red,
              ));
            }
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            resizeToAvoidBottomInset: true,
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
                  'Account Information',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 20),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 284,
                      width: double.infinity,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // green shape
                          Positioned.fill(
                            bottom: 56,
                            child: Container(
                              decoration: BoxDecoration(
                                color: MyColors.primary,
                                border:
                                    Border.all(color: const Color(0xffA0D037)),
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
                                child: _buildAvatar(user),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 100,
                            right: 0,
                            bottom: 12,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: MyColors.black,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: MyColors.white, width: 2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: _isProcessingImage
                                    ? const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: MyColors.onPrimary,
                                      )
                                    : SvgPicture.asset(
                                        'lib/assets/icons/pencil.svg',
                                        width: 16,
                                        height: 16,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          Center(
                            child: TextButton(
                              onPressed: _isProcessingImage ? null : _pickImage,
                              child: Text(
                                'Change photo',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Text(
                            'Name',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(fontSize: 14),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          MyTextField(
                            textEditingController: _nameController,
                            hintText: 'Your Name',
                            isObscureText: false,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name cannot be empty';
                              }

                              if (value.trim().length < 2) {
                                return 'Name must be at least 2 characters';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Text(
                            'Email',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(fontSize: 14),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          MyTextField(
                            textEditingController: _emailController,
                            hintText: _emailController.text,
                            enabled: false,
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          BlocBuilder<UpdateAccountInfoBloc,
                              UpdateAccountInfoState>(
                            builder: (context, state) {
                              final isLoading =
                                  state is UpdateAccountInfoLoading;
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading || _isProcessingImage
                                      ? null
                                      : () => _save(user.userId),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: MyColors.black,
                                      foregroundColor: MyColors.white,
                                      padding: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16))),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: MyColors.white,
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
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(MyUser user) {
    if (_newPhotoBytes != null) {
      return CircleAvatar(
        radius: 56,
        backgroundImage: MemoryImage(_newPhotoBytes!),
      );
    }

    if (user.hasPhotoUrl) {
      return CircleAvatar(
        radius: 56,
        backgroundImage: MemoryImage(base64Decode(user.photoUrl)),
      );
    }

    final initials = user.name.isNotEmpty
        ? user.name.trim().split(' ').map((e) => e[0]).take(2).join()
        : '?';

    return CircleAvatar(
      radius: 56,
      backgroundColor: MyColors.primary,
      child: Text(
        initials.toUpperCase(),
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 32,
              color: MyColors.onPrimary,
            ),
      ),
    );
  }
}
