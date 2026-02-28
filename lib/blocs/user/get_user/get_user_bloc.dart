import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uangin/blocs/authenticaton_bloc/authentication_bloc.dart';
import 'package:user_repository/user_repository.dart';

part 'get_user_event.dart';
part 'get_user_state.dart';

class GetUserBloc extends Bloc<GetUserEvent, GetUserState> {
  final AuthenticationBloc _authenticationBloc;
  StreamSubscription<AuthenticationState>? _authSubscription;

  final UserRepository _userRepository;
  StreamSubscription<MyUser?>? _userSubscription;

  String? userId;

  GetUserBloc(this._authenticationBloc, this._userRepository)
      : super(GetUserInitial()) {
    on<GetUser>(
      (event, emit) async {
        emit(GetUserLoading());
        try {
          await _authSubscription?.cancel();
          await _userSubscription?.cancel();

          final currentAuthState = _authenticationBloc.state;
          if (currentAuthState.status == AuthenticationStatus.authenticated &&
              currentAuthState.user != null) {
            log('GetUser: Using current auth state - ${currentAuthState.user!.userId}');
            userId = currentAuthState.user!.userId;
            add(GetUserUpdated(currentAuthState.user));
            _subscribeToUserStream(currentAuthState.user!.userId);
          }

          _authSubscription = _authenticationBloc.stream.listen((authState) {
            log('GetUser: Auth state changes - ${authState.status}');
            if (authState.status == AuthenticationStatus.authenticated &&
                authState.user != null) {
              add(GetUserUpdated(authState.user));
              _subscribeToUserStream(authState.user!.userId);
            } else if (authState.status ==
                AuthenticationStatus.unauthenticated) {
              log('GetUser: Auth state changes into unauthenticated');
              userId = null;
              _userSubscription?.cancel();
              add(const GetUserUpdated(null));
            }
          });
        } catch (e) {
          log('Error in getting user: $e');
          emit(GetUserFailure());
        }
      },
    );

    on<GetUserUpdated>(
      (event, emit) {
        if (event.user != null) {
          log('GetUserUpdated with user: ${event.user}');
          emit(GetUserSuccess(event.user!));
        } else {
          log('GetUserUpdated with null user');
          emit(GetUserFailure());
        }
      },
    );
  }

  void _subscribeToUserStream(String userId) {
    log('Subscribing to user stream for user: $userId');
    _userSubscription = _userRepository.user.listen(
      (user) {
        if (user != null && user.userId == userId) {
          log('User stream updated: $userId');
          add(GetUserUpdated(user));
        }
      },
    );
  }

  @override
  Future<void> close() {
    // _authSubscription?.cancel();
    _userSubscription?.cancel();
    return super.close();
  }
}
