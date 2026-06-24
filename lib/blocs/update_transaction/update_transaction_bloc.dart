import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'update_transaction_event.dart';
part 'update_transaction_state.dart';

class UpdateTransactionBloc
    extends Bloc<UpdateTransactionEvent, UpdateTransactionState> {
  final AllowanceRepository _allowanceRepository;
  UpdateTransactionBloc(this._allowanceRepository)
      : super(UpdateTransactionInitial()) {
    on<UpdateTransaction>((event, emit) async {
      emit(UpdateTransactionLoading());
      try {
        await _allowanceRepository.updateTransaction(
            updatedTransaction: event.transactions,
            originalBudgetId: event.originalBudgetId,
            originalAmount: event.originalAmount);

        emit(UpdateTransactionSuccess());
      } catch (e) {
        log('UpdateTransaction failed: $e');
        emit(UpdateTransactionFailure());
      }
    });
  }
}
