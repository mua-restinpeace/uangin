import 'package:flutter/material.dart';
import 'package:uangin/features/onBoarding/views/splash_screen.dart';
import 'package:uangin/core/theme/themes.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uangin',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      home: const SplashScreen(),
    );
  }
}