part of 'edit_allowance_bloc.dart';

sealed class EditAllowanceState extends Equatable {
  const EditAllowanceState();
  
  @override
  List<Object?> get props => [];
}

final class EditAllowanceInitial extends EditAllowanceState {}
final class EditAllowanceLoading extends EditAllowanceState {}
final class EditAllowanceSuccess extends EditAllowanceState {}
final class EditAllowanceFailure extends EditAllowanceState {
  final String? message;

  const EditAllowanceFailure(this.message);

  @override
  List<Object?> get props => [message];
}
