import 'dart:async';
import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'get_total_allocated_budgets_event.dart';
part 'get_total_allocated_budgets_state.dart';

class GetTotalAllocatedBudgetsBloc
    extends Bloc<GetTotalAllocatedBudgetsEvent, GetTotalAllocatedBudgetsState> {
  final AllowanceRepository _allowanceRepository;
  StreamSubscription<double>? _totalAllocatedSubscription;

  GetTotalAllocatedBudgetsBloc(this._allowanceRepository)
      : super(GetTotalAllocatedBudgetsInitial()) {
    on<GetTotalAllocatedBudgets>((event, emit) async {
      emit(GetTotalAllocatedBudgetsLoading());
      try {
        await _totalAllocatedSubscription?.cancel();

        double currentTotal;

        _totalAllocatedSubscription = _allowanceRepository
            .getTotalAllocatedBudgets(event.userId)
            .listen((total) {
          currentTotal = total;

          add(GetTotalAllocatedBudgetUpdated(currentTotal));
        });
      } catch (e) {
        log('Error getting total allocated budgets: $e');
        emit(GetTotalAllocatedBudgetsFailure());
      }
    });

    on<GetTotalAllocatedBudgetUpdated>((event, emit) {
      emit(GetTotalAllocatedBudgetsSuccess(event.totalAllocated));
    });
  }
}
