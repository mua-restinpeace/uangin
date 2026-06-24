part of 'add_saving_goal_bloc_bloc.dart';

sealed class AddSavingGoalBlocEvent extends Equatable {
  const AddSavingGoalBlocEvent();

  @override
  List<Object> get props => [];
}

class AddSavingGoal extends AddSavingGoalBlocEvent{
  final String userId;
  final String name;
  final double targetAmount;

  const AddSavingGoal({
    required this.userId,
    required this.name,
    required this.targetAmount,
  });

  @override
  List<Object> get props => [userId, name, targetAmount];
}
