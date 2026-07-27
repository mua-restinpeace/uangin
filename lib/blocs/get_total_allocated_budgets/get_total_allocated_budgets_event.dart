part of 'get_total_allocated_budgets_bloc.dart';

sealed class GetTotalAllocatedBudgetsEvent extends Equatable {
  const GetTotalAllocatedBudgetsEvent();

  @override
  List<Object> get props => [];
}

class GetTotalAllocatedBudgets extends GetTotalAllocatedBudgetsEvent {
  final String userId;

  const GetTotalAllocatedBudgets(this.userId);

  @override
  List<Object> get props => [userId];
}

class GetTotalAllocatedBudgetUpdated extends GetTotalAllocatedBudgetsEvent {
  final double totalAllocated;

  const GetTotalAllocatedBudgetUpdated(this.totalAllocated);

  @override
  List<Object> get props => [totalAllocated];
}

class ResetTotalAllocatedBudget extends GetTotalAllocatedBudgetsEvent {}
