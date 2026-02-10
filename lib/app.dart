import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangin/app_view.dart';
import 'package:uangin/features/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'blocs/authenticaton_bloc/authentication_bloc.dart';

class MyApp extends StatelessWidget {
  final AllowanceRepository allowanceRepository;
  final UserRepository userRepository;
  const MyApp(this.userRepository, this.allowanceRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (context) =>
              AuthenticationBloc(userRepository: userRepository),
        ),
        BlocProvider(
          create: (context) => SignInBloc(userRepository),
        ),
      ],
      child: const MyAppView(),
    );
  }
}
