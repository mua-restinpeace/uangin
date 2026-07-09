part of 'edit_allowance_bloc.dart';

sealed class EditAllowanceEvent extends Equatable {
  const EditAllowanceEvent();

  @override
  List<Object?> get props => [];
}

class EditAllowanceSubmitted extends EditAllowanceEvent{
  final String userId;
  final double targetAmount;
  final DateTime date;
  final String? notes;

  const EditAllowanceSubmitted({
    required this.userId,
    required this.targetAmount,
    required this.date,
    this.notes
  });

  @override
  List<Object?> get props => [userId, targetAmount, date, notes];
}
