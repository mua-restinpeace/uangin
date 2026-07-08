import 'dart:async';
import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'allowance_history_event.dart';
part 'allowance_history_state.dart';

enum AllowanceFilter {
  thisMonth,
  lastMonth,
  thisYear,
}

class AllowanceHistoryBloc
    extends Bloc<AllowanceHistoryEvent, AllowanceHistoryState> {
  final AllowanceRepository _allowanceRepository;
  StreamSubscription<List<Allowances>>? _allowanceSubscription;
  AllowanceHistoryBloc(this._allowanceRepository)
      : super(AllowanceHistoryInitial()) {
    on<GetFilteredAllowance>((event, emit) async {
      emit(AllowanceHistoryLoading());
      try {
        await _allowanceSubscription?.cancel();

        final dateRange = _getDateRange(event.filter);
        log('fetching allowance from ${dateRange.start} to ${dateRange.end}');

        _allowanceSubscription = _allowanceRepository
            .getAllowanceByDateRange(
                event.userId, dateRange.start, dateRange.end)
            .listen(
          (allowance) {
            final grouped = _groupedAllowanceByDate(allowance);
            add(FilteredAllowanceUpdate(grouped, event.filter));
          },
        );
      } catch (e) {
        log('get fitered allowance failed: $e');
        emit(AllowanceHistoryFailure());
      }
    });

    on<FilteredAllowanceUpdate>((event, emit) {
      emit(
          AllowanceHistorySuccess(event.groupedAllowance, event.currentFilter));
    });
  }

  DateTimeRange _getDateRange(AllowanceFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case AllowanceFilter.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(seconds: 1));
        return DateTimeRange(start: monthStart, end: monthEnd);
      case AllowanceFilter.lastMonth:
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd = DateTime(now.year, now.month, 1)
            .subtract(const Duration(seconds: 1));
        return DateTimeRange(start: lastMonthStart, end: lastMonthEnd);
      case AllowanceFilter.thisYear:
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

  String _formatDateKey(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }

  Map<String, List<Allowances>> _groupedAllowanceByDate(
      List<Allowances> allowances) {
    final Map<String, List<Allowances>> grouped = {};

    for (var allowance in allowances) {
      final dateKey = _formatDateKey(allowance.date!);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }

      grouped[dateKey]!.add(allowance);
    }

    return grouped;
  }

  @override
  Future<void> close() {
    _allowanceSubscription?.cancel();
    return super.close();
  }
}
