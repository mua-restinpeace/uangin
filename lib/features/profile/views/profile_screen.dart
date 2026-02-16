import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangin/blocs/user/get_user/get_user_bloc.dart';
import 'package:uangin/core/widgets/long_button.dart';
import 'package:uangin/features/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:user_repository/user_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignInBloc(context.read<UserRepository>()),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<GetUserBloc, GetUserState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('This is Profile Screen'),
                    LongButton(
                        text: "Sign Out",
                        onPressed: () {
                          context.read<SignInBloc>().add(SignOutRequired());
                        })
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
