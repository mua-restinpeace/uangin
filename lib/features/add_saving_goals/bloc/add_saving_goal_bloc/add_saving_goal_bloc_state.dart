part of 'add_saving_goal_bloc_bloc.dart';

sealed class AddSavingGoalState extends Equatable {
  const AddSavingGoalState();

  @override
  List<Object> get props => [];
}

final class AddSavingGoalBlocInitial extends AddSavingGoalState {}

final class AddSavingGoalBlocLoading extends AddSavingGoalState {}

final class AddSavingGoalBlocFailure extends AddSavingGoalState {}

final class AddSavingGoalBlocSuccess extends AddSavingGoalState {}
