part of 'update_transaction_bloc.dart';

sealed class UpdateTransactionEvent extends Equatable {
  const UpdateTransactionEvent();

  @override
  List<Object> get props => [];
}

class UpdateTransaction extends UpdateTransactionEvent {
  final Transactions transactions;
  final String originalBudgetId;
  final double originalAmount;

  const UpdateTransaction(
      this.transactions, this.originalAmount, this.originalBudgetId);

  @override
  List<Object> get props => [transactions, originalAmount, originalBudgetId];
}
