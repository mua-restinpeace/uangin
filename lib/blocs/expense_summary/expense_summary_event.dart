part of 'expense_summary_bloc.dart';

sealed class ExpenseSummaryEvent extends Equatable {
  const ExpenseSummaryEvent();

  @override
  List<Object> get props => [];
}

class GetExpenseSummary extends ExpenseSummaryEvent {
  final String userId;
  final SummaryFilter filter;

  const GetExpenseSummary(this.userId, this.filter);

  @override
  List<Object> get props => [userId, filter];
}

class ExpenseSummaryUpdated extends ExpenseSummaryEvent{
  final double totalSpent;
  final Map<String, double> breakdown;

  const ExpenseSummaryUpdated(this.totalSpent, this.breakdown);

  @override
  List<Object> get props => [totalSpent, breakdown];
}
