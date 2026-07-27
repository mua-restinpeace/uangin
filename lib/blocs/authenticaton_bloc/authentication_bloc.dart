import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_repository/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  late final StreamSubscription<MyUser?> _userSubscription;

  AuthenticationBloc({required this.userRepository})
      : super(const AuthenticationState.unknown()) {
    _userSubscription = userRepository.user.listen((user) {
      if (user == null) {
        log('user was null. authentication logout request called');
        add(AuthenticatonLogoutRequest());
      } else {
        log('Authentication user changed: $user');
        add(AuthenticationUserChanged(user));
      }
    });
    on<AuthenticationUserChanged>((event, emit) async {
      await _saveUserIdForBackgroundTask(event.user.userId);
      emit(AuthenticationState.authenticated(event.user));
    });

    on<AuthenticationLogoutRequested>(
      (event, emit) async {
        await userRepository.logout();
      },
    );

    on<AuthenticatonLogoutRequest>((event, emit) async {
      final hasSeenOnBoarding = await userRepository.hasOnBoardingComplete();
      if (hasSeenOnBoarding) {
        await _clearuserIdForBackgroundTask();
        emit(const AuthenticationState.unauthenticated());
      } else {
        emit(const AuthenticationState.unknown());
      }
    });

    on<AuthenticationOnBoardingCompleted>((event, emit) async {
      await userRepository.setOnBoardingComplete();
      emit(const AuthenticationState.unauthenticated());
    });
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }

  Future<void> _saveUserIdForBackgroundTask(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<void> _clearuserIdForBackgroundTask() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    log('userId cleared from background task');
  }
}
