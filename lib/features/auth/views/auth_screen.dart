import 'package:flutter/material.dart';
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
            ? SignInScreen(
                onSwitch: toggle,
              )
            : SignUpScreen(
                onSwitch: toggle,
              ),
      ),
    );
  }
}
