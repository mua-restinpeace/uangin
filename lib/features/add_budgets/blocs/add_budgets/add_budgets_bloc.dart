import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_budgets_event.dart';
part 'add_budgets_state.dart';

class AddBudgetsBloc extends Bloc<AddBudgetsEvent, AddBudgetsState> {
  final AllowanceRepository _allowanceRepository;
  AddBudgetsBloc(this._allowanceRepository) : super(AddBudgetsInitial()) {
    on<AddBudgetSubmitted>((event, emit) async {
      emit(AddBudgetsLoading());
      try {
        final budget = await _allowanceRepository.createBudget(
            userId: event.userId,
            name: event.name,
            icon: event.icon,
            color: event.color,
            allocatedAmount: event.allocatedAmount,
            periodStart: event.periodStart,
            periodEnd: event.periodEnd);

        log('budget added: ${budget.budgetId}');
        emit(AddBudgetsSuccess());
      } catch (e) {
        log('error adding budget: $e');
        emit(AddBudgetsFailure());
      }
    });
  }
}
