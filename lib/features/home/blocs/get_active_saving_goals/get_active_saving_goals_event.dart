part of 'get_active_saving_goals_bloc.dart';

sealed class GetActiveSavingGoalsEvent extends Equatable {
  const GetActiveSavingGoalsEvent();

  @override
  List<Object> get props => [];
}

class GetActiveGoals extends GetActiveSavingGoalsEvent{
  final String userId;

  const GetActiveGoals(this.userId);

  @override
  List<Object> get props => [userId];
}

class GetActiveGoalsUpdated extends GetActiveSavingGoalsEvent{
  final List<SavingGoals> goals;

  const GetActiveGoalsUpdated(this.goals);

  @override
  List<Object> get props => [goals];
}