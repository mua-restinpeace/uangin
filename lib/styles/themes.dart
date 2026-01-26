import 'package:flutter/material.dart';
import 'package:uangin/styles/colors.dart';

ThemeData get lightTheme {
  return ThemeData(
    fontFamily: 'Plus Jakarta Sans',
    colorScheme: const ColorScheme.light(
      primary: MyColors.primary,
      onPrimary: MyColors.onPrimary,
      surface: MyColors.lightBackground,
      onSurface: MyColors.onPrimary
    )
  );
}