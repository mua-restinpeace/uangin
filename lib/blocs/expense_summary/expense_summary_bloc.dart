import 'dart:async';
import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'expense_summary_event.dart';
part 'expense_summary_state.dart';

class ExpenseSummaryBloc
    extends Bloc<ExpenseSummaryEvent, ExpenseSummaryState> {
  final AllowanceRepository _allowanceRepository;
  StreamSubscription<double>? _totalSpentSubscription;
  StreamSubscription<Map<String, dynamic>>? _breakdownSubscription;

  ExpenseSummaryBloc(this._allowanceRepository)
      : super(ExpenseSummaryInitial()) {
    on<GetExpenseSummary>((event, emit) async {
      emit(ExpenseSummaryLoading());
      try {
        await _totalSpentSubscription?.cancel();
        await _breakdownSubscription?.cancel();

        double? currentTotal;
        Map<String, double>? currentBreakdown;

        _totalSpentSubscription = _allowanceRepository
            .getTotalSpentThisPeriod(
                event.userId, event.periodStart, event.periodEnd)
            .listen((total) {
          currentTotal = total;

          if (currentBreakdown != null) {
            log('Expense Summary: current total is $currentTotal');
            add(ExpenseSummaryUpdated(currentTotal!, currentBreakdown!));
          }
        });

        _breakdownSubscription = _allowanceRepository
            .getSpendingBreakdown(
                event.userId, event.periodStart, event.periodEnd)
            .listen((breakdown) {
          currentBreakdown = breakdown;

          if (currentTotal != null) {
            log('Expense Summary: current breakdown is $currentBreakdown');
            add(ExpenseSummaryUpdated(currentTotal!, currentBreakdown!));
          }
        });
      } catch (e) {
        log('getting expense summary failed: $e');
        emit(ExpenseSummaryFailure());
      }
    });

    on<ExpenseSummaryUpdated>((event, emit) {
      emit(ExpenseSummarySuccess(
          totalSpent: event.totalSpent, breakdown: event.breakdown));
    });
  }
}
