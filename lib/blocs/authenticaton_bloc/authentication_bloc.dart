import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  late final StreamSubscription<MyUser?> _userSubscription;

  AuthenticationBloc({required this.userRepository})
      : super(const AuthenticationState.unknown()) {
    on<AuthenticationUserChanged>((event, emit) {
      emit(AuthenticationState.authenticated(event.user));
    });

    on<AuthenticatonLogoutRequest>((event, emit) async {
      final hasSeenOnBoarding = await userRepository.hasOnBoardingComplete();
      if (hasSeenOnBoarding) {
        emit(const AuthenticationState.unauthenticated());
      } else {
        emit(const AuthenticationState.unknown());
      }
    });

    on<AuthenticationOnBoardingCompleted>((event, emit) async{
      await userRepository.setOnBoardingComplete();
      emit(const AuthenticationState.unauthenticated());
    });

    _userSubscription = userRepository.user.listen((user) {
      if (user == null) {
        add(AuthenticatonLogoutRequest());
      } else {
        add(AuthenticationUserChanged(user));
      }
    });
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
