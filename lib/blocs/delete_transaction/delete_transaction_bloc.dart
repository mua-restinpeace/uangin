import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'delete_transaction_event.dart';
part 'delete_transaction_state.dart';

class DeleteTransactionBloc
    extends Bloc<DeleteTransactionEvent, DeleteTransactionState> {
  final AllowanceRepository _allowanceRepository;
  DeleteTransactionBloc(this._allowanceRepository)
      : super(DeleteTransactionInitial()) {
    on<DeleteTransaction>((event, emit) async {
      emit(DeleteTransactionLoading());
      try {
        await _allowanceRepository.deleteTransaction(
            event.userId, event.transactionId);
        emit(DeleteTransactionSuccess());
      } catch (e) {
        log('Delete transaction error: $e');
        emit(DeleteTransactionFailure());
      }
    });
  }
}
