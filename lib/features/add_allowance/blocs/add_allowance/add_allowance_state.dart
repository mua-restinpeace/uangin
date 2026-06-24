part of 'add_allowance_bloc.dart';

sealed class AddAllowanceState extends Equatable {
  const AddAllowanceState();
  
  @override
  List<Object?> get props => [];
}

final class AddAllowanceInitial extends AddAllowanceState {}
final class AddAllowanceLoading extends AddAllowanceState {}
final class AddAllowanceFailure extends AddAllowanceState {
  final String? message;

  const AddAllowanceFailure(this.message);

  @override
  List<Object?> get props => [message];
}
final class AddAllowanceSuccess extends AddAllowanceState {}
