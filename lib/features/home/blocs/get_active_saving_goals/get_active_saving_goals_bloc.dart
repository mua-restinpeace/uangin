import 'dart:async';
import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'get_active_saving_goals_event.dart';
part 'get_active_saving_goals_state.dart';

class GetActiveSavingGoalsBloc
    extends Bloc<GetActiveSavingGoalsEvent, GetActiveSavingGoalsState> {
  final AllowanceRepository _allowanceRepository;
  StreamSubscription<List<SavingGoals>>? _goalsSubscription;

  GetActiveSavingGoalsBloc(this._allowanceRepository)
      : super(GetActiveSavingGoalsInitial()) {
    on<GetActiveGoals>((event, emit) async {
      emit(GetActiveSavingGoalsLoading());

      try {
        await _goalsSubscription?.cancel();

        _goalsSubscription = _allowanceRepository
            .getActiveSavingGoals(event.userId)
            .listen((goal) {
          add(GetActiveGoalsUpdated(goal));
        });
      } catch (e) {
        log('Get active goals failure: $e');
        emit(GetActiveSavingGoalsFailure());
      }
    });

    on<GetActiveGoalsUpdated>((event, emit) {
      emit(GetActiveSavingGoalsSuccess(event.goals));
    });
  }

  @override
  Future<void> close() {
    _goalsSubscription?.cancel();
    return super.close();
  }
}
