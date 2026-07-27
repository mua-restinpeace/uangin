import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangin/features/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:uangin/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:uangin/features/auth/views/sign_in_screen.dart';
import 'package:uangin/features/auth/views/sign_up_screen.dart';
import 'package:user_repository/user_repository.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showLogin = true;

  void toggle() {
    debugPrint('Auth switch tapped. showLogin before: $_showLogin');

    setState(() {
      _showLogin = !_showLogin;
    });

    debugPrint('Auth switch done. showLogin after: $_showLogin');
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SignInBloc(context.read<UserRepository>()),
        ),
        BlocProvider(
          create: (context) => SignUpBloc(context.read<UserRepository>()),
        ),
      ],
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: _showLogin
              ? SignInScreen(
                  key: const ValueKey('sign-in-screen'),
                  onSwitch: toggle,
                )
              : SignUpScreen(
                  key: const ValueKey('sign-up-screen'),
                  onSwitch: toggle,
                ),
        ),
      ),
    );
  }
}
