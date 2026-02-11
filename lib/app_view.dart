import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangin/blocs/authenticaton_bloc/authentication_bloc.dart';
import 'package:uangin/features/auth/views/auth_screen.dart';
import 'package:uangin/features/home/views/home_screen.dart';
import 'package:uangin/features/onBoarding/views/on_boarding_screen.dart';
import 'package:uangin/features/onBoarding/views/splash_screen.dart';
import 'package:uangin/core/theme/themes.dart';

class MyAppView extends StatefulWidget {
  const MyAppView({super.key});

  @override
  State<MyAppView> createState() => _MyAppViewState();
}

class _MyAppViewState extends State<MyAppView> {
  bool _splashScren = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _splashScren = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Uangin',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
          if (_splashScren) {
            return const SplashScreen();
          }

          if (state.status == AuthenticationStatus.authenticated) {
            return const HomeScreen();
          }

          if(state.status == AuthenticationStatus.unauthenticated){
            return const AuthScreen();
          }

          return const OnBoardingScreen();
        }));
  }
}
