import 'dart:async';
import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'get_filtered_transaction_event.dart';
part 'get_filtered_transaction_state.dart';

enum TransactionFilter {
  today,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisYear
}

class GetFilteredTransactionBloc
    extends Bloc<GetFilteredTransactionEvent, GetFilteredTransactionState> {
  final AllowanceRepository _allowanceRepository;
  StreamSubscription<List<Transactions>>? _transactionSubscription;

  GetFilteredTransactionBloc(this._allowanceRepository)
      : super(GetFilteredTransactionInitial()) {
    on<GetFilteredTransactions>((event, emit) async {
      emit(GetFilteredTransactionLoading());
      try {
        await _transactionSubscription?.cancel();

        final dateRange = _getDateRange(event.filter);
        log('fetchin transaction from ${dateRange.start} to ${dateRange.end}');

        _transactionSubscription = _allowanceRepository
            .getTransactionByDateRange(
                event.userId, dateRange.start, dateRange.end)
            .listen((transactions) {
          final grouped = _groupedTransactionByDate(transactions);
          add(FilteredTransactionUpdate(grouped, event.filter));
        });
      } catch (e) {
        log('get filtered transaction failed: $e');
        emit(GetFilteredTransactionFailure());
      }
    });

    on<FilteredTransactionUpdate>((event, emit) {
      log("updating get filtered transaction: ${event.groupedTransaction}");
      emit(GetFilteredTransactionSuccess(
          event.groupedTransaction, event.currentFilter));
    });
  }

  DateTimeRange _getDateRange(TransactionFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case TransactionFilter.today:
        return DateTimeRange(
            start: today,
            end: today
                .add(const Duration(days: 1))
                .subtract(const Duration(seconds: 1)));
      case TransactionFilter.thisWeek:
        final weekStart = today.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart
            .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return DateTimeRange(start: weekStart, end: weekEnd);
      case TransactionFilter.lastWeek:
        final lastWeekStart = today
            .subtract(Duration(days: now.weekday - 1))
            .subtract(const Duration(days: 7));
        final lastWeekEnd = lastWeekStart
            .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return DateTimeRange(start: lastWeekStart, end: lastWeekEnd);
      case TransactionFilter.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(seconds: 1));
        return DateTimeRange(start: monthStart, end: monthEnd);
      case TransactionFilter.lastMonth:
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd = DateTime(now.year, now.month, 1)
            .subtract(const Duration(seconds: 1));
        return DateTimeRange(start: lastMonthStart, end: lastMonthEnd);
      case TransactionFilter.thisYear:
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

  Map<String, List<Transactions>> _groupedTransactionByDate(
      List<Transactions> transactions) {
    final Map<String, List<Transactions>> grouped = {};

    for (var transaction in transactions) {
      final dateKey = _formatDateKey(transaction.date!);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }

      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    return super.close();
  }
}
