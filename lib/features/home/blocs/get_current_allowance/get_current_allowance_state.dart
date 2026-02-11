part of 'get_current_allowance_bloc.dart';

sealed class GetCurrentAllowanceState extends Equatable {
  const GetCurrentAllowanceState();
  
  @override
  List<Object> get props => [];
}

final class GetCurrentAllowanceInitial extends GetCurrentAllowanceState {}
final class GetCurrentAllowanceLoading extends GetCurrentAllowanceState{}
final class GetCurrentAllowanceFailure extends GetCurrentAllowanceState{}
final class GetCurrentAllowanceSuccess extends GetCurrentAllowanceState{
  final double currentAllowance;

  const GetCurrentAllowanceSuccess(
    this.currentAllowance
  );

  @override
  List<Object> get props => [currentAllowance];
}