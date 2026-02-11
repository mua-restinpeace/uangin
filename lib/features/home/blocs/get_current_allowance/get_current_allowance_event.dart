part of 'get_current_allowance_bloc.dart';

sealed class GetCurrentAllowanceEvent extends Equatable {
  const GetCurrentAllowanceEvent();

  @override
  List<Object> get props => [];
  
}
class GetCurrentAllowance extends GetCurrentAllowanceEvent {}

class GetCurrentAllowanceUpdated extends GetCurrentAllowanceEvent{
  final double currentAllowance;

  const GetCurrentAllowanceUpdated(this.currentAllowance);

  @override
  List<Object> get props => [currentAllowance];
}

