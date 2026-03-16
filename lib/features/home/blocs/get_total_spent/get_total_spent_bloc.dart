import 'dart:async';
import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'get_total_spent_event.dart';
part 'get_total_spent_state.dart';

class GetTotalSpentBloc extends Bloc<GetTotalSpentEvent, GetTotalSpentState> {
  final AllowanceRepository _allowanceRepository;
  StreamSubscription<double>? _totalSpentSubscription;

  GetTotalSpentBloc(this._allowanceRepository) : super(GetTotalSpentInitial()) {
    on<GetTotalSpent>((event, emit) async {
      emit(GetTotalSpentLoading());
      try {
        await _totalSpentSubscription?.cancel();

        double? currentTotal;
        _totalSpentSubscription = _allowanceRepository
            .getTotalSpentThisPeriod(event.userId, event.periodStart, event.periodEnd)
            .listen((total) {
          currentTotal = total;

          add(GetTotalSpentUpdated(currentTotal!));
        });
      } catch (e) {
        log('Get total spent failure: $e');
        emit(GetTotalSpentFailure());
      }
    });

    on<GetTotalSpentUpdated>((event, emit) {
      emit(GetTotalSpentSuccess(event.spentAmount));
    });
  }

  @override
  Future<void> close() {
    _totalSpentSubscription?.cancel();
    return super.close();
  }
}
