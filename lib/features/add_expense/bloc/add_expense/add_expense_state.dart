part of 'add_expense_bloc.dart';

sealed class AddExpenseState extends Equatable {
  const AddExpenseState();
  
  @override
  List<Object?> get props => [];
}

final class AddExpenseInitial extends AddExpenseState {}
final class AddExpenseLoading extends AddExpenseState {}
final class AddExpenseFailure extends AddExpenseState {
  final String? message;

  const AddExpenseFailure(this.message);

  @override
  List<Object?> get props => [message];
}
final class AddExpenseSuccess extends AddExpenseState {}
