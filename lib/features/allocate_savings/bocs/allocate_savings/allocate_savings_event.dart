part of 'allocate_savings_bloc.dart';

sealed class AllocateSavingsEvent extends Equatable {
  const AllocateSavingsEvent();

  @override
  List<Object> get props => [];
}

class AllocateSaving extends AllocateSavingsEvent{
  final String userId;
  final String goalId;
  final double amountToAdd;

  const AllocateSaving(this.userId, this.goalId, this.amountToAdd);

  @override
  List<Object> get props => [userId, goalId, amountToAdd];
}
