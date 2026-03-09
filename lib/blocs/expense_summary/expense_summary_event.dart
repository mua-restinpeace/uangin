part of 'expense_summary_bloc.dart';

sealed class ExpenseSummaryEvent extends Equatable {
  const ExpenseSummaryEvent();

  @override
  List<Object> get props => [];
}

class GetExpenseSummary extends ExpenseSummaryEvent {
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;

  const GetExpenseSummary(this.userId, this.periodStart, this.periodEnd);

  @override
  List<Object> get props => [userId, periodStart, periodEnd];
}

class ExpenseSummaryUpdated extends ExpenseSummaryEvent{
  final double totalSpent;
  final Map<String, double> breakdown;

  const ExpenseSummaryUpdated(this.totalSpent, this.breakdown);

  @override
  List<Object> get props => [totalSpent, breakdown];
}
