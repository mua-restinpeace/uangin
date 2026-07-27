import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'update_account_info_event.dart';
part 'update_account_info_state.dart';

class UpdateAccountInfoBloc
    extends Bloc<UpdateAccountInfoEvent, UpdateAccountInfoState> {
  final UserRepository _userRepository;
  UpdateAccountInfoBloc(this._userRepository)
      : super(UpdateAccountInfoInitial()) {
    on<UpdateAccountInfo>((event, emit) async {
      emit(UpdateAccountInfoLoading());
      try {
        await _userRepository.updateAccountInformation(
            name: event.name, userId: event.userId, photoUrl: event.photoUrl);

        emit(UpdateAccountInfoSuccess());
      } catch (e) {
        emit(UpdateAccountInfoFailure(e.toString()));
      }
    });
  }
}
