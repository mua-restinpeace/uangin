part of 'get_budgets_bloc.dart';

sealed class GetBudgetsEvent extends Equatable {
  const GetBudgetsEvent();

  @override
  List<Object> get props => [];
}

class GetBudgets extends GetBudgetsEvent {
  final String userId;

  const GetBudgets(this.userId);

  @override
  List<Object> get props => [userId];
}

class BudgetUpdate extends GetBudgetsEvent {
  final List<Budgets> budgetList;

  const BudgetUpdate(this.budgetList);

  @override
  List<Object> get props => [budgetList];
}
