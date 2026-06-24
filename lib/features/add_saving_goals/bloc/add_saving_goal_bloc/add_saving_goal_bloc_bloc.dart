import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_saving_goal_bloc_event.dart';
part 'add_saving_goal_bloc_state.dart';

class AddSavingGoalBloc
    extends Bloc<AddSavingGoalBlocEvent, AddSavingGoalState> {
  final AllowanceRepository _allowanceRepository;
  AddSavingGoalBloc(this._allowanceRepository)
      : super(AddSavingGoalBlocInitial()) {
    on<AddSavingGoal>((event, emit) async {
      emit(AddSavingGoalBlocLoading());
      try {
        final goal = await _allowanceRepository.createdSavingGoal(
          userId: event.userId,
          name: event.name,
          targetAmount: event.targetAmount,
        );

        log('saving goal added: ${goal.userId}');
        emit(AddSavingGoalBlocSuccess());
      } catch (e) {
        log('Error adding saving goal: $e');
        emit(AddSavingGoalBlocFailure());
      }
    });
  }
}
