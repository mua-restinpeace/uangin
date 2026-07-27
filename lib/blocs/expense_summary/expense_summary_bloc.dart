import 'dart:async';
import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'expense_summary_event.dart';
part 'expense_summary_state.dart';

enum SummaryFilter { thisWeek, lastWeek, thisMonth, lastMonth, thisYear }

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

        final dateRange = _getDateRange(event.filter);
        log('fetching expense summary from ${dateRange.start} to ${dateRange.end}');

        _totalSpentSubscription = _allowanceRepository
            .getTotalSpentThisPeriod(
                event.userId, dateRange.start, dateRange.end)
            .listen((total) {
          currentTotal = total;

          if (currentBreakdown != null) {
            log('Expense Summary: current total is $currentTotal');
            add(ExpenseSummaryUpdated(currentTotal!, currentBreakdown!));
          }
        });

        _breakdownSubscription = _allowanceRepository
            .getSpendingBreakdown(event.userId, dateRange.start, dateRange.end)
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

    on<ResetExpenseSummary>(
      (event, emit) async {
        await _totalSpentSubscription?.cancel();
        await _breakdownSubscription?.cancel();

        _totalSpentSubscription = null;
        _breakdownSubscription = null;

        emit(ExpenseSummaryInitial());
      },
    );
  }

  DateTimeRange _getDateRange(SummaryFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case SummaryFilter.thisWeek:
        final weekStart = today.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart
            .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return DateTimeRange(start: weekStart, end: weekEnd);
      case SummaryFilter.lastWeek:
        final lastWeekStart = today
            .subtract(Duration(days: now.weekday - 1))
            .subtract(const Duration(days: 7));
        final lastWeekEnd = lastWeekStart
            .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return DateTimeRange(start: lastWeekStart, end: lastWeekEnd);
      case SummaryFilter.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(seconds: 1));
        return DateTimeRange(start: monthStart, end: monthEnd);
      case SummaryFilter.lastMonth:
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd = DateTime(now.year, now.month, 1)
            .subtract(const Duration(seconds: 1));
        return DateTimeRange(start: lastMonthStart, end: lastMonthEnd);
      case SummaryFilter.thisYear:
        final yearStart = DateTime(now.year, 1, 1);
        final yearEnd = DateTime(now.year, 12, 31, 23, 59, 59);
        return DateTimeRange(start: yearStart, end: yearEnd);
      default:
        log("_getDateRange return default");
        return DateTimeRange(
            start: today,
            end: today
                .add(const Duration(days: 1))
                .subtract(const Duration(seconds: 1)));
    }
  }
}
