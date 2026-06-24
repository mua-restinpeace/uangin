part of 'get_filtered_transaction_bloc.dart';

sealed class GetFilteredTransactionEvent extends Equatable {
  const GetFilteredTransactionEvent();

  @override
  List<Object> get props => [];
}

class GetFilteredTransactions extends GetFilteredTransactionEvent{
  final String userId;
  final TransactionFilter filter;

  const GetFilteredTransactions(this.userId, this.filter);

  @override
  List<Object> get props => [userId, filter];
}

class FilteredTransactionUpdate extends GetFilteredTransactionEvent{
  final Map<String, List<Transactions>> groupedTransaction;
  final TransactionFilter currentFilter;

  const FilteredTransactionUpdate(this.groupedTransaction, this.currentFilter);

  @override
  List<Object> get props => [groupedTransaction, currentFilter];
}
