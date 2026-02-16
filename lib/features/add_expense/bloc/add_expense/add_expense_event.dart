part of 'add_expense_bloc.dart';

sealed class AddExpenseEvent extends Equatable {
  const AddExpenseEvent();

  @override
  List<Object?> get props => [];
}

class AddExpenseSubmitted extends AddExpenseEvent {
  final String userId;
  final String budgetId;
  final String budgetName;
  final String budgetIcon;
  final String budgetColor;
  final double amount;
  final DateTime date;
  final String? description;

  const AddExpenseSubmitted(
      {required this.userId,
      required this.budgetId,
      required this.budgetName,
      required this.budgetIcon,
      required this.budgetColor,
      required this.amount,
      required this.date,
      this.description});

  @override
  List<Object?> get props => [
        userId,
        budgetId,
        budgetName,
        budgetIcon,
        budgetColor,
        amount,
        date,
        description
      ];
}
