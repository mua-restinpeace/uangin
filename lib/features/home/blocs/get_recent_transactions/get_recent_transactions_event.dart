part of 'get_recent_transactions_bloc.dart';

sealed class GetRecentTransactionsEvent extends Equatable {
  const GetRecentTransactionsEvent();

  @override
  List<Object?> get props => [];
}

class GetRecentTransactions extends GetRecentTransactionsEvent{
  final String userId;

  const GetRecentTransactions(this.userId);

  @override
  List<Object> get props => [userId];
}

class GetRecentTransactionUpdated extends GetRecentTransactionsEvent{
  final List<Transactions> transactionList;

  const GetRecentTransactionUpdated(this.transactionList);

  @override
  List<Object?> get props => [transactionList];
}
