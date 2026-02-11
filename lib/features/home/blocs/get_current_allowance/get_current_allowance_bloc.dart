import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'get_current_allowance_event.dart';
part 'get_current_allowance_state.dart';

class GetCurrentAllowanceBloc
    extends Bloc<GetCurrentAllowanceEvent, GetCurrentAllowanceState> {
  final UserRepository _userRepository;
  StreamSubscription<MyUser?>? _userSubsription;

  GetCurrentAllowanceBloc(this._userRepository) : super(GetCurrentAllowanceInitial()) {
    on<GetCurrentAllowance>((event, emit) async {
      emit(GetCurrentAllowanceLoading());
      try {
        await _userSubsription?.cancel();

        _userSubsription = _userRepository.user.listen((user) {
          if (user != null && user.isNotEmpty) {
            add(GetCurrentAllowanceUpdated(user.currentAllowance));
          } else {
            add(GetCurrentAllowanceUpdated(0.0));
          }
        });
      } catch (e) {
        emit(GetCurrentAllowanceFailure());
      }
    });

    on<GetCurrentAllowanceUpdated>(
      (event, emit) {
        emit(GetCurrentAllowanceSuccess(event.currentAllowance));
      },
    );
  }

  @override
  Future<void> close() {
    _userSubsription?.cancel();
    return super.close();
  }
}
