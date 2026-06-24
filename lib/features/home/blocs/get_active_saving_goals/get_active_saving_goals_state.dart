part of 'get_active_saving_goals_bloc.dart';

sealed class GetActiveSavingGoalsState extends Equatable {
  const GetActiveSavingGoalsState();
  
  @override
  List<Object> get props => [];
}

final class GetActiveSavingGoalsInitial extends GetActiveSavingGoalsState {}
final class GetActiveSavingGoalsLoading extends GetActiveSavingGoalsState {}
final class GetActiveSavingGoalsFailure extends GetActiveSavingGoalsState {}
final class GetActiveSavingGoalsSuccess extends GetActiveSavingGoalsState {
  final List<SavingGoals> goals;

  const GetActiveSavingGoalsSuccess(this.goals);

  @override
  List<Object> get props => [goals];
}
