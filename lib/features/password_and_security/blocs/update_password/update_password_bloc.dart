import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'update_password_event.dart';
part 'update_password_state.dart';

class UpdatePasswordBloc
    extends Bloc<UpdatePasswordEvent, UpdatePasswordState> {
  final UserRepository _userRepository;
  UpdatePasswordBloc(this._userRepository) : super(UpdatePasswordInitial()) {
    on<UpdatePassword>((event, emit) async {
      emit(UpdatePasswordLoading());
      try {
        await _userRepository.updatePassword(
            currentPassword: event.currentPassword,
            newPassword: event.newPassword);

        emit(UpdatePasswordSuccess());
      } catch (e) {
        final message = e.toString().replaceFirst('Exception: ', '');
        emit(UpdatePasswordFailure(message));
      }
    });
  }
}
