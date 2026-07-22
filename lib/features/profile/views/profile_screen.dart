import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangin/blocs/user/get_user/get_user_bloc.dart';
import 'package:uangin/features/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:uangin/features/profile/widgets/profiile_header.dart';
import 'package:uangin/features/profile/widgets/settings.dart';
import 'package:user_repository/user_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignInBloc(context.read<UserRepository>()),
      child: Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Profile',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontSize: 20),
              ),
            ),
          ),
          body: BlocBuilder<GetUserBloc, GetUserState>(
            builder: (context, userState) {
              if (userState is GetUserLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (userState is GetUserSuccess) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      ProfileHeader(
                        user: userState.user,
                      ),
                      const SizedBox(
                        height: 16,
                      ),

                      Settings(),
                    ],
                  ),
                );
              }

              log('Profile screen error: Failed to fetch user information.');
              return Center(
                child: Text(
                  'Something went wrong. Please try again later.',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 20,
                      ),
                ),
              );
            },
          )),
    );
  }
}
