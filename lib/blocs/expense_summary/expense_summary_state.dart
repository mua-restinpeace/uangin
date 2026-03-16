part of 'expense_summary_bloc.dart';

sealed class ExpenseSummaryState extends Equatable {
  const ExpenseSummaryState();

  @override
  List<Object> get props => [];
}

final class ExpenseSummaryInitial extends ExpenseSummaryState {}

final class ExpenseSummaryLoading extends ExpenseSummaryState {}

final class ExpenseSummaryFailure extends ExpenseSummaryState {}

final class ExpenseSummarySuccess extends ExpenseSummaryState {
  final double totalSpent;
  final Map<String, double> breakdown;

  const ExpenseSummarySuccess(
      {required this.totalSpent, required this.breakdown});

  @override
  List<Object> get props => [totalSpent, breakdown];
}
