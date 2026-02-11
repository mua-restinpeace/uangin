import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangin/blocs/authenticaton_bloc/authentication_bloc.dart';
import 'package:uangin/features/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:uangin/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:uangin/features/auth/views/sign_in_screen.dart';
import 'package:uangin/features/auth/views/sign_up_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showLogin = true;

  void toggle() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: _showLogin
            ? BlocProvider<SignInBloc>(
                create: (context) => SignInBloc(
                    context.read<AuthenticationBloc>().userRepository),
                child: SignInScreen(
                  onSwitch: toggle,
                ),
              )
            : BlocProvider<SignUpBloc>(
                create: (context) => SignUpBloc(
                    context.read<AuthenticationBloc>().userRepository),
                child: SignUpScreen(
                  onSwitch: toggle,
                ),
              ),
      ),
    );
  }
}
