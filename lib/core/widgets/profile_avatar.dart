import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:user_repository/user_repository.dart';

class ProfileAvatar extends StatelessWidget {
  final MyUser user;
  final double radius;
  final double fontSize;
  const ProfileAvatar({
    required this.user,
    this.radius = 56,
    this.fontSize = 32,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (user.hasPhotoUrl) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(base64Decode(user.photoUrl)),
      );
    }

    final initials = user.name.isNotEmpty
        ? user.name.trim().split(' ').map((e) => e[0]).take(2).join()
        : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: MyColors.primary,
      child: Text(
        initials.toUpperCase(),
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: fontSize,
              color: MyColors.onPrimary,
            ),
      ),
    );
  }
}
