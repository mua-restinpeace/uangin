import 'package:flutter/material.dart';
import 'package:uangin/core/theme/colors.dart';

ThemeData get lightTheme {
  return ThemeData(
    fontFamily: 'Plus Jakarta Sans',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: MyColors.onPrimary,
        fontWeight: FontWeight.bold
      ),
      displayMedium: TextStyle(
        color: MyColors.onPrimary,
        fontWeight: FontWeight.w600
      ),
      bodyLarge: TextStyle(
        color: MyColors.onPrimary,
        fontWeight: FontWeight.w400
      ),
      bodyMedium: TextStyle(
        color: MyColors.grey,
        fontWeight: FontWeight.w400
      )
    ),
    colorScheme: const ColorScheme.light(
      primary: MyColors.primary,
      onPrimary: MyColors.onPrimary,
      surface: MyColors.white,
      onSurface: MyColors.onPrimary
    )
  );
}