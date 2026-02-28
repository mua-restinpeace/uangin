part of 'update_transaction_bloc.dart';

sealed class UpdateTransactionState extends Equatable {
  const UpdateTransactionState();
  
  @override
  List<Object> get props => [];
}

final class UpdateTransactionInitial extends UpdateTransactionState {}
final class UpdateTransactionLoading extends UpdateTransactionState {}
final class UpdateTransactionFailure extends UpdateTransactionState {}
final class UpdateTransactionSuccess extends UpdateTransactionState {}
