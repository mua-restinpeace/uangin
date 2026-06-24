import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_expense_event.dart';
part 'add_expense_state.dart';

class AddExpenseBloc extends Bloc<AddExpenseEvent, AddExpenseState> {
  final AllowanceRepository _allowanceRepository;

  AddExpenseBloc(this._allowanceRepository) : super(AddExpenseInitial()) {
    on<AddExpenseSubmitted>((event, emit) async {
      emit(AddExpenseLoading());
      try {
        final addTransaction = await _allowanceRepository.addTransaction(
            userId: event.userId,
            budgetId: event.budgetId,
            budgetName: event.budgetName,
            budgetIcon: event.budgetIcon,
            budgetColor: event.budgetColor,
            amount: event.amount,
            date: event.date,
            type: TransactionType.expense,
            description: event.description);

        log('expense added: ${addTransaction.transactionId}');
        emit(AddExpenseSuccess());
      } catch (e) {
        log('error adding expense: $e');
        emit(AddExpenseFailure(e.toString()));
      }
    });
  }
}
