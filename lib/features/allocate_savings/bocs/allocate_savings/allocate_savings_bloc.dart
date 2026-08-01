import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'allocate_savings_event.dart';
part 'allocate_savings_state.dart';

class AllocateSavingsBloc
    extends Bloc<AllocateSavingsEvent, AllocateSavingsState> {
  final AllowanceRepository _allowanceRepository;
  AllocateSavingsBloc(this._allowanceRepository)
      : super(AllocateSavingsInitial()) {
    on<AllocateSaving>((event, emit) async {
      emit(AllocateSavingsLoading());
      try {
        final (amountAdded, goalCompleted) =
            await _allowanceRepository.updateSavingGoalProgress(
                event.userId, event.goalId, event.amountToAdd);

        emit(AllocateSavingsSuccess(
          amountAdded: amountAdded,
          amountToAdd: event.amountToAdd,
          goalCompleted: goalCompleted,
        ));
      } catch (e) {
        log('Allocate saving error: $e');
        emit(AllocateSavingsFailure());
      }
    });
  }
}
