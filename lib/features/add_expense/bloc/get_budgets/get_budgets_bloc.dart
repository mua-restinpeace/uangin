import 'dart:async';
import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'get_budgets_event.dart';
part 'get_budgets_state.dart';

class GetBudgetsBloc extends Bloc<GetBudgetsEvent, GetBudgetsState> {
  final AllowanceRepository _allowanceRepository;
  StreamSubscription<List<Budgets>>? _budgetSubscription;

  GetBudgetsBloc(this._allowanceRepository) : super(GetBudgetsInitial()) {
    on<GetBudgets>((event, emit) async {
      emit(GetBudgetsLoading());
      try {
        await _budgetSubscription?.cancel();

        _budgetSubscription = _allowanceRepository
            .getActiveBudgets(event.userId)
            .listen((budget) {
            add(BudgetUpdate(budget));
          }
        );
      } catch (e) {
        log('error getting budgets: $e');
        emit(GetBudgetsFailure());
      }
    });

    on<BudgetUpdate>((event, emit) {
        emit(GetBudgetsSuccess(event.budgetList));
      }
    );
  }

  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    return super.close();
  }
}
