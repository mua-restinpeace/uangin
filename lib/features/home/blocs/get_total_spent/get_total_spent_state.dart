part of 'get_total_spent_bloc.dart';

sealed class GetTotalSpentState extends Equatable {
  const GetTotalSpentState();
  
  @override
  List<Object?> get props => [];
}

final class GetTotalSpentInitial extends GetTotalSpentState {}
final class GetTotalSpentLoading extends GetTotalSpentState {}
final class GetTotalSpentFailure extends GetTotalSpentState {}
final class GetTotalSpentSuccess extends GetTotalSpentState {
  final double spentTotal;

  const GetTotalSpentSuccess(this.spentTotal);

  @override
  List<Object?> get props => [spentTotal];
}
