import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangin/blocs/authenticaton_bloc/authentication_bloc.dart';
import 'package:uangin/blocs/user/get_user/get_user_bloc.dart';
import 'package:uangin/features/auth/views/auth_screen.dart';
import 'package:uangin/features/onBoarding/views/on_boarding_screen.dart';
import 'package:uangin/features/onBoarding/views/splash_screen.dart';
import 'package:uangin/core/theme/themes.dart';
import 'package:uangin/main_scaffold.dart';

class MyAppView extends StatefulWidget {
  const MyAppView({super.key});

  @override
  State<MyAppView> createState() => _MyAppViewState();
}

class _MyAppViewState extends State<MyAppView> {
  bool _splashScren = true;
  bool _getUserTriggerd = false;

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
        home: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state.status == AuthenticationStatus.authenticated &&
                !_getUserTriggerd) {
              context.read<GetUserBloc>().add(const GetUser());
              _getUserTriggerd = true;
            }
          },
          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
            if (_splashScren) {
              return const SplashScreen();
            }

            if (state.status == AuthenticationStatus.authenticated) {
              return const MainScaffold();
            }

            if (state.status == AuthenticationStatus.unauthenticated) {
              return const AuthScreen();
            }

            return const OnBoardingScreen();
          }),
        ));
  }
}
