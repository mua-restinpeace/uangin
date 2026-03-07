part of 'add_allowance_bloc.dart';

sealed class AddAllowanceEvent extends Equatable {
  const AddAllowanceEvent();

  @override
  List<Object?> get props => [];
}

class AddAllowanceSubmitted extends AddAllowanceEvent {
  final String userId;
  final double amount;
  final double currentAllowance;
  final bool addToSaving;
  final String? notes;

  const AddAllowanceSubmitted(
      {required this.userId,
      required this.amount,
      required this.currentAllowance,
      required this.addToSaving,
      this.notes});

  @override
  List<Object?> get props =>
      [userId, amount, currentAllowance, addToSaving, notes];
}
