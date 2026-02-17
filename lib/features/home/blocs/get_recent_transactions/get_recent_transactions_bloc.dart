import 'dart:async';
import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'get_recent_transactions_event.dart';
part 'get_recent_transactions_state.dart';

class GetRecentTransactionsBloc
    extends Bloc<GetRecentTransactionsEvent, GetRecentTransactionsState> {
  final AllowanceRepository _allowanceRepository;
  StreamSubscription<List<Transactions>>? _transactionSubscription;

  GetRecentTransactionsBloc(this._allowanceRepository)
      : super(GetRecentTransactionsInitial()) {
    on<GetRecentTransactions>((event, emit) async {
      emit(GetRecentTransactionsLoading());
      try {
        await _transactionSubscription?.cancel();

        final endDate = DateTime.now();
        final startDate = endDate.subtract(const Duration(days: 30));
        _transactionSubscription = _allowanceRepository
            .getTransactionByDateRange(event.userId, startDate, endDate)
            .listen((transaction) {
          final recentTransactions = transaction.take(6).toList();
          add(GetRecentTransactionUpdated(recentTransactions));
        });
      } catch (e) {
        log('Error getting recent transactions: $e');
        emit(GetRecentTransactionsFailure());
      }
    });

    on<GetRecentTransactionUpdated>(
      (event, emit) {
        emit(GetRecentTransactionsSuccess(event.transactionList));
      },
    );
  }
}
