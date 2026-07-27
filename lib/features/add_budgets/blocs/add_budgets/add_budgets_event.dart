part of 'add_budgets_bloc.dart';

sealed class AddBudgetsEvent extends Equatable {
  const AddBudgetsEvent();

  @override
  List<Object> get props => [];
}

class AddBudgetSubmitted extends AddBudgetsEvent {
  final String userId;
  final String name;
  final String icon;
  final String color;
  final double allocatedAmount;
  final DateTime periodStart;
  final DateTime periodEnd;

  const AddBudgetSubmitted(
      {required this.userId,
      required this.name,
      required this.icon,
      required this.color,
      required this.allocatedAmount,
      required this.periodStart,
      required this.periodEnd});

  @override
  List<Object> get props =>
      [userId, name, icon, color, allocatedAmount, periodStart, periodEnd];
}
