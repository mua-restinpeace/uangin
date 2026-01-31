import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangin/core/widgets/long_button.dart';
import 'package:uangin/features/auth/blocs/sign_in_bloc/sign_in_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('This is Home'),
            const SizedBox(
              height: 24,
            ),
            LongButton(text: 'Log Out', onPressed: () {
              context.read<SignInBloc>().add(SignOutRequired());
            })
          ],
        ),
      ),
    );
  }
}
