part of 'update_password_bloc.dart';

sealed class UpdatePasswordState extends Equatable {
  const UpdatePasswordState();
  
  @override
  List<Object> get props => [];
}

final class UpdatePasswordInitial extends UpdatePasswordState {}
final class UpdatePasswordLoading extends UpdatePasswordState {}
final class UpdatePasswordSuccess extends UpdatePasswordState {}
final class UpdatePasswordFailure extends UpdatePasswordState {
  final String errorMessage;

  const UpdatePasswordFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
