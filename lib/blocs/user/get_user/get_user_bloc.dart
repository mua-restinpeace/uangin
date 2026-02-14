import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'get_user_event.dart';
part 'get_user_state.dart';

class GetUserBloc
    extends Bloc<GetUserEvent, GetUserState> {
  final UserRepository _userRepository;
  StreamSubscription<MyUser?>? _userSubsription;

  GetUserBloc(this._userRepository) : super(GetUserInitial()) {
    on<GetUser>((event, emit) async {
      emit(GetUserLoading());
      try {
        await _userSubsription?.cancel();

        _userSubsription = _userRepository.user.listen((user) {
          if (user != null && user.isNotEmpty) {
            add(GetUserUpdated(user));
          } else {
            add(const GetUserUpdated(null));
          }
        });
      } catch (e) {
        emit(GetUserFailure());
      }
    });

    on<GetUserUpdated>(
      (event, emit) {
        if(event.user != null){
          emit(GetUserSuccess(event.user!));
        }else{
          emit(GetUserFailure());
        }
      },
    );
  }

  @override
  Future<void> close() {
    _userSubsription?.cancel();
    return super.close();
  }
}
