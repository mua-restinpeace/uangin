part of 'get_total_spent_bloc.dart';

sealed class GetTotalSpentEvent extends Equatable {
  const GetTotalSpentEvent();

  @override
  List<Object> get props => [];
}

class GetTotalSpent extends GetTotalSpentEvent {
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;

  const GetTotalSpent(this.userId, this.periodStart, this.periodEnd);

  @override
  List<Object> get props => [userId, periodStart, periodEnd];
}

class GetTotalSpentUpdated extends GetTotalSpentEvent {
  final double spentAmount;

  const GetTotalSpentUpdated(this.spentAmount);

  @override
  List<Object> get props => [spentAmount];
}
