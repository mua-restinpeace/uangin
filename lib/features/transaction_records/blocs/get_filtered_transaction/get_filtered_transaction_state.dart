part of 'get_filtered_transaction_bloc.dart';

sealed class GetFilteredTransactionState extends Equatable {
  const GetFilteredTransactionState();
  
  @override
  List<Object> get props => [];
}

final class GetFilteredTransactionInitial extends GetFilteredTransactionState {}
final class GetFilteredTransactionLoading extends GetFilteredTransactionState {}
final class GetFilteredTransactionFailure extends GetFilteredTransactionState {}
final class GetFilteredTransactionSuccess extends GetFilteredTransactionState {
  final Map<String, List<Transactions>> groupedTransaction;
  final TransactionFilter currentFilter;

  const GetFilteredTransactionSuccess(this.groupedTransaction, this.currentFilter);

  @override
  List<Object> get props => [groupedTransaction, currentFilter];
}
