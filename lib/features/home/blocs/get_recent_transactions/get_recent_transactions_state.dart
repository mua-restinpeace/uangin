part of 'get_recent_transactions_bloc.dart';

sealed class GetRecentTransactionsState extends Equatable {
  const GetRecentTransactionsState();
  
  @override
  List<Object?> get props => [];
}

final class GetRecentTransactionsInitial extends GetRecentTransactionsState {}
final class GetRecentTransactionsLoading extends GetRecentTransactionsState {}
final class GetRecentTransactionsFailure extends GetRecentTransactionsState {}
final class GetRecentTransactionsSuccess extends GetRecentTransactionsState {
  final List<Transactions> transactionList;

  const GetRecentTransactionsSuccess(this.transactionList);

  @override
  List<Object?> get props => [transactionList];
}
