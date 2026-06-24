part of 'delete_transaction_bloc.dart';

sealed class DeleteTransactionEvent extends Equatable {
  const DeleteTransactionEvent();

  @override
  List<Object> get props => [];
}

class DeleteTransaction extends DeleteTransactionEvent{
  final String userId;
  final String transactionId;

  const DeleteTransaction(this.userId, this.transactionId);

  @override
  List<Object> get props => [userId, transactionId];
}
