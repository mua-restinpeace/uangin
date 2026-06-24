import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_allowance_event.dart';
part 'add_allowance_state.dart';

class AddAllowanceBloc extends Bloc<AddAllowanceEvent, AddAllowanceState> {
  final AllowanceRepository _allowanceRepository;
  AddAllowanceBloc(this._allowanceRepository) : super(AddAllowanceInitial()) {
    on<AddAllowanceSubmitted>((event, emit) async {
      emit(AddAllowanceLoading());
      try {
        final addAllowance = await _allowanceRepository.addAllowance(
            userId: event.userId,
            amount: event.amount,
            currentAllowance: event.currentAllowance,
            addToSaving: event.addToSaving,
            date: DateTime.now(),
            notes: event.notes);

          log('allowance added: ${addAllowance.allowanceId}');
          emit(AddAllowanceSuccess());
      } catch (e) {
        log('add allowance error: $e');
        emit(AddAllowanceFailure(e.toString()));
      }
    });
  }
}
