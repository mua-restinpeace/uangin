part of 'update_account_info_bloc.dart';

sealed class UpdateAccountInfoState extends Equatable {
  const UpdateAccountInfoState();
  
  @override
  List<Object?> get props => [];
}

final class UpdateAccountInfoInitial extends UpdateAccountInfoState {}
final class UpdateAccountInfoLoading extends UpdateAccountInfoState {}
final class UpdateAccountInfoSuccess extends UpdateAccountInfoState {}
final class UpdateAccountInfoFailure extends UpdateAccountInfoState {
  final String errorMessage;
  const UpdateAccountInfoFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
