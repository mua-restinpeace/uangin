part of 'update_password_bloc.dart';

sealed class UpdatePasswordEvent extends Equatable {
  const UpdatePasswordEvent();

  @override
  List<Object> get props => [];
}

class UpdatePassword extends UpdatePasswordEvent {
  final String currentPassword;
  final String newPassword;

  const UpdatePassword(
      {required this.currentPassword, required this.newPassword});

  @override
  List<Object> get props => [currentPassword, newPassword];
}
