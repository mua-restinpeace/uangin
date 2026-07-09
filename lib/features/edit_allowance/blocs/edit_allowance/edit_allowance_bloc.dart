import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'edit_allowance_event.dart';
part 'edit_allowance_state.dart';

class EditAllowanceBloc extends Bloc<EditAllowanceEvent, EditAllowanceState> {
  final AllowanceRepository _allowanceRepository;

  EditAllowanceBloc(this._allowanceRepository) : super(EditAllowanceInitial()) {
    on<EditAllowanceSubmitted>((event, emit) async {
      emit(EditAllowanceLoading());
      try {
        final udpatedAllowance =
            await _allowanceRepository.updateCurrentAllowance(
                userId: event.userId,
                targetAmount: event.targetAmount,
                date: event.date,
                notes: event.notes);

        log('allowance updated: ${udpatedAllowance.amount} from current amount');
        emit(EditAllowanceSuccess());
      } catch (e) {
        log('error edit allowance: $e');
        emit(EditAllowanceFailure(e.toString()));
      }
    });
  }
}
